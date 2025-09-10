local http = require "resty.http"
local json = require "cjson"

local OracleIdcsHandler = {
  VERSION = "0.2.2",
  PRIORITY = 1000
}

-- Utility function to split string by separator
function string:split(sep)
  local sep, fields = sep or " ", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields + 1] = c end)
  return fields
end

-- Função auxiliar para validar a resposta do introspect
local function validate_token_response(response_body, client, client_index)
  -- Verifica se o token foi reconhecido pelo IDCS
  if not response_body.active or response_body.active == false then
    kong.log.debug("Token não ativo para cliente ", client_index)
    return false, 401, "Token inválido!"
  end

  -- Verifica expiração do token
  if response_body.exp then
    local current_time = os.time()
    if response_body.exp < current_time then
      kong.log.debug("Token expirado para cliente ", client_index)
      return false, 401, "Token expirado!"
    end
  end

  -- Se o cliente não exige scope específico, token é válido
  if not client.scope then
    kong.log.debug("Token válido para cliente ", client_index, " (sem validação de scope)")
    return true, 200, "Token válido"
  end

  -- Validar scope necessário para o cliente
  local token_scopes = response_body.scope and response_body.scope:split(" ") or {}
  local required_scope = client.scope
  local scope_found = false
  for _, scope in ipairs(token_scopes) do
    if scope == required_scope then
      scope_found = true
      break
    end
  end

  if scope_found then
    kong.log.debug("Token válido para cliente ", client_index, " (scope '", required_scope, "' encontrado)")
    return true, 200, "Token válido"
  else
    kong.log.debug("Scope '", required_scope, "' não encontrado para cliente ", client_index, ". Scopes disponíveis: ", table.concat(token_scopes, ", "))
    return false, 403, "Acesso não autorizado! Scope necessário: " .. required_scope
  end
end

function OracleIdcsHandler:access(conf)
  local req = kong.request
  local token = req.get_header("Authorization")
  if not token then
    return kong.response.exit(401, { message = "Acesso não autorizado!" })
  end

  token = token:match("^Bearer%s+(.+)$")
  if not token then
    return kong.response.exit(401, { message = "Formato do token inválido!" })
  end

  local httpc = http.new()
  local last_error_status = 401
  local last_error_message = "Token inválido ou expirado!"
  
  for client_index, client in ipairs(conf.clients) do
    kong.log.debug("Validando token com cliente ", client_index, " (client_id: ", client.client_id, ")")
    
    local introspect_url = conf.oracle_idcs_base_url
    local Authorization = "Basic " .. ngx.encode_base64(client.client_id .. ":" .. client.client_secret)
    local res, err = httpc:request_uri(introspect_url, {
      method = "POST",
      body = ngx.encode_args({
        token = token
      }),
      headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Authorization"] = Authorization
      },
      ssl_verify = false,
    })

    kong.log.debug("Introspect URL para cliente ", client_index, ": ", introspect_url)

    if not res then
      kong.log.warn("Falha ao validar token com cliente ", client_index, ": ", err)
      last_error_status = 500
      last_error_message = "Internal Server Error"
      -- Continue para tentar o próximo cliente
      goto continue
    end

    kong.log.debug("Resposta do cliente ", client_index, ": ", res.body)

    local success, decode_err = pcall(json.decode, res.body)
    if not success then
      kong.log.warn("Erro ao decodificar resposta JSON do cliente ", client_index, ": ", decode_err)
      last_error_status = 500
      last_error_message = "Erro na resposta do servidor de autenticação"
      goto continue
    end
    
    local response_body = json.decode(res.body)
    local is_valid, status_code, message = validate_token_response(response_body, client, client_index)
    
    if is_valid then
      kong.log.debug("Token autorizado com sucesso pelo cliente ", client_index)
      return -- Token é válido, permitir requisição
    else
      last_error_status = status_code
      last_error_message = message
    end

    ::continue::
  end

  -- Se chegou aqui, nenhum cliente validou o token com sucesso
  kong.log.warn("Token rejeitado por todos os ", #conf.clients, " clientes configurados")
  return kong.response.exit(last_error_status, { message = last_error_message })
end

return OracleIdcsHandler
