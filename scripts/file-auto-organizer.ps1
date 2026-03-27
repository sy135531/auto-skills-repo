# File Auto Organizer
# Monitors and organizes files automatically
param(
    [string]$WatchFolder = "$env:USERPROFILE\Downloads",
    [string]$OrganizeFolder = "$env:USERPROFILE\Documents\Organized"
)

$ErrorActionPreference = "Continue"

Write-Host "[1/3] Scanning files..."
$files = Get-ChildItem -Path $WatchFolder -File -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }

if ($files.Count -eq 0) {
    Write-Host "No new files"
    exit 0
}

# Create category folders
$categories = @{
    Documents = Join-Path $OrganizeFolder "Documents"
    Images = Join-Path $OrganizeFolder "Images"
    Code = Join-Path $OrganizeFolder "Code"
    Archives = Join-Path $OrganizeFolder "Archives"
    Others = Join-Path $OrganizeFolder "Others"
}

foreach ($folder in $categories.Values) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

Write-Host "[2/3] Organizing files..."
$moved = 0

foreach ($file in $files) {
    $dest = $categories.Others
    switch -Regex ($file.Extension) {
        '\.(txt|doc|docx|pdf|md)$' { $dest = $categories.Documents }
        '\.(jpg|jpeg|png|gif|bmp|webp)$' { $dest = $categories.Images }
        '\.(py|js|ps1|sh|bat|sql|html|css)$' { $dest = $categories.Code }
        '\.(zip|rar|7z|tar|gz)$' { $dest = $categories.Archives }
    }
    
    $destPath = Join-Path $dest $file.Name
    try {
        Move-Item -Path $file.FullName -Destination $destPath -Force
        $moved++
        Write-Host "  Moved: $($file.Name) -> $dest"
    } catch {}
}

Write-Host "[3/3] Generating report..."
$logFile = Join-Path $OrganizeFolder "organize-log-$(Get-Date -Format 'yyyyMMdd').txt"
$log = @"
File Organization Log
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
Files processed: $($files.Count)
Files moved: $moved
"@
$log | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "Done! Moved $moved files"
