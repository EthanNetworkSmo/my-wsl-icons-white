# Christian Lempa Complete Windows Setup Script
# Configures Windows 11 with Christian Lempa's theme, tools, and settings
# Run as Administrator in PowerShell

#Requires -RunAsAdministrator

$ErrorActionPreference = "Continue"

# Configuration
$DOTFILES_REPO = "https://github.com/ChristianLempa/dotfiles.git"
$DOTFILES_COMMIT = "8dbebcfca2c4f1e067540c6ae33ac913668d452f"
$ICONS_REPO = "https://github.com/EthanNetworkSmo/my-wsl-icons-white.git"
$WALLPAPER_URL = "https://raw.githubusercontent.com/ChristianLempa/hackbox/main/src/assets/mr-robot-wallpaper.png"
$DOTFILES_DIR = "$env:USERPROFILE\.dotfiles"
$ICONS_DIR = "$env:USERPROFILE\.wsl-icons"

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Christian Lempa Windows Setup        ║" -ForegroundColor Cyan
Write-Host "║  Complete System Configuration        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan

function Print-Status {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Print-Info {
    param([string]$Message)
    Write-Host "[→] $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
}

function Print-Section {
    param([string]$Message)
    Write-Host "`n▶ $Message" -ForegroundColor Cyan
}

# Install Winget if not present
function Install-Winget {
    Print-Section "Checking Windows Package Manager (Winget)"
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Print-Status "Winget is already installed"
        return
    }
    
    Print-Info "Installing Winget..."
    $progressPreference = 'silentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile "$env:TEMP\winget.msixbundle"
    Add-AppxPackage "$env:TEMP\winget.msixbundle"
    Print-Status "Winget installed"
}

# Install Chocolatey
function Install-Chocolatey {
    Print-Section "Checking Chocolatey Package Manager"
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Print-Status "Chocolatey is already installed"
        return
    }
    
    Print-Info "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Print-Status "Chocolatey installed"
}

# Install Git
function Install-Git {
    Print-Section "Installing Git"
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Print-Status "Git is already installed"
        return
    }
    
    Print-Info "Installing Git..."
    winget install --id Git.Git -e --source winget --silent
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Print-Status "Git installed"
}

# Install Christian Lempa's essential tools
function Install-EssentialTools {
    Print-Section "Installing Christian Lempa's Essential Tools"
    
    $tools = @(
        @{Name="Windows Terminal"; Id="Microsoft.WindowsTerminal"},
        @{Name="PowerShell 7"; Id="Microsoft.PowerShell"},
        @{Name="VS Code"; Id="Microsoft.VisualStudioCode"},
        @{Name="Docker Desktop"; Id="Docker.DockerDesktop"},
        @{Name="Notepad++"; Id="Notepad++.Notepad++"},
        @{Name="7-Zip"; Id="7zip.7zip"},
        @{Name="Everything Search"; Id="voidtools.Everything"},
        @{Name="PuTTY"; Id="PuTTY.PuTTY"},
        @{Name="WinSCP"; Id="WinSCP.WinSCP"},
        @{Name="Google Chrome"; Id="Google.Chrome"},
        @{Name="VLC Media Player"; Id="VideoLAN.VLC"},
        @{Name="GitHub Desktop"; Id="GitHub.GitHubDesktop"},
        @{Name="Postman"; Id="Postman.Postman"},
        @{Name="Wireshark"; Id="WiresharkFoundation.Wireshark"},
        @{Name="Node.js LTS"; Id="OpenJS.NodeJS.LTS"}
    )
    
    foreach ($tool in $tools) {
        Print-Info "Installing $($tool.Name)..."
        try {
            winget install --id $tool.Id -e --source winget --silent --accept-package-agreements --accept-source-agreements
            Print-Status "$($tool.Name) installed"
        } catch {
            Print-Error "Failed to install $($tool.Name)"
        }
    }
}

# Install development tools
function Install-DevTools {
    Print-Section "Installing Development & DevOps Tools"
    
    Print-Info "Installing Python..."
    winget install --id Python.Python.3.12 -e --silent
    
    Print-Info "Installing Terraform..."
    choco install terraform -y
    
    Print-Info "Installing kubectl..."
    choco install kubernetes-cli -y
    
    Print-Info "Installing Helm..."
    choco install kubernetes-helm -y
    
    Print-Info "Installing Ansible..."
    choco install ansible -y
    
    Print-Status "DevOps tools installed"
}

# Enable and configure WSL2
function Setup-WSL {
    Print-Section "Configuring WSL2"
    
    Print-Info "Enabling WSL and Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    Print-Info "Setting WSL 2 as default..."
    wsl --set-default-version 2
    
    Print-Info "Installing WSL kernel update..."
    $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $wslUpdateFile = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateFile
    Start-Process msiexec.exe -Wait -ArgumentList "/i $wslUpdateFile /quiet"
    
    Print-Status "WSL2 configured (restart may be required)"
}

# Configure Windows 11 Dark Mode
function Enable-DarkMode {
    Print-Section "Enabling Windows Dark Mode"
    
    # Enable dark mode for apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    
    # Enable dark mode for system
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    
    Print-Status "Dark mode enabled"
}

# Configure Taskbar
function Configure-Taskbar {
    Print-Section "Configuring Taskbar (Christian Lempa Style)"
    
    Print-Info "Setting taskbar to left alignment..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
    
    Print-Info "Hiding taskbar icons..."
    # Hide Task View button
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
    
    # Hide Search icon
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
    
    # Hide Widgets
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    
    # Hide Chat/Teams
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0
    
    # Small taskbar icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSi" -Value 0
    
    Print-Status "Taskbar configured"
}

# Remove desktop icons
function Remove-DesktopIcons {
    Print-Section "Removing Desktop Icons"
    
    Print-Info "Hiding desktop icons..."
    
    # Hide This PC
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 1
    
    # Hide Recycle Bin
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1
    
    # Hide User Files
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value 1
    
    # Hide Network
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 1
    
    Print-Status "Desktop icons hidden"
}

# Download Mr. Robot wallpaper and set it
function Setup-Wallpaper {
    Print-Section "Setting up Mr. Robot Wallpaper"
    
    $wallpaperPath = "$env:USERPROFILE\Pictures\mr-robot-wallpaper.png"
    
    if (-not (Test-Path $wallpaperPath)) {
        Print-Info "Downloading Mr. Robot wallpaper..."
        Invoke-WebRequest -Uri $WALLPAPER_URL -OutFile $wallpaperPath
        Print-Status "Wallpaper downloaded"
    }
    
    Print-Info "Setting wallpaper..."
    
    # Set wallpaper using registry
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $wallpaperPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 2
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0
    
    # Force refresh
    rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false
    
    Print-Status "Mr. Robot wallpaper set"
}

# Clone dotfiles
function Clone-Dotfiles {
    Print-Section "Cloning Christian Lempa's Dotfiles"
    
    if (Test-Path $DOTFILES_DIR) {
        Print-Info "Dotfiles directory exists, updating..."
        Push-Location $DOTFILES_DIR
        git fetch --all
        git checkout $DOTFILES_COMMIT
        Pop-Location
    } else {
        Print-Info "Cloning dotfiles..."
        git clone $DOTFILES_REPO $DOTFILES_DIR
        Push-Location $DOTFILES_DIR
        git checkout $DOTFILES_COMMIT
        Pop-Location
    }
    
    Print-Status "Dotfiles ready"
}

# Setup Windows Terminal with Christian Lempa's config
function Setup-WindowsTerminal {
    Print-Section "Configuring Windows Terminal"
    
    $wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    
    if (-not (Test-Path $wtSettingsDir)) {
        Print-Error "Windows Terminal not found - install it first"
        return
    }
    
    # Clone icons
    if (Test-Path $ICONS_DIR) {
        Remove-Item -Path $ICONS_DIR -Recurse -Force
    }
    
    Print-Info "Downloading WSL icons..."
    git clone $ICONS_REPO $ICONS_DIR
    
    # Copy icons to Windows Terminal
    $iconsDestDir = "$wtSettingsDir\icons"
    New-Item -ItemType Directory -Path $iconsDestDir -Force | Out-Null
    
    Copy-Item "$ICONS_DIR\wsl-icons\icons8-fsociety-mask-50.png" "$iconsDestDir\kali.png" -Force
    Copy-Item "$ICONS_DIR\wsl-icons\icons8-arch-linux-24.png" "$iconsDestDir\arch.png" -Force
    Copy-Item "$ICONS_DIR\wsl-icons\icons8-ubuntu-24.png" "$iconsDestDir\ubuntu.png" -Force
    Copy-Item "$ICONS_DIR\wsl-icons\icons8-cmd-50.png" "$iconsDestDir\cmd.png" -Force
    Copy-Item "$ICONS_DIR\wsl-icons\icons8-powershell-24.png" "$iconsDestDir\powershell.png" -Force
    
    # Copy wallpaper for terminal background
    Copy-Item "$env:USERPROFILE\Pictures\mr-robot-wallpaper.png" "$wtSettingsDir\mr-robot-wallpaper.png" -Force
    
    Print-Status "Windows Terminal icons installed"
    Print-Info "Configure icons manually in Windows Terminal settings"
}

# Install Nerd Fonts
function Install-NerdFonts {
    Print-Section "Installing Hack Nerd Font"
    
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"
    $fontZip = "$env:TEMP\Hack.zip"
    $fontExtract = "$env:TEMP\HackFont"
    
    Print-Info "Downloading Hack Nerd Font..."
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
    
    Print-Info "Extracting fonts..."
    Expand-Archive -Path $fontZip -DestinationPath $fontExtract -Force
    
    Print-Info "Installing fonts..."
    $fonts = Get-ChildItem -Path $fontExtract -Filter "*.ttf"
    $shellApp = New-Object -ComObject Shell.Application
    $fontsFolder = $shellApp.Namespace(0x14)
    
    foreach ($font in $fonts) {
        if ($font.Name -like "*Windows Compatible*") {
            Print-Info "Installing $($font.Name)..."
            $fontsFolder.CopyHere($font.FullName)
        }
    }
    
    # Cleanup
    Remove-Item -Path $fontZip -Force
    Remove-Item -Path $fontExtract -Recurse -Force
    
    Print-Status "Hack Nerd Font installed"
}

# Create WSL setup script
function Create-WSLSetupScript {
    Print-Section "Creating WSL Setup Script"
    
    $wslScript = @'
#!/bin/bash
# Christian Lempa WSL Setup Script
# Run this inside each WSL distro (Ubuntu, Kali, Arch)

set -e

echo "Installing Starship..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo "Setting up dotfiles..."
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/ChristianLempa/dotfiles.git"
DOTFILES_COMMIT="8dbebcfca2c4f1e067540c6ae33ac913668d452f"

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    git checkout "$DOTFILES_COMMIT"
fi

echo "Configuring Starship..."
mkdir -p "$HOME/.config"

# Find and copy starship.toml
if [ -f "$DOTFILES_DIR/starship.toml" ]; then
    cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
elif [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
    cp "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
fi

echo "Configuring bashrc..."
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    cp "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

# Add Starship init if not present
if ! grep -q "starship init" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Initialize Starship prompt' >> "$HOME/.bashrc"
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
fi

echo "Installing Hack Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "HackNerdFont-Regular.ttf" ]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
    unzip -q Hack.zip
    rm Hack.zip
    fc-cache -fv
fi

echo ""
echo "Setup complete! Run: source ~/.bashrc"
echo ""
'@
    
    $scriptPath = "$env:USERPROFILE\setup-wsl-distro.sh"
    Set-Content -Path $scriptPath -Value $wslScript
    
    Print-Status "WSL setup script created: $scriptPath"
}

# Main execution
function Main {
    Print-Info "Starting Christian Lempa Windows Setup..."
    Print-Info "This will configure your Windows 11 system`n"
    
    Install-Winget
    Install-Chocolatey
    Install-Git
    Install-EssentialTools
    Install-DevTools
    Setup-WSL
    Enable-DarkMode
    Configure-Taskbar
    Remove-DesktopIcons
    Setup-Wallpaper
    Clone-Dotfiles
    Setup-WindowsTerminal
    Install-NerdFonts
    Create-WSLSetupScript
    
    Print-Section "Setup Complete!"
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  ✓ Dark mode enabled" -ForegroundColor Green
    Write-Host "  ✓ Taskbar configured (left-aligned, icons hidden)" -ForegroundColor Green
    Write-Host "  ✓ Desktop icons removed" -ForegroundColor Green
    Write-Host "  ✓ Mr. Robot wallpaper set" -ForegroundColor Green
    Write-Host "  ✓ Christian Lempa's tools installed" -ForegroundColor Green
    Write-Host "  ✓ Windows Terminal configured" -ForegroundColor Green
    Write-Host "  ✓ Hack Nerd Font installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. RESTART YOUR COMPUTER for all changes to take effect" -ForegroundColor Cyan
    Write-Host "  2. Install WSL distros:" -ForegroundColor White
    Write-Host "     wsl --install Ubuntu" -ForegroundColor Gray
    Write-Host "     wsl --install kali-linux" -ForegroundColor Gray
    Write-Host "     wsl --install Arch" -ForegroundColor Gray
    Write-Host "  3. Run setup script in each distro:" -ForegroundColor White
    Write-Host "     bash /mnt/c/Users/$env:USERNAME/setup-wsl-distro.sh" -ForegroundColor Gray
    Write-Host "  4. Configure Windows Terminal:" -ForegroundColor White
    Write-Host "     - Open Settings (Ctrl+,)" -ForegroundColor Gray
    Write-Host "     - Set font to 'Hack Nerd Font Mono'" -ForegroundColor Gray
    Write-Host "     - Set icons for each profile from LocalState\icons folder" -ForegroundColor Gray
    Write-Host "     - Add mr-robot-wallpaper.png as background image" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Enjoy your Christian Lempa setup! 🚀" -ForegroundColor Green
    Write-Host ""
}

# Run main function
Main
