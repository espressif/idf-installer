﻿; Copyright 2019-2020 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

[LangOptions]
LanguageID=$0409

[CustomMessages]
PreInstallationCheckTitle=Pre-installation system check
PreInstallationCheckSubtitle=Verification of environment
SystemCheckStart=Starting system check ...
SystemCheckForDefender=Checking Windows Defender
SystemCheckHint=Hint
SystemCheckResultFound=FOUND
SystemCheckResultNotFound=NOT FOUND
SystemCheckResultOk=OK
SystemCheckResultFail=FAIL
SystemCheckResultError=ERR
SystemCheckResultWarn=WARN
SystemCheckStopped=Check stopped.
SystemCheckStopButtonCaption=Stop
SystemCheckComplete=Check complete.
SystemCheckForComponent=Checking installed
SystemCheckUnableToExecute=Unable to execute
SystemCheckUnableToFindFile=Unable to find file
SystemCheckRemedyMissingPip=Please use a supported version of Python available on the next screen.
SystemCheckRemedyMissingVirtualenv=Please install virtualenv and retry the installation. Suggested commands:
SystemCheckRemedyCreateVirtualenv=Please use the supported Python version that is available on the next screen.
SystemCheckRemedyPythonInVirtualenv=Please use the supported Python version that is available on the next screen.
SystemCheckRemedyBinaryPythonWheel=Please use the supported Python version that is available on the next screen.
SystemCheckRemedyFailedHttpsDownload=Please use the supported Python version that is available on the next screen.
SystemCheckRemedyFailedSubmoduleRun=Python contains a subprocess.run module intended for Python 2. Please uninstall the module. Suggested command:
SystemCheckApplyFixesButtonCaption=Apply Fixes
SystemCheckFullLogButtonCaption=Full log
SystemCheckApplyFixesConsent=Do you want to apply the commands with the suggested fixes to update your Windows environment and start a new System Check?
SystemCheckFixesSuccessful=Successful application of Fixes.
SystemCheckFixesFailed=Failed application of Fixes. Please refer to the Full log.
SystemCheckNotCompleteConsent=System check is not complete. Do you want to proceed by skipping checks?
SystemCheckRootCertificates=Checking certificates
SystemCheckRootCertificateWarning=Unable to load data from server.
SystemCheckForLongPathsEnabled=Checking "Long Paths Enabled" in Windows registry
SystemCheckRemedyFailedLongPathsEnabled=Please set registry HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled to 1. The operation requires Administrator privileges. Command:
SystemCheckRemedyApplyFixInfo=Click 'Apply Fixes' button after finishing System Check.
CreateShortcutStartMenu=Start Menu
CreateShortcutDesktop=Desktop
CreateShortcutPowerShell=PowerShell - Create shortcut for the ESP-IDF Tools:
CreateShortcutCMD=CMD - Create shortcut for the ESP-IDF Tools:
OptimizationTitle=Optimization:
OptimizationWindowsDefender=Register the ESP-IDF Tools executables as Windows Defender exclusions. The registration might improve compilation time by about 30%. The installer deployed the files on the operating system and antivirus software scanned them. The registration of exclusions requires the elevation of privileges. The exclusions can be added/removed by idf-env tool. More details: https://github.com/espressif/idf-env.
OptimizationDownloadMirror=Use Espressif download server instead of downloading tool packages from GitHub.
ErrorTooLongIdfPath=Length of the path to ESP-IDF exceeds 90 characters. Too long path might cause problem to some build tools. Please choose shorter path.
ErrorTooLongToolsPath=Length of the path to ESP-IDF Tools exceeds 90 characters. Too long path might cause problem to some build tools. Please choose shorter path.
ComponentIde=Development integrations
ComponentEclipse=Eclipse
ComponentRust=Rust language support for Xtensa (beta - requires Windows 10 SDK and MSVC C++)
ComponentDesktopShortcut=Desktop shortcut
ComponentPowerShell=PowerShell
ComponentPowerShellWindowsTerminal=Windows Terminal Dropdown Menu
ComponentStartMenuShortcut=Start Menu shortcut
ComponentCommandPrompt=Command Prompt
ComponentDrivers=Drivers - Requires elevation of privileges
ComponentDriverEspressif=Espressif - WinUSB support for JTAG (ESP32-C3/S3)
ComponentDriverFtdi=FTDI Chip - Virtual COM Port for USB (WROVER, WROOM)
ComponentDriverSilabs=Silicon Labs - Virtual COM Port for USB CP210x (ESP boards)
ComponentTarget=Chip Targets - more details at https://products.espressif.com/
ComponentTargetEsp32=ESP32
ComponentTargetEsp32c3=ESP32-C3
ComponentTargetEsp32s=ESP32-S Series
ComponentTargetEsp32s3=ESP32-S3
ComponentTargetEsp32s2=ESP32-S2
ComponentOptimization=Optimization
ComponentOptimizationEspressifDownload=Use Espressif download mirror instead of GitHub
InstallationFull=Full installation
InstallationMinimal=Minimal installation
InstallationCustom=Custom installation
RunInstallGit=Installing Git
RunEclipse=Run ESP-IDF Eclipse Environment
RunPowerShell=Run ESP-IDF PowerShell Environment
RunCmd=Run ESP-IDF Command Prompt Environment
InstallationCancelled=Installation has been cancelled.
InstallationFailed=Installation has failed with exit code
InstallationFailedAtStep=Installation has failed at step:
DirectoryAlreadyExists=Directory already exists and is not empty:
ChooseDifferentDirectory=Please choose a different directory.
SpacesInPathNotSupported=ESP-IDF build system does not support spaces in paths.
SpecialCharactersInPathNotSupported=The installation of selected version of IDF is not supported on path with special characters.
EspIdfVersion=Version of ESP-IDF
ChooseEspIdfVersion=Please choose ESP-IDF version to install
MoreInformation=For more information about ESP-IDF versions, see
EspIdfVersionInformationUrl=https://docs.espressif.com/projects/esp-idf/en/latest/versions.html
ChooseEspIdfDirectory=Choose a directory to install ESP-IDF to
DownloadOrUseExistingEspIdf=Download or use ESP-IDF
DownloadOrUseExistingEspIdfDetail=Please choose ESP-IDF version to download, or use an existing ESP-IDF copy
AvailableEspIdfVersions=Available ESP-IDF versions
ChooseExistingEspIdfDirectory=Choose existing ESP-IDF directory
DirectoryDoesNotExist=Directory does not exist:
UnableToFindIdfpy=Can not find idf.py in
UnableToFindRequirementsTxt=Can not find requirements.txt in
EspIdfToolsShouldNotBeLocatedUnderSource=Tools should not be located under ESP-IDF source code directory selected on the previous page. Please select a different location for Tools directory.
PythonVersionChoice=Python choice
PythonVersionChoiceDetail=Please choose Python version
AvailablePythonVersions=Available Python versions
UnableToWriteConfiguration=Unable to write ESP-IDF configuration to
CheckPermissionToFile=Please check the file access and retry the installation.
SwitchBranch=Switching branch
FinishingEspIdfInstallation=Finishing ESP-IDF installation
CleaningUntrackedDirectories=Cleaning untracked directories
ExtractingEspIdf=Extracting ESP-IDF
SettingUpReferenceRepository=Setting up reference repository
DownloadingEspIdf=Downloading ESP-IDF
UsingGitToClone=Using git to clone ESP-IDF repository
CopyingEspIdf=Copying ESP-IDF into the destination directory
InstallingEspIdfTools=Installing ESP-IDF tools
CheckingPythonVirtualEnvSupport=Checking Python virtualenv support
CreatingPythonVirtualEnv=Creating Python environment
InstallingPythonVirtualEnv=Installing Python environment
RepackingRepository=Re-packing the repository
UpdatingSubmodules=Updating submodules
UpdatingFileMode=Updating fileMode
UpdatingFileModeInSubmodules=Updating fileMode in submodules
UpdatingNewLines=Updating newlines
UpdatingNewLinesInSubmodules=Updating newlines in submodules
FailedToCreateShortcut=Failed to create the shortcut:
ExtractingPython=Extracting Python Interpreter
UsingEmbeddedPython=Using Embedded Python
ExtractingGit=Extracting Git
UsingEmbeddedGit=Using Embedded Git
Extracting=Extracting...
InstallationLogCreated=Installation log has been created, it may contain more information about the problem.
DisplayInstallationLog=Display the installation log now?
UsingPython=Using Python
UsingGit=Using Git
DownloadGitForWindows=Will download and install Git for Windows
UsingExistingEspIdf=Using existing ESP-IDF copy:
InstallingNewEspIdf=Will install ESP-IDF
EspIdfToolsDirectory=IDF tools directory (IDF_TOOLS_PATH):
DownloadEspIdf=Download ESP-IDF
UsingExistingEspIdfDirectory=Use an existing ESP-IDF directory
InstallingDrivers=Installing drivers
InstallingRust=Installing Rust language
SystemCheckToolsPathSpecialCharacter=System code page is set to 65001 and Tools path contains special character. It's not possible to install Eclipse on the path with a special character due to the limitation of JRE. Choose Tools location without special characters.
SystemCheckTmpPathSpecialCharacter=System code page is set to 65001 and environment variable TMP contains special character. It's not possible to start Eclipse when TMP contains character due to the limitation of JRE. Set TMP variable to the path without special characters and restart the installation.
SystemCheckActiveCodePage=Active code page:
SystemCheckUnableToDetermine=unable to determine
SystemVersionTooLow=Too old version of operating system. Please use supported version of Windows.
WindowsVersion=Windows version
SystemCheckAlternativeMirror=Testing alternative mirror
ComponentOptimizationGiteeMirror=Git mirror gitee.com/EspressifSystems/esp-idf
ComponentOptimizationGitShallow=Shallow clone (--depth 1)
SummaryComponents=Components
SummaryDrivers=Drivers
SummaryTargets=Targets
SummaryOptimization=Optimization
ComponentToitJaguar=Toit language - tool Jaguar (beta - jag.exe)
InstallingToit=Installing Toit language
