# SongTools PowerShell module

Small module with helpers for querying `songs.csv` created from your `songcollection` file.

Installation (manual):
- Copy the `SongTools` folder into one of your module paths, e.g.:
  - `%UserProfile%\Documents\WindowsPowerShell\Modules\SongTools\` (Windows PowerShell)
  - `%UserProfile%\Documents\PowerShell\Modules\SongTools\` (PowerShell Core)

Usage examples:
```powershell
Import-Module SongTools
Get-SongsByKey -Key 'A' | Format-Table -AutoSize
Get-Albums -Artist 'Muddy' | Out-File Muddy_albums.txt
Export-SongsByKey -Key 'Bb' -OutFile .\Bb_songs.csv
Get-TopArtists -Top 20
Find-Songs -Query 'Live' | Select-Object -First 20
Convert-SongsToJson -OutFile .\songs.json
```

If you want I can copy/install the module into your module paths and import it automatically.