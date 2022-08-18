[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $IdfPath = "${HOME}/Desktop/esp-idf",
    [String]
    $IdfShortVersion = "4.4"
)

# Stop if any command fails
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'
function ThrowOnNativeFailure {
    if (-not $?)
    {
        throw 'Native Failure'
    }
}

Set-Location "${IdfPath}"

# Timeout is necessary to fix the problem when installer is writing some final files
# it seems that installer exits, but locks were not released yet
Start-Sleep -s 5

$WSShell = New-Object -comObject WScript.Shell
$LinkPath = "${HOME}/Desktop/ESP-IDF ${IdfShortVersion} PowerShell.lnk"

if (-Not(Test-Path $LinkPath -PathType Leaf)) {
    "$LinkPath does not exist"
    Exit 1
}

$Shortcut = $WSShell.CreateShortcut($LinkPath)
$Command =  '. ' + $Shortcut.Arguments
$Command = $Command -replace " -ExecutionPolicy Bypass -NoExit -File", ""
$Command
Invoke-Expression -Command $Command

cd examples\get-started\blink\
# Run several commands to test functionality of installed environment
idf.py --version
idf.py build
idf.py all --help

# Check whether the repository is clean
$GitChanges=(git status -s).Lenght
if ($GitChanges -gt 0) {
    "* Warning! Git repository dirty."
    $GitChanges
} else {
    "Git repository clean."
}
