#!/bin/bash

# Port number requested
PORT=49210
SERVICE_DIR="$HOME/.termux/services/our-planner"

echo "🚀 Our Planner Premium: Termux Manager"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    pkg install openssh nodejs termux-services -y
fi

if [ ! -f "package.json" ]; then
    npm init -y
    npm install express
fi

# 2. Service Management
if [ "$1" == "service" ]; then
    echo "⚙️ Registering Our Planner as a system service..."
    
    mkdir -p "$SERVICE_DIR"
    
    # Create the run script for the service
    cat <<EOF > "$SERVICE_DIR/run"
#!/bin/bash
exec 2>&1
cd "$PWD"
exec node server.js
EOF
    
    chmod +x "$SERVICE_DIR/run"
    
    echo "✅ Service registered!"
    echo "🚀 Starting service now..."
    sv up our-planner
    echo "📱 Use 'sv status our-planner' to check status."
    exit 0
fi

if [ "$1" == "status" ]; then
    sv status our-planner
    exit 0
fi

if [ "$1" == "stop" ]; then
    echo "🛑 Stopping the service..."
    sv down our-planner
    exit 0
fi

# 3. Foreground Mode (Standard)
echo "✨ Starting in foreground mode..."
echo "🌐 Access at: http://$(tailscale ip -4):$PORT"
echo "💡 Tip: Run './start_termux.sh service' to make it a permanent background service!"
node server.js
