[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Installer="./installer.exe",
    [String]
    $IdfVersion = "v4.2",
    [String]
    $Components = "ide/powershell,ide/cmd",
    # Allows testing installation with specific Temp directory.
    # Some environments contains path with spaces and special characters.
    [String]
    $TmpDirectory = $env:TMP
)

if ($env:TMP -ne $TmpDirectory) {
    $env:TMP = $TmpDirectory
    if (!( Test-Path -Path $env:TMP -PathType Container )) {
        New-Item $env:TMP -Type Directory
    }
}

"Configuration:"
"* Installer = $Installer"
"* IdfVersion = $IdfVersion"
"* env:TMP = $env:TMP"

$Directory = (Get-Location).Path
$LogFile = Join-Path -Path $Directory -ChildPath out.txt
$ProcessName = (Get-Item $Installer).Basename
"Waiting for process: $ProcessName"
&$Installer /VERYSILENT /LOG=$LogFile /COMPONENTS=$Components /SUPPRESSMSGBOXES /SP- /NOCANCEL /NORESTART /IDFVERSION=${IdfVersion}
$InstallerProcess = Get-Process $ProcessName
Sleep 5
# Logs must be watched in separate job, because Inno Setup does not allow to print stdout.
$LogWatcher = Start-Job -ArgumentList $LogFile -ScriptBlock {
    Param($LogFile)
    Get-Content -Path $LogFile -Wait
}

# Wait for installer to finish
while (!$InstallerProcess.HasExited) {
    Sleep 1
    Receive-Job $LogWatcher
}

Stop-Job $LogWatcher
