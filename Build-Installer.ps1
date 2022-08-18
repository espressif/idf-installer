[CmdletBinding()]
param (
    [Parameter()]
    [String]
    [ValidateSet('none', 'lzma', 'zip')]
    $Compression = 'lzma',
    [String]
    $IdfPythonWheelsVersion = '3.8-2022-03-14',
    [String]
    [ValidateSet('online', 'offline', 'espressif-ide')]
    $InstallerType = 'online',
    [String]
    $OfflineBranch = 'v4.4',
    [String]
    $Python = 'python',
    [Boolean]
    $SignInstaller = $true,
    [String]
    $SetupCompiler = 'iscc',
    [String]
    $IdfEnvVersion = '1.2.30',
    [String]
    $EspressifIdeVersion = '2.5.0',
    [String]
    $JdkVersion = "jdk11.0.15_9",
    [String]
    $JdkArtifactVersion = "11.0.15.9.1"
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
    Invoke-WebRequest -O $Versions https://dl.espressif.com/dl/esp-idf/idf_versions.txt
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
        "Downloading $FullDistZipPath"
        Invoke-WebRequest -O $FullDistZipPath $DownloadUrl
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
    Invoke-WebRequest -O $FullFilePath $DownloadUrl
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
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-git\2.34.2 `
        -FilePath cmd/git.exe `
        -DistZip idf-git-2.34.2-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-git/idf-git-2.34.2-win64.zip
}

function PrepareIdfPython {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-python\3.8.7 `
        -FilePath python.exe `
        -DistZip idf-python-3.8.7-embed-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-python/idf-python-3.8.7-embed-win64.zip
}

function PrepareIdfPythonWheels {
    $WheelsDirectory = "build\$InstallerType\tools\idf-python-wheels\$IdfPythonWheelsVersion"
    if (!( Test-Path -Path $WheelsDirectory -PathType Container )) {
        mkdir $WheelsDirectory

        # Patch requirements.txt to become resolvable
        $Requirements = "${WheelsDirectory}\requirements.txt"
        $regex = '^[^#].*windows-curses.*'
        (Get-Content $BundleDir\requirements.txt) -replace $regex, 'windows-curses' | Set-Content $Requirements

        python3 -m pip download --python-version 3.8 `
            --only-binary=":all:" `
            --extra-index-url "https://dl.espressif.com/pypi/" `
            -r ${Requirements} `
            -d ${WheelsDirectory}
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
        -DownloadUrl https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-${EspressifIdeVersion}-win32.win32.x86_64.zip `
        -StripDirectory Espressif-IDE
}

function PrepareIdfDriver {
    &".\build\$InstallerType\lib\idf-env.exe" driver download --espressif --ftdi --silabs
}

function PrepareOfflineBranches {
    if ( Test-Path -Path $BundleDir -PathType Container ) {
        git -C "$BundleDir" fetch
    } else {
        "Performing full clone."
        git clone --branch "$OfflineBranch" -q --depth 1 --shallow-submodules --recursive https://github.com/espressif/esp-idf.git "$BundleDir"

        # Remove hidden attribute from .git. Inno Setup is not able to read it.
        attrib "$BundleDir\.git" -s -h

        # Fix repo mode
        git -C "$BundleDir" config --local core.fileMode false
        git -C "$BundleDir" submodule foreach --recursive git config --local core.fileMode false

        # Fix autocrlf - if autocrlf is not set from global gitconfig the files in unzipped repo
        # are marked as dirty
        git -C "$BundleDir" config --local core.autocrlf true
        git -C "$BundleDir" submodule foreach --recursive git config --local core.autocrlf true

        # Allow deleting directories by git clean --force
        # Required when switching between versions which does not have a module present in current branch
        git -C "$BundleDir" config --local clean.requireForce false
        git -C "$BundleDir" reset --hard
        git -C "$BundleDir" submodule foreach git reset --hard

    }

    Push-Location "$BundleDir"
    if (0 -ne (git status -s | Measure-Object).Count) {
        "git status not empty. Repository is dirty. Aborting."
        git status
        Exit 1
    }

    &$Python tools\idf_tools.py --tools-json tools/tools.json --non-interactive install
    Pop-Location

    # Remove symlinks which are not supported on Windws, unfortunatelly -c core.symlinks=false does not work
    Get-ChildItem "$BundleDir" -recurse -force | Where-Object { $_.Attributes -match "ReparsePoint" }
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
    "signtool.exe not found"
    Exit 1
}

function SignInstaller {
    $SignTool = FindSignTool
    "Using: $SignTool"
    $CertificateFile = [system.io.path]::GetTempPath() + "certificate.pfx"

    if ($null -eq $env:CERTIFICATE) {
        "CERTIFICATE variable not set, unable to sign installer"
        Exit 1
    }

    if ("" -eq $env:CERTIFICATE) {
        "CERTIFICATE variable is empty, unable to sign installer"
        Exit 1
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
        "Signing failed"
        Exit 1
    }

}

function CheckInnoSetupInstallation {
    if (Get-Command $SetupCompiler -ErrorAction SilentlyContinue) {
        "Inno Setup found"
        return
    }
    "Inno Setup not found in PATH. Please install as Administrator following dependencies:"
    "choco install innosetup inno-download-plugin"
    Exit 1
}

CheckInnoSetupInstallation

if ('espressif-ide' -eq $InstallerType) {
    $EspIdfBranchVersion = $OfflineBranch.Replace('v', '')
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
    $IsccParameters += '/DOFFLINEBRANCH=' + $OfflineBranch.Replace('v', '')
    $IsccParameters += '/DFRAMEWORK_ESP_IDF=' + $OfflineBranch

    if (($OfflineBranch -like 'v4.1*') -or ($OfflineBranch -like 'v4.2*') ){
        $IsccParameters += '/DDISABLE_TARGET_ESP32_C3'
        $IsccParameters += '/DDISABLE_TARGET_ESP32_S3'
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

    PrepareIdfDriver
    PrepareIdfGit
    PrepareIdfPython
    if ('espressif-ide' -eq $InstallerType) {
        $IsccParameters += '/DESPRESSIFIDE=yes'
        $IsccParameters += '/DAPPNAME=Espressif-IDE'
        $IsccParameters += '/DVERSION=' + $EspressifIdeVersion
        $IsccParameters += '/DESPRESSIFIDEVERSION=' + $EspressifIdeVersion
        $IsccParameters += '/DJDKVERSION=' + $JdkVersion
        $IsccParameters += '/DJDKARTIFACTVERSION=' + $JdkArtifactVersion
        PrepareIdfEclipse
    } else {
        $IsccParameters += '/DVERSION=' + $OfflineBranch.Replace('v', '')
        $IsccParameters += '/DAPPNAME=ESP-IDF Tools Offline'
    }
    "${OfflineBranch}" > $Versions
    PrepareOfflineBranches
    PrepareIdfPythonWheels
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
    "Build failed!"
    Exit 1
}

if ($true -eq $SignInstaller) {
    SignInstaller
} else {
    "Signing installer disabled by command line option. Leaving installer unsigned."
}

