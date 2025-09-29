#!/usr/bin/env bash

# API synchronization script for Central Registry
# Syncs with external API repositories while maintaining local copies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REGISTRY_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API repository mappings
declare -A API_REPOS=(
    ["common-definitions"]="protobuf-sm-common-definitions"
    ["timestamp-api"]="protobuf-sm-timestamp-api"
    ["media-stream-api"]="protobuf-sm-media-stream-api"
    ["video-viewer-api"]="protobuf-sm-video-viewer-api"
)

print_usage() {
    echo "🔄 API Synchronization for Central Registry"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  status               Show status of all APIs"
    echo "  update-all          Sync all APIs from external repositories"
    echo "  update <name>       Sync specific API"
    echo "  list                List available APIs"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 update timestamp-api"
    echo "  $0 update-all"
}

detect_github_user() {
    local github_user=""
    
    # Try GitHub CLI first
    if command -v gh >/dev/null 2>&1; then
        github_user=$(gh api user --jq '.login' 2>/dev/null || echo "")
    fi
    
    # Fallback to git config github.user
    if [ -z "$github_user" ]; then
        github_user=$(git config --global github.user 2>/dev/null || echo "")
    fi
    
    echo "$github_user"
}

api_status() {
    echo "📋 API Status:"
    echo ""
    
    for api_dir in "${!API_REPOS[@]}"; do
        if [ -d "$api_dir" ]; then
            echo -e "   ${GREEN}✅ $api_dir${NC}"
            if [ -f "$api_dir/buf.yaml" ]; then
                echo "      📄 buf.yaml present"
            fi
            if [ -f "$api_dir/README.md" ]; then
                echo "      📖 README.md present"
            fi
        else
            echo -e "   ${RED}❌ $api_dir (missing)${NC}"
        fi
    done
    
    echo ""
    echo "📊 Summary:"
    local total_count=${#API_REPOS[@]}
    local present_count=0
    
    for api_dir in "${!API_REPOS[@]}"; do
        if [ -d "$api_dir" ]; then
            ((present_count++))
        fi
    done
    
    echo "   Total APIs: $total_count"
    echo "   Present: $present_count"
    
    if [ "$present_count" -lt "$total_count" ]; then
        echo -e "   ${YELLOW}⚠️  $((total_count - present_count)) API(s) missing${NC}"
    fi
}

sync_api() {
    local api_name=$1
    local repo_name="${API_REPOS[$api_name]}"
    
    if [ -z "$repo_name" ]; then
        echo -e "${RED}❌ Unknown API: $api_name${NC}"
        echo "💡 Available APIs:"
        for api in "${!API_REPOS[@]}"; do
            echo "   $api"
        done
        return 1
    fi
    
    local github_user
    github_user=$(detect_github_user)
    
    if [ -z "$github_user" ]; then
        echo -e "${RED}❌ Could not detect GitHub username${NC}"
        echo "💡 Please set: export GITHUB_USER=your-username"
        return 1
    fi
    
    local repo_url="https://github.com/${github_user}/${repo_name}.git"
    local temp_dir="/tmp/sync-${repo_name}-$$"
    
    echo "🔄 Syncing API: $api_name"
    echo "   Repository: $repo_url"
    echo "   Target: $api_name/"
    
    # Clone to temporary directory
    echo "   📥 Cloning repository..."
    if ! git clone "$repo_url" "$temp_dir" 2>/dev/null; then
        echo -e "${RED}❌ Failed to clone repository: $repo_name${NC}"
        echo "💡 Check if repository exists: https://github.com/${github_user}/${repo_name}"
        return 1
    fi
    
    # Remove old directory if it exists
    if [ -d "$api_name" ]; then
        echo "   🗑️  Removing old directory..."
        rm -rf "$api_name"
    fi
    
    # Copy relevant files (exclude .git)
    echo "   📂 Copying files..."
    mkdir -p "$api_name"
    
    # Copy all files except .git directory
    (cd "$temp_dir" && find . -name ".git" -prune -o -type f -print0 | xargs -0 cp --parents -t "$REGISTRY_ROOT/$api_name")
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    echo -e "   ${GREEN}✅ Successfully synced: $api_name${NC}"
    
    # Check for changes
    if git diff --quiet "$api_name"; then
        echo "   📄 No changes detected"
    else
        echo "   📝 Changes detected:"
        git diff --stat "$api_name"
    fi
}

sync_all_apis() {
    echo "🔄 Syncing all APIs..."
    echo ""
    
    local success_count=0
    local total_count=${#API_REPOS[@]}
    
    for api_name in "${!API_REPOS[@]}"; do
        if sync_api "$api_name"; then
            ((success_count++))
        fi
        echo ""
    done
    
    echo "📊 Sync Summary:"
    echo "   Total APIs: $total_count"
    echo "   Successfully synced: $success_count"
    
    if [ "$success_count" -eq "$total_count" ]; then
        echo -e "   ${GREEN}✅ All APIs synced successfully${NC}"
    else
        echo -e "   ${YELLOW}⚠️  $((total_count - success_count)) API(s) failed to sync${NC}"
    fi
    
    # Check for any changes
    if ! git diff --quiet; then
        echo ""
        echo "📝 Changes detected. To commit:"
        echo "   git add ."
        echo "   git commit -m 'Sync APIs from external repositories'"
    else
        echo ""
        echo "📄 No changes detected - all APIs are up to date"
    fi
}

list_apis() {
    echo "📋 Available APIs:"
    echo ""
    for api_name in "${!API_REPOS[@]}"; do
        local repo_name="${API_REPOS[$api_name]}"
        echo "   📁 $api_name"
        echo "      🔗 Repository: $repo_name"
        if [ -d "$api_name" ]; then
            echo -e "      ${GREEN}✅ Present${NC}"
        else
            echo -e "      ${RED}❌ Missing${NC}"
        fi
        echo ""
    done
}

# Main command handling
case "${1:-}" in
    "status")
        api_status
        ;;
    "update-all")
        sync_all_apis
        ;;
    "update")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify API name${NC}"
            list_apis
            exit 1
        fi
        sync_api "$2"
        ;;
    "list")
        list_apis
        ;;
    "help"|"-h"|"--help"|"")
        print_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
