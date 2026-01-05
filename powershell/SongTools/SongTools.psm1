<#
.SYNOPSIS
Helper commands for querying `songs.csv` (songcollection) from PowerShell.
.DESCRIPTION
Lightweight module that provides common queries and export helpers for the songs CSV.
#>

$ModuleVersion = '0.1.0'

function Get-DefaultCsvPath {
    # Prefer a workspace-level songs.csv when available. This checks locations in order:
    # 1) Two levels up from the module folder (common when module lives inside the repo)
    # 2) Current working directory
    # 3) Fallback to the original user Documents path
    try {
        $modCandidate = Resolve-Path -Path (Join-Path $PSScriptRoot '..\..\songs.csv') -ErrorAction SilentlyContinue
        if ($modCandidate) { return $modCandidate.Path }
    } catch { }

    try {
        $cwdCandidate = Resolve-Path -Path (Join-Path (Get-Location) 'songs.csv') -ErrorAction SilentlyContinue
        if ($cwdCandidate) { return $cwdCandidate.Path }
    } catch { }

    return (Join-Path $env:USERPROFILE 'Documents\testplace\songs.csv')
}

function Get-Songs { 
    [CmdletBinding()]
    param(
        [string]$CsvPath = $null
    )
    # Resolve default when not provided
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    if (-not (Test-Path $CsvPath)) {
        Throw "CSV not found: $CsvPath"
    }
    Import-Csv -Path $CsvPath
} 

function Get-SongsByKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Key,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    Get-Songs -CsvPath $CsvPath | Where-Object { $_.Key -ieq $Key }
}

function Get-Albums {
    [CmdletBinding()]
    param(
        [string]$Artist,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    $q = Get-Songs -CsvPath $CsvPath
    if ($Artist) { $q = $q | Where-Object { $_.Artist -match $Artist } }
    $q | Select-Object -ExpandProperty Album | Sort-Object -Unique
}

function Export-SongsByKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Key,
        [Parameter(Mandatory=$true, Position=1)] [string]$OutFile,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    Get-Songs -CsvPath $CsvPath | Where-Object { $_.Key -ieq $Key } | Export-Csv -Path $OutFile -NoTypeInformation
}

function Get-TopArtists {
    [CmdletBinding()]
    param(
        [int]$Top = 10,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    Get-Songs -CsvPath $CsvPath | Group-Object Artist | Sort-Object Count -Descending | Select-Object -First $Top
}

function Find-Songs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Query,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    $q = Get-Songs -CsvPath $CsvPath
    $regex = [regex]::Escape($Query)

    $q | Where-Object {
        ($_.Title -match $regex) -or ($_.Artist -match $regex) -or ($_.Album -match $regex)
    }
}

function Convert-SongsToJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$OutFile,
        [string]$CsvPath = $null
    )
    if (-not $CsvPath) { $CsvPath = Get-DefaultCsvPath }
    Get-Songs -CsvPath $CsvPath | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutFile -Encoding utf8
}

Export-ModuleMember -Function * -Alias *
