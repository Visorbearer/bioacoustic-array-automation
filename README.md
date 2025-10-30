## Code to Trigger Nightly Recording with a Bioacoustic Array

This repository contains relevant scripts to trigger a multichannel bioacoustic recording array,
which utilizes a Behringer UMC1820 recorder connected to a Raspberry Pi. It gets the sunset and 
sunrise times each day and then records from 1 hour before sunset to 1 hour after sunrise on the 
following day. Recordings are broken up into 15 minute segments, compressed into 24-bit, 24kHz .flac files, 
and saved these recordings to a folder on an SSD with the name of the date the recording segment started on 
(i.e. `/rec/20250926` for audio recorded the night of September 26th, 2025).

## Post-processing of Audio

Within the Post-Processing folder, there are scripts to split the 4-channel audio recorded by the array into
four separate audio files (North, East, West, and South), to merge the Nighthawk output of those files back together
into a combined .csv file, to convert the combined file into a format OpenSoundscape accepts, and to get relative 
coordinates for the microphones. This also includes the output file from the coordinate-generating script.
