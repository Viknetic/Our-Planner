#!/bin/bash

# Configuration
PORT=49210
SCRIPT_PATH=$(realpath "$0")
DIR_PATH=$(dirname "$SCRIPT_PATH")
SERVICE_NAME="planner"
SERVICE_DIR="$PREFIX/var/service/$SERVICE_NAME"

echo "🚀 Our Planner: System Daemon Manager"

# 1. Dependency Check
if ! command -v node &> /dev/null; then
    echo "📦 Initializing Dependencies..."
    pkg install nodejs termux-services -y
fi

# 2. Service Management
case "$1" in
    "install-service")
        echo "⚙️ Installing as a Termux System Service (Suwayomi-style)..."
        
        # Create service directory
        mkdir -p "$SERVICE_DIR"
        
        # Create the RUN script
        cat <<EOF > "$SERVICE_DIR/run"
#!/bin/bash
# Send errors to standard output
exec 2>&1
# Move to app directory
cd "$DIR_PATH"
# Run the node server
echo "Starting Our Planner Daemon on port $PORT..."
exec node server.js
EOF
        
        chmod +x "$SERVICE_DIR/run"
        
        # Create a log directory
        mkdir -p "$SERVICE_DIR/log"
        cat <<EOF > "$SERVICE_DIR/log/run"
#!/bin/bash
exec svlogd -tt ./
EOF
        chmod +x "$SERVICE_DIR/log/run"

        echo "✅ Service registered!"
        echo "🔄 Please RESTART Termux now."
        echo "💡 After restart, use 'sv status $SERVICE_NAME' to check it."
        exit 0
        ;;
        
    "status")
        sv status "$SERVICE_NAME"
        exit 0
        ;;
        
    "stop")
        echo "🛑 Stopping daemon..."
        sv down "$SERVICE_NAME"
        exit 0
        ;;
        
    "start")
        echo "🚀 Starting daemon..."
        sv up "$SERVICE_NAME"
        exit 0
        ;;
        
    "logs")
        echo "📜 Viewing service logs..."
        tail -f "$SERVICE_DIR/current"
        exit 0
        ;;
esac

# 3. Default Foreground Mode
echo "✨ Our Planner: Foreground"
echo "🌐 Local: http://localhost:$PORT"
echo "💡 To install as a permanent background service: ./start_termux.sh install-service"
cd "$DIR_PATH"
node server.js
