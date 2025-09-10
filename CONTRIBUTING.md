# Contributing to Kong Oracle IDCS Plugin

Thank you for your interest in contributing to the Kong Oracle IDCS Plugin! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue template** when available
3. **Provide clear reproduction steps** for bugs
4. **Include environment information** (Kong version, Lua version, OS, etc.)

### Suggesting Features

When suggesting new features:

1. **Check if the feature already exists** in newer versions
2. **Explain the use case** and why it's valuable
3. **Consider backward compatibility** implications
4. **Provide implementation ideas** if possible

### Submitting Pull Requests

1. **Fork the repository** and create a feature branch
2. **Write clear commit messages** following conventional commits
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Ensure all tests pass** before submitting

## 🛠️ Development Setup

### Prerequisites

- Lua 5.1 or higher
- LuaRocks package manager
- Kong Gateway 3.x (for testing)
- Git

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/pedrofarbo/kong-oracle-idcs.git
   cd kong-oracle-idcs
   ```

2. **Install dependencies**:
   ```bash
   luarocks install lua-resty-http
   luarocks install cjson
   ```

3. **Install development dependencies**:
   ```bash
   luarocks install busted    # Testing framework
   luarocks install luacov    # Code coverage
   luarocks install ldoc      # Documentation generation
   ```

### Testing

#### Unit Tests

```bash
# Run all tests
busted spec/

# Run specific test file
busted spec/handler_spec.lua

# Run with coverage
busted --coverage spec/
```

#### Integration Tests

```bash
# Start Kong with the plugin for testing
kong start -c test/kong.conf

# Run integration tests
bash test/integration/test_plugin.sh

# Stop Kong
kong stop
```

### Code Style

We follow these coding conventions:

- **Indentation**: 2 spaces
- **Line length**: 100 characters maximum
- **Naming**: snake_case for variables and functions
- **Comments**: Use descriptive comments for complex logic
- **Error handling**: Always handle errors gracefully

#### Example Code Style

```lua
-- Good
local function validate_token_response(response_body, client, client_index)
  if not response_body.active or response_body.active == false then
    kong.log.debug("Token not active for client ", client_index)
    return false, 401, "Invalid token!"
  end
  
  return true, 200, "Valid token"
end

-- Bad
local function validateTokenResponse(responseBody,client,clientIndex)
  if not responseBody.active or responseBody.active==false then
    kong.log.debug("Token not active for client "..clientIndex)
    return false,401,"Invalid token!"
  end
  return true,200,"Valid token"
end
```

## 📋 Commit Message Guidelines

We use [Conventional Commits](https://conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (no logic changes)
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

### Examples

```bash
feat: add support for multiple IDCS environments
fix: resolve token validation bug for expired tokens
docs: update README with new configuration options
test: add unit tests for scope validation
```

## 🔧 Release Process

### Version Numbers

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Update version** in `handler.lua` and `rockspec` files
2. **Update CHANGELOG.md** with new version details
3. **Create release tag**: `git tag v0.2.3`
4. **Build and test** the release package
5. **Submit to LuaRocks** (maintainers only)

## 🧪 Testing Guidelines

### Writing Tests

- **Unit tests**: Test individual functions in isolation
- **Integration tests**: Test plugin behavior with Kong
- **Performance tests**: Ensure no significant performance regression

### Test Structure

```lua
describe("OracleIdcsHandler", function()
  local handler
  
  before_each(function()
    handler = require("kong.plugins.kong-oracle-idcs.handler")
  end)
  
  describe("validate_token_response", function()
    it("should return true for valid active token", function()
      local response_body = { active = true, exp = os.time() + 3600 }
      local client = {}
      local is_valid, status, message = handler.validate_token_response(response_body, client, 1)
      
      assert.is_true(is_valid)
      assert.equals(200, status)
    end)
  end)
end)
```

## 📖 Documentation

### Documentation Standards

- **Clear examples** for all features
- **API reference** for all configuration options
- **Troubleshooting guides** for common issues
- **Migration guides** for breaking changes

### Building Documentation

```bash
# Generate API documentation
ldoc .

# Serve documentation locally
python -m http.server 8000 -d doc/
```

## 🎯 Areas for Contribution

We welcome contributions in these areas:

### High Priority
- **Performance optimizations**
- **Additional test coverage**
- **Documentation improvements**
- **Bug fixes**

### Medium Priority
- **Support for additional OAuth2 flows**
- **Metrics and monitoring integration**
- **Configuration validation enhancements**

### Low Priority
- **Code refactoring**
- **Development tooling**
- **Example applications**

## 💬 Communication

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: pedrofarbo@gmail.com for sensitive issues

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

Thank you for contributing to make this plugin better for the Kong community! 🚀
