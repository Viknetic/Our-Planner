#!/bin/bash

# Configuration
PORT=49210
SCRIPT_PATH=$(realpath "$0")
DIR_PATH=$(dirname "$SCRIPT_PATH")
DATA_DIR="$DIR_PATH/data"

echo "🚀 Our Planner Premium: System Manager"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Initializing dependencies..."
    pkg install openssh nodejs screen termux-services -y
fi

if [ ! -f "$DIR_PATH/package.json" ]; then
    cd "$DIR_PATH"
    npm init -y
    npm install express
fi

# 2. Command: autostart
if [ "$1" == "autostart" ]; then
    echo "⚙️ Setting up robust autostart..."
    
    AUTORUN_CMD="if ! screen -ls | grep -q \"planner\"; then cd \"$DIR_PATH\" && screen -dmS planner ./start_termux.sh; fi"
    
    # Setup for both Bash and Zsh
    for SHELL_CONFIG in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$SHELL_CONFIG" ] || [ "$SHELL_CONFIG" == "$HOME/.bashrc" ]; then
            # Remove old autostart if exists to prevent duplicates
            sed -i '/Our Planner Autostart/,/End Our Planner/d' "$SHELL_CONFIG"
            
            # Append new block
            cat <<EOF >> "$SHELL_CONFIG"

# --- Our Planner Autostart ---
$AUTORUN_CMD
# --- End Our Planner ---
EOF
            echo "✅ Configured $SHELL_CONFIG"
        fi
    done
    
    echo "✨ Autostart is now locked in! Restart Termux to test."
    exit 0
fi

# 3. Server Startup
cd "$DIR_PATH" # Ensure we are in the right folder

# Ensure data directory exists
mkdir -p "$DATA_DIR"

echo "✨ Starting Our Planner..."
echo "🌐 Network: http://$(tailscale ip -4):$PORT"
echo "🖥️ Local:   http://localhost:$PORT"
echo "💡 To manually run in background: screen -dmS planner ./start_termux.sh"

node server.js
