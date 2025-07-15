#!/bin/bash
# DevContainer Post-Create Script
# 初回作成時に実行される設定スクリプト

set -e

echo "🚀 Setting up CCTeam Beta v0.5.0 DevContainer..."

# Update package lists
sudo apt-get update

# Install additional tools
echo "📦 Installing additional tools..."
sudo apt-get install -y \
    tmux \
    htop \
    jq \
    ripgrep \
    fd-find \
    bat \
    httpie \
    postgresql-client \
    redis-tools

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt || echo "No requirements.txt found"

# Install AutoGen
echo "🤖 Installing AutoGen..."
pip install pyautogen[all]>=0.9.6
pip install autogenstudio

# Install Node dependencies
echo "📦 Installing Node dependencies..."
if [ -f package.json ]; then
    npm install
fi

# Setup Git
echo "🔧 Configuring Git..."
git config --global --add safe.directory /workspaces
git config --global user.name "${GITHUB_USER:-CCTeam Developer}"
git config --global user.email "${GITHUB_EMAIL:-developer@ccteam.local}"

# Create necessary directories
echo "📁 Creating project directories..."
mkdir -p logs
mkdir -p worktrees
mkdir -p memory
mkdir -p SOW/Daily
mkdir -p .autogen

# Setup Git Worktree
echo "🌳 Setting up Git Worktree..."
if [ -d "cc-team" ] && [ -f "cc-team/scripts/worktree-parallel-manual.sh" ]; then
    cd cc-team
    ./scripts/worktree-parallel-manual.sh setup || echo "Worktree setup skipped"
    cd ..
fi

# Setup tmux
echo "⚡ Configuring tmux..."
cat > ~/.tmux.conf << 'EOF'
# Enable mouse support
set -g mouse on

# Set prefix to Ctrl-a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config
bind r source-file ~/.tmux.conf

# Status bar
set -g status-bg black
set -g status-fg white
set -g status-left '#[fg=green]#H #[fg=black]• #[fg=green,bright]CCTeam#[default]'
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M#[default]'

# History
set -g history-limit 10000
EOF

# Create welcome message
echo "✅ DevContainer setup complete!"
echo ""
echo "Welcome to CCTeam Beta v0.5.0 Development Environment!"
echo "======================================================="
echo ""
echo "Quick commands:"
echo "  ccteam          - Launch CCTeam"
echo "  tmux attach     - Attach to tmux session"
echo "  autogenstudio   - Launch AutoGen Studio"
echo ""
echo "Project structure:"
echo "  /workspaces     - Main project directory"
echo "  /workspaces/worktrees - Git worktree branches"
echo ""
echo "Happy coding! 🚀"