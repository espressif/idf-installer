[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $IdfPath = "C:/Users/runneradmin/Desktop/esp-idf",
    [String]
    $IdfShortVersion = "4.2"
)

Set-Location "${IdfPath}"

# Timeout is necessary to fix the problem when installer is writing some final files
# it seems that installer exits, but locks were not released yet
Start-Sleep -s 5

$WSShell = New-Object -comObject WScript.Shell
$LinkPath = "C:/Users/runneradmin/Desktop/ESP-IDF ${IdfShortVersion} CMD.lnk"

if (-Not(Test-Path $LinkPath -PathType Leaf)) {
    "$LinkPath does not exist"
    Exit 1
}

$Shortcut = $WSShell.CreateShortcut($LinkPath)
$Arguments = $Shortcut.Arguments -replace "/k ", "/c '"
$Command = $Shortcut.TargetPath + ' ' + $Arguments -replace '""', '"'
$Command += " && cd examples\get-started\blink\ && idf.py build'"

$Command
Invoke-Expression -Command $Command
