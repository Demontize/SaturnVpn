# Load the desktop window rendering dependencies into the active memory segment cleanly
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

# =====================================================================
# GLOBAL INTERFACE GEOMETRY & COLOR PALETTE (SATURN THEMED)
# =====================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SATURN CONTROL CENTER'
$form.Size = New-Object System.Drawing.Size(460, 420) 
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 9, 9, 12)       # Ultra-dark abyssal background
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Accent Color Resources
$ColorPrimaryText = [System.Drawing.Color]::FromArgb(255, 240, 240, 245)
$ColorMutedText   = [System.Drawing.Color]::FromArgb(255, 120, 120, 135)
$ColorSaturnNeon  = [System.Drawing.Color]::FromArgb(255, 191, 64, 255)   # Signature Saturn Violet/Purple
$ColorBorderDark  = [System.Drawing.Color]::FromArgb(255, 24, 24, 35)
$ColorStatusGreen = [System.Drawing.Color]::FromArgb(255, 52, 199, 89)

# =====================================================================
# INTERFACE LABELS & TYPOGRAPHY
# =====================================================================
# Top Accent Line Decor
$accentLine = New-Object System.Windows.Forms.Label
$accentLine.Location = New-Object System.Drawing.Point(0, 0)
$accentLine.Size = New-Object System.Drawing.Size(460, 4)
$accentLine.BackColor = $ColorSaturnNeon
$form.Controls.Add($accentLine)

# Brand Title Text
$title = New-Object System.Windows.Forms.Label
$title.Text = "SATURN ENGINE"
$title.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = $ColorPrimaryText
$title.Location = New-Object System.Drawing.Point(35, 30)
$title.AutoSize = $true
$form.Controls.Add($title)

# Active Sub-status Notification Text
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "READY TO INITIALIZE DEPLOYMENT"
$statusLabel.Font = New-Object System.Drawing.Font('Consolas', 9, [System.Drawing.FontStyle]::Bold)
$statusLabel.ForeColor = $ColorMutedText
$statusLabel.Location = New-Object System.Drawing.Point(36, 70)
$statusLabel.Size = New-Object System.Drawing.Size(375, 20)
$form.Controls.Add($statusLabel)

# =====================================================================
# INTERACTIVE CONTROL ELEMENTS
# =====================================================================
# Animated Progress Loader Bar (Configured for standard continuous fluid motion)
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(38, 110)
$progressBar.Size = New-Object System.Drawing.Size(370, 6)
$progressBar.Style = 'Marquee'
$progressBar.MarqueeAnimationSpeed = 0 # Stays locked completely invisible until button execution begins
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# Action Control Button
$btnLaunch = New-Object System.Windows.Forms.Button
$btnLaunch.Text = "INITIALIZE CLIENT"
$btnLaunch.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$btnLaunch.Size = New-Object System.Drawing.Size(370, 50)
$btnLaunch.Location = New-Object System.Drawing.Point(38, 145)
$btnLaunch.BackColor = [System.Drawing.Color]::FromArgb(255, 14, 14, 22)
$btnLaunch.ForeColor = $ColorSaturnNeon
$btnLaunch.FlatStyle = 'Flat'
$btnLaunch.FlatAppearance.BorderSize = 1
$btnLaunch.FlatAppearance.BorderColor = $ColorSaturnNeon
$btnLaunch.Cursor = [System.Windows.Forms.Cursors]::Hand

$btnLaunch.Add_Click({
    # Swap control states immediately to lock user input during rendering
    $btnLaunch.Enabled = $false
    $progressBar.Visible = $true
    $progressBar.Style = 'Marquee'
    $progressBar.MarqueeAnimationSpeed = 30 # Triggers responsive continuous flow animation
    
    # Sequential Mock Render Engine Sequence
    try {
        $statusLabel.Text = "ESTABLISHING CORE HANDSHAKE..."
        $statusLabel.ForeColor = $ColorSaturnNeon
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 900

        $statusLabel.Text = "RESOLVING LOCAL ENVIRONMENT CONFIGURATION..."
        $statusLabel.ForeColor = $ColorPrimaryText
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 900

        $statusLabel.Text = "SYNC COMPLETE. DEPLOYING WORKSPACE COMPONENTS..."
        $statusLabel.ForeColor = $ColorStatusGreen
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 600

        # Reset button status to clear completion indicator
        $progressBar.Visible = $false
        $progressBar.MarqueeAnimationSpeed = 0
        $btnLaunch.Text = "DEPLOYMENT COMPLETE"
        $btnLaunch.FlatAppearance.BorderColor = $ColorStatusGreen
        $btnLaunch.ForeColor = $ColorStatusGreen
    }
    catch {
        $progressBar.Visible = $false
        $statusLabel.Text = "CRITICAL ARCHITECTURE EXCEPTION DETECTION"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
        $btnLaunch.Text = "RETRY INITIALIZATION"
        $btnLaunch.Enabled = $true
    }
})
$form.Controls.Add($btnLaunch)

# Close Window Exit Button
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "TERMINATE INTERFACE"
$btnExit.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$btnExit.Size = New-Object System.Drawing.Size(370, 45)
$btnExit.Location = New-Object System.Drawing.Point(38, 215)
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(255, 14, 14, 22)
$btnExit.ForeColor = $ColorMutedText
$btnExit.FlatStyle = 'Flat'
$btnExit.FlatAppearance.BorderSize = 1
$btnExit.FlatAppearance.BorderColor = $ColorBorderDark

$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# Developer Footer Reference Label
$footer = New-Object System.Windows.Forms.Label
$footer.Text = "CONNECTION PORT: ACTIVE // SECURE SYSTEM CORE"
$footer.Font = New-Object System.Drawing.Font('Consolas', 8)
$footer.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60, 75)
$footer.Location = New-Object System.Drawing.Point(38, 310)
$footer.Size = New-Object System.Drawing.Size(370, 25)
$footer.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($footer)

# Execute and launch the dialog screen wrapper natively inside memory
[void]$form.ShowDialog()
