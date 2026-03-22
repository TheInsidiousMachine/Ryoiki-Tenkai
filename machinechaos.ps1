# 1. THE STEALTH RELAUNCH: Kills the visible window immediately
if ($args -notcontains "-Invisible") {
    $arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Invisible"
    Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 2. Setup Paths
$scriptDir = $PSScriptRoot
$gifPath = Join-Path -Path $scriptDir -ChildPath "machine.gif"
$audioPath = Join-Path -Path $scriptDir -ChildPath "gifmachine.wav"
$totalDuration = 22.465

# 3. Pre-Load Assets
$img = [System.Drawing.Image]::FromFile($gifPath)
$dimension = New-Object System.Drawing.Imaging.FrameDimension($img.FrameDimensionsList[0])
$frameCount = $img.GetFrameCount($dimension)
$sound = New-Object System.Media.SoundPlayer($audioPath)
$sound.Load()

# 4. Create the Overlay Form
$form = New-Object Windows.Forms.Form
$form.FormBorderStyle = "None"
$form.WindowState = "Maximized"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.BackColor = [System.Drawing.Color]::Black
$form.TransparencyKey = [System.Drawing.Color]::Black

$picBox = New-Object Windows.Forms.PictureBox
$picBox.Dock = "Fill"
$picBox.SizeMode = "Zoom"
$picBox.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($picBox)

# 5. Phase 1: The Incantation (24fps + 0.25s Audio Sync)
$form.Show()
$globalStartTime = Get-Date
$currentFrame = 0
$audioStarted = $false

while ((New-TimeSpan -Start $globalStartTime -End (Get-Date)).TotalSeconds -lt 6) {
    $frameStart = Get-Date
    if ((New-TimeSpan -Start $globalStartTime -End (Get-Date)).TotalSeconds -ge 0.25 -and !$audioStarted) {
        $sound.Play()
        $audioStarted = $true
        $audioStartTime = Get-Date
    }
    $null = $img.SelectActiveFrame($dimension, $currentFrame)
    $picBox.Image = [System.Drawing.Bitmap]::new($img)
    $currentFrame = ($currentFrame + 1) % $frameCount
    [System.Windows.Forms.Application]::DoEvents()
    $elapsed = (New-TimeSpan -Start $frameStart -End (Get-Date)).TotalMilliseconds
    if ($elapsed -lt 41) { Start-Sleep -Milliseconds (41 - $elapsed) }
}
$form.Close()

# 6. Phase 2: Domain Expansion (High-Response Chaos)
try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "ms-settings:display"
    $psi.WindowStyle = "Hidden"
    $psi.CreateNoWindow = $true
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    
    $shell = New-Object -ComObject WScript.Shell
    Add-Type -AssemblyName UIAutomationClient
    
    $orientations = @("Landscape (flipped)", "Portrait", "Portrait (flipped)")
    $j = 0
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

    while ((New-TimeSpan -Start $audioStartTime -End (Get-Date)).TotalSeconds -lt ($totalDuration - 1.5)) {
        # Mouse Chaos runs constantly
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((Get-Random -Max $screen.Width), (Get-Random -Max $screen.Height))
        
        $target = $orientations[($j % 3)]
        $shell.AppActivate("Settings")
        
        # HIGH-SPEED POLLING: No more 1200ms flat delay
        $settings = $null
        $settings = [Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Children, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "Settings")))
        
        if ($settings) {
            $combo = $settings.FindFirst([Windows.Automation.TreeScope]::Descendants, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::AutomationIdProperty, "SystemSettings_Display_Orientation_ComboBox")))
            if ($combo) {
                try {
                    $combo.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
                    Start-Sleep -Milliseconds 50 # Snappier expansion
                    $item = $combo.FindFirst([Windows.Automation.TreeScope]::Descendants, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, $target)))
                    if ($item) {
                        $item.GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
                        Start-Sleep -Milliseconds 250 # Faster confirmation
                        $shell.SendKeys("{ENTER} ")
                    }
                } catch { Start-Sleep -Milliseconds 50 } # Catch race conditions and retry immediately
            }
        } else {
            Start-Sleep -Milliseconds 50 # Wait just a tiny bit if window isn't up yet
        }
        $j++
    }

    # Restoration Phase
    $shell.AppActivate("Settings")
    $finalSettings = [Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Children, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "Settings")))
    if ($finalSettings) {
        $finalCombo = $finalSettings.FindFirst([Windows.Automation.TreeScope]::Descendants, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::AutomationIdProperty, "SystemSettings_Display_Orientation_ComboBox")))
        if ($finalCombo) {
            $finalCombo.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
            Start-Sleep -Milliseconds 100
            $land = $finalCombo.FindFirst([Windows.Automation.TreeScope]::Descendants, (New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "Landscape")))
            if ($land) {
                $land.GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
                Start-Sleep -Milliseconds 300
                $shell.SendKeys("{ENTER} ")
            }
        }
    }

    while ((New-TimeSpan -Start $audioStartTime -End (Get-Date)).TotalSeconds -lt $totalDuration) {
        Start-Sleep -Milliseconds 10
    }
}
finally {
    Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
    $sound.Stop()
}