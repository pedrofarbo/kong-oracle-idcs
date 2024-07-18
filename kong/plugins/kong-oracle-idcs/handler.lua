local http = require "resty.http"
local json = require "cjson"

local OracleIdcsHandler = {
  VERSION = "0.1.0",
  PRIORITY = 1000
}

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
  for _, client in ipairs(conf.clients) do
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

    kong.log.info("Introspect URL: ", introspect_url);

    if not res then
      kong.log.err("Falha ao validar token: ", err)
      return kong.response.exit(500, { message = "Internal Server Error" })
    end

    kong.log.info(res.body)

    local response_body = json.decode(res.body)

    kong.log.info("Token Exp: ", response_body.exp);
    kong.log.info("Current datetime: ", os.time());

    if response_body.exp then
      local current_time = os.time()
      if response_body.exp < current_time then
        return kong.response.exit(401, { message = "Token expirado!" })
      end
    end

    if not client.scope then
      return -- token is valid, allow the request
    end

    -- Validate the required scope for the client
    local token_scopes = response_body.scope and response_body.scope:split(" ") or {}
    local required_scope = client.scope
    local scope_found = false
    for _, scope in ipairs(token_scopes) do
      if scope == required_scope then
        scope_found = true
        break
      end
    end

    if not scope_found then
      return kong.response.exit(403, { message = "Acesso não autorizado!" })
    end

    return -- token is valid, allow the request
  end

  return kong.response.exit(401, { message = "Token inválido ou expirado!" })
end

-- Utility function to split string by spaces
function string:split(sep)
  local sep, fields = sep or " ", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields + 1] = c end)
  return fields
end

return OracleIdcsHandler
