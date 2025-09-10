# Kong Oracle IDCS Authentication Plugin

[![Version](https://img.shields.io/badge/version-0.2.2-blue.svg)](https://github.com/pedrofarbo/kong-oracle-idcs)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Kong](https://img.shields.io/badge/Kong-3.x-orange.svg)](https://konghq.com/)

A Kong Gateway plugin that provides seamless integration with Oracle Identity Cloud Service (IDCS) for OAuth2 token authentication and authorization.

## 🚀 Features

- **Multi-Client Support**: Configure multiple Oracle IDCS clients with fallback validation
- **Scope Validation**: Optional scope-based authorization per client
- **Token Introspection**: Validates tokens using Oracle IDCS introspection endpoint
- **Robust Error Handling**: Comprehensive error handling with detailed logging
- **High Performance**: Optimized for production environments
- **Debug Logging**: Detailed debug information when needed

## 📋 Requirements

- Kong Gateway 3.x or higher
- Lua 5.1 or higher
- lua-resty-http 0.15 or higher
- Oracle Identity Cloud Service (IDCS) instance

## 📦 Installation

### Method 1: Using LuaRocks (Recommended)

```bash
luarocks install kong-plugin-oracle-idcs
```

### Method 2: Using .src.rock file

```bash
luarocks install kong-plugin-oracle-idcs-0.2.2-1.src.rock
```

### Method 3: Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/pedrofarbo/kong-oracle-idcs.git
   ```

2. Copy the plugin to your Kong plugins directory:
   ```bash
   cp -r kong/plugins/kong-oracle-idcs /usr/local/share/lua/5.1/kong/plugins/
   ```

3. Add the plugin to your Kong configuration:
   ```bash
   export KONG_PLUGINS=bundled,kong-oracle-idcs
   ```

## ⚙️ Configuration

### Plugin Configuration Schema

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oracle_idcs_base_url` | string | ✅ | Oracle IDCS introspection endpoint URL |
| `clients` | array | ✅ | Array of Oracle IDCS client configurations |
| `clients[].client_id` | string | ✅ | Oracle IDCS client ID |
| `clients[].client_secret` | string | ✅ | Oracle IDCS client secret (encrypted) |
| `clients[].scope` | string | ❌ | Required scope for this client (optional) |

### Example Configuration

#### Via Kong Admin API

```bash
curl -X POST http://kong-admin:8001/services/{service-id}/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "kong-oracle-idcs",
    "config": {
      "oracle_idcs_base_url": "https://your-idcs-domain.identity.oraclecloud.com/oauth2/v1/introspect",
      "clients": [
        {
          "client_id": "your-primary-client-id",
          "client_secret": "your-primary-client-secret",
          "scope": "read:users"
        },
        {
          "client_id": "your-fallback-client-id", 
          "client_secret": "your-fallback-client-secret"
        }
      ]
    }
  }'
```

#### Via Kong Declarative Configuration

```yaml
plugins:
- name: kong-oracle-idcs
  service: your-service
  config:
    oracle_idcs_base_url: "https://your-idcs-domain.identity.oraclecloud.com/oauth2/v1/introspect"
    clients:
      - client_id: "your-primary-client-id"
        client_secret: "your-primary-client-secret"
        scope: "read:users"
      - client_id: "your-fallback-client-id"
        client_secret: "your-fallback-client-secret"
```

## 🔧 Usage

### Making Authenticated Requests

Once the plugin is configured, clients must include a valid Bearer token in the Authorization header:

```bash
curl -X GET http://your-kong-gateway:8000/your-protected-endpoint \
  -H "Authorization: Bearer your-oauth2-token"
```

### Response Scenarios

| Scenario | HTTP Status | Response |
|----------|-------------|----------|
| Valid token with correct scope | 200 | Request forwarded to upstream |
| Missing Authorization header | 401 | `{"message": "Acesso não autorizado!"}` |
| Invalid token format | 401 | `{"message": "Formato do token inválido!"}` |
| Expired token | 401 | `{"message": "Token expirado!"}` |
| Invalid token | 401 | `{"message": "Token inválido!"}` |
| Insufficient scope | 403 | `{"message": "Acesso não autorizado! Scope necessário: {scope}"}` |
| IDCS service error | 500 | `{"message": "Internal Server Error"}` |

## 🔄 How It Works

1. **Token Extraction**: The plugin extracts the Bearer token from the Authorization header
2. **Multi-Client Validation**: Iterates through configured clients, attempting validation with each
3. **Token Introspection**: Calls Oracle IDCS introspection endpoint for each client
4. **Token Validation**: Checks if token is active and not expired
5. **Scope Authorization**: Validates required scopes if configured
6. **Access Decision**: Allows request if any client successfully validates the token

## 📊 Logging

The plugin provides comprehensive logging at different levels:

- **DEBUG**: Detailed validation steps, token information, and client testing
- **WARN**: Failed validations, JSON decode errors, and final rejections
- **ERROR**: Critical errors and service failures

To enable debug logging, set Kong's log level:

```bash
export KONG_LOG_LEVEL=debug
```

## 🔄 Version History

### v0.2.2 (Latest) - 2025-09-10
- 🐛 **Critical Bug Fix**: Fixed validation issue where only the first configured client was being tested
- 🚀 **Multi-Client Enhancement**: Added proper support for multiple client validation with fallback
- 📊 **Improved Logging**: Changed verbose logs to debug level for better production performance
- ✅ **Enhanced Validation**: Added token 'active' field validation from IDCS response
- 🛡️ **Robust Error Handling**: Enhanced error handling with JSON decode protection and better error messages
- 🔧 **Code Quality**: Refactored code with helper functions for better maintainability

### v0.1.1 - Initial Release
- Basic Oracle IDCS authentication support
- Single client configuration
- Token introspection and scope validation

## 🛠️ Development

### Building from Source

```bash
git clone https://github.com/pedrofarbo/kong-oracle-idcs.git
cd kong-oracle-idcs
luarocks make kong-plugin-oracle-idcs-0.2.2-1.rockspec
```

### Running Tests

```bash
# Install test dependencies
luarocks install busted
luarocks install luacov

# Run tests
busted spec/
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/pedrofarbo/kong-oracle-idcs/issues)
- **Email**: pedrofarbo@gmail.com
- **Documentation**: [Kong Plugin Development Guide](https://docs.konghq.com/gateway/latest/plugin-development/)

## 🔗 Related Projects

- [Kong Gateway](https://github.com/Kong/kong)
- [Oracle Identity Cloud Service](https://docs.oracle.com/en/cloud/paas/identity-cloud/)
- [OAuth 2.0 Token Introspection](https://tools.ietf.org/html/rfc7662)

---

<div align="center">
  <strong>Made with ❤️ for the Kong community</strong>
</div>