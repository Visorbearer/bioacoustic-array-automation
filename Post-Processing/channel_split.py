import soundfile as sf
import sys
import os
from glob import glob

def channel_split(folder_path):
    # Find all .flac files in the folder
    flac_files = glob(os.path.join(folder_path, "*.flac"))
    
    if not flac_files:
        print("No .flac files found in the folder.")
        return
    
    for flac_path in flac_files:
        # Read the audio file
        data, samplerate = sf.read(flac_path)
        
        # Check number of channels
        if len(data.shape) == 1:
            print("File is mono, skipping channel split.")
            continue
        
        num_channels = data.shape[1]
        print(f"File has {num_channels} channels at {samplerate} Hz")

        # Label channels in NEWS order
        labels = ["NORTH", "EAST", "WEST", "SOUTH"]

        # Save output files from each channel per input audio
        for i, label in enumerate(labels[:num_channels]):
            channel_data = data[:, i]
            output_file = flac_path.replace(".flac", f"_{label}.flac")
            sf.write(output_file, channel_data, samplerate)
            print(f"Saved {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 channel_split.py <folder_path>")
        sys.exit(1)
    channel_split(sys.argv[1])