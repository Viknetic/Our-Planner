#!/bin/bash

# Port number requested
PORT=49210

echo "🚀 Starting Our Planner Premium Server on port $PORT..."

# Check if node is installed
if ! command -v node &> /dev/null
then
    echo "📦 Node.js not found. Installing..."
    pkg install nodejs -y
fi

# Initialize npm if package.json doesn't exist
if [ ! -f "package.json" ]; then
    echo "📦 Initializing Node project..."
    npm init -y
    npm install express
fi

# Ensure express is installed
if [ ! -d "node_modules/express" ]; then
    echo "📦 Installing express..."
    npm install express
fi

echo "✨ Server is starting!"
echo "📱 Access it at: http://localhost:$PORT"
echo "🌐 Or via Tailscale IP at: http://$(tailscale ip -4):$PORT"

# Run the server
node server.js
