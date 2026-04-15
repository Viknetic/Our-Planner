#!/bin/bash

# Port number requested
PORT=49210

echo "🚀 Our Planner Premium: Termux Startup"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    pkg install nodejs -y
fi

if [ ! -f "package.json" ]; then
    npm init -y
    npm install express
fi

if [ ! -d "node_modules/express" ]; then
    npm install express
fi

# 2. PM2 (Background Manager) Setup
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2 for background support..."
    npm install -g pm2
fi

# 3. Handle Command Arguments
if [ "$1" == "stop" ]; then
    echo "🛑 Stopping the background server..."
    pm2 stop our-planner
    exit 0
fi

if [ "$1" == "logs" ]; then
    pm2 logs our-planner
    exit 0
fi

if [ "$1" == "bg" ]; then
    echo "🌙 Starting in BACKGROUND mode..."
    pm2 start server.js --name our-planner
    echo "✅ Server is running in the background!"
    echo "📱 Access it at: http://$(tailscale ip -4):$PORT"
    echo "💡 Run './start_termux.sh logs' to see what's happening."
    echo "💡 Run './start_termux.sh stop' to kill it."
    termux-wake-lock
    exit 0
fi

# 4. Standard Foreground Mode
echo "✨ Starting in foreground mode (Ctrl+C to stop)..."
echo "🌐 Access at: http://$(tailscale ip -4):$PORT"
echo "💡 Tip: Run './start_termux.sh bg' to run it in the background instead!"
node server.js
