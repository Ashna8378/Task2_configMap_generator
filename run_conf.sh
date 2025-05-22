#!/bin/bash

LOGFILE="/home/ashna/Documents/Task1/configmap.log"

while true; do
  echo "------------------- $(date) -------------------" >> "$LOGFILE"
  bash /home/ashna/Documents/Task1/configMap.sh >> "$LOGFILE" 2>&1
  echo "------------------- End -------------------" >> "$LOGFILE"
  sleep 60
done








