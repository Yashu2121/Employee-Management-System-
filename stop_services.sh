#!/bin/bash
echo "Stopping all services..."
kill 18756 18757 18758 2>/dev/null
kill $(lsof -t -i:8000) $(lsof -t -i:5000) $(lsof -t -i:3000) 2>/dev/null
echo "Services stopped successfully."
