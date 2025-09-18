import time
from astral import LocationInfo
from astral.sun import sun
from datetime import date, datetime, timedelta
import subprocess
import os

# Get location (general is fine)
city = LocationInfo("Grein Farm", "Illinois", "America/Chicago", latitude: 40.070442, longitude: -88.222556)

# Pull datetime from radar
# TBD

# Get sunset/rise times for today and tomorrow, since sunrise is tomorrow
stoday = sun(city.observer, date=date.today(), tzinfo=city.timezone)
stom = sun(city.observer, date=(date.today() + timedelta(days=1)), tzinfo=city.timezone)
sunrise = stom["sunrise"]
sunset = stoday["sunset"]

# Set the start time to an hour before sunset and
# the stop time to an hour after sunrise
start_time = sunset - timedelta(hours=1)
stop_time = sunrise + timedelta(hours=1)

# Format
start_at = start_time.strftime("%Y%m%d%H%M")
stop_at  = stop_time.strftime("%Y%m%d%H%M")

# Path for script that simulates R press
script_path = "simulate_R.sh"

# Schedule start and stop jobs with at
subprocess.run(["at", "-t", start_at], input=f"{script_path}\n", text=True)
subprocess.run(["at", "-t", stop_at], input=f"{script_path}\n", text=True)

# Log sunset and sunrise times
log_dir = "/var/timelog/sun_times"
os.makedirs(log_dir, exist_ok=True)
log_path = os.path.join(log_dir, datetime.today().strftime("%Y-%m-%d") + ".log")

with open(log_path, "a") as f:
    f.write(f"Scheduled start at {start_time} and stop at {stop_time}.\n")