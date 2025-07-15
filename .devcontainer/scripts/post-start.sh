#!/bin/bash
# DevContainer Post-Start Script
# コンテナ起動時に毎回実行される

set -e

echo "🔄 Starting CCTeam DevContainer services..."

# Ensure directories exist
mkdir -p logs worktrees memory SOW/Daily .autogen

# Check if tmux session exists
if ! tmux has-session -t main 2>/dev/null; then
    echo "📺 Creating tmux session..."
    tmux new-session -d -s main -n "CCTeam"
fi

# Start any background services if needed
# For future: AutoGen services, monitoring, etc.

echo "✅ DevContainer services started!"