#!/bin/bash

# Create logs directory
mkdir -p logs

echo "🚀 Starting Employee Portal Services..."

# 1. Start Mock ERPNext Server (Port 8000)
echo "Starting Mock ERPNext on port 8000..."
./venv/bin/python3 backend/mock_erp.py > logs/mock_erp.log 2>&1 &
ERP_PID=$!

# 2. Start FastAPI Backend (Port 5000)
echo "Starting FastAPI Backend on port 5000..."
./venv/bin/python3 backend/main.py > logs/backend.log 2>&1 &
BACKEND_PID=$!

# 3. Start Flutter Web-Server (Port 3000)
echo "Starting Flutter Web Server on port 3000..."
/home/embeded/flutter/bin/flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0 > logs/flutter.log 2>&1 &
FLUTTER_PID=$!

echo "--------------------------------------------------------"
echo "Services started in the background:"
echo "  - Mock ERPNext Server: http://localhost:8000  (PID: $ERP_PID)"
echo "  - FastAPI Backend:     http://localhost:5000  (PID: $BACKEND_PID)"
echo "  - Flutter Web App:     http://localhost:3000  (PID: $FLUTTER_PID)"
echo "--------------------------------------------------------"
echo "Log files are saved in the 'logs/' folder."
echo "Use './stop_services.sh' to stop them."

# Write the stop script
cat <<EOF > stop_services.sh
#!/bin/bash
echo "Stopping all services..."
kill $ERP_PID $BACKEND_PID $FLUTTER_PID 2>/dev/null
kill \$(lsof -t -i:8000) \$(lsof -t -i:5000) \$(lsof -t -i:3000) 2>/dev/null
echo "Services stopped successfully."
EOF
chmod +x stop_services.sh

# Keep script running to monitor or sleep
sleep 3
echo "Checking service status..."
if ps -p $ERP_PID > /dev/null; then
    echo "✅ Mock ERPNext is running."
else
    echo "❌ Mock ERPNext failed to start. Check logs/mock_erp.log"
fi

if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ FastAPI Backend is running."
else
    echo "❌ FastAPI Backend failed to start. Check logs/backend.log"
fi

if ps -p $FLUTTER_PID > /dev/null; then
    echo "✅ Flutter Web App is running."
else
    echo "❌ Flutter Web App failed to start. Check logs/flutter.log"
fi
