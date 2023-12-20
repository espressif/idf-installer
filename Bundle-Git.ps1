param (
    [string]$GitVersion="2.43.0"
)

$GitDirectory = "idf-git-${GitVersion}-win64"


# Download Git
Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v${GitVersion}.windows.1/PortableGit-${GitVersion}-64-bit.7z.exe" -OutFile git.7z.exe

# Test and download/run 7z
$7z = 'C:/Program Files/7-Zip/7z.exe'
"Test if directory [$7z] exists"
if (Test-Path -Path $7z) {
    "Path exists!"
    7z x git.7z.exe -ogit
    Rename-Item -Path "git" -NewName ${GitDirectory}
} else {
    "Path doesn't exist."
    # Install 7zip PS module
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
    Install-Module -Name 7Zip4PowerShell -Force

    # Extract 7zip file
    Expand-7Zip -ArchiveFileName "git.7z.exe" -TargetPath ${GitDirectory}
}

Start-Process "${GitDirectory}\post-install.bat" -ArgumentList "/s" -Wait

# Clean directory
Remove-Item "git.7z.exe"
Remove-Item "${GitDirectory}\dev" -Recurse
Remove-Item "${GitDirectory}\tmp"
Remove-Item "${GitDirectory}\README.portable"

# Create final zip - GitHub performs compression of artifacts automatically
Compress-Archive -Path "${GitDirectory}\*" -DestinationPath "${GitDirectory}.zip"
Remove-Item "${GitDirectory}" -Recurse -Force
