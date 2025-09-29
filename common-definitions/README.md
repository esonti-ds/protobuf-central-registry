# Protobuf Sub-Module (SM) Common Definitions

**Shared Protocol Buffer definitions** for use across all protobuf-sm services. This repository contains common messages, enums, and services that can be imported by other API specifications.

## 🎯 Purpose

- **Shared Types**: Common data structures used across multiple services
- **Consistency**: Ensure consistent field names, types, and patterns
- **Reusability**: Avoid duplicating definitions across API repositories
- **Standards**: Establish common patterns for licenses, authentication, etc.

## 📋 Available Definitions

### License System (`common/license.proto`)

Complete licensing system for product activation and validation:

**Key Messages**:
- `License` - Core license information with features and metadata
- `LicenseFeatures` - Feature flags and limits (users, storage, API rate limits)
- `LicenseStatus` - Status enumeration (active, expired, suspended, etc.)
- `ProductType` - Supported product types enumeration

**Service Operations**:
- `IssueLicense` - Create new licenses with specified features
- `CheckLicense` - Validate license status and feature availability  
- `ActivateLicense` - Activate pending licenses
- `RevokeLicense` - Revoke licenses administratively

**Usage Examples**:
```protobuf
// Import in your API specifications
import "common/license.proto";

// Use in your service definitions
message VideoServiceRequest {
  string video_id = 1;
  common.License license = 2;  // Reference shared license type
}
```

## 🚀 Integration Guide

### 1. Add Dependency in API Repository

In your API repository's `buf.yaml`:
```yaml
version: v2
modules:
  - path: .
    name: buf.build/your-org/your-api
deps:
  - buf.build/shared-api-poc/common-definitions
```

### 2. Import in Proto Files

```protobuf
syntax = "proto3";

package yourservice;

// Import common definitions
import "common/license.proto";

// Use in your messages
message YourServiceRequest {
  string request_id = 1;
  common.License license = 2;
  common.ProductType product = 3;
}
```

### 3. Update Central Registry

Add as submodule to `protobuf-sm-central-registry`:
```bash
cd protobuf-sm-central-registry
git submodule add https://github.com/your-org/protobuf-sm-common-definitions.git common-definitions
```

### 4. Code Generation

Implementation services automatically get common definitions via buf.gen.yaml:
```yaml
inputs:
  - git_repo: https://github.com/your-org/protobuf-sm-central-registry.git
    recurse_submodules: true  # Includes common-definitions automatically
```

## 🏗️ Architecture Benefits

### ✅ No Local Copies
- Implementation repos never store .proto files locally
- Buf CLI fetches common definitions remotely
- Always uses latest versions during build

### ✅ Single Source of Truth  
- Common definitions maintained in one place
- Changes propagate to all consumers automatically
- Consistent types across all services

### ✅ Language Independence
- Generated code available for Go, C++, Dart, etc.
- Same types work across different implementation languages
- Type safety maintained across service boundaries

### ✅ Versioning Control
- Git commits track exact versions of common definitions
- Central registry can pin to specific versions if needed
- Individual APIs can evolve independently

## 🔧 Development Workflow

### Adding New Common Definitions

1. **Create new .proto file** in appropriate directory
2. **Add comprehensive documentation** and examples  
3. **Test with buf lint** and validate
4. **Update README** with usage examples
5. **Commit and tag** for version tracking

### Using in API Repositories

1. **Add dependency** in buf.yaml
2. **Import common definitions** in your .proto files
3. **Reference common types** in your messages/services
4. **Update central registry** to include your updated API

### Implementation in Services

1. **Run buf generate** - automatically fetches common definitions
2. **Use generated common types** in your service code
3. **Implement license checks** using common license service interfaces
4. **Test integration** with license validation

## 📚 Common Patterns

### License Integration Pattern

```protobuf
// In your API specification
import "common/license.proto";

service YourService {
  rpc YourMethod(YourRequest) returns (YourResponse);
}

message YourRequest {
  string request_data = 1;
  common.License license = 2;  // Include license for validation
}
```

### Product Type Usage

```protobuf
message ProductConfiguration {
  common.ProductType product = 1;
  common.LicenseFeatures required_features = 2;
}
```

### License Validation Flow

```protobuf
// Service can validate license before processing
rpc ProcessRequest(ProcessRequestWithLicense) returns (ProcessResponse);

message ProcessRequestWithLicense {
  string data = 1;
  common.License license = 2;
}
```

## 🎯 Future Extensions

Planned common definitions:
- **Authentication** - Common user/service authentication types
- **Audit Logging** - Standard audit event structures  
- **Rate Limiting** - Common rate limiting configurations
- **Health Checks** - Standard health check message formats
- **Metrics** - Common metrics and monitoring types

## 🤝 Contributing

### Adding New Common Definitions

1. **Design Phase**: Consider reusability across multiple services
2. **Documentation**: Provide clear examples and integration guides
3. **Validation**: Test with buf lint and breaking change detection
4. **Integration**: Update at least one existing API to demonstrate usage
5. **Documentation**: Update this README with new definitions

### Modifying Existing Definitions

1. **Backward Compatibility**: Ensure changes don't break existing APIs
2. **Buf Breaking**: Run `buf breaking` to validate compatibility
3. **Migration Guide**: Document any required changes for consumers
4. **Versioning**: Consider semantic versioning for major changes

---

**🎯 This repository demonstrates how Protocol Buffers can create truly reusable, type-safe common definitions that work across multiple languages and services without requiring local copies anywhere in the system.**
