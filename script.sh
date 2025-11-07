#!/bin/bash
set -e

echo "🚀 Setting up Claude CLI in Docker..."

# Check Docker
docker ps &>/dev/null || { echo "❌ Docker not available"; exit 1; }

# Create Dockerfile
cat > Dockerfile <<'EOF'
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl unzip bash ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/root/.local/bin:${PATH}"
ENV TERM=xterm-256color

# Pre-configure theme to skip selection
RUN mkdir -p /root/.config/claude && \
    echo '{"theme":"dark","onboardingCompleted":true}' > /root/.config/claude/config.json

CMD ["/bin/bash"]
EOF

# Build image
echo "🔨 Building claude-cli:ready image..."
docker build -t claude-cli:ready .

# Create aliases
echo "⚙️  Adding aliases..."
sed -i '/alias claude-cli/d' ~/.bashrc 2>/dev/null || true
sed -i '/alias claude-cleanup/d' ~/.bashrc 2>/dev/null || true

echo "alias claude-cli='docker run -it --rm --privileged claude-cli:ready'" >> ~/.bashrc
echo "alias claude-cleanup='docker ps -a | grep claude-cli | awk '\"'\"'{print \$1}'\"'\"' | xargs -r docker rm -f'" >> ~/.bashrc

source ~/.bashrc

# Test
echo ""
echo "🎯 Testing installation..."
docker run --rm claude-cli:ready claude --version

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 CLAUDE CLI - QUICK REFERENCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Start Claude (interactive):"
echo "   claude-cli"
echo ""
echo "💬 Inside container - Interactive mode:"
echo "   claude"
echo ""
echo "💬 Inside container - Quick mode:"
echo "   ANTHROPIC_API_KEY=\"sk-key\" claude --print \"Your question\""
echo ""
echo "🔄 Continue conversation:"
echo "   claude --print --continue \"Follow-up\""
echo ""
echo "📋 Check version:"
echo "   claude --version"
echo ""
echo "🆘 Get help:"
echo "   claude --help"
echo ""
echo "🚪 Exit container:"
echo "   exit  (or Ctrl+D)"
echo ""
echo "🧹 Cleanup all Claude containers:"
echo "   claude-cleanup"
echo ""
echo "♻️  Auto-cleanup:"
echo "   ✅ Containers auto-removed after exit (--rm flag)"
echo "   ✅ No leftover containers"
echo "   ✅ API keys never persisted"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Setup complete! Run: claude-cli"
