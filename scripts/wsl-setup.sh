#!/bin/bash
# scripts/wsl-setup.sh

# Check Docker Desktop integration
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker not accessible from WSL2"
    echo "Please ensure:"
    echo "1. Docker Desktop is running"
    echo "2. WSL2 integration is enabled in Docker Desktop settings"
    echo "3. Restart WSL2: wsl --shutdown (from PowerShell)"
    exit 1
fi

# Set WSL2 memory limits (optional)
cat > ~/.wslconfig << EOF
[wsl2]
memory=8GB
processors=4
swap=2GB
EOF

echo "✅ WSL2 Docker configuration complete"
echo "Note: .wslconfig changes require WSL restart: wsl --shutdown"
