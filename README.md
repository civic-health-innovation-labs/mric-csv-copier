# AzCopy CSV Folder Copier
Author: David Salac

## Overview

The **AzCopy CSV Folder Copier** is a PowerShell script that leverages [AzCopy](https://learn.microsoft.com/azure/storage/common/storage-use-azcopy-v10) to copy CSV files from one Azure Storage Account container to another. This script is designed to:

- **Filter CSV files:** Only process CSV files that are stored inside folders (i.e., files with a path like `FolderName/filename.csv`).
- **Rename files:** Rename each CSV file to match its containing folder (e.g., the CSV file in `FolderName/filename.csv` is copied as `FolderName.csv`).
- **Utilize SAS tokens:** Use SAS tokens for secure access to both the source and destination containers.

## Prerequisites

- **PowerShell:** Version 5.1 or later (or PowerShell Core).
- **AzCopy v10+:** Ensure [AzCopy](https://learn.microsoft.com/azure/storage/common/storage-use-azcopy-v10) is installed and available in your system’s PATH.
- **Azure Storage SAS Tokens:** Valid SAS tokens for both the source and destination containers with appropriate permissions (read access for the source, write access for the destination).

## Setup

1. **Clone or Download:** Obtain the script from your repository.
2. **Review the Script:** Open the script file (e.g., `copier.ps1`) in your preferred text editor to review or customize it.
3. **Ensure Dependencies:** Verify that AzCopy is installed and the SAS tokens are valid. Use only SAS with correct permissions (List and Read on the source, Write on the destination).

## Usage
Run the script from a PowerShell prompt with the required parameters:

```powershell
    .\copier.ps1 `
        -SourceContainerUrl "https://sourceacct.blob.core.windows.net/sourcecont" `
        -SourceSasToken "?sv=...sourceSAS..." `
        -DestContainerUrl "https://destacct.blob.core.windows.net/destcont" `
        -DestSasToken "?sv=...destSAS..."
```
