<#
.SYNOPSIS
Helper commands for querying `songs.csv` (songcollection) from PowerShell.
.DESCRIPTION
Lightweight module that provides common queries and export helpers for the songs CSV.
#>

$ModuleVersion = '0.1.0'

function Get-Songs {
    [CmdletBinding()]
    param(
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    if (-not (Test-Path $CsvPath)) {
        Throw "CSV not found: $CsvPath"
    }
    Import-Csv -Path $CsvPath
}

function Get-SongsByKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Key,
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    Get-Songs -CsvPath $CsvPath | Where-Object { $_.Key -ieq $Key }
}

function Get-Albums {
    [CmdletBinding()]
    param(
        [string]$Artist,
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    $q = Get-Songs -CsvPath $CsvPath
    if ($Artist) { $q = $q | Where-Object { $_.Artist -match $Artist } }
    $q | Select-Object -ExpandProperty Album | Sort-Object -Unique
}

function Export-SongsByKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Key,
        [Parameter(Mandatory=$true, Position=1)] [string]$OutFile,
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    Get-Songs -CsvPath $CsvPath | Where-Object { $_.Key -ieq $Key } | Export-Csv -Path $OutFile -NoTypeInformation
}

function Get-TopArtists {
    [CmdletBinding()]
    param(
        [int]$Top = 10,
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    Get-Songs -CsvPath $CsvPath | Group-Object Artist | Sort-Object Count -Descending | Select-Object -First $Top
}

function Find-Songs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string]$Query,
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
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
        [string]$CsvPath = "$env:USERPROFILE\Documents\testplace\songs.csv"
    )
    Get-Songs -CsvPath $CsvPath | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutFile -Encoding utf8
}

Export-ModuleMember -Function * -Alias *
