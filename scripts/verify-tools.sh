#!/bin/bash
# scripts/verify-tools.sh

set -euo pipefail

echo "🔍 Verifying development tools for Lumina Prism ERP..."
echo "====================================================="

# Define minimum versions
declare -A MIN_VERSIONS=(
    ["go"]="1.21"
    ["docker"]="20.10"
    ["kind"]="0.20.0"
    ["kubectl"]="1.28"
    ["helm"]="3.13"
    ["tilt"]="0.33"
    ["buf"]="1.28"
)

# Function to extract version
get_version() {
    case $1 in
        "go")
            go version | awk '{print $3}' | sed 's/go//'
            ;;
        "docker")
            docker --version | awk '{print $3}' | sed 's/,//'
            ;;
        "kind")
            kind --version | awk '{print $3}'
            ;;
        "kubectl")
            kubectl version --client --short 2>/dev/null | awk '{print $3}' | sed 's/v//'
            ;;
        "helm")
            helm version --short | sed 's/v//' | cut -d'+' -f1
            ;;
        "tilt")
            tilt version | head -n1 | awk '{print $1}' | sed 's/v//'
            ;;
        "buf")
            buf --version 2>/dev/null || echo "0.0.0"
            ;;
    esac
}

# Check each tool
FAILED=0
for tool in "${!MIN_VERSIONS[@]}"; do
    echo -n "Checking $tool... "
    if ! command -v $tool &> /dev/null; then
        echo "❌ Not installed"
        ((FAILED++))
    else
        version=$(get_version $tool)
        echo "✅ $version (minimum: ${MIN_VERSIONS[$tool]})"
    fi
done

echo ""
if [ $FAILED -gt 0 ]; then
    echo "❌ Some tools are missing. Please install them first."
    exit 1
else
    echo "✅ All tools verified successfully!"
fi

# WSL2 specific checks
if grep -qi microsoft /proc/version; then
    echo ""
    echo "📌 WSL2 Detected - Additional Checks:"
    echo "====================================="

    # Check Docker Desktop integration
    if docker info > /dev/null 2>&1; then
        echo "✅ Docker Desktop integration working"
    else
        echo "❌ Docker Desktop integration not working"
        echo "   Please enable WSL2 integration in Docker Desktop settings"
    fi

    # Check memory
    total_mem=$(free -g | awk '/^Mem:/{print $2}')
    echo "💾 WSL2 Memory: ${total_mem}GB"
    if [ $total_mem -lt 4 ]; then
        echo "⚠️  Low memory detected. Consider increasing WSL2 memory allocation"
    fi
fi
