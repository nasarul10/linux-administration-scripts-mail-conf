#!/bin/bash

# Service to monitor
SERVICE="ssh"

# Email to notify
ADMIN_EMAIL="admin@example.com"

# Check if service is active
if ! systemctl is-active --quiet $SERVICE; then
  # Attempt to restart the service
  systemctl restart $SERVICE
  
  # Verify if the restart was successful
  if systemctl is-active --quiet $SERVICE; then
    STATUS="Service $SERVICE was down and has been restarted successfully on $(hostname) at $(date)."
  else
    STATUS="Service $SERVICE was down and failed to restart on $(hostname) at $(date). Immediate attention needed!"
  fi

  # Send alert email (make sure mail is configured)
  echo "$STATUS" | mail -s "Service Alert: $SERVICE status on $(hostname)" $ADMIN_EMAIL
fi
