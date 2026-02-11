# Assetto Corsa Skin Folder Name Fixer

[한국어](README_KR.md)

PowerShell script that sanitizes Assetto Corsa skin folder names by replacing all non-alphanumeric characters with underscores (`_`).

## Why?

Some Assetto Corsa mods ship with skin folder names containing special characters (spaces, unicode, symbols, etc.) that can cause issues with Content Manager, online servers, or other tools. This script normalizes all skin folder names to safe `[a-zA-Z0-9_]` patterns.

## Requirements

- Windows with PowerShell 5.1+
- Assetto Corsa installed via Steam (default path)

## Execution Policy (Important! One-time setup)

Windows blocks PowerShell script (`.ps1`) execution by default.
When you try to run the script for the first time, you will see a **red error** like this:

```
.\rename_skins.ps1 : File ... cannot be loaded because running scripts is disabled on this system.
```

If you see this error, follow **one of the methods** below.

---

### Method 1: Permanent (Recommended - do it once and forget!)

After this setup, you can freely run any PowerShell script on your PC.

**Step 1:** Press the `Windows key` on your keyboard and type **"PowerShell"**.

**Step 2:** In the search results, find **"Windows PowerShell"**, **right-click** it, and select **"Run as administrator"**.

**Step 3:** A popup will ask "Do you want to allow this app to make changes to your device?" — click **"Yes"**.

**Step 4:** A blue PowerShell window will open. Copy and paste the command below **exactly as-is**, then press `Enter`:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Step 5:** You will see a confirmation prompt like this:

```
Execution Policy Change
The execution policy helps protect you from scripts that you do not trust. ...
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"):
```

Type **`Y`** and press `Enter`.

**Step 6:** If the cursor moves to the next line with no error message, **it worked!** You can close the PowerShell window.

> From now on, you can run `.ps1` scripts freely. This setup only needs to be done once.

---

### Method 2: One-time only (Temporary)

Use this if you don't want to change any settings and just want to run the script **once**.

Open PowerShell (no administrator required) and copy-paste the following command, then press `Enter`:

```powershell
powershell -ExecutionPolicy Bypass -File .\rename_skins.ps1
```

> This method does not change any PC settings. However, you need to type this long command every time you want to run the script.

---

### Comparison

| Method | Pros | Cons |
|---|---|---|
| **Method 1** (Permanent) | Set once, then just type `.\rename_skins.ps1` | Requires admin, changes PC setting |
| **Method 2** (Temporary) | No setting changes, no admin needed | Must type the long command every time |

---

### Verify the setup

After setup, you can check that it worked by running:

```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

If the result shows `RemoteSigned` or `Bypass`, you're good to go.
If it shows `Restricted`, the setup didn't work — try the steps above again.

## Usage

```powershell
# Dry-run preview (no changes made)
.\rename_skins.ps1

# Execute the rename
.\rename_skins.ps1 -Execute

# Handle name collisions with auto-numbering (_1, _2, ...)
.\rename_skins.ps1 -Execute -AutoSuffix

# Handle name collisions by deleting the original folder
.\rename_skins.ps1 -Execute -OverlapDel

# Show help
.\rename_skins.ps1 -Help
```

## Options

| Option | Description |
|---|---|
| `-Execute` | Actually rename folders. Without this flag the script only shows a preview. |
| `-AutoSuffix` | Append `_1`, `_2`, ... when a naming collision occurs. |
| `-OverlapDel` | Delete the original folder when a naming collision occurs. |
| `-Help` | Show usage information. |

> `-AutoSuffix` and `-OverlapDel` are mutually exclusive.

## How It Works

1. Scans all `skins/` subdirectories under each car in the Assetto Corsa `content/cars` folder.
2. For each skin folder, replaces non-alphanumeric characters with `_`, collapses consecutive underscores, and trims leading/trailing underscores.
3. Skips folders that already have clean names.
4. Handles naming collisions based on the chosen option.

## Default Path

```
C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars
```

## License

See [LICENSE](LICENSE).
