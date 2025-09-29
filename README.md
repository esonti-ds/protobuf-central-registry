# Protobuf Central Registry

**Single source of truth** for all API definitions using direct file copies. This registry contains **only** the API definitions - code generation happens in the individual implementation repositories.

## 🏗️ Architecture

```
protobuf-central-registry/           # Central registry (this repo)
├── timestamp-api/                   # Timestamp API definitions (copied)
├── media-stream-api/                # Media stream API definitions (copied)
├── video-viewer-api/                # Video viewer API definitions (copied)
├── common-definitions/              # Common definitions (copied)
└── scripts/                         # API management scripts
    ├── setup.sh                     # Initialize registry
    └── sync-apis.sh                 # Sync with external API repos

Implementation repositories handle their own code generation:
protobuf-sm-timestamp/               # C++ implementation + buf codegen
protobuf-sm-media-stream/            # Go implementation + buf codegen  
protobuf-sm-video-viewer/            # Flutter implementation + buf codegen
```

## 🎯 Purpose

- **API Version Control**: Direct tracking of all API definitions
- **Single Source of Truth**: Central location for all API schemas
- **Implementation Separation**: Code generation handled by consumers
- **Team Coordination**: Clear view of API dependencies and versions
- **No Submodules**: Direct file copies for simpler management

## 🚀 Quick Start

```bash
# Setup the registry
./scripts/setup.sh

# Generate code (if needed)
buf generate

# Sync with external API repositories
./scripts/sync-apis.sh
```

## 📋 API Dependencies

```
timestamp-api
    ↓
media-stream-api → timestamp-api  
    ↓
video-viewer-api → timestamp-api + media-stream-api
```

## 🔧 Implementation Guidelines

**For API directories** (`timestamp-api`, `media-stream-api`, etc.):
- Contains only `.proto` files and `buf.yaml`
- No code generation scripts
- Focus on API design and documentation

**For implementation repositories** (`protobuf-sm-timestamp`, etc.):
- Use buf CLI to fetch APIs from GitHub
- Generate code for APIs they implement AND consume  
- Maintain their own buf configurations
- Handle language-specific build processes

## 🛠️ API Management

### Common Operations

```bash
# Check status of all APIs
./scripts/sync-apis.sh status

# Sync all APIs from external sources
./scripts/sync-apis.sh update-all

# Sync specific API
./scripts/sync-apis.sh update timestamp-api

# Validate all APIs
buf lint

# Generate code for all APIs
buf generate
```

## 📚 Benefits

- ✅ **Clean Separation**: APIs separate from implementations
- ✅ **Simple Management**: No git submodules to manage
- ✅ **Buf CLI Integration**: Remote fetching without local copies
- ✅ **Scalable**: Each team manages their own code generation
- ✅ **Single Source**: All API definitions in one registry
- ✅ **Team Coordination**: Clear view of what APIs are being used where
- ✅ **Easy Cloning**: Standard git clone with all content

## 🔗 Related Repositories

| Repository | Purpose | Language |
|------------|---------|----------|
| [protobuf-sm-timestamp-api](https://github.com/esonti/protobuf-sm-timestamp-api) | Timestamp API definitions | Proto |
| [protobuf-sm-media-stream-api](https://github.com/esonti/protobuf-sm-media-stream-api) | Media streaming API definitions | Proto |
| [protobuf-sm-video-viewer-api](https://github.com/esonti/protobuf-sm-video-viewer-api) | Video viewer API definitions | Proto |
| protobuf-sm-timestamp | Timestamp service implementation | C++ |
| protobuf-sm-media-stream | Media streaming service implementation | Go |
| protobuf-sm-video-viewer | Video viewer app implementation | Flutter |

## 🚀 Getting Started for New APIs

1. **Create new API directory**: `mkdir your-api-name-api`
2. **Add API definitions**: Create `.proto` files and `buf.yaml`
3. **Update central registry**: 
   ```bash
   # Add new API directory with definitions
   # Update buf.yaml if needed
   # Commit changes
   ```
4. **Update implementation repos**: Add new API as dependency in their `buf.yaml`
5. **Generate code**: Implementation repos run `make proto-gen` to get new APIs

## 🔄 Syncing with External Repositories

This registry can be kept in sync with external API repositories using the sync script:

```bash
# Sync all APIs
./scripts/sync-apis.sh update-all

# This will:
# 1. Pull latest from external repos
# 2. Copy relevant files (excluding .git)
# 3. Commit changes if any
```
