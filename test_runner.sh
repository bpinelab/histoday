#!/bin/bash

set -e

LOG_FILE="/var/log/histoday-test.log"
SCRIPT="/opt/histoday/fetch_event.py"
VENV_PATH="/opt/histoday/venv"

# Load .env if available
set -a
[ -f /opt/histoday/.env ] && source /opt/histoday/.env
set +a

# Check for fetch_event.py
if [ ! -f "$SCRIPT" ]; then
  echo "Error: fetch_event.py not found at $SCRIPT" | tee -a "$LOG_FILE"
  exit 1
fi

# Check for virtualenv
if [ ! -f "$VENV_PATH/bin/activate" ]; then
  echo "Error: Python virtualenv not found at $VENV_PATH" | tee -a "$LOG_FILE"
  exit 1
fi

# Activate virtualenv
source "$VENV_PATH/bin/activate"

# Run the script
echo "[$(date)] Running fetch_event.py manually..." | tee -a "$LOG_FILE"
python "$SCRIPT" 2>&1 | tee -a "$LOG_FILE"
echo "[$(date)] Done." | tee -a "$LOG_FILE"
