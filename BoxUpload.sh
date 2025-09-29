#!/bin/bash
set -euo pipefail

LOCAL_BASE="/home/admin/rec"
BOX_BASE="Box:Grein_Farm_Recordings"

# Folder recorded from the previous night
DAY_FOLDER=$(basename "$1")

# Upload audio from the previous night
rclone copy "$LOCAL_BASE/$DAY_FOLDER" "$BOX_BASE/Audio/$DAY_FOLDER" -v

# Upload the night's log
LOGFILE=$(ls -t "$LOCAL_BASE/timelog" | head -n1)
rclone copyto "$LOCAL_BASE/timelog/$LOGFILE" "$BOX_BASE/Logs/$LOGFILE" -v

# Delete local logs older than 4 days
find "$LOCAL_BASE/timelog" -type f -name "*.log" -mtime +4 -exec rm -f {} \;


# Delete local recording folders older than 4 days
find "$LOCAL_BASE" -maxdepth 1 -type d -regex ".*/[0-9]{8}" -mtime +4 -exec rm -rf {} \;
