<#
.SYNOPSIS
    Assetto Corsa skin folder name fixer.

.DESCRIPTION
    Replaces all non-alphanumeric characters in Assetto Corsa skin folder names
    with underscores (_). Consecutive underscores are collapsed and leading/trailing
    underscores are trimmed.

.PARAMETER Execute
    Actually rename folders. Without this flag the script only shows a preview.

.PARAMETER AutoSuffix
    When a naming collision occurs, append _1, _2, ... to make the name unique.

.PARAMETER OverlapDel
    When a naming collision occurs, delete the original folder instead of renaming.

.PARAMETER Help
    Show usage information.

.NOTES
    -AutoSuffix and -OverlapDel are mutually exclusive.
#>

param(
    [switch]$Execute,
    [switch]$AutoSuffix,
    [switch]$OverlapDel,
    [switch]$Help
)

# ─── Help ────────────────────────────────────────────────────────────────────

if ($Help) {
    Write-Host "`n========== Usage ==========" -ForegroundColor Cyan
    Write-Host "
.\rename_skins.ps1 [options]

Description:
    Replaces all non-alphanumeric characters in Assetto Corsa skin folder names
    with underscores (_).

Options:
    -Execute      Run the actual rename (omit for dry-run preview)
    -AutoSuffix   Append _1, _2, ... on name collision
    -OverlapDel   Delete the original folder on name collision
    -Help         Show this help message

Examples:
    .\rename_skins.ps1                       Dry-run preview
    .\rename_skins.ps1 -Execute              Execute (skip collisions)
    .\rename_skins.ps1 -AutoSuffix           Preview with suffix numbering
    .\rename_skins.ps1 -Execute -AutoSuffix  Execute with suffix numbering
    .\rename_skins.ps1 -Execute -OverlapDel  Execute and delete collisions

Note:
    -AutoSuffix and -OverlapDel cannot be used together.
" -ForegroundColor White
    exit
}

# ─── Validation ──────────────────────────────────────────────────────────────

if ($AutoSuffix -and $OverlapDel) {
    Write-Host "Error: -AutoSuffix and -OverlapDel cannot be used together." -ForegroundColor Red
    exit 1
}

# ─── Configuration ───────────────────────────────────────────────────────────

$basePath = "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars"

if (-not (Test-Path $basePath)) {
    Write-Host "Path not found: $basePath" -ForegroundColor Red
    exit 1
}

# ─── Collect skin folders ────────────────────────────────────────────────────

$skinFolders = Get-ChildItem -Path $basePath -Directory | ForEach-Object {
    $skinsPath = Join-Path $_.FullName "skins"
    if (Test-Path $skinsPath) {
        Get-ChildItem -Path $skinsPath -Directory
    }
}

# ─── Classify each folder ───────────────────────────────────────────────────

$toRename = @()
$skipped  = @()
$suffixed = @()
$toDelete = @()

foreach ($folder in $skinFolders) {
    # Sanitize: keep only a-z, A-Z, 0-9 -> replace rest with _, collapse, trim
    $newName = $folder.Name -replace '[^a-zA-Z0-9]', '_'
    $newName = $newName -replace '_+', '_'
    $newName = $newName.Trim('_')

    if ($folder.Name -eq $newName) { continue }

    $newPath  = Join-Path $folder.Parent.FullName $newName
    $carName  = Split-Path (Split-Path $folder.FullName -Parent) -Leaf

    if (Test-Path $newPath) {
        if ($AutoSuffix) {
            $counter  = 1
            $baseName = $newName
            while (Test-Path (Join-Path $folder.Parent.FullName $newName)) {
                $newName = "${baseName}_${counter}"
                $counter++
            }
            $suffixed += [PSCustomObject]@{
                Car          = $carName
                Original     = $folder.Name
                New          = $newName
                FullPath     = $folder.FullName
                ConflictWith = $baseName
            }
        }
        elseif ($OverlapDel) {
            $toDelete += [PSCustomObject]@{
                Car          = $carName
                Original     = $folder.Name
                New          = $newName
                FullPath     = $folder.FullName
                ExistingPath = $newPath
            }
        }
        else {
            $skipped += [PSCustomObject]@{
                Car      = $carName
                Original = $folder.Name
                New      = $newName
                FullPath = $folder.FullName
            }
        }
    }
    else {
        $toRename += [PSCustomObject]@{
            Car      = $carName
            Original = $folder.Name
            New      = $newName
            FullPath = $folder.FullName
        }
    }
}

# ─── Preview ─────────────────────────────────────────────────────────────────

Write-Host "`n========== Preview ==========" -ForegroundColor Cyan

if ($toRename.Count -gt 0) {
    Write-Host "`n[To rename: $($toRename.Count)]" -ForegroundColor Green
    $toRename | Format-Table -Property Car, Original, New -AutoSize
}

if ($suffixed.Count -gt 0) {
    Write-Host "[Suffixed to resolve collision: $($suffixed.Count)]" -ForegroundColor Magenta
    foreach ($item in $suffixed) {
        Write-Host "  $($item.FullPath)" -ForegroundColor Gray
        Write-Host "    -> $($item.New) (existing: $($item.ConflictWith))" -ForegroundColor Magenta
    }
}

if ($toDelete.Count -gt 0) {
    Write-Host "`n[To delete (collision): $($toDelete.Count)]" -ForegroundColor Red
    foreach ($item in $toDelete) {
        Write-Host "  $($item.FullPath)" -ForegroundColor Gray
        Write-Host "    deleted (keeping existing: $($item.New))" -ForegroundColor Red
    }
}

if ($skipped.Count -gt 0) {
    Write-Host "`n[Skipped (collision): $($skipped.Count)]" -ForegroundColor Yellow
    foreach ($item in $skipped) {
        Write-Host "  $($item.FullPath)" -ForegroundColor Gray
        Write-Host "    -> $($item.New) (already exists)" -ForegroundColor DarkYellow
    }
    Write-Host "`n  TIP: use -AutoSuffix or -OverlapDel to handle collisions" -ForegroundColor DarkCyan
}

if ($toRename.Count -eq 0 -and $suffixed.Count -eq 0 -and $skipped.Count -eq 0 -and $toDelete.Count -eq 0) {
    Write-Host "`nNothing to rename." -ForegroundColor Yellow
}

# ─── Execute ─────────────────────────────────────────────────────────────────

if ($Execute) {
    Write-Host "`n========== Executing ==========" -ForegroundColor Magenta
    $renamedCount = 0
    $deletedCount = 0

    # Rename
    foreach ($item in ($toRename + $suffixed)) {
        try {
            Rename-Item -Path $item.FullPath -NewName $item.New -ErrorAction Stop
            Write-Host "[OK]   $($item.Car): $($item.Original) -> $($item.New)" -ForegroundColor Green
            $renamedCount++
        }
        catch {
            Write-Host "[FAIL] $($item.Car): $($item.Original) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Delete collisions
    foreach ($item in $toDelete) {
        try {
            Remove-Item -Path $item.FullPath -Recurse -Force -ErrorAction Stop
            Write-Host "[DEL]  $($item.Car): $($item.Original) deleted" -ForegroundColor Yellow
            $deletedCount++
        }
        catch {
            Write-Host "[FAIL] $($item.Car): $($item.Original) delete failed - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nDone: $renamedCount renamed, $deletedCount deleted" -ForegroundColor Cyan
}
else {
    Write-Host "`n* Dry-run only. To apply: .\rename_skins.ps1 -Execute [-AutoSuffix | -OverlapDel]" -ForegroundColor Yellow
    Write-Host "* Help: .\rename_skins.ps1 -Help" -ForegroundColor Yellow
}
