#!/bin/bash

# Port number requested
PORT=49210

echo "🚀 Our Planner Premium: Termux Manager"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    pkg install openssh nodejs screen termux-services -y
fi

if [ ! -f "package.json" ]; then
    npm init -y
    npm install express
fi

# 2. Command: autostart
if [ "$1" == "autostart" ]; then
    echo "⚙️ Setting up autostart in .bashrc..."
    BASHRC="$HOME/.bashrc"
    
    # Check if already in bashrc
    if grep -q "screen -ls | grep -q planner" "$BASHRC"; then
        echo "✅ Autostart is already configured!"
    else
        cat <<EOF >> "$BASHRC"

# --- Our Planner Autostart ---
if ! screen -ls | grep -q "planner"; then
    echo "🚀 Starting Our Planner in background (screen)..."
    cd "$PWD"
    screen -dmS planner ./start_termux.sh
fi
# -----------------------------
EOF
        echo "✅ Autostart added to .bashrc!"
        echo "💡 Next time you open Termux, the planner will start automatically."
    fi
    exit 0
fi

# 3. Standard Startup via Screen
echo "✨ Starting Our Planner..."
echo "🌐 Access at: http://$(tailscale ip -4):$PORT"
echo "💡 To run in background, use: screen -dmS planner ./start_termux.sh"
echo "💡 To enable auto-start on boot, run: ./start_termux.sh autostart"

node server.js
