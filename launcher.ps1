# Ensure the required Windows desktop layout engines are loaded into memory cleanly
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

# =====================================================================
# CONFIGURATION & GLOBAL STATE
# =====================================================================
# 1. Dynamically resolve the active operating system profile username
$CurrentUser = $env:USERNAME
$BaseDownloadsFolder = "C:\Users\$CurrentUser\Downloads"

# 2. FIX: Generate a unique timestamped name to guarantee a NEW folder is built every run
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$NewFolderName = "SaturnVPN_$Timestamp"

# 3. Target the newly calculated directory explicitly
$TargetFolder = Join-Path -Path $BaseDownloadsFolder -ChildPath $NewFolderName

# Internal file output locations within the fresh sandbox directory
$PsiphonPath  = Join-Path -Path $TargetFolder -ChildPath "saturn.exe"
$IconPath     = Join-Path -Path $TargetFolder -ChildPath "favicon.ico"
$ShortcutPath = "C:\Users\$CurrentUser\Desktop\Saturn VPN ($Timestamp).lnk"

# CHANGE THIS: Set this to the exact location where you saved your uploaded Saturn logo image
$SourceImagePath = "C:\Users\$CurrentUser\Downloads\saturn_logo.png"

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
$form.Size = New-Object System.Drawing.Size(420, 280)
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
$desc.Text = "Generating unique target directory inside Downloads..."
$desc.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$desc.ForeColor = [System.Drawing.Color]::FromArgb(255, 136, 136, 153)
$desc.Location = New-Object System.Drawing.Point(30, 60)
$desc.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($desc)

# Button 1: Enforce Folder Build, Convert Icon, and Download Payload
$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "DOWNLOAD PROXY"
$btnDownload.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnDownload.Size = New-Object System.Drawing.Size(345, 45)
$btnDownload.Location = New-Object System.Drawing.Point(30, 100)
$btnDownload.BackColor = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)
$btnDownload.ForeColor = [System.Drawing.Color]::FromArgb(255, 52, 199, 89)
$btnDownload.FlatStyle = 'Flat'
$btnDownload.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 52, 199, 89)
$btnDownload.Add_Click({
    $btnDownload.Enabled = $false
    $btnDownload.Text = "DOWNLOADING..."
    $form.Refresh()

    try {
        # 1. FORCED ARCHITECTURE: Enforce the creation of the NEW timestamped directory first
        if (-not (Test-Path $TargetFolder)) {
            New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        }

        # Update description text to show the exact new folder path created
        $desc.Text = "Saved to: Downloads\$NewFolderName\"
        $form.Refresh()

        # 2. Convert and place the custom icon asset directly inside the newly made folder
        Convert-ToIcon -InputPath $SourceImagePath -OutputPath $IconPath

        # 3. Establish TLS handshake protocols and download the binary payload to the new target
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        
        if (-not (Test-Path $PsiphonPath)) {
            # Bypasses string-matching firewalls by pulling from an obfuscated string targeting the AWS mirror infrastructure
            $B64_Endpoint = "aHR0cHM6Ly9zMy5hbWF6b25hd3MuY29tLzB1YnotMnExMS1naTl5L3BzaXBob24zLmV4ZQ=="
            $URL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($B64_Endpoint))
            Invoke-RestMethod -Uri $URL -OutFile $PsiphonPath
        }

        # 4. Create the final themed Desktop Shortcut using the new folder's specific icon asset
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $PsiphonPath
        $Shortcut.WorkingDirectory = $TargetFolder
        $Shortcut.Description = "Saturn VPN Desktop Client"
        
        if (Test-Path $IconPath) {
            $Shortcut.IconLocation = $IconPath
        }
        $Shortcut.Save()

        $btnDownload.Text = "DEPLOYMENT COMPLETE"
    }
    catch {
        $btnDownload.Text = "ERROR / TRY AGAIN"
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

# Show the GUI interface box natively
[void]$form.ShowDialog()
