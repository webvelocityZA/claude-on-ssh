#!/bin/bash
set -e

echo "🚀 Setting up Claude CLI in Docker..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Create Dockerfile
cat > /tmp/Dockerfile-claude <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl unzip bash ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /root
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"
RUN claude --version
CMD ["/bin/bash", "-c", "exec bash"]
EOF

# Build the image
echo "🔨 Building claude-cli:ready image..."
docker build -f /tmp/Dockerfile-claude -t claude-cli:ready /tmp/

# Clean up
rm /tmp/Dockerfile-claude

# Add alias to bashrc
echo "⚙️  Adding alias to ~/.bashrc..."
sed -i '/alias claude-cli/d' ~/.bashrc 2>/dev/null || true
echo "alias claude-cli='docker run -it --rm claude-cli:ready'" >> ~/.bashrc

# Source bashrc
source ~/.bashrc

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Testing Claude CLI..."

# Test the setup
if docker run --rm claude-cli:ready claude --version &> /dev/null; then
    CLAUDE_VERSION=$(docker run --rm claude-cli:ready claude --version)
    echo "✅ Claude CLI is working! (${CLAUDE_VERSION})"
else
    echo "❌ Test failed. Please check Docker logs."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 CLAUDE CLI - QUICK REFERENCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Start Claude:"
echo "   claude-cli"
echo ""
echo "🔐 Run Claude with API key (inside container):"
echo "   ANTHROPIC_API_KEY=\"sk-your-key\" claude chat"
echo ""
echo "📋 Check version (inside container):"
echo "   claude --version"
echo ""
echo "🆘 Get help (inside container):"
echo "   claude --help"
echo ""
echo "🚪 Exit Claude:"
echo "   Type 'exit' or press Ctrl+D"
echo ""
echo "♻️  Container cleanup:"
echo "   ✅ Automatically removed after exit (--rm flag)"
echo "   ✅ No leftover containers"
echo "   ✅ API keys never persisted"
echo ""
echo "🔄 Re-run this setup on other servers:"
echo "   Just paste this entire script and run it!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Launching claude-cli now..."
echo ""

# Auto-launch claude-cli
exec bash -c "source ~/.bashrc && claude-cli"
