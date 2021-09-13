; Copyright 2019-2020 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

[LangOptions]
LanguageID=$041b
LanguageCodePage=1250

[CustomMessages]
PreInstallationCheckTitle=Kontrola systému pred inštaláciou
PreInstallationCheckSubtitle=Overenie prostredia
SystemCheckStart=Štart kontroly systému ...
SystemCheckForDefender=Kontrola Windows Defender
SystemCheckHint=Nápoveda
SystemCheckResultFound=NÁJDENÉ
SystemCheckResultNotFound=NENÁJDENÉ
SystemCheckResultOk=OK
SystemCheckResultFail=ZLYHANIE
SystemCheckResultError=CHYBA
SystemCheckResultWarn=VAROVANIE
SystemCheckStopped=Kontrola zastavená.
SystemCheckStopButtonCaption=Zastaviť
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
SystemCheckRootCertificateWarning=Unable to load data from server dl.espressif.com.
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
