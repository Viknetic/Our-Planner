#!/bin/bash

# Configuration
PORT=49210
SCRIPT_PATH=$(realpath "$0")
DIR_PATH=$(dirname "$SCRIPT_PATH")
DATA_DIR="$DIR_PATH/data"

# Ensure we are in the right folder
cd "$DIR_PATH"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Initializing dependencies..."
    pkg install openssh nodejs screen termux-services -y
    [ ! -f "package.json" ] && npm init -y && npm install express
fi

# 2. Commands
case "$1" in
    "start")
        if screen -ls | grep -q "planner"; then
            echo "✅ Server is already running in the background."
        else
            echo "🌙 Starting Our Planner in BACKGROUND mode..."
            screen -dmS planner ./start_termux.sh run
            echo "✅ Done! You can now safely close your SSH session."
        fi
        exit 0
        ;;
    "stop")
        if screen -ls | grep -q "planner"; then
            echo "🛑 Stopping the background server..."
            screen -X -S planner quit
            echo "✅ Stopped."
        else
            echo "ℹ️ No background server found."
        fi
        exit 0
        ;;
    "logs")
        echo "📜 Opening logs (Press Ctrl+A then D to exit logs without stopping server)..."
        screen -r planner
        exit 0
        ;;
    "autostart")
        echo "⚙️ Setting up robust autostart..."
        # Simplified autostart command
        CMD="if ! screen -ls | grep -q \"planner\"; then cd \"$DIR_PATH\" && ./start_termux.sh start > /dev/null 2>&1; fi"
        for CFG in "$HOME/.bashrc" "$HOME/.zshrc"; do
            [ -f "$CFG" ] || [ "$CFG" == "$HOME/.bashrc" ] && {
                sed -i '/Our Planner Autostart/,/End Our Planner/d' "$CFG"
                echo -e "\n# --- Our Planner Autostart ---\n$CMD\n# --- End Our Planner ---" >> "$CFG"
                echo "✅ Configured $CFG"
            }
        done
        exit 0
        ;;
    "run")
        # Internal command used by screen
        node server.js
        exit 0
        ;;
esac

# 3. Default (Foreground)
echo "✨ Our Planner: Foreground Mode"
echo "🌐 Network: http://$(tailscale ip -4):$PORT"
echo "💡 To run in background: ./start_termux.sh start"
node server.js
