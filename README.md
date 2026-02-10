# deweyr <img src="https://github.com/user-attachments/assets/4125e4c7-aa77-43d1-8e81-8c7e9ab14ffb" align="right" width="150" height="150" alt="DeweyHex2" style="margin-left: 20px; margin-bottom: 20px;" />


> An R interface to [deweypy](https://github.com/dewey-data/deweypy) for downloading files from the Dewey file management system.





## Overview

`deweyr` provides a simple way to download files from Dewey folders directly from R, without requiring manual Python environment setup. The package offers two download methods:

- **`dewey_download()`** - Recommended method using [UV](https://docs.astral.sh/uv/) (automatic Python environment management)
- **`dewey_download_py()`** - Traditional method using an existing Python installation

## Installation

Install the development version from GitHub:
```r
# install.packages("devtools")
devtools::install_github("Coxabc/deweyr")
```

## Quick Start

### Method 1: Using UV (Recommended)

The easiest way to get started - no Python installation required:
```r
library(deweyr)

dewey_download(
  api_key = "your-api-key",
  folder_id = "your-folder-id"
)
```

> **First-time setup:** If UV isn't installed, `deweyr` will install it automatically. You may see a message recommending you restart your terminal for optimal performance in future runs.

### Method 2: Using Existing Python

If you already have Python and deweypy installed:
```r
library(deweyr)

dewey_download_py(
  api_key = "your-api-key",
  folder_id = "your-folder-id"
)
```

## Usage Examples

### Basic Download
```r
# Download to default location (./dewey-downloads)
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123"
)
```

### Custom Download Location
```r
# Specify where to save files
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123",
  download_path = "C:/Users/YourName/Documents/data"
)
```

### Download from URL

You can use either a folder ID or the full Dewey URL:
```r
dewey_download(
  api_key = "your-api-key",
  folder_id = "https://api.deweydata.io/api/v1/external/data/abc123"
)
```

## Advanced Options

### Multi-threaded Downloads

Adjust the number of workers for faster downloads (default is 8):
```r
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123",
  num_workers = 16  # Use 16 parallel workers
)
```

### Date-Partitioned Datasets

For datasets partitioned by date, you can filter which partitions to download:
```r
# Download only data from 2024 onwards
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123",
  partition_key_after = "2024-01-01"
)

# Download only data up to a certain date
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123",
  partition_key_before = "2023-12-31"
)

# Download a specific date range
dewey_download(
  api_key = "your-api-key",
  folder_id = "abc123",
  partition_key_after = "2024-01-01",
  partition_key_before = "2024-03-31"
)
```
---

**Note:** This package requires an active Dewey account and API key. Visit [Dewey](https://dewey.works) to learn more.
