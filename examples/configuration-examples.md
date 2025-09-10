# Kong Oracle IDCS Plugin - Configuration Examples

This file contains various configuration examples for the Kong Oracle IDCS plugin.

## Basic Configuration (Single Client)

```yaml
plugins:
- name: kong-oracle-idcs
  service: my-service
  config:
    oracle_idcs_base_url: "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect"
    clients:
      - client_id: "your-client-id"
        client_secret: "your-client-secret"
```

## Multi-Client Configuration with Scopes

```yaml
plugins:
- name: kong-oracle-idcs
  service: my-service
  config:
    oracle_idcs_base_url: "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect"
    clients:
      - client_id: "admin-client-id"
        client_secret: "admin-client-secret"
        scope: "admin:read admin:write"
      - client_id: "user-client-id"
        client_secret: "user-client-secret"
        scope: "user:read"
      - client_id: "public-client-id"
        client_secret: "public-client-secret"
        # No scope required for this client
```

## Via Kong Admin API

### Add plugin to a service

```bash
curl -X POST http://kong-admin:8001/services/my-service/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "kong-oracle-idcs",
    "config": {
      "oracle_idcs_base_url": "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect",
      "clients": [
        {
          "client_id": "your-client-id",
          "client_secret": "your-client-secret",
          "scope": "read:users"
        }
      ]
    }
  }'
```

### Add plugin to a route

```bash
curl -X POST http://kong-admin:8001/routes/my-route/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "kong-oracle-idcs",
    "config": {
      "oracle_idcs_base_url": "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect",
      "clients": [
        {
          "client_id": "route-specific-client",
          "client_secret": "route-specific-secret"
        }
      ]
    }
  }'
```

### Global plugin configuration

```bash
curl -X POST http://kong-admin:8001/plugins \
  -H "Content-Type: application/json" \
  -d '{
    "name": "kong-oracle-idcs",
    "config": {
      "oracle_idcs_base_url": "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect",
      "clients": [
        {
          "client_id": "global-client-id",
          "client_secret": "global-client-secret"
        }
      ]
    }
  }'
```

## Environment-Specific Configurations

### Development Environment

```yaml
plugins:
- name: kong-oracle-idcs
  service: dev-service
  config:
    oracle_idcs_base_url: "https://dev-domain.identity.oraclecloud.com/oauth2/v1/introspect"
    clients:
      - client_id: "dev-client-id"
        client_secret: "dev-client-secret"
        scope: "dev:access"
```

### Production Environment

```yaml
plugins:
- name: kong-oracle-idcs
  service: prod-service
  config:
    oracle_idcs_base_url: "https://prod-domain.identity.oraclecloud.com/oauth2/v1/introspect"
    clients:
      - client_id: "prod-primary-client"
        client_secret: "prod-primary-secret"
        scope: "prod:read prod:write"
      - client_id: "prod-fallback-client"
        client_secret: "prod-fallback-secret"
        scope: "prod:read"
```

## Kong Declarative Configuration (kong.yml)

```yaml
_format_version: "3.0"

services:
- name: protected-api
  url: http://backend-api:8080
  routes:
  - name: api-route
    paths:
    - /api
    plugins:
    - name: kong-oracle-idcs
      config:
        oracle_idcs_base_url: "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect"
        clients:
        - client_id: "api-client-id"
          client_secret: "api-client-secret"
          scope: "api:access"

- name: admin-api
  url: http://admin-backend:8080
  routes:
  - name: admin-route
    paths:
    - /admin
    plugins:
    - name: kong-oracle-idcs
      config:
        oracle_idcs_base_url: "https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect"
        clients:
        - client_id: "admin-client-id"
          client_secret: "admin-client-secret"
          scope: "admin:full"
```

## Testing Your Configuration

### Test with valid token

```bash
# Replace YOUR_TOKEN with an actual OAuth2 token from Oracle IDCS
curl -X GET http://your-kong-gateway:8000/your-protected-endpoint \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -v
```

### Test without token (should return 401)

```bash
curl -X GET http://your-kong-gateway:8000/your-protected-endpoint \
  -v
```

### Test with invalid token (should return 401)

```bash
curl -X GET http://your-kong-gateway:8000/your-protected-endpoint \
  -H "Authorization: Bearer invalid-token" \
  -v
```

## Troubleshooting

### Enable debug logging

```bash
# Set Kong log level to debug
export KONG_LOG_LEVEL=debug

# Or in kong.conf
log_level = debug
```

### Check plugin status

```bash
curl -X GET http://kong-admin:8001/plugins | jq '.data[] | select(.name == "kong-oracle-idcs")'
```

### Verify Oracle IDCS endpoint

```bash
# Test introspection endpoint manually
curl -X POST https://your-domain.identity.oraclecloud.com/oauth2/v1/introspect \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'client_id:client_secret' | base64)" \
  -d "token=YOUR_TOKEN"
```
