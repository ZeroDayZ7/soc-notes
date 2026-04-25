Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# POLSKIE ZNAKI
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Text.Encoding]::Default = [System.Text.Encoding]::UTF8
[System.Threading.Thread]::CurrentThread.CurrentCulture = "pl-PL"
[System.Threading.Thread]::CurrentThread.CurrentUICulture = "pl-PL"

# KOLORY (dark hacker theme)
$bgColor = [System.Drawing.Color]::FromArgb(18,18,18)
$accent = [System.Drawing.Color]::FromArgb(0,255,140)
$textColor = [System.Drawing.Color]::FromArgb(200,200,200)

# OKNO
$form = New-Object System.Windows.Forms.Form
$form.Text = "[SOC ALERT]"
$form.Size = New-Object System.Drawing.Size(520,360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackColor = $bgColor

# TYTUŁ
$title = New-Object System.Windows.Forms.Label
$title.Text = "SECURITY OPERATIONS CENTER"
$title.ForeColor = $accent
$title.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(20,10)
$title.Size = New-Object System.Drawing.Size(480,30)
$title.TextAlign = "MiddleCenter"
$form.Controls.Add($title)

# TEKST
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(30,50)
$label.Size = New-Object System.Drawing.Size(460,80)
$label.ForeColor = $textColor
$label.Text = "Wykryto brak nadzoru nad stacją roboczą.`nGenerowanie wiadomości e-mail do przełożonego:`n'Jutro stawiam pączki dla całego działu!'"
$label.Font = New-Object System.Drawing.Font("Consolas", 10)
$label.TextAlign = "MiddleCenter"
$form.Controls.Add($label)

# PROGRESS BAR (custom kolor)
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(60,140)
$progressBar.Size = New-Object System.Drawing.Size(400,25)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# PROCENT
$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Location = New-Object System.Drawing.Point(60,170)
$percentLabel.Size = New-Object System.Drawing.Size(400,25)
$percentLabel.ForeColor = $accent
$percentLabel.Text = "[INIT] 0%"
$percentLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($percentLabel)

# PRZYCISK UCIEKAJĄCY
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "ANULUJ"
$btn.Size = New-Object System.Drawing.Size(120,40)
$btn.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$btn.ForeColor = $accent
$btn.FlatStyle = "Flat"
$btn.Location = New-Object System.Drawing.Point(200,240)

$btn.Add_MouseEnter({
    $btn.Location = New-Object System.Drawing.Point(
        (Get-Random -Minimum 20 -Maximum 360),
        (Get-Random -Minimum 210 -Maximum 280)
    )
    $btn.Text = Get-Random @(
        "Za wolno...",
        "Brak dostępu",
        "Odmowa",
        "Nie tym razem",
        "Spróbuj ponownie"
    )
})

$form.Controls.Add($btn)

# TIMER
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 120

$timer.Add_Tick({
    if ($progressBar.Value -lt 100) {
        $progressBar.Value += 1
        $percentLabel.Text = "[TRANSMIT] $($progressBar.Value)%"
    }
    else {
        $timer.Stop()
        $percentLabel.Text = "[OK] Wysłano pomyślnie. Smacznego 🍩"
        $percentLabel.ForeColor = "Red"
        $btn.Visible = $false

        Start-Sleep 2
        $form.Close()
    }
})

# START
$timer.Start()
$form.ShowDialog()