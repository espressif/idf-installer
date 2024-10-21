[CmdletBinding()]
param (
    [Parameter()]
    [String]
    [ValidateSet('none', 'lzma', 'zip')]
    $Compression = 'lzma',
    [String]
    $IdfPythonWheelsVersion = '3.11-2023-03-05',
    [String]
    $IdfPythonVersion = '3.11.2',
    [String]
    $IdfPythonShortVersion = '3.11',
    [String]
    $GitVersion = '2.44.0',
    [String]
    [ValidateSet('online', 'offline', 'espressif-ide')]
    $InstallerType = 'online',
    [String]
    $OfflineBranch = 'v5.0.1',
    [String]
    $Python = 'python',
    [Boolean]
    $SignInstaller = $true,
    [String]
    $SetupCompiler = 'iscc',
    [String]
    $IdfEnvVersion = '1.2.32',
    [String]
    $EspressifIdeVersion = '2.9.0',
    [String]
    $JdkVersion = "jdk17.0.6_10",
    [String]
    $JdkArtifactVersion = "17.0.6.10.1"
)

# Stop on error
$ErrorActionPreference = "Stop"
# Disable progress bar when downloading - speed up download - https://stackoverflow.com/questions/28682642/powershell-why-is-using-invoke-webrequest-much-slower-than-a-browser-download
$ProgressPreference = 'SilentlyContinue'
# Display logs correctly on GitHub Runner
$ErrorView = 'NormalView'

"Processing configuration:"
"-Compression            = ${Compression}"
"-IdfPythonWheelsVersion = ${IdfPythonWheelsVersion}"
"-IdfEnvVersion          = ${IdfEnvVersion}"
"-InstallerType          = ${InstallerType}"
"-JdkVersion             = ${JdkVersion}"
"-JdkArtifactVersion     = ${JdkArtifactVersion}"
"-OfflineBranch          = ${OfflineBranch}"
"-Python                 = ${Python}"
"-SignInstaller          = ${SignInstaller}"
"-SetupCompiler          = ${SetupCompiler}"

$BundleDir="build\$InstallerType\frameworks\esp-idf-${OfflineBranch}"

function DownloadIdfVersions() {
    if (Test-Path -Path $Versions -PathType Leaf) {
        "$Versions exists."
        return
    }
    "Downloading idf_versions.txt..."
    Invoke-WebRequest -OutFile $Versions https://dl.espressif.com/dl/esp-idf/idf_versions.txt
}

# Get short version of Constraint file.
# For example, for v5.0.1, return 5.0; for v5.0.0-rc, return 5.0
function GetConstraintFile() {
    $VersionString = $OfflineBranch -replace "^v" -replace "-.*$"
    $SplitVersion = $VersionString -split "\."
    $ShortVersion = $SplitVersion[0] + "." + $SplitVersion[1]
    return "espidf.constraints.v${ShortVersion}.txt"
}

function PrepareConstraints {
    $ConstraintFile = GetConstraintFile
    $ConstraintUrl = "https://dl.espressif.com/dl/esp-idf/$ConstraintFile"
    "Downloading $ConstraintUrl"
    Invoke-WebRequest -OutFile "build\$InstallerType\${ConstraintFile}" $ConstraintUrl
}

function PrepareIdfPackage {
    param (
        [Parameter()]
        [String]
        $BasePath,
        [String]
        $FilePath,
        [String]
        $DownloadUrl,
        [String]
        $DistZip,
        [String]
        $StripDirectory
    )
    $FullFilePath = Join-Path -Path $BasePath -ChildPath $FilePath
    "Checking existence of file: $FullFilePath"
    if (Test-Path -Path $FullFilePath -PathType Leaf) {
        "$FullFilePath found."
        return
    }

    if (-Not(Test-Path $BasePath -PathType Container)) {
        New-Item $BasePath -Type Directory
    }

    $FullDistZipPath = Join-Path -Path $BasePath -ChildPath $DistZip
    "Checking existence of dist: $FullDistZipPath"
    if (-Not(Test-Path -Path $FullDistZipPath -PathType Leaf)) {
        "Downloading from $DownloadUrl to $FullDistZipPath"
        Invoke-WebRequest -OutFile $FullDistZipPath $DownloadUrl
    }

    if ("" -ne $StripDirectory) {
        $TempBasePath="${BasePath}-tmp"
        Expand-Archive -Path $FullDistZipPath -DestinationPath $TempBasePath
        Move-Item -Path "${TempBasePath}/${StripDirectory}/*" $BasePath
        Remove-Item -Path $TempBasePath -Recurse
    } else {
        Expand-Archive -Path $FullDistZipPath -DestinationPath $BasePath
    }
    Remove-Item -Path $FullDistZipPath
}

function PrepareIdfFile {
    param (
        [Parameter()]
        [String]
        $BasePath,
        [String]
        $FilePath,
        [String]
        $DownloadUrl
    )
    $FullFilePath = Join-Path -Path $BasePath -ChildPath $FilePath
    if (Test-Path -Path $FullFilePath -PathType Leaf) {
        "$FullFilePath found."
        return
    }

    "Downloading: $DownloadUrl"
    Invoke-WebRequest -OutFile $FullFilePath $DownloadUrl
}

function PrepareIdfCmdlinerunner {
    PrepareIdfPackage -BasePath build\$InstallerType\lib `
        -FilePath cmdlinerunner.dll `
        -DistZip idf-cmdlinerunner-1.0.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-cmdlinerunner/idf-cmdlinerunner-1.0.zip
}

function PrepareIdf7za {
    PrepareIdfPackage -BasePath build\$InstallerType\lib `
        -FilePath 7za.exe `
        -DistZip idf-7za.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-7za/idf-7za-19.0.zip
}

function PrepareIdfEnv {
    PrepareIdfFile -BasePath build\$InstallerType\lib `
        -FilePath idf-env.exe `
        -DownloadUrl https://github.com/espressif/idf-env/releases/download/v${IdfEnvVersion}/win64.idf-env.exe
}

function PrepareIdfGit {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-git\${GitVersion} `
        -FilePath cmd/git.exe `
        -DistZip idf-git-${GitVersion}-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-git/idf-git-${GitVersion}-win64.zip
}

function PrepareIdfPython {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-python\${IdfPythonVersion} `
        -FilePath python.exe `
        -DistZip idf-python-${IdfPythonVersion}-embed-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-python/idf-python-${IdfPythonVersion}-embed-win64.zip
}

function PrepareIdfDocumentation {
    $FullFilePath = ".\build\$InstallerType\IDFdocumentation.pdf"
    $DownloadUrl = "https://docs.espressif.com/projects/esp-idf/en/$OfflineBranch/esp32/esp-idf-en-$OfflineBranch-esp32.pdf"

    if (Test-Path -Path $FullFilePath -PathType Leaf) {
        "$FullFilePath found."
        return
    }

    "Downloading: $DownloadUrl"
    try {
	    $Request = Invoke-WebRequest $DownloadUrl -OutFile $FullFilePath -MaximumRedirection 0
        [int]$StatusCode = $Request.StatusCode
    }
    catch {
        [int]$StatusCode = $_.Exception.Response.StatusCode
    }


    if ($StatusCode -eq 302) {
        FailBuild -Message "Failed to download documentation from $DownloadUrl. Status code: $StatusCode"
    }
}

function FailBuild {
    param (
        [Parameter()]
        [String]
        $Message
    )
    Write-Error $Message
    exit 1
}

function PrepareIdfPythonWheels {
    $WheelsDirectory = "build\$InstallerType\tools\idf-python-wheels\$IdfPythonWheelsVersion"
    if ( Test-Path -Path $WheelsDirectory -PathType Container ) {
        "$WheelsDirectory exists. Using cached content."
        return
    }
    mkdir $WheelsDirectory

    # Patch requirements.txt to become resolvable
    $Requirements = "${WheelsDirectory}\requirements.txt"
    $regex = '^[^#].*windows-curses.*'

    $RequirementsPath = "$BundleDir\tools\requirements\requirements.core.txt"
    # ESP-IDF v5 - requirements is in tools\requirements\requirements.core.txt

    if (Test-Path -Path "$RequirementsPath" -PathType Leaf) {
        # ESP-IDF v5.0 remove the dependency line
        (Get-Content $RequirementsPath) -replace $regex, '' | Set-Content $Requirements
        # ESP-IDF v5.0, v5.1 and newer - add the dependency line athe end of the file
        Add-Content $Requirements "windows-curses"

        $ConstraintFile = GetConstraintFile

        &$Python -m pip download --python-version $IdfPythonShortVersion `
            --only-binary=":all:" `
            --extra-index-url "https://dl.espressif.com/pypi/" `
            -r ${Requirements} `
            -d ${WheelsDirectory} `
            -c "build\$InstallerType\${ConstraintFile}" || FailBuild -Message "Failed to download Python wheels"
    } else {
        # ESP-IDF v4 and older
        $RequirementsPath = "$BundleDir\requirements.txt" # Fallback to ESP-IDF v4

        (Get-Content $RequirementsPath) -replace $regex, 'windows-curses' | Set-Content $Requirements

        &$Python -m pip download --python-version $IdfPythonShortVersion `
            --only-binary=":all:" `
            --extra-index-url "https://dl.espressif.com/pypi/" `
            -r ${Requirements} `
            -d ${WheelsDirectory} || FailBuild -Message "Failed to download Python wheels"
    }
}

function PrepareIdfEclipse {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\amazon-corretto-11-x64-windows-jdk\ `
        -FilePath ${JdkVersion}\bin\java.exe `
        -DistZip amazon-corretto-11-x64-windows-jdk.zip `
        -DownloadUrl https://corretto.aws/downloads/resources/${JdkArtifactVersion}/amazon-corretto-${JdkArtifactVersion}-windows-x64-jdk.zip

    PrepareIdfPackage -BasePath build\$InstallerType\tools\espressif-ide\${EspressifIdeVersion} `
        -FilePath espressif-ide.exe `
        -DistZip Espressif-IDE-${EspressifIdeVersion}-win32.win32.x86_64.zip `
        -DownloadUrl "https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-${EspressifIdeVersion}-win32.win32.x86_64.zip" `
        -StripDirectory Espressif-IDE
}

function PrepareIdfDriver {
    &".\build\$InstallerType\lib\idf-env.exe" driver download --espressif --ftdi --silabs --wch
    if ($LASTEXITCODE -ne 0) {
        FailBuild -Message "Command failed with exit code: $LASTEXITCODE. Aborting."
    }
}

function PrepareOfflineBranches {
    if ( Test-Path -Path $BundleDir -PathType Container ) {
        git -C "$BundleDir" fetch
    } else {
        "Performing full clone."
        git clone --branch "$OfflineBranch" -q --single-branch --shallow-submodules --recursive https://github.com/espressif/esp-idf.git "$BundleDir"

        # Remove hidden attribute from .git. Inno Setup is not able to read it.
        attrib "$BundleDir\.git" -s -h
        git -C "$BundleDir" submodule foreach --recursive attrib .git -s -h

        # Fix repo mode
        git -C "$BundleDir" config --local core.fileMode false
        git -C "$BundleDir" submodule foreach --recursive git config --local core.fileMode false

        # Fix autocrlf - if autocrlf is not set from global gitconfig the files in unzipped repo
        # are marked as dirty
        git -C "$BundleDir" config --local core.autocrlf true
        git -C "$BundleDir" submodule foreach --recursive git config --local core.autocrlf true

        # Allow deleting directories by git clean --force
        # Required when switching between versions which does not have a module present in current branch
        #git -C "$BundleDir" config --local clean.requireForce false
        #git -C "$BundleDir" reset --hard
        #git -C "$BundleDir" submodule foreach git reset --hard

    }

    Push-Location "$BundleDir"
    if (0 -ne (git status -s | Measure-Object).Count) {
        git status
        FailBuild -Message "git status not empty. Repository is dirty. Aborting."
    }

    &$Python tools\idf_tools.py --tools-json tools/tools.json --non-interactive install
    &$Python tools\idf_tools.py --tools-json tools/tools.json --non-interactive install esp-clang
    Pop-Location

    # Remove symlinks which are not supported on Windws, unfortunatelly -c core.symlinks=false does not work
    Get-ChildItem "$BundleDir" -recurse -force | Where-Object { $_.Attributes -match "ReparsePoint" }
}

function PrepareIdfComponents {
    $ComponentsDirectory = "build\$InstallerType\registry"
    if ( Test-Path -Path $ComponentsDirectory -PathType Container ) {
        "$ComponentsDirectory exists. Using cached content."
        return
    }

    $Compote = "compote"
    # Install compote command
    &$Python -m pip install idf-component-manager

    $env:IDF_PATH="$BundleDir"
    &$Compote registry sync --recursive $ComponentsDirectory
}

function FindSignTool {
    $SignTool = "signtool.exe"
    if (Get-Command $SignTool -ErrorAction SilentlyContinue) {
        return $SignTool
    }
    $SignTool = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\x64\signtool.exe"
    if (Test-Path -Path $SignTool -PathType Leaf) {
        return $SignTool
    }
    $SignTool = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\x86\signtool.exe"
    if (Test-Path -Path $SignTool -PathType Leaf) {
        return $SignTool
    }
    $SignTool = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.19041.0\x64\signtool.exe"
    if (Test-Path -Path $SignTool -PathType Leaf) {
        return $SignTool
    }
    FailBuild -Message "signtool.exe not found"
}

function SignInstaller {
    $SignTool = FindSignTool
    "Using: $SignTool"
    $CertificateFile = [system.io.path]::GetTempPath() + "certificate.pfx"

    if ($null -eq $env:CERTIFICATE) {
        FailBuild -Message "CERTIFICATE variable not set, unable to sign installer"
    }

    if ("" -eq $env:CERTIFICATE) {
        FailBuild -Message "CERTIFICATE variable is empty, unable to sign installer"
    }

    $SignParameters = @("sign", "/tr", 'http://timestamp.digicert.com', "/f", $CertificateFile)
    if ($env:CERTIFICATE_PASSWORD) {
        "CERTIFICATE_PASSWORD detected, using the password"
        $SignParameters += "/p"
        $SignParameters += $env:CERTIFICATE_PASSWORD
    }
    $SignParameters += "build\${OutputFileBaseName}.exe"

    [byte[]]$CertificateBytes = [convert]::FromBase64String($env:CERTIFICATE)
    "File: $CertificateFile"
    [IO.File]::WriteAllBytes($CertificateFile, $CertificateBytes)

    &$SignTool $SignParameters

    if (0 -eq $LASTEXITCODE) {
        mv build\${OutputFileBaseName}.exe build\$OutputFileSigned
        Get-ChildItem -l build\$OutputFileSigned
        Remove-Item $CertificateFile
    } else {
        Remove-Item $CertificateFile
        FailBuild -Message "Signing failed"
    }

}

function CheckInnoSetupInstallation {
    if (Get-Command $SetupCompiler -ErrorAction SilentlyContinue) {
        "Inno Setup found"
        return
    }
    "Inno Setup not found in PATH. Please install as Administrator following dependencies:"
    FailBuild -Message "choco install innosetup inno-download-plugin"
}

function CheckPythonInstallation {
    if (Get-Command $Python -ErrorAction SilentlyContinue) {
        "$Python found"
        return
    }
    "$Python not found in PATH. Use parameter -Python to specify custom Python, e.g. just 'python' or install following dependencies:"
    FailBuild -Message "winget install --id Python.Python.3.11"
}

CheckInnoSetupInstallation
CheckPythonInstallation

if ('espressif-ide' -eq $InstallerType) {
    $EspIdfBranchVersion = $OfflineBranch -replace '^v'
    $OutputFileBaseName = "espressif-ide-setup-${InstallerType}-with-esp-idf-${EspIdfBranchVersion}-unsigned"
    $OutputFileSigned = "espressif-ide-setup-${InstallerType}-with-esp-idf-${EspIdfBranchVersion}-signed.exe"
} else {
    $OutputFileBaseName = "esp-idf-tools-setup-${InstallerType}-unsigned"
    $OutputFileSigned = "esp-idf-tools-setup-${InstallerType}-signed.exe"
}

$IdfToolsPath = Join-Path -Path (Get-Location).Path -ChildPath "build/$InstallerType"
$Versions = Join-Path -Path $IdfToolsPath -ChildPath '/idf_versions.txt'
$env:IDF_TOOLS_PATH=$IdfToolsPath
if (!(Test-Path -PathType Container -Path  $IdfToolsPath)) {
    New-Item $IdfToolsPath -Type Directory
}
"Using IDF_TOOLS_PATH specific for installer type: $IdfToolsPath"
$IsccParameters = @("/DCOMPRESSION=$Compression", "/DSOLIDCOMPRESSION=no", "/DPYTHONWHEELSVERSION=$IdfPythonWheelsVersion")
$IsccParameters += "/DDIST=..\..\build\$InstallerType"

if (-Not(Test-Path build/$InstallerType/lib -PathType Container)) {
    New-Item build/$InstallerType/lib -Type Directory
}
PrepareIdfCmdlinerunner
PrepareIdf7za
PrepareIdfEnv

if (('offline' -eq $InstallerType) -or ('espressif-ide' -eq $InstallerType)){
    $IsccParameters += '/DOFFLINE=yes'
    $IsccParameters += '/DOFFLINEBRANCH=' + ($OfflineBranch -replace '^v')
    $IsccParameters += '/DFRAMEWORK_ESP_IDF=' + $OfflineBranch

    if (($OfflineBranch -like 'v4.1*') -or ($OfflineBranch -like 'v4.2*') ){
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C3'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_S3'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C2'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C6'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_P4'
    }

    if (($OfflineBranch -like 'v4.3*') -or ($OfflineBranch -like 'v4.4*') ){
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C2'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C6'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_P4'
    }

    if ($OfflineBranch -like 'v5.0*') {
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C6'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_P4'
    }

    if (($OfflineBranch -like 'v5.1*') -or ($OfflineBranch -like 'v5.2*') ){
        $IsccParameters += '/DDISABLE_TARGET_ESP32_P4'
    }

    if ($Compression -eq 'none') {
        $IsccParameters += '/DDISKSPANNING=yes'
    }

    if (-Not(Test-Path build/$InstallerType/tools -PathType Container)) {
        New-Item build/$InstallerType/tools -Type Directory
    }

    if (-Not(Test-Path build/$InstallerType/dist -PathType Container)) {
        New-Item build/$InstallerType/dist -Type Directory
    }

    # Download constraint files for ESP-IDF 5
    if ($OfflineBranch -like 'v5.*') {
        PrepareConstraints
    }

    PrepareIdfDriver
    PrepareIdfGit
    PrepareIdfPython
    PrepareIdfDocumentation
    if ('espressif-ide' -eq $InstallerType) {
        $IsccParameters += '/DESPRESSIFIDE=yes'
        $IsccParameters += '/DAPPNAME=Espressif-IDE'
        $IsccParameters += '/DVERSION=' + $EspressifIdeVersion
        $IsccParameters += '/DESPRESSIFIDEVERSION=' + $EspressifIdeVersion
        $IsccParameters += '/DJDKVERSION=' + $JdkVersion
        $IsccParameters += '/DJDKARTIFACTVERSION=' + $JdkArtifactVersion
        PrepareIdfEclipse
    } else {
        $IsccParameters += '/DVERSION=' + ($OfflineBranch -replace '^v')
        $IsccParameters += '/DAPPNAME=ESP-IDF Tools Offline'
    }
    "${OfflineBranch}" > $Versions
    PrepareOfflineBranches
    PrepareIdfPythonWheels
    #PrepareIdfComponents
} elseif ('online' -eq $InstallerType) {
    DownloadIdfVersions
    $IsccParameters += '/DJDKVERSION=' + $JdkVersion
    $IsccParameters += '/DJDKARTIFACTVERSION=' + $JdkArtifactVersion
    $IsccParameters += '/DESPRESSIFIDE=yes'
    $IsccParameters += '/DOFFLINE=no'
} else {
    $IsccParameters += '/DOFFLINE=no'
}

$IsccParameters += "/DINSTALLERBUILDTYPE=$InstallerType"

$IsccParameters += ".\src\InnoSetup\IdfToolsSetup.iss"
$IsccParameters += "/F$OutputFileBaseName"

$Command = "$SetupCompiler $IsccParameters"
$Command
&$SetupCompiler $IsccParameters
if (0 -eq $LASTEXITCODE) {
    $Command
    Get-ChildItem -l build\$OutputFileName
} else {
    FailBuild -Message "Build failed!"
}

if ($true -eq $SignInstaller) {
    SignInstaller
} else {
    "Signing installer disabled by command line option. Leaving installer unsigned."
}

