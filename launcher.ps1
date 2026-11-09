# Ensure the required Windows desktop layout engines are loaded into memory cleanly
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

# =====================================================================
# CONFIGURATION & GLOBAL STATE
# =====================================================================
$PsiphonPath = "$env:TEMP\psiphon3.exe"

# Pre-session sanitation check: Ensure a clean slate
if (Test-Path $PsiphonPath) { Remove-Item -Force $PsiphonPath -ErrorAction SilentlyContinue }

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
$desc.Text = "Deploy or terminate the network proxy module."
$desc.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$desc.ForeColor = [System.Drawing.Color]::FromArgb(255, 136, 136, 153)
$desc.Location = New-Object System.Drawing.Point(30, 60)
$desc.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($desc)

# Button 1: Download & Run Core Bypass
$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "DEPLOY PROXY"
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

    # FIX: Uses an independent asynchronous process task string to prevent main UI window freeze
    $DownloadCommand = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13; if (-not (Test-Path '$PsiphonPath')) { Invoke-RestMethod -Uri 'https://psiphon3.com' -OutFile '$PsiphonPath' }; Start-Process -FilePath '$PsiphonPath'"
    
    # Encodes and offloads the execution thread context completely to a hidden background executor instance
    $EncodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($DownloadCommand))
    Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden", "-EncodedCommand", $EncodedCommand

    $btnDownload.Text = "DEPLOYED"
})
$form.Controls.Add($btnDownload)

# Button 2: Exit & Automatic Secure Clean Wipe
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "EXIT SYSTEM"
$btnExit.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnExit.Size = New-Object System.Drawing.Size(345, 45)
$btnExit.Location = New-Object System.Drawing.Point(30, 160)
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(255, 20, 20, 25)
$btnExit.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 59, 48)
$btnExit.FlatStyle = 'Flat'
$btnExit.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 255, 59, 48)
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# Show the GUI interface box to the user natively
[void]$form.ShowDialog()

# =====================================================================
# CLEANUP SHUTDOWN ROUTINE (TRIGGERS IMMEDIATELY ON WINDOW CLOSE)
# =====================================================================
Stop-Process -Name "psiphon3" -Force -ErrorAction SilentlyContinue
if (Test-Path $PsiphonPath) {
    Remove-Item -Force $PsiphonPath -ErrorAction SilentlyContinue
}
