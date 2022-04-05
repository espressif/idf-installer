Invoke-WebRequest -Uri https://github.com/espressif/inno-download-plugin/releases/download/v1.5.1/idpsetup-1.5.1.exe -OutFile idpsetup.exe; .\idpsetup.exe /SILENT
$ProcessName = (Get-Item idpsetup.exe).Basename
$InstallerProcess = Get-Process $ProcessName

$Counter = 0
# Wait for installer to finish
while (!$InstallerProcess.HasExited) {
    Sleep 1
    $Counter++
    if (120 -lt $Counter) {
        "Timeout"
        break
    }
}
