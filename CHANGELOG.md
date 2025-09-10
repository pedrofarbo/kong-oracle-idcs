# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2025-09-10

### 🐛 Fixed
- **Critical Bug**: Fixed validation issue where only the first configured client was being tested
- **Error Handling**: Added JSON decode error protection to prevent crashes on malformed responses

### 🚀 Added
- **Multi-Client Support**: Enhanced support for multiple client validation with proper fallback mechanism
- **Token Active Validation**: Added validation of the 'active' field from IDCS introspection response
- **Enhanced Error Messages**: More specific error messages including required scope information
- **Improved Logging**: Added detailed debug logging for troubleshooting while keeping production logs clean

### 🔧 Changed
- **Logging Level**: Changed verbose operational logs from 'info' to 'debug' level for better production performance
- **Code Structure**: Refactored code with helper functions for better maintainability and readability
- **Error Handling**: Enhanced error handling with better categorization and user-friendly messages

### 📊 Technical Details
- The plugin now iterates through all configured clients until one successfully validates the token
- Added `validate_token_response()` helper function for cleaner code organization
- Improved error state management with `last_error_status` and `last_error_message` tracking
- Enhanced logging provides client index information for easier debugging

## [0.1.1] - 2024-XX-XX

### 🚀 Added
- Initial release with basic Oracle IDCS authentication support
- Token introspection using Oracle IDCS endpoint
- Basic scope validation support
- Single client configuration support
- Bearer token extraction and validation

### 📋 Features
- OAuth2 token introspection
- Scope-based authorization
- Integration with Kong Gateway
- Basic error handling and logging
