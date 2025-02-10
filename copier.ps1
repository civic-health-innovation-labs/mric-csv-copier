<# 
.SYNOPSIS
    Copies CSV files from one Azure Blob Storage container to another using AzCopy and SAS tokens.
.DESCRIPTION
    This script lists all blobs in the source container (using AzCopy), filters for CSV files that are stored
    inside a folder (i.e. blob name of the form "FolderName/filename.csv"), and then copys each CSV blob to 
    the destination container. The CSV file is renamed so that its name is that of its parent folder 
    (e.g. “FolderName.csv”).
.PARAMETER SourceContainerUrl
    The base URL for the source container (e.g. https://mystorageaccount.blob.core.windows.net/sourcecontainer).
.PARAMETER SourceSasToken
    The SAS token for the source container (including the leading “?”).
.PARAMETER DestContainerUrl
    The base URL for the destination container.
.PARAMETER DestSasToken
    The SAS token for the destination container.
.EXAMPLE
    .\copier.ps1 `
        -SourceContainerUrl "https://sourceacct.blob.core.windows.net/sourcecont" `
        -SourceSasToken "?sv=...sourceSAS..." `
        -DestContainerUrl "https://destacct.blob.core.windows.net/destcont" `
        -DestSasToken "?sv=...destSAS..."
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SourceContainerUrl,

    [Parameter(Mandatory = $true)]
    [string]$SourceSasToken,

    [Parameter(Mandatory = $true)]
    [string]$DestContainerUrl,

    [Parameter(Mandatory = $true)]
    [string]$DestSasToken
)

# Write informational header
Write-Host "Starting CSV copy using AzCopy..." -ForegroundColor Cyan

# First, list all blobs in the source container recursively.
# (AzCopy list returns one blob path per line, e.g. "FolderName/SomeFile.csv")
Write-Host "Listing blobs in the source container..."
try {
    $listArgs = @("list", "$SourceContainerUrl$SourceSasToken")
    $blobList = & azcopy @listArgs
}
catch {
    Write-Error "Error executing azcopy list. Ensure AzCopy is installed and the parameters are correct."
    exit 1
}

if (-not $blobList) {
    Write-Host "No blobs found in the source container." -ForegroundColor Yellow
    exit 0
}

# Process each blob found in the list.
foreach ($blob in $blobList) {
    $blob = $blob.Trim()
    # Process only CSV files
    if ($blob.Contains(".csv")) {
        Write-Host "Found CSV blob: $blob"

        # Expect the blob to be inside a folder (i.e. "FolderName/SomeFile.csv")
        $parts = $blob -split "/"
        if ($parts.Length -ge 2) {
            # Use the first folder name as the new name (append .csv)
            $folderName = $parts[0].Substring(6)
            $newFileName = "$folderName.csv"
            $blobRightName = $blob.Substring(6, $blob.IndexOf(".csv")-2)

            # Construct the full source blob URL.
            # (Make sure there is a single "/" between the container URL and the blob path.)
            $sourceBlobUrl = "$SourceContainerUrl/$blobRightName$SourceSasToken"

            # Construct the destination blob URL with the new name.
            $destBlobUrl = "$DestContainerUrl/$newFileName$DestSasToken"

            Write-Host "Copying blob:" -ForegroundColor Green
            Write-Host "   Source:      $sourceBlobUrl"
            Write-Host "   Destination: $destBlobUrl"

            # Use AzCopy's copy command to copy and keep source untouched.
            # The flag --from-to BlobBlob tells AzCopy the source and destination are Azure Blobs.
            $copyArgs = @("copy", "$sourceBlobUrl", "$destBlobUrl", "--from-to", "BlobBlob", "--overwrite", "true")
            $copyResult = & azcopy @copyArgs

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Successfully copied '$blobRightName' to '$newFileName'."
            }
            else {
                Write-Error "Failed to copy '$blobRightName'. Check the output above for details."
            }
        }
        else {
            Write-Warning "Blob '$blob' does not appear to be stored in a folder. Skipping."
        }
    }
    else {
        Write-Host "Skipping non-CSV blob: $blob"
    }
}

Write-Host "CSV copy process completed." -ForegroundColor Cyan
