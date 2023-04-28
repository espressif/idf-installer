# The PowerShell script performs test of idf-installer.exe in Hyper-V.
# The script turns off the networkinterface in Hyper-V,
# then it copies the installer to the VM and runs it.
# After the installation is finished, the script turns off the Hyper-V machine.

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VMName = "Windows 11 dev environtment",
    [string]
    $InstallerPath = "build/esp-idf-installer.exe",
    [string]
    $DestinationPath = "C:\Users\Public\esp-idf-installer.exe"
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

# Turn off network interface on VM
Get-VMNetworkAdapter -VMName $VMName | Disconnect-VMNetworkAdapter

# Turn on VM
Start-VM -Name $VMName

# Enable Integration Services to copy file
Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"

# Copy installer to VM
Copy-VMFile -Name $VMName -SourcePath $InstallerPath -DestinationPath $DestinationPath -FileSource Host

# Start installer inside VM
Invoke-Command -VMName $VMName -ScriptBlock {
    param($installerPath)
    Start-Process -FilePath $installerPath -Wait
} -ArgumentList $installerPath

# Turn off VM
Stop-VM -Name $VMName
