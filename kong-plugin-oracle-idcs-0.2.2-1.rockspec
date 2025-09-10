local plugin_name = "oracle-idcs"
local package_name = "kong-plugin-"..plugin_name
local package_version = "0.2.2"
local rockspec_revision = "1"

package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }

source = {
  url = "git://github.com/pedrofarbo/kong-oracle-idcs",
  tag = "v" .. package_version
}

description = {
  summary = "Kong plugin for Oracle IDCS OAuth2 Authentication",
  detailed = [[
    This plugin uses the Oracle IDCS introspection endpoint to validate tokens and
    supports multiple clients, scope validation, and robust error handling.
    
    Version 0.2.2 improvements:
    - Fixed bug where only the first configured client was being validated
    - Added support for multiple client validation (tries all clients until one succeeds)
    - Improved logging with debug level for detailed information
    - Added token 'active' field validation
    - Enhanced error handling with better error messages
    - Added JSON decode error protection
  ]],
  homepage = "https://github.com/pedrofarbo/kong-oracle-idcs",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lua-resty-http >= 0.15"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kong-oracle-idcs.handler"] = "kong/plugins/kong-oracle-idcs/handler.lua",
    ["kong.plugins.kong-oracle-idcs.schema"] = "kong/plugins/kong-oracle-idcs/schema.lua"
  }
}
