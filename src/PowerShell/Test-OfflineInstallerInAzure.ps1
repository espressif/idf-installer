# Define CLI parameters with default values
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "idf-installer",
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    [Parameter(Mandatory=$false)]
    [string]$VMName = "idf-tester",
    [Parameter(Mandatory=$false)]
    [string]$VMSize = "Standard_DS1_v2",
    [Parameter(Mandatory=$false)]
    [string]$AdminUsername = "YourAdminUsername",
    [Parameter(Mandatory=$false)]
    [string]$AdminPassword = "YourAdminPassword",
    [Parameter(Mandatory=$false)]
    [string]$ImageOffer = "Windows",
    [Parameter(Mandatory=$false)]
    [string]$ImagePublisher = "MicrosoftVisualStudio",
    [Parameter(Mandatory=$false)]
    [string]$ImageSku = "Windows-11-N-x64",
    [Parameter(Mandatory=$false)]
    [string]$InstallerUrl = "https://github.com/espressif/idf-installer/releases/download/online-2.21/esp-idf-tools-setup-online-2.21.exe"
)

# Set variables
$resourceGroupName = $ResourceGroupName
$location = $Location
$vmName = $VMName
$vmSize = $VMSize
$adminUsername = $AdminUsername
$adminPassword = $AdminPassword
$imageOffer = $ImageOffer
$imagePublisher = $ImagePublisher
$imageSku = $ImageSku
$installerUrl = $InstallerUrl

# Check if VM exists
if (Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction SilentlyContinue) {
    Write-Host "VM $vmName already exists in resource group $resourceGroupName."
} else {
    # Create new VM
    Write-Host "Creating new VM $vmName in resource group $resourceGroupName..."
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)
    New-AzVm `
        -ResourceGroupName $resourceGroupName `
        -Name $vmName `
        -Location $location `
        -Size $vmSize `
        -Credential $cred `
        -ImageReference `
            @{
                Offer = $imageOffer
                Publisher = $imagePublisher
                Sku = $imageSku
                Version = "latest"
            } `
        -OpenPorts 3389

    Write-Host "New VM $vmName created in resource group $resourceGroupName."
}

# Start VM and run code
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
Write-Host "Waiting for VM to start..."
Start-Sleep -Seconds 60 # wait for VM to start

Write-Host "Downloading idf-installer.exe..."
$installerPath = "C:\Users\Administrator\Downloads\idf-installer.exe"
Invoke-Command -ResourceGroupName $resourceGroupName -Name $vmName -ScriptBlock {
    param($installerUrl, $installerPath)
    (New-Object System.Net.WebClient).DownloadFile($installerUrl, $installerPath)
} -ArgumentList $installerUrl, $installerPath

Write-Host "Starting idf-installer.exe..."
Invoke-Command -ResourceGroupName $resourceGroupName -Name $vmName -ScriptBlock {
    param($installerPath)
    Start-Process -FilePath $installerPath -Wait
} -ArgumentList $installerPath

Write-Host "Installation complete."
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName