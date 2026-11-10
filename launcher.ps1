# Ensure the required Windows desktop layout engines are loaded into memory cleanly
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

# =====================================================================
# CONFIGURATION & GLOBAL STATE
# =====================================================================
# Dynamically resolve the active operating system profile username
$CurrentUser = $env:USERNAME
$BaseDownloadsFolder = "C:\Users\$CurrentUser\Downloads"

# LOCAL SOURCE ASSETS: Ensure these files exist in your Downloads folder before running
$SourceImagePath = "C:\Users\$CurrentUser\Downloads\saturn_logo.png"
$LocalSourceExe  = "C:\Users\$CurrentUser\Downloads\saturn_source.exe"

# =====================================================================
# FILE CONVERSION ENGINE (PNG/JPG -> NATIVE ICO)
# =====================================================================
function Convert-ToIcon {
    param (
        [string]$InputPath,
        [string]$OutputPath
    )
    if (Test-Path $InputPath) {
        try {
            $bitmap = New-Object System.Drawing.Bitmap($InputPath)
            # Create a properly scaled square icon matrix from the source image
            $scaledBitmap = New-Object System.Drawing.Bitmap($bitmap, (New-Object System.Drawing.Size(128, 128)))
            $hIcon = $scaledBitmap.GetHicon()
            $icon = [System.Drawing.Icon]::FromHandle($hIcon)
            
            $fileStream = New-Object System.IO.FileStream($OutputPath, [System.IO.FileMode]::Create)
            $icon.Save($fileStream)
            
            $fileStream.Close()
            $icon.Dispose()
            $scaledBitmap.Dispose()
            $bitmap.Dispose()
        }
        catch {
            # Silent fallback if the GDI+ subsystem fails to write out the data stream
        }
    }
}

# =====================================================================
# INTERFACE CONSTRUCTION (.NET NATIVE WINDOW CONTAINER)
# =====================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SATURN PROTOCOLS'
$form.Size = New-Object System.Drawing.Size(420, 350) 
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 11, 11, 16)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Brand Text Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "SATURN ENGINE CONTROL"
$title.Font = New-Object System.Drawing.Font('Consolas', 14, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(255, 226, 226, 229)
$title.Location = New-Object System.Drawing.Point(30, 25)
$title.AutoSize = $true
$form.Controls.Add($title)

# Description Text Label
$desc = New-Object System.Windows.Forms.Label
$desc.Text = "Press launch to deploy the application workspace."
$desc.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$desc.ForeColor = [System.Drawing.Color]::FromArgb(255, 136, 136, 153)
$desc.Location = New-Object System.Drawing.Point(30, 60)
$desc.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($desc)

# Button 1: Enforce Folder Build, Convert Icon, Verify Assets, and Execute
$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "LAUNCH WORKSPACE"
$btnDownload.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnDownload.Size = New-Object System.Drawing.Size(345, 45)
$btnDownload.Location = New-Object System.Drawing.Point(30, 100)
$btnDownload.BackColor = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)
$btnDownload.ForeColor = [System.Drawing.Color]::FromArgb(255, 52, 199, 89)
$btnDownload.FlatStyle = 'Flat'
$btnDownload.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 52, 199, 89)
$btnDownload.Add_Click({
    $btnDownload.Enabled = $false
    $btnDownload.Text = "INITIALIZING..."
    $form.Refresh()

    try {
        # Check for necessary source file before doing anything
        if (-not (Test-Path $LocalSourceExe)) {
            $desc.Text = "Error: Place 'saturn_source.exe' in Downloads first."
            $desc.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 59, 48)
            throw "Missing Source Exe"
        }

        # Generate the paths INSIDE the click action block so it executes sequentially
        $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $NewFolderName = "SaturnWorkspace_$Timestamp"
        $TargetFolder = Join-Path -Path $BaseDownloadsFolder -ChildPath $NewFolderName

        $PsiphonPath  = Join-Path -Path $TargetFolder -ChildPath "saturn.exe"
        $IconPath     = Join-Path -Path $TargetFolder -ChildPath "favicon.ico"
        $ShortcutPath = "C:\Users\$CurrentUser\Desktop\Saturn Tool ($Timestamp).lnk"

        # 1. FORCED ARCHITECTURE: Explicitly make the fresh timestamped directory first
        if (-not (Test-Path $TargetFolder)) {
            New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        }

        # Update UI text to show successful workspace staging
        $desc.Text = "Workspace: Downloads\$NewFolderName\"
        $desc.ForeColor = [System.Drawing.Color]::FromArgb(255, 136, 136, 153)
        $form.Refresh()

        # 2. Convert and save the custom icon asset directly inside the new folder
        if (Test-Path $SourceImagePath) {
            Convert-ToIcon -InputPath $SourceImagePath -OutputPath $IconPath
        }

        # 3. Local deployment step (Replaces the broken 404 remote download link)
        if (-not (Test-Path $PsiphonPath)) {
            Copy-Item -Path $LocalSourceExe -Destination $PsiphonPath -Force
        }

        # 4. Create the final themed Desktop Shortcut pointing to the isolated files
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $PsiphonPath
        $Shortcut.WorkingDirectory = $TargetFolder
        $Shortcut.Description = "Saturn Desktop Client"
        
        if (Test-Path $IconPath) {
            $Shortcut.IconLocation = $IconPath
        }
        $Shortcut.Save()

        $btnDownload.Text = "LAUNCHING APPLICATION..."
        $form.Refresh()
        Start-Sleep -Seconds 1

        # 5. Auto-Launch the executable cleanly from the new workspace directory
        Start-Process -FilePath $PsiphonPath -WorkingDirectory $TargetFolder

        $btnDownload.Text = "DEPLOYMENT COMPLETE"
        $btnDownload.Enabled = $true
    }
    catch {
        $btnDownload.Text = "LAUNCH FAILED"
        $btnDownload.Enabled = $true
    }
})
$form.Controls.Add($btnDownload)

# Button 2: Close
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "CLOSE INTERFACE"
$btnExit.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnExit.Size = New-Object System.Drawing.Size(345, 45)
$btnExit.Location = New-Object System.Drawing.Point(30, 160)
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)
$btnExit.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 59, 48)
$btnExit.FlatStyle = 'Flat'
$btnExit.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 59, 48)
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# Signature Developer Label Placed safely inside the window bounds
$signature = New-Object System.Windows.Forms.Label
$signature.Text = "Made by Envzy_ on discord, Contact for support"
$signature.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Italic)
$signature.ForeColor = [System.Drawing.Color]::FromArgb(255, 110, 110, 125)
$signature.Location = New-Object System.Drawing.Point(30, 240)
$signature.Size = New-Object System.Drawing.Size(345, 20)
$signature.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($signature)

# Show the GUI interface box natively
[void]$form.ShowDialog()
