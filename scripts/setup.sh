#!/usr/bin/env bash

# Setup script for Protobuf Central Registry
# This script sets up the registry without git submodules

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🏗️  Setting up Protobuf Central Registry..."
echo "📁 Registry root: $REGISTRY_ROOT"

cd "$REGISTRY_ROOT"

# Auto-detect GitHub username from authentication
detect_github_user() {
    local github_user=""
    
    # Try GitHub CLI first
    if command -v gh >/dev/null 2>&1; then
        github_user=$(gh api user --jq '.login' 2>/dev/null || echo "")
    fi
    
    # Fallback to git remote origin URL
    if [ -z "$github_user" ] && git remote get-url origin >/dev/null 2>&1; then
        local origin_url
        origin_url=$(git remote get-url origin)
        if [[ "$origin_url" == *"github.com"* ]]; then
            if [[ "$origin_url" =~ github\.com[:/]([^/]+) ]]; then
                github_user="${BASH_REMATCH[1]}"
            fi
        fi
    fi
    
    # Fallback to git config github.user
    if [ -z "$github_user" ]; then
        github_user=$(git config --global github.user 2>/dev/null || echo "")
    fi
    
    echo "$github_user"
}

# Get GitHub username
GITHUB_ORG="${GITHUB_USER:-$(detect_github_user)}"

if [ -z "$GITHUB_ORG" ]; then
    echo "❌ Could not detect GitHub username!"
    echo "💡 Please set your GitHub username:"
    echo "   export GITHUB_USER=your-github-username"
    echo "   OR: gh auth login"
    echo ""
    read -p "Enter your GitHub username manually: " GITHUB_ORG
    
    if [ -z "$GITHUB_ORG" ]; then
        echo "❌ No GitHub username provided. Exiting."
        exit 1
    fi
fi

echo "👤 Using GitHub username: $GITHUB_ORG"

# Verify all API directories exist
echo ""
echo "📚 Verifying API directories..."

API_DIRS=("common-definitions" "timestamp-api" "media-stream-api" "video-viewer-api")

for api_dir in "${API_DIRS[@]}"; do
    if [ -d "$api_dir" ]; then
        echo "   ✅ Found: $api_dir"
    else
        echo "   ❌ Missing: $api_dir"
        echo "   💡 Please ensure all API directories are copied to this registry"
        exit 1
    fi
done

# Validate buf configuration
echo ""
echo "🔧 Validating buf configuration..."

if command -v buf >/dev/null 2>&1; then
    if buf lint; then
        echo "   ✅ Buf lint passed"
    else
        echo "   ⚠️  Buf lint has warnings/errors"
    fi
    
    if buf format --diff --exit-code; then
        echo "   ✅ Buf format is correct"
    else
        echo "   ⚠️  Some files need formatting"
    fi
else
    echo "   ⚠️  Buf CLI not found - install from https://buf.build/docs/installation"
fi

# Initialize git repository if needed
if [ ! -d ".git" ]; then
    echo ""
    echo "🔧 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial central registry setup

- Add all API definitions (copied from submodules)
- Clean architecture: registry contains direct copies
- Code generation handled by implementation repositories"
fi

echo ""
echo "✅ Central registry setup complete!"
echo ""
echo "📋 Current API directories:"
for api_dir in "${API_DIRS[@]}"; do
    if [ -d "$api_dir" ]; then
        echo "   📁 $api_dir"
        if [ -f "$api_dir/buf.yaml" ]; then
            echo "      ✅ buf.yaml present"
        fi
    fi
done

echo ""
echo "🔄 To sync with external repositories:"
echo "   ./scripts/sync-apis.sh update-all"
echo ""
echo "📖 To clone this registry elsewhere:"
echo "   git clone https://github.com/${GITHUB_ORG}/protobuf-central-registry.git"
echo ""
echo "🏗️  To generate code:"
echo "   buf generate"
