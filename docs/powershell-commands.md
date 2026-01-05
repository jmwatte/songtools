# PowerShell commands for songs.csv

This file contains copy/paste-ready PowerShell snippets to query `songs.csv` (generated from your `songcollection` file). Set the path below and run the examples you need.

---

## Setup
```powershell
$csv = 'C:\Users\resto\Documents\testplace\songs.csv'
# Load once into memory for speed (recommended)
$songs = Import-Csv $csv
# Quick preview
$songs | Select-Object -First 10 | Format-Table -AutoSize
```

---

## Basic counts & previews ✅
```powershell
# Total records
$songs.Count
# Rows by key
$songs | Group-Object Key | Sort-Object Count -Descending
# First 20 titles
$songs | Select-Object -Property Title,Artist,Album -First 20 | Format-Table -AutoSize
```

---

## Filters (copy/paste) 🔎
```powershell
# All songs in Key 'A'
$songs | Where-Object { $_.Key -eq 'A' } | Select-Object Title,Artist,Album

# Case-insensitive by key
$songs | Where-Object { $_.Key -ieq 'a' }

# Songs by artist (regex)
$songs | Where-Object { $_.Artist -match 'Muddy Waters' }

# Albums containing 'Live'
$songs | Where-Object { $_.Album -match 'Live' } | Select Title,Artist,Album

# Multi-criteria (Key A AND Album contains Live)
$songs | Where-Object { $_.Key -eq 'A' -and $_.Album -match 'Live' }

# Title contains word (wildcard)
$songs | Where-Object { $_.Title -like '*Love*' }

# Search across multiple fields
$songs | Where-Object { $_.Title -match 'love' -or $_.Artist -match 'Muddy' }
```

---

## Exporting results ⤓
```powershell
# Export Key A to a new CSV
$songs | Where-Object Key -eq 'A' | Export-Csv -Path '.\A_songs.csv' -NoTypeInformation

# Export a TSV (tab-separated)
$songs | Where-Object Key -eq 'A' | Export-Csv -Path '.\A_songs.tsv' -Delimiter "`t" -NoTypeInformation

# Export subset to JSON
$songs | Where-Object Key -eq 'A' | ConvertTo-Json -Depth 3 | Out-File -FilePath '.\A_songs.json' -Encoding utf8
```

---

## Summaries & groupings 📊
```powershell
# Top artists by number of tracks
$songs | Group-Object Artist | Sort-Object Count -Descending | Select-Object -First 20

# Distinct albums
$songs | Select-Object -ExpandProperty Album | Sort-Object -Unique

# Track count per album
$songs | Group-Object Album | Sort-Object Count -Descending | Select-Object Name,Count

# Albums per artist (list)
$songs | Group-Object Artist | ForEach-Object { [PSCustomObject]@{ Artist=$_.Name; Albums=($_.Group | Select-Object -ExpandProperty Album -Unique -ErrorAction SilentlyContinue) } }
```

---

## Playlist formats (text / M3U) 🎵
```powershell
# Simple text playlist: "Title - Artist"
$songs | Where-Object Key -eq 'A' | ForEach-Object { "$($_.Title) - $($_.Artist)" } > '.\playlist_A.txt'

# M3U (basic): add file list lines (if you have file paths you can substitute)
"#EXTM3U" | Out-File playlist.m3u
$songs | Where-Object Key -eq 'A' | ForEach-Object { "#EXTINF:-1,$($_.Artist) - $($_.Title)"; "./music/$($_.Artist) - $($_.Title).mp3" } | Out-File -Append playlist.m3u
```

---

## Helpful functions (add to your profile or a module) 🧰
```powershell
function Get-SongsByKey { param([string]$Key) Import-Csv $csv | Where-Object { $_.Key -eq $Key } }

function Get-Albums { param([string]$Artist) 
    if ($Artist) { Import-Csv $csv | Where-Object { $_.Artist -match $Artist } | Select-Object -ExpandProperty Album | Sort-Object -Unique } 
    else { Import-Csv $csv | Select-Object -ExpandProperty Album | Sort-Object -Unique } }

function Export-SongsByKey { param([string]$Key, [string]$OutFile) 
    Import-Csv $csv | Where-Object { $_.Key -eq $Key } | Export-Csv -Path $OutFile -NoTypeInformation }
```

Usage:
```powershell
Get-SongsByKey -Key 'A' | Format-Table -AutoSize
Get-Albums -Artist 'Muddy' > Muddy_albums.txt
Export-SongsByKey -Key 'Bb' -OutFile '.\Bb_songs.csv'
```

---

## Advanced / performance tips ⚡
- Load the CSV once into $songs for repeated queries (avoids disk I/O).  Example: `$songs = Import-Csv $csv`
- For very large datasets, PowerShell 7 has streaming Where-Object/ForEach-Object enhancements. Consider `Import-Csv $csv | Where-Object { ... } | ...` and avoid materializing huge arrays if you only pipe to a file.
- Use `Out-GridView -PassThru` for interactive selection: `$songs | Out-GridView -PassThru`

---

## JSON: converting and querying
```powershell
# CSV -> JSON
Import-Csv $csv | ConvertTo-Json -Depth 5 > '.\songs.json'

# Query JSON
$data = Get-Content '.\songs.json' | ConvertFrom-Json
$data | Where-Object { $_.Key -eq 'A' }
```

---

## Useful one-liners
```powershell
# List unique albums containing "Live"
Import-Csv $csv | Where-Object { $_.Album -match 'Live' } | Select-Object -ExpandProperty Album | Sort-Object -Unique

# Titles in Key A sorted by Title
Import-Csv $csv | Where-Object Key -eq 'A' | Sort-Object Title | Select-Object Title,Artist

# Export top 10 artists by track count to CSV
Import-Csv $csv | Group-Object Artist | Sort-Object Count -Descending | Select-Object -First 10 | Export-Csv top10_artists.csv -NoTypeInformation
```

---

If you'd like, I can also:
- Add these helper functions as a PowerShell module (`.psm1`) in the workspace, or
- Add a short README with example workflows (filter → review → export).

Happy to proceed with either option — tell me which one you'd like next.