import time
import math
import os
import re
import subprocess
from astral import LocationInfo
from astral.sun import sun
from datetime import date, datetime, timedelta

# Get location (coords from radar location)
city = LocationInfo("Grein Farm", "Illinois", "America/Chicago", 40.070442, -88.222556)

# Pull datetime from radar
# Ensure the Pi running this script has passwordless sudo for ntpdate
# and uncomment the line below to force sync time with the radar
## subprocess.run(["sudo", "ntpdate", "-u", "localhost"])

# Get sunset/rise times for today and tomorrow, since sunrise is tomorrow
stoday = sun(city.observer, date=date.today(), tzinfo=city.timezone)
stom = sun(city.observer, date=(date.today() + timedelta(days=1)), tzinfo=city.timezone)
sunrise = stom["sunrise"]
sunset = stoday["sunset"]

# Set the start time to an hour before sunset and
# the stop time to an hour after sunrise
start_time = sunset - timedelta(hours=1)
stop_time = sunrise + timedelta(hours=1)

# Format datetime
start_at = start_time.strftime("%Y%m%d%H%M")
stop_at  = stop_time.strftime("%Y%m%d%H%M")

# Calculate number of 30-min intervals to record for,
# including partial intervals
rec_intervals = math.ceil((stop_time - start_time).total_seconds() / (30 * 60))

# Find sound card being used by the UMC
arecord_output = subprocess.run(["arecord", "-l"], capture_output=True, text=True).stdout
match = re.search(r"card (\d+):.*?UMC", arecord_output)

# Set device if found, if not assume card number 1
if match:
    card_number = match.group(1)
    device = f"hw:{card_number},0"
    print(f"Found UMC recorder on {device}.")
else:
    device = "hw:1,0"
    print("Could not find the UMC recorder. Defaulting to hw:1,0.")

# Log sunset and sunrise times
log_dir = ("/home/admin/rec/timelog/sun_times")
os.makedirs(log_dir, exist_ok=True)
log_path = os.path.join(log_dir, datetime.today().strftime("%Y-%m-%d_%H%M%S_%f") + ".log")

# Make day folder for recordings
day_folder = f"/home/admin/rec/{start_time.strftime('%Y%m%d')}"
os.makedirs(day_folder, exist_ok=True)

# Loop over each 30 min interval nightly
for i in range(rec_intervals):
    interval_start = start_time + timedelta(minutes=30 * i)
    interval_stop = min(interval_start + timedelta(minutes=30), stop_time)
    run_time = (interval_stop - interval_start).total_seconds() - 0.2  # <- Subtract small buffer to avoid overlap, which messes up 'at' scheduling
    
    # Filename with interval index
    file_name = interval_start.strftime('%Y%m%d_%H%M%S_%f') + ".wav"
    file_path = os.path.join(day_folder, file_name)
    start_record = f"arecord -D {device} -f S16_LE -r 24000 -c 10 -d {run_time:.1f} {file_path}"
    
    # Format for 'at' (YYYYMMDDHHMM.SS)
    start_at = interval_start.strftime("%Y%m%d%H%M.%S")
    
    # Schedule the recording job
    subprocess.run(["at", "-t", start_at], input=f"{start_record}\n", text=True)
    
    # Log the recording
    with open(log_path, "a") as f:
        f.write(f"Scheduled part {i+1}: {interval_start} to {interval_stop}, {file_name}\n")

print(f"Scheduled {rec_intervals} recordings from {start_time} to {stop_time}.")

# Schedule upload and cleanup after recording is done
final_time = stop_time + timedelta(minutes=5)
final_at = final_time.strftime("%Y%m%d%H%M.%S")

# Call the upload script with the day folder as argument
upload_cmd = f"/home/admin/rec/BoxUpload.sh {day_folder}"
subprocess.run(["at", "-t", final_at], input=f"{upload_cmd}\n", text=True)

print(f"Scheduled upload and cleanup for {day_folder} at {final_time}.")

