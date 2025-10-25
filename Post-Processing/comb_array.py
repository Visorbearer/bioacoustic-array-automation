import os
import sys
import pandas as pd
from glob import glob

def comb_array(folder_path):
    # Get all CSV files in the folder
    csv_files = sorted(glob(os.path.join(folder_path, "*.csv")))
    
    if not csv_files:
        print("No CSV files found in the folder.")
        return
    
    # Read and concatenate all CSVs
    df_list = []
    for idx, csv_path in enumerate(csv_files):
        print(f"Reading {os.path.basename(csv_path)}")
        df = pd.read_csv(csv_path)
        
        # Skip header duplication
        df_list.append(df)
    
    combined_df = pd.concat(df_list, ignore_index=True)
    
    # Use folder name to build combined output filename
    folder_name = os.path.basename(os.path.normpath(folder_path))
    output_file = os.path.join(folder_path, f"{folder_name}_combined.csv")
    
    # Save combined CSV
    combined_df.to_csv(output_file, index=False)
    print(f"\n Combined CSV saved as: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 channel_split.py <folder_path>")
        sys.exit(1)
    comb_array(sys.argv[1])
