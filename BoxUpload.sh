#!/bin/bash
set -euo pipefail

LOCAL_BASE="/home/admin/rec"
BOX_BASE="Box:Grein_Farm_Recordings"

# Folder recorded from the previous night
DAY_FOLDER=$(basename "$1")

# Convert each .wav to 24-bit / 24kHz
for f in "$LOCAL_BASE/$DAY_FOLDER"/*.wav; do
    tmp="${f%.wav}.tmp.wav"
    ffmpeg -y -loglevel error -i "$f" -ar 24000 -ac 10 -sample_fmt s24 "$tmp" && mv "$tmp" "$f" || rm -f "$tmp"
done

# Upload converted audio
rclone copy "$LOCAL_BASE/$DAY_FOLDER" "$BOX_BASE/Audio/$DAY_FOLDER" -v


# Upload the night's log
LOGFILE=$(ls -t "$LOCAL_BASE/timelog" | head -n1)
rclone copyto "$LOCAL_BASE/timelog/$LOGFILE" "$BOX_BASE/Logs/$LOGFILE" -v

# Delete local logs older than 4 days
find "$LOCAL_BASE/timelog" -type f -name "*.log" -mtime +4 -exec rm -f {} \;


# Delete local recording folders older than 4 days
find "$LOCAL_BASE" -maxdepth 1 -type d -regex ".*/[0-9]{8}" -mtime +4 -exec rm -rf {} \;
