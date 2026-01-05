# Converts the songcollection text file into a songs.csv (Key,Title,Artist,Album)
# Usage: run this script in PowerShell

$in = 'C:\Users\resto\Documents\testplace\songcollection'
$out = 'C:\Users\resto\Documents\testplace\songs.csv'

$result = @()
$currentKey = ''

Get-Content $in | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '') { return }

    # Key lines: either "key:Ab" or "Key C low" etc.
    if ($line -match '^[Kk]ey\s*:\s*(.+)$') { $currentKey = $matches[1].Trim(); return }
    if ($line -match '^[Kk]ey\s+(.+)$') { $currentKey = $matches[1].Trim(); return }

    # Skip header lines
    if ($line -match '^(Song title|Title|itle)\s*\t') { return }

    # Only process lines with a tab (Title<TAB>Artist<TAB>Album)
    if (-not ($line -match '\t')) { return }

    $parts = $line -split "`t"
    if ($parts.Count -lt 2) { return }

    $title = $parts[0].Trim()
    $artist = $parts[1].Trim()
    $album = ''
    if ($parts.Count -ge 3) { $album = ($parts[2..($parts.Count-1)] -join ' ').Trim() }

    $obj = [PSCustomObject]@{
        Key    = $currentKey
        Title  = $title
        Artist = $artist
        Album  = $album
    }
    $result += $obj
}

# Export
$result | Export-Csv -Path $out -NoTypeInformation -Encoding UTF8
Write-Output "Wrote $($result.Count) records to $out"