#!/bin/bash

LOGFILE="/var/log/configmap.log"

exec >> "$LOGFILE" 2>&1

while true; do
  echo "------------------- $(date) -------------------" >> "$LOGFILE"
  bash /home/ashna/Documents/Task1/configMap.sh >> "$LOGFILE" 2>&1
  echo "------------------- End -------------------" >> "$LOGFILE"
  sleep 10
done






