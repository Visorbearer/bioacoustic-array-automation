#!/bin/bash
set -euo pipefail

LOCAL_BASE="/home/admin/rec"
BOX_BASE="Box:Grein_Farm_Recordings"

# Folder recorded from the previous night
DAY_FOLDER=$(basename "$1")

# Convert each .wav to 24-bit / 24kHz
for f in "$LOCAL_BASE/$DAY_FOLDER"/*.wav; do
    tmp="${f%.wav}.tmp.flac"
    final="${f%.wav}.flac"
    if ffmpeg -y -loglevel error -i "$f" -map_channel 0.0.0 -map_channel 0.0.1 -map_channel 0.0.2 -map_channel 0.0.3 -map_channel 0.0.4 -ar 24000 -sample_fmt s32 "$tmp"; then
        mv "$tmp" "$final"
        rm -f "$f"
    else
        rm -f "$tmp"
    fi
done

# Upload converted audio
rclone copy "$LOCAL_BASE/$DAY_FOLDER" "$BOX_BASE/Audio/$DAY_FOLDER" -v

# Upload the night's log
LOGFILE=$(ls -t "$LOCAL_BASE/timelog" | head -n1)
rclone copyto "$LOCAL_BASE/timelog/$LOGFILE" "$BOX_BASE/Logs/$LOGFILE" -v

# Delete local logs older than 4 days
find "$LOCAL_BASE/timelog" -type f -name "*.log" -mtime +4 -exec rm -f {} \;
