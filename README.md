# Rec-Array-Trigger
## Code to Sync a Bioacoustic Array to an X-Band Radar and Record Nightly

This repository contains relevant scripts to sync a multichannel bioacoustic recording array,
which utilizes a Behringer UMC1820 recorder connected to a Raspberry Pi, to the GPS
clock of a FaunaScan MR2 fine-scale radar. It forces the synchronization of the Pi's internal
clock to that of the radar, gets the sunset and sunrise times each day, and then records 
recordings from 1 hour before sunset to 1 hour after sunrise on the following day, broken up into
15 minute segments, compresses these recordings into 24-bit, 24kHz .flac files, and
saves these recordings to a folder in `/home/admin/rec/` with the name of the date the recording 
segment started on (i.e. `/home/admin/rec/20250926` for audio recorded the night of 
September 26-27th, 2025).
