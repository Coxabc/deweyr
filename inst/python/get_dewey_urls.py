# /// script
# dependencies = ["deweypy"]
# ///
import sys
import json
import re
from deweypy.auth import set_api_key
from deweypy.download.synchronous import get_dataset_files

# Accept api_key and data_id as command line arguments from R via system2()
api_key = sys.argv[1]
data_id = sys.argv[2]

# Authenticate and fetch file metadata for the dataset
set_api_key(api_key)
files = get_dataset_files(data_id)

# Extract download URLs for all files in the dataset
urls = [f["link"] for f in files]

# Derive a clean parent folder name from the first file's name
# e.g. "airline-employment-data_0_0_0.snappy.parquet" -> "airline-employment"
file_name = files[0]["file_name"]
parent_folder = re.sub(r"[-_]\d.*$", "", file_name)
parent_folder = re.sub(r"-data$", "", parent_folder)

file_extension = files[0]["file_extension"]

# Print JSON to stdout — R captures this via system2(stdout = TRUE)
print(
    json.dumps(
        {
            "urls": urls,
            "parent_folder": parent_folder,
            "file_extension": file_extension,
            "partition_key": files[0][
                "partition_key"
            ],  # dewey-provided partition column, may be null
            "file_size_bytes": sum(
                f["file_size_bytes"] for f in files
            ),  # total dataset size in bytes
        }
    )
)
