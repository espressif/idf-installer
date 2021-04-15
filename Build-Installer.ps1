[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Compression = 'lzma',
    [String]
    $IdfPythonWheelsVersion = '3.8-2021-01-21',
    [String]
    $InstallerType = 'online',
    [String]
    $Python = 'python',
    [Boolean]
    $SignInstaller = $true,
    [String]
    $SetupCompiler = 'iscc'
)

# Stop on error
$ErrorActionPreference = "Stop"
# Display logs correctly on GitHub Runner
$ErrorView = 'NormalView'

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
        $DistZip
    )
    $FullFilePath = Join-Path -Path $BasePath -ChildPath $FilePath
    if (Test-Path -Path $FullFilePath -PathType Leaf) {
        "$FullFilePath found."
        return
    }

    if (-Not(Test-Path $BasePath -PathType Container)) {
        New-Item $BasePath -Type Directory
    }

    $FullDistZipPath = Join-Path -Path $BasePath -ChildPath $DistZip
    if (-Not(Test-Path -Path $FullDistZipPath -PathType Leaf)) {
        "Downloading $FullDistZipPath"
        Invoke-WebRequest -O $FullDistZipPath $DownloadUrl
    }
    Expand-Archive -Path $FullDistZipPath -DestinationPath $BasePath
    Remove-Item -Path $FullDistZipPath
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
    PrepareIdfPackage -BasePath build\$InstallerType\lib `
        -FilePath idf-env.exe `
        -DistZip idf-env.zip `
        -DownloadUrl https://github.com/espressif/idf-env/releases/download/v1.0.0/idf-env.zip
}

function PrepareIdfGit {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-git\2.30.1 `
        -FilePath cmd/git.exe `
        -DistZip idf-git-2.30.1-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-git/idf-git-2.30.1-win64.zip
}

function PrepareIdfPython {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-python\3.8.7 `
        -FilePath python.exe `
        -DistZip idf-python-3.8.7-embed-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-python/idf-python-3.8.7-embed-win64.zip
}

function PrepareIdfPythonWheels {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-python-wheels\3.8-2021-01-21 `
        -FilePath version.txt `
        -DistZip idf-python-wheels-3.8-2021-01-21-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-python-wheels/idf-python-wheels-3.8-2021-01-21-win64.zip
}

function PrepareIdfEclipse {
    PrepareIdfPackage -BasePath build\$InstallerType\tools\idf-eclipse\2021-03 `
        -FilePath eclipse.exe `
        -DistZip idf-eclipse-2021-03-win64.zip `
        -DownloadUrl https://dl.espressif.com/dl/idf-eclipse/idf-eclipse-2021-03-win64.zip
}

function PrepareOfflineBranches {
    $BundleDir="build\$InstallerType\releases\esp-idf-bundle"

    if ( Test-Path -Path $BundleDir -PathType Container ) {
        git -C "$BundleDir" fetch
    } else {
        "Performing full clone."
        git clone -q --shallow-since=2020-01-01 --jobs 8 --recursive https://github.com/espressif/esp-idf.git "$BundleDir"

        # Remove hidden attribute from .git. Inno Setup is not able to read it.
        attrib "$BundleDir\.git" -s -h

        # Fix repo mode
        git -C "$BundleDir" config --local core.fileMode false
        git -C "$BundleDir" submodule foreach --recursive git config --local core.fileMode false
        # Allow deleting directories by git clean --force
        # Required when switching between versions which does not have a module present in current branch
        git -C "$BundleDir" config --local clean.requireForce false
        git -C "$BundleDir" reset --hard
        git -C "$BundleDir" submodule foreach git reset --hard

    }

    $Content = Get-Content -Path $Versions
    [array]::Reverse($Content)
    $Content | ForEach-Object {
        $Branch = $_

        if ($null -eq $Branch) {
            continue;
        }

        Push-Location "$BundleDir"

        "Processing branch: ($Branch)"
        git fetch origin tag "$Branch"
        git checkout "$Branch"

        # Pull changes only for branches, tags does not support pull
        #https://stackoverflow.com/questions/1593188/how-to-programmatically-determine-whether-the-git-checkout-is-a-tag-and-if-so-w
        git describe --exact-match HEAD
        if (0 -ne $LASTEXITCODE) {
            git pull
        }

        git submodule update --init --recursive

        # Clean up left over submodule directories after switching to other branch
        git clean --force -d
        # Some modules are very persistent like cmok and needs 2nd round of cleaning
        git clean --force -d

        git reset --hard
        git submodule foreach git reset --hard

        if (0 -ne (git status -s | Measure-Object).Count) {
            "git status not empty. Repository is dirty. Aborting."
            git status
            Exit 1
        }

        &$Python tools\idf_tools.py --tools-json tools/tools.json --non-interactive download --platform Windows-x86_64 all
        Pop-Location
    }

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
$OutputFileBaseName = "esp-idf-tools-setup-${InstallerType}-unsigned"
$OutputFileSigned = "esp-idf-tools-setup-${InstallerType}-signed.exe"
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

if ('offline' -eq $InstallerType) {
    $IsccParameters += '/DOFFLINE=yes'

    if (-Not(Test-Path build/$InstallerType/tools -PathType Container)) {
        New-Item build/$InstallerType/tools -Type Directory
    }

    PrepareIdfGit
    PrepareIdfPython
    PrepareIdfPythonWheels
    PrepareIdfEclipse
    Copy-Item .\src\Resources\idf_versions_offline.txt $Versions
    PrepareOfflineBranches
} elseif ('online' -eq $InstallerType) {
    DownloadIdfVersions
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

