# ESP-IDF Tools Installer for Windows

> [!IMPORTANT]
> Starting with [ESP-IDF](https://github.com/espressif/esp-idf) v6.0 this Windows Installer is deprecated.
> Please use the new Espressif's Installation Manager: [EIM](https://github.com/espressif/idf-im-ui)

## Download

ESP-IDF Tools Installer for Windows download page: https://dl.espressif.com/dl/esp-idf/

### Video with installation of ESP-IDF

[![How to install the ESP-IDF Toolchain on Windows](https://img.youtube.com/vi/byVPAfodTyY/0.jpg)](https://youtu.be/byVPAfodTyY)

### Universal Online Installer, Espressif-IDE Offline Installer, Offline Installer

All releases of Installer are available on the download page: https://dl.espressif.com/dl/esp-idf/ (older versions are in the bottom table)

> [!TIP] 
> Online Installer is the recommended way of the installation.

## Command-line parameters

Windows Installer `esp-idf-tools-setup` provides the following command-line parameters:

* ``/CHECKPATH=[yes|no]`` - Check whether the installation path does not contain spaces or special characters or if it's too long. Set to ``no`` to disable checks. Default: yes.
* ``/CONFIG=[PATH]`` - Path to ``ini`` configuration file to override default configuration of the installer. Default: ``config.ini``.
* ``/GITCLEAN=[yes|no]`` - Perform git clean and remove untracked directories in Offline mode installation. Default: yes.
* ``/GITDEPTH=[number]`` - Clone repository in shallow mode E.g. 1. Default: empty.
* ``/GITRECURSIVE=[yes|no]`` - Clone recursively all git repository submodules. Default: yes
* ``/GITREPO=[URL|PATH]`` - URL of repository to clone ESP-IDF. Default: https://github.com/espressif/esp-idf.git
* ``/GITRESET=[yes|no]`` - Enable/Disable git reset of repository during installation. Default: yes.
* ``/GITSUBMODULEURL=[URL]`` - Update URL in submodules after cloning to custom URL. Default: ''.
* ``/GITUSEMIRROR=[yes|no]`` - Use Git mirror for cloning. Clone non-recursive and update URL of submodules. Default: no.
* ``/HELP`` - Display command line options provided by Inno Setup installer.
* ``/IDFDIR=[PATH]`` - Path to directory where it will be installed. Default: ``{userdesktop}\esp-idf}``
* ``/IDFUSEEXISTING=[yes|no]`` - Indicates whether installer should be initialized in update mode of existing IDF. Default: no.
* ``/IDFVERSION=[v4.3|v4.1|master]`` - Use specific IDF version. E.g. v4.1, v4.2, master. Default: empty, pick the first version in the list.
* ``/IDFVERSIONSURL=[URL]`` - Use URL to download list of IDF versions. Default: https://dl.espressif.com/dl/esp-idf/idf_versions.txt
* ``/LOG=[PATH]`` - Store installation log file in specific directory. Default: empty.
* ``/OFFLINE=[yes|no]`` - Execute installation of Python packages by PIP in offline mode. The same result can be achieved by setting the environment variable PIP_NO_INDEX. Default: no.
* ``/USEEMBEDDEDGIT=[yes|no]`` - Use Embedded Git for the installation. Set to ``no`` to enable Git selection screen. Default: yes.
* ``/USEEMBEDDEDPYTHON=[yes|no]`` - Use Embedded Python version for the installation. Set to ``no`` to allow Python selection screen in the installer. Default: yes.
* ``/PYTHONNOUSERSITE=[yes|no]`` - Set PYTHONNOUSERSITE variable before launching any Python command to avoid loading Python packages from AppData\Roaming. Default: yes.
* ``/PYTHONWHEELSURL=[URL]`` - Specify URLs to PyPi repositories for resolving binary Python Wheel dependencies. The same result can be achieved by setting the environment variable PIP_EXTRA_INDEX_URL. Default: https://dl.espressif.com/pypi
* ``/SKIPSYSTEMCHECK=[yes|no]`` - Skip System Check page. Default: no.
* ``/VERYSILENT /SUPPRESSMSGBOXES /SP- /NOCANCEL`` - Perform silent installation.

### Unattended installation


The unattended installation of IDF can be achieved by following command-line parameters:

```
esp-idf-tools-setup-x.x.exe /VERYSILENT /SUPPRESSMSGBOXES /SP- /NOCANCEL
```

The installer detaches its process from the command-line. Waiting for installation to finish could be achieved by following PowerShell script:

```
esp-idf-tools-setup-x.x.exe /VERYSILENT /SUPPRESSMSGBOXES /SP- /NOCANCEL
$InstallerProcess = Get-Process esp-idf-tools-setup
Wait-Process -Id $InstallerProcess.id
```

### Custom Python and custom location of Python wheels

The IDF installer is using by default embedded Python with reference to Python Wheel mirror.

Following parameters allows to select custom Python and custom location of Python wheels:

esp-idf-tools-setup-x.x.exe /USEEMBEDDEDPYTHON=no /PYTHONWHEELSURL=https://pypi.org/simple/


### Manual installation of drivers

The installer takes care of driver installation.

The installation is pefromed by [idf-env.exe driver install --espressif --ftdi --silabs --wch](https://github.com/espressif/idf-env#quick-start-with-powershell).

The tool is downloading and installing following drivers:

  - Espressif JTAG: https://dl.espressif.com/dl/idf-driver/idf-driver-esp32-usb-jtag-2021-07-15.zip
  - FTDI: https://www.ftdichip.com/Driver/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip
  - Silabs: https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip
  - WCH: https://www.wch.cn/downloads/CH341SER_ZIP.html

The recommended tool for adding libusb support to driver (e.g. debugging of Wroower kit):

  - [UsbDriverTool](https://visualgdb.com/UsbDriverTool/)

## Developer documentation

This directory contains source files required to build the tools installer for Windows.

The installer is built using [Inno Setup](http://www.jrsoftware.org/isinfo.php).

The main source file of the installer is `src/InnoSetup/IdfToolsSetup.iss`. PascalScript code is split into multiple `*.iss` files in directory `src/InnoSetup`.

Some functionality of the installer depends on additional programs:

* [Inno Download Plugin](https://mitrichsoftware.wordpress.com/inno-setup-tools/inno-download-plugin/) — used to download additional files during the installation.

* [7-zip](https://www.7-zip.org) — used to extract downloaded IDF archives.

* [cmdlinerunner](https://github.com/espressif/innosetup-cmdlinerunner/blob/main/cmdlinerunner.c) — a helper DLL used to run external command-line programs from the installer, capture live console output, and get the exit code.

## Installation of dependencies via Chocolatey

Run with Administrator privileges:

```
choco install inno-download-plugin
```

## Building the installer

### Building Online Installer on Windows

The minimalistic version of the installer.

```
.\Build-Installer.ps1 -InstallerType online
```

Output file: `build\esp-idf-tools-setup-online-unsigned.exe`

### Building Offline Installer on Windows

The version which bundles all packages into one installer file which does not requires internet connection to complete the installation.

```
.\Build-Installer.ps1 -InstallerType offline
```

Output file: `build\esp-idf-tools-setup-offline-unsigned.exe`

### Building the installer by GitHub Actions

Build script is stored in .github\workflows

### Building the installer in Docker with Linux image

The project contains multi-stage Dockerfile which allows build of the installer even on macOS or Linux. The build is using Wine.

Build the image:
```
docker build . -t wine-innosetup
```

Copy installer from the container
```
docker run --name builder --rm wine-innosetup && docker cp builder:/opt/idf-installer/build/esp-idf-tools-setup-online-unsigned.exe . && docker stop builder
```

Another option is to execute the build manually:
```
docker run -it wine-innosetup
.\Build-Installer.ps1 -InstallerType online
```

### Testing the installer in Docker with Linux image

It's possible to build the installer using Docker with Linux image, but it's not possible to make full test of the installer. Wine is not working correctly with Windows version of Git. The recommended approach for testing in containers is to use Docker with Windows image.

### Windows development env with WSL2 and Windows Docker Containers

The best approach to quickly develop and test all aspects of the build process is to use Windows with WSL2.

Requirements:

* WSL2 and Ubuntu distribution via Microsoft Store
* Install Windows Terminal - https://github.com/microsoft/terminal
* Install Docker and switch container runner to Windows
* Install Visual Studio Code - install plugin for Inno Setup and Docker
* Install Inno Setup - `choco install innnosetup`

#### The first build of the installer

This step is bootstrapping the whole process. Open Windows Terminal, click + sign and select Ubuntu.

```
.\Build-Installer -InstallerType online
```

The setup will download the necessary dependencies and it will build the installer.

#### Build of offline version of the installer

The offline version is built by setting /DOFFLINE=yes to ISCC on the command-line. To speed up build, it's possible to redirect stdout of ISCC to the file.

```
.\Build-Installer.ps1 -InstallerType offline -OfflineBranch v4.4 >out.txt
```

To speed up development build it's possible to disable compression which is set by default to lzma.

```
.\Build-Installer.ps1 -InstallerType offline -Compression none -SignInstaller $false -OfflineBranch v4.4 >out.txt
```

Build of Espressif-IDE installer which contains also latest stable ESP-IDF:

```
.\Build-Installer.ps1 -InstallerType espressif-ide -Compression none -SignInstaller $false -OfflineBranch v4.4
```

#### Development work in idf_tool_setup.iss

Open Inno Setup and open file `src\InnoSetup\IdfToolsSetup.iss`. This is the main file of the installer

Press CTRL+F9 to rebuild the whole installer. Inno Setup detects changes only in the main file. If you change anything in include files, you need to explicitly press CTRL+F9 to build and Run.

Press F9 to run the installer.

Additional parameters to speed up development could be passed via Run - Parameters

#### Manually, step by step

* Build cmdlinerunner DLL.
  - On Linux/Mac, install mingw-w64 toolchain (`i686-w64-mingw32-gcc`). Then build the DLL using CMake:
    ```
    mkdir -p cmdlinerunner/build
    cd cmdlinerunner/build
    cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-i686-w64-mingw32.cmake -DCMAKE_BUILD_TYPE=Release ..
    cmake --build .
    ```
    This will produce `cmdlinerunner.dll` in the build directory.
  - On Windows, it is possible to build using Visual Studio, with CMake support installed. By default, VS produces build artifacts in some hard to find directory. You can adjust this in CmakeSettings.json file generated by VS.

* Download 7zip.exe [("standalone console version")](https://www.7-zip.org/download.html) and put it into `unzip` directory (to get `unzip/7za.exe`).

* Download [idf_versions.txt](https://dl.espressif.com/dl/esp-idf/idf_versions.txt) and place it into the current directory. The installer will use it as a fallback, if it can not download idf_versions.txt at run time.

* Create the `dist` directory and populate it with the tools which should be bundled with the installer. At the moment the easiest way to obtain it is to use `install.sh`/`install.bat` in IDF, and then copy the contents of `$HOME/.espressif/dist` directory. If the directory is empty, the installer should still work, and the tools will be downloaded during the installation.

* Build the installer using Inno Setup Compiler: `ISCC.exe idf_tools_setup.iss`.

### Testing of the installer

Development and testing of the installer can be simplified by using command line parameters which can be passed to the installer.

Select Run - Parameters in Inno Setup and add parameters.

Example of parameters:

```
/SKIPSYSTEMCHECK=yes /IDFVERSIONSURL=https://dl.espressif.com/dl/esp-idf/idf_versions.txt /GITRESET=no /GITREPO=C:/projects/esp-idf /GITRECURSIVE=no
```

These combinations of parameters will result:
* ``SKIPSYSTEMCHECK=yes`` - The screen with System Check will be skipped.
* ``IDFVERSIONURL`` - idf_versions.txt will be downloaded from localhost:8000
  - it's possible to add branch name into idf_versions.txt, e.g. feature/win_inst
* ``GITRESET=no`` - Git repository won't be reset after clone, it can save time and add custom changes in case of the zip archive with repository
* ``GITREPO`` - The version will be cloned from the specific location, e.g. from a local directory
* ``GITRECURSIVE=no`` - The clone of the repo won't contain modules, it speeds up the cloning process. Use when modules are not necessary.

Documentation of parameters is available in api-guides/tools/idf-windows-installer.rst

### Testing installation directly on Windows

Recommendation: For higher level of isolation you can use Docker with Windows containers described in the next chapter.

Test can be executed by following commands which will peform the installation and execute tests by accessing desktop link to PowerShell and CMD:

```
cd src\PowerShell
.\Install-Idf.ps1 -Installer ..\..\build\esp-tools-setup-online-unsigned.exe -IdfPath C:\idf-test -IdfVersion v4.2
```

### Testing installation in Docker with Windows containers

The testing script is stored in docker-compose.yml. The test performs full silent installation and executes the build of get-started example.

Commands for testing of `online` and `offline` installer with support for cache of dist and releases:

```
cd src\Docker
$env:IDF_VERSION="v4.1"; docker-compose.exe run idf-setup-online-test
$env:IDF_VERSION="release/v4.2"; docker-compose.exe run idf-setup-online-test
$env:IDF_VERSION="master"; docker-compose.exe run idf-setup-online-test
```

Command for testing `offline` type of installer which contains everything but kitchen sink.:

```
$env:IDF_VERSION="v4.2"; docker-compose.exe run idf-setup-offline-test
$env:IDF_VERSION="release/v4.2"; docker-compose.exe run idf-setup-offline-test
```

The installation log is not displayed immediately on the screen. It's stored in the file and it's displayed when the installation finishes.

Recommendation: Use Visual Studio Code with Docker plugin to work with container.
The log file is then accessible under Docker - Containers - Container - Files - Temp - install.txt - right click - Open.

### Testing multiple installations at once

Docker compose contains definition of multiple scenarios. The test can be launched by command:

```
$env:IDF_VERSION="v4.2"; docker-compose up --force-recreate
```

Note: `--force-recreate` is necessary otherwise the container will be just resumed from previous state.
### Testing the installation in Hyper-V

Docker does not support the test of installation with GUI and enabled Windows Defender. These tests can be executed in Hyper-V available on Windows. Launch `Hyper-V Manager`, create VM, and connect to it.

Use the following command to copy the installer to Hyper-V machine with the name "win10":

```
 Copy-VMFile "win10"  -SourcePath C:\projects\esp-idf\tools\windows\tool_setup\Output\esp-idf-tools-setup-unsigned.exe -DestinationPath "C:\Users\Tester\Desktop\esp-idf-tools-setup-unsigned.exe" -CreateFullPath -FileSource Host -Force
```

## Signing the installer

* Obtain the signing key (e.g `key.pem`) and the certificate chain (e.g. `certchain.pem`). Set the environment variables to point to these files:
  - `export KEYFILE=key.pem`
  - `export CERTCHAIN=certchain.pem`

* Run `sign_installer.sh` script. This will ask for the `key.pem` password and produce the signed installer in the Output directory. If you plan to run the script multiple times, you may also set `KEYPASSWORD` environment variable to the `key.pem` password, to avoid the prompt.


## Contributing L10N

Localization messages for the installer are stored in [src/InnoSetup/Languages](https://github.com/espressif/idf-installer/tree/main/src/InnoSetup/Languages).

Adding new localization: 
- create issue on [GitHub](https://github.com/espressif/idf-installer/issues)
- register new language in src/InnoSetup/IdfToolsSetup.iss

Files can be converted to XLIFF using Translate Toolkit - ini2po and po2xliff.

File format is INI in UTF-8 with BOM header. Without BOM header the localization is not correctly displayed. Use VS Code to save the file with BOM header.

### Setting up translation environment

```
python -m pipenv shell
pip install translate-toolkit iniparse
```

### Transforming file for translation

```
cp file.isl file.ini
ini2po file.ini file.po
po2xliff file.po file.xliff
```

### Processing handback

```
xliff2po file.xliff file.po
po2ini -t file.ini file.po file.ini
cp file.ini file.isl
```

- add BOM header using Save function in Visual Studio Code

## Bundle Git

Repackage of Git for Windows. Git for Windows is provided in ```.7z.exe``` format, the workflow with script repackages it to ```.zip``` format and uploads it to Espressif's download server where it is used by IDF-installer.

### How to use bundle Git

* Check the version of Git on the website https://git-scm.com/download/win
* Use the version as input into the manual workflow run
* Run the workflow ```.github/workflow/bundle-git.yaml`
* On success the Git version will be on Espressif's download server

## Automatic release of IDF Windows Installer

There is the workflow for the automatic release of IDF Windows installer (build-installer-any), in this workflow few parameters have to be specified:

* Installer Type - choose the installer type (offline, online, espressif-ide)
* ESP-IDF version - needed for offline installer type, version of ESP-IDF in the format `X.Y` or `X.Y.Z`
* Espressif IDE version - needed for espressif-ide installer type, version of ESP-IDE in the format `X.Y.Z`
* Online Installer version - needed for online installer type, version of online installer (application) in the format `X.Y`

The offline installer buttons on the index page are created based on the variable `SUPPORTED_IDF_VERSIONS` which has to be edited in the workflow file if the change is needed.

This workflow will edit all necessary files and create PR, after the PR is reviewed and merged the workflow for updating the index.html is triggered and release will be available on the web page.