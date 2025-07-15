#!/bin/bash
# DevContainer Post-Attach Script
# VSCodeがコンテナにアタッチした時に実行される

set -e

# Display welcome message
cat << 'EOF'

  ██████╗ ██████╗████████╗███████╗ █████╗ ███╗   ███╗
 ██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
 ██║     ██║        ██║   █████╗  ███████║██╔████╔██║
 ██║     ██║        ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
 ╚██████╗╚██████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
  ╚═════╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
                                                       
  Beta v0.5.0 - AutoGen Edition

EOF

# Show current status
echo "📊 Current Status:"
echo "  - Container: ${CCTEAM_DEV_CONTAINER}"
echo "  - Version: ${CCTEAM_VERSION}"
echo "  - AutoGen Mode: ${CCTEAM_AUTOGEN_MODE}"
echo ""

# Check for updates
if [ -f "CLAUDE.md" ]; then
    echo "📋 Latest TODO from CLAUDE.md:"
    grep -A 3 "次のアクション" CLAUDE.md 2>/dev/null || echo "  No specific action items found"
    echo ""
fi

# Show recent logs
if [ -d "SOW/Daily" ]; then
    echo "📅 Recent daily reports:"
    ls -lt SOW/Daily/*.md 2>/dev/null | head -3 | awk '{print "  - " $9}'
    echo ""
fi

echo "Ready to develop! Use 'ccteam' to start the AI team."