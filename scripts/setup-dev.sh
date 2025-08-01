#!/bin/bash
# scripts/setup-dev.sh

set -euo pipefail

echo "🚀 Setting up Lumina Prism ERP development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check required tools
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        VERSION=$($1 version 2>/dev/null || $1 --version 2>/dev/null || echo "version unknown")
        echo -e "${GREEN}✅ $1 is installed${NC} - ${VERSION}"
        return 0
    fi
}

echo "📋 Checking required tools..."
MISSING_TOOLS=0

for tool in go docker kind kubectl helm tilt buf golang-migrate golangci-lint; do
    if ! check_tool $tool; then
        ((MISSING_TOOLS++))
    fi
done

if [ $MISSING_TOOLS -gt 0 ]; then
    echo -e "${RED}Please install missing tools before continuing.${NC}"
    exit 1
fi

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo "Please start Docker Desktop and ensure WSL2 integration is enabled"
    exit 1
fi

# Create directories if not exist
echo "📁 Creating directory structure..."
mkdir -p {deployments/kind,scripts,docs,.secrets}

# Setup git hooks
echo "🪝 Installing pre-commit hooks..."
if [ ! -f .git/hooks/pre-commit ]; then
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Check formatting
unformatted=$(gofmt -l .)
if [ -n "$unformatted" ]; then
    echo "❌ Go files are not formatted:"
    echo "$unformatted"
    echo "Run 'gofmt -w .' to format"
    exit 1
fi

echo "✅ Pre-commit checks passed!"
EOF
    chmod +x .git/hooks/pre-commit
fi

# Initialize go workspace
if [ ! -f go.work ]; then
    echo "📦 Initializing Go workspace..."
    go work init
    go work use ./shared
    go work use ./tools
fi

echo -e "${GREEN}✨ Development environment setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run 'make setup-cluster' to create kind cluster"
echo "2. Run 'make up' to start infrastructure services"
echo "3. Check http://localhost:9001 for MinIO console"
