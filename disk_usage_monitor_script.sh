#!/bin/bash

# Set threshold percentage (e.g., 80)
THRESHOLD=80

# Set email for alert (replace with actual admin email)
ADMIN_EMAIL="admin@example.com"

# Get disk usage percentage of root partition (can be modified for other partitions)
USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
  # If usage is above threshold, send alert email
  SUBJECT="Disk Space Alert on $(hostname)"
  BODY="Warning: Disk usage is at ${USAGE}% on $(hostname) as of $(date). Please take action."
  echo "$BODY" | mail -s "$SUBJECT" "$ADMIN_EMAIL"
fi
