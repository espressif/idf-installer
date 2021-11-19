; Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>

#define MyAppName "ESP-IDF Tools"
#define MyAppVersion "2.12"
#define MyAppPublisher "Espressif Systems (Shanghai) Co. Ltd."
#define MyAppURL "https://github.com/espressif/esp-idf"

#ifndef PYTHONVERSION
  #define PYTHONVERSION "3.8.7"
#endif
#define PythonInstallerName "idf-python-" + PYTHONVERSION + "-embed-win64.zip"
#define PythonInstallerDownloadURL "https://dl.espressif.com/dl/idf-python/idf-python-" + PYTHONVERSION + "-embed-win64.zip"

#ifndef GITVERSION
  #define GITVERSION "2.30.1"
#endif
; The URL where git is stored is not equal to it's version. Minor build has prefixes with windows
#ifndef GITVERSIONDIR
  #define GITVERSIONDIR "v2.30.0.windows.2"
#endif
#define GitInstallerName "idf-git-" + GITVERSION + "-win64.zip"
#define GitInstallerDownloadURL "https://dl.espressif.com/dl/idf-git/" + GitInstallerName

#define ECLIPSE_VERSION "2021-09"
#define ECLIPSE_INSTALLER "idf-eclipse-" + ECLIPSE_VERSION + "-win64.zip"
#define ECLIPSE_DOWNLOADURL "https://dl.espressif.com/dl/idf-eclipse/" + ECLIPSE_INSTALLER

#define IDFVersionsURL "https://dl.espressif.com/dl/esp-idf/idf_versions.txt"

; Example of file name on desktop "ESP-IDF 4.2 Powershell"
#define IDF_SHORTCUT_PREFIX "ESP-IDF"

#define IDFCmdExeShortcutDescription "Open ESP-IDF CMD Environment"
#define IDFPsShortcutDescription "Open ESP-IDF PowerShell Environment"

#define IDFEclipseShortcutDescription "Open ESP-IDF Eclipse IDE"
#define IDFEclipseShortcutFile "ESP-IDF Eclipse.lnk"

; List of default values
;  Default values can be set by command-line option when startig installer
;  or it can be stored in .INI file which can be passed to installer by /CONFIG=[PATH].
;  Code for evaluating configuration is in the file configuration.inc.iss.
#ifndef COMPRESSION
  #define COMPRESSION = 'none';
#endif
; In case of large installer set it to 'no' to avoid problem delay during starting installer
; In case of 1 GB installer it could be 30+ seconds just to start installer.
#ifndef SOLIDCOMPRESSION
  #define SOLIDCOMPRESSION = 'yes';
#endif

; Offline installation specific options
#ifndef OFFLINE
  #define OFFLINE = 'no';
#endif
#ifndef PYTHONWHEELSVERSION
  #define PYTHONWHEELSVERSION = '3.8-2021-06-15'
#endif

; Tool for managing ESP-IDF environments
#define IDF_ENV = 'idf-env.exe'

; Build time variable which determines location of sources for the installer.
; OFFLINE mentioned above is runtime variable which allows to switch way how installer operates
#ifndef INSTALLERBUILDTYPE
  #define INSTALLERBUILDTYPE = 'online'
#endif

#ifndef DIST
  #define DIST = '..\..\build\' + INSTALLERBUILDTYPE + '\dist'
#endif

#define EXT = '..\..\ext'
#define BUILD = '..\..\build\' + INSTALLERBUILDTYPE

#define COMPONENT_TOOLS = 'tools'
#define COMPONENT_TOOLS_GIT = 'tools/git'
#define COMPONENT_ECLIPSE = 'ide/eclipse'
#define COMPONENT_ECLIPSE_DESKTOP = 'ide/eclipse/desktop'
#define COMPONENT_RUST = 'ide/rust'
#define COMPONENT_POWERSHELL = 'ide/powershell'
#define COMPONENT_POWERSHELL_WINDOWS_TERMINAL = 'ide/powershell/windowsterminal'
#define COMPONENT_POWERSHELL_DESKTOP = 'ide/powershell/desktop'
#define COMPONENT_POWERSHELL_STARTMENU = 'ide/powershell/startmenu'
#define COMPONENT_CMD = 'ide/cmd'
#define COMPONENT_CMD_DESKTOP = 'ide/cmd/desktop'
#define COMPONENT_CMD_STARTMENU = 'ide/cmd/startmenu'
#define COMPONENT_DRIVER = "driver"
#define COMPONENT_DRIVER_FTDI = "driver/ftdi"
#define COMPONENT_DRIVER_SILABS = "driver/silabs"
#define COMPONENT_DRIVER_ESPRESSIF = "driver/espressif"
#define COMPONENT_TARGET = "target"
#define COMPONENT_TARGET_ESP32 = "target/esp32"
#define COMPONENT_TARGET_ESP32_C3 = "target/esp32c3"
#define COMPONENT_TARGET_ESP32_S = "target/esp32s"
#define COMPONENT_TARGET_ESP32_S3 = "target/esp32s/s3"
#define COMPONENT_TARGET_ESP32_S2 = "target/esp32s/s2"
#define COMPONENT_OPTIMIZATION = 'optimization'
#define COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD = 'optimization/espressif_download'

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{9E068D99-5C4B-4E5F-96A3-B17CF291E6BD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={%USERPROFILE}\.espressif
UsePreviousAppDir=no
DirExistsWarning=no
DefaultGroupName=ESP-IDF
DisableProgramGroupPage=yes
OutputBaseFilename=esp-idf-tools-setup-unsigned
Compression={#COMPRESSION}
SolidCompression={#SOLIDCOMPRESSION}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
LicenseFile=..\Resources\License.txt
PrivilegesRequired=lowest
SetupLogging=yes
ChangesEnvironment=yes
WizardStyle=modern
ShowLanguageDialog=yes
OutputDir=..\..\build\

; https://jrsoftware.org/ishelp/index.php?topic=setup_touchdate
; Default values are set to 'no' which might result in files that are installed on the machine
; in the 'future'. This creates a problem for Ninja/CMake which may end up in a neverending loop.
; Setting this flag to 'yes' should avoid the problem.
TimeStampsInUTC=yes

[Languages]
; English must be first, because it's used as fallback language
Name: "english"; MessagesFile: "compiler:Default.isl,Languages/IdfToolsSetup_en-US.isl"
; Language codes (requires conversion to hex): https://docs.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a
; Localization files must be saved with BOM header UTF-8
; Chinese Simplified is not part of official Inno Setup. The file originates from:
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages/BrazilianPortuguese.isl,Languages/IdfToolsSetup_pt-BR.isl"
; https://github.com/jrsoftware/issrc/blob/main/Files/Languages/Unofficial/ChineseSimplified.isl
Name: "chinese"; MessagesFile: "Languages/ChineseSimplified.isl,Languages/IdfToolsSetup_zh-CN.isl"
Name: "czech"; MessagesFile: "compiler:Languages/Czech.isl,Languages/IdfToolsSetup_cs-CZ.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages/Portuguese.isl,Languages/IdfToolsSetup_pt-PT.isl"
Name: "slovak"; MessagesFile: "compiler:Languages/Slovak.isl,Languages/IdfToolsSetup_sk-SK.isl"
Name: "spanish"; MessagesFile: "compiler:Languages/Spanish.isl,Languages/IdfToolsSetup_es-ES.isl"

[Dirs]
Name: "{app}\dist"

[Files]
;Source: "configuration.ini"; Flags: dontcopy noencryption
Source: "{#BUILD}\lib\cmdlinerunner.dll"; Flags: dontcopy
;Source: "..\..\lib\WebBrowser.dll"; Flags: dontcopy
;Source: "..\..\lib\Microsoft.Toolkit.Wpf.UI.Controls.WebView.dll"; Flags: dontcopy
Source: "{#BUILD}\lib\7za.exe"; Flags: dontcopy
Source: "{#BUILD}\lib\{#IDF_ENV}"; DestDir: "{app}"; DestName: "{#IDF_ENV}"
Source: "{#BUILD}\idf_versions.txt"; Flags: dontcopy
Source: "..\Python\idf_tools.py"; DestDir: "{app}"; DestName: "idf_tools_fallback.py" ; Flags: skipifsourcedoesntexist
; Note: this tools.json matches the requirements of IDF v3.x versions.
Source: "tools_fallback.json"; DestDir: "{app}"; DestName: "tools_fallback.json" ;Flags: skipifsourcedoesntexist
Source: "..\Batch\idf_cmd_init.bat"; DestDir: "{app}";
Source: "..\PowerShell\Initialize-Idf.ps1"; DestDir: "{app}";
Source: "{#BUILD}\dist\*"; DestDir: "{app}\dist"; Flags: skipifsourcedoesntexist;
;Source: "..\Resources\IdfSelector\*"; Flags: dontcopy
Source: "{#BUILD}\tools\idf-eclipse\*"; DestDir: "\\?\{app}\tools\idf-eclipse"; Components: "{#COMPONENT_ECLIPSE}"; Flags: recursesubdirs skipifsourcedoesntexist;
Source: "{#BUILD}\tools\idf-git\*"; DestDir: "{app}\tools\idf-git"; Flags: recursesubdirs skipifsourcedoesntexist;

; esp-idf-bundle - bundle only in case it exists, it's used only in offline installer
Source: "{#BUILD}\releases\esp-idf-bundle\*"; DestDir: "{code:GetIDFPath}"; Flags: recursesubdirs skipifsourcedoesntexist;

Source: "{#BUILD}\tools\idf-python\*"; DestDir: "{app}\tools\idf-python\"; Flags: recursesubdirs skipifsourcedoesntexist;
Source: "{#BUILD}\tools\idf-python-wheels\*"; DestDir: "{app}\tools\idf-python-wheels\"; Flags: recursesubdirs skipifsourcedoesntexist;
; Helper Python files for sanity check of Python environment - used by system_check_page
Source: "..\Python\system_check\system_check_download.py"; Flags: dontcopy
Source: "..\Python\system_check\system_check_subprocess.py"; Flags: dontcopy
Source: "..\Python\system_check\system_check_virtualenv.py"; Flags: dontcopy

Source: "{#BUILD}\tools\idf-driver\*"; DestDir: "{app}\tools\idf-driver\"; Flags: recursesubdirs skipifsourcedoesntexist;

[Types]
Name: "full"; Description: {cm:InstallationFull}
Name: "minimal"; Description: {cm:InstallationMinimal}
Name: "custom"; Description: {cm:InstallationCustom}; Flags: iscustom

[Components]
Name: "ide"; Description: {cm:ComponentIde}; Types: full custom; Flags: fixed
Name: "{#COMPONENT_ECLIPSE}"; Description: {cm:ComponentEclipse}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_ECLIPSE_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full custom
Name: "{#COMPONENT_RUST}"; Description: {cm:ComponentRust}; Types: custom
Name: "{#COMPONENT_POWERSHELL}"; Description: {cm:ComponentPowerShell}; Types: full custom; Flags: checkablealone
Name: "{#COMPONENT_POWERSHELL_WINDOWS_TERMINAL}"; Description: {cm:ComponentPowerShellWindowsTerminal}; Types: full custom
Name: "{#COMPONENT_POWERSHELL_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full custom minimal
Name: "{#COMPONENT_POWERSHELL_STARTMENU}"; Description: {cm:ComponentStartMenuShortcut}; Types: full
Name: "{#COMPONENT_CMD}"; Description: {cm:ComponentCommandPrompt}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_CMD_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full
Name: "{#COMPONENT_CMD_STARTMENU}"; Description: {cm:ComponentStartMenuShortcut}; Types: full
Name: "{#COMPONENT_DRIVER}"; Description: {cm:ComponentDrivers}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_ESPRESSIF}"; Description: {cm:ComponentDriverEspressif}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_FTDI}"; Description: {cm:ComponentDriverFtdi}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_SILABS}"; Description: {cm:ComponentDriverSilabs}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET}"; Description: {cm:ComponentTarget}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32}"; Description: {cm:ComponentTargetEsp32}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_C3}"; Description: {cm:ComponentTargetEsp32c3}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S}"; Description: {cm:ComponentTargetEsp32s}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S3}"; Description: {cm:ComponentTargetEsp32s3}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S2}"; Description: {cm:ComponentTargetEsp32s2}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_OPTIMIZATION}"; Description: {cm:ComponentOptimization}; Types: custom;
Name: "{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}"; Description: {cm:ComponentOptimizationEspressifDownload}; Types: custom; Flags: checkablealone
;Name: "{#COMPONENT_TOOLS}"; Description: "Tools"; Types: full custom; Flags: fixed;
;Name: "{#COMPONENT_TOOLS_GIT}"; Description: "Git"; Types: full custom;
;Name: "optimization\windowsdefender"; Description: "Register Windows Defender exceptions"; Types: full


;Name: "idf"; Description: "ESP-IDF"; Types: full
;Name: "idf\tools"; Description: "Chip"; Types: full
;Name: "idf\tools\chip_esp32"; Description: "ESP32"; Types: full
;Name: "idf\tools\chip_esp32\esp_idf_v4_2"; Description: "ESP-IDF v4.2"; Types: full
;Name: "idf\tools\chip_esp32\esp_idf_v4_1"; Description: "ESP-IDF v4.1"; Types: full
;Name: "idf\tools\chip_esp8266"; Description: "ESP32"; Types: full
;Name: "idf\tools\chip_esp8266\esp_idf_v3_3_4"; Description: "ESP-IDF v3.3.4"; Types: full
;Name: "idf\tools\chip_esp8266\esp_idf_v4_1"; Description: "ESP-IDF v4.1"; Types: full

[UninstallDelete]
Type: filesandordirs; Name: "{app}\dist"
Type: filesandordirs; Name: "{app}\releases"
Type: filesandordirs; Name: "{app}\tools"
Type: filesandordirs; Name: "{app}\python_env"
;Type: files; Name: "{group}\{#IDFCmdExeShortcutFile}"
;Type: files; Name: "{group}\{#IDFPsShortcutFile}"
;Type: files; Name: "{autodesktop}\{#IDFCmdExeShortcutFile}"
;Type: files; Name: "{autodesktop}\{#IDFPsShortcutFile}"

;[Tasks]
;Name: CreateLinkStartPowerShell; GroupDescription: "{cm:CreateShortcutPowerShell}"; Description: "{cm:CreateShortcutStartMenu}";
;Name: CreateLinkDeskPowerShell; GroupDescription: "{cm:CreateShortcutPowerShell}"; Description: "{cm:CreateShortcutDesktop}";

;Name: CreateLinkStartCmd; GroupDescription: "{cm:CreateShortcutCMD}"; Description: "{cm:CreateShortcutStartMenu}";
;Name: CreateLinkDeskCmd; GroupDescription: "{cm:CreateShortcutCMD}"; Description: "{cm:CreateShortcutDesktop}";

; Optimization for Online mode
;Name: UseMirror;  GroupDescription:"{cm:OptimizationTitle}"; Description: "{cm:OptimizationDownloadMirror}"; Flags: unchecked; Check: IsOnlineMode

[Run]
Filename: "{app}\dist\{#GitInstallerName}"; Parameters: "/silent /tasks="""" /norestart"; Description: {cm:RunInstallGit}; Check: GitInstallRequired
Filename: "{autodesktop}\{#IDFEclipseShortcutFile}"; Flags: runascurrentuser postinstall shellexec unchecked; Description: {cm:RunEclipse}; Components: "{#COMPONENT_ECLIPSE_DESKTOP}"
Filename: "{code:GetLauncherPathPowerShell}"; Flags: postinstall shellexec; Description: {cm:RunPowerShell}; Components: "{#COMPONENT_POWERSHELL_DESKTOP} {#COMPONENT_CMD_STARTMENU}"
Filename: "{code:GetLauncherPathCMD}"; Flags: postinstall shellexec; Description: {cm:RunCmd}; Components: "{#COMPONENT_CMD_DESKTOP} {#COMPONENT_CMD_STARTMENU}";

; WD registration checkbox is identified by 'Windows Defender' substring anywhere in its caption, not by the position index in WizardForm.TasksList.Items
; Please, keep this in mind when making changes to the item's description - WD checkbox is to be disabled on systems without the Windows Defender installed
Filename: "{app}\idf-env.exe"; Parameters: "antivirus exclusion add --all"; Flags: postinstall shellexec runhidden; Description: "{cm:OptimizationWindowsDefender}"; Check: GetIsWindowsDefenderEnabled


[UninstallRun]
Filename: "{app}\idf-env.exe"; \
  Parameters: "antivirus exclusion remove --all"; \
  WorkingDir: {app}; Flags: runhidden

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "IDF_TOOLS_PATH"; \
    ValueData: "{app}"; Flags: preservestringtype createvalueifdoesntexist uninsdeletevalue deletevalue;


#include "Configuration.iss"
#include "Utils.iss"

#include "Pages/ChoicePage.iss"
#include "Pages/CmdlinePage.iss"
#include "Pages/IdfPage.iss"
#include "Pages/GitPage.iss"
#include "Pages/PythonPage.iss"
#include "Environment.iss"
#include "Pages/SystemCheckPage.iss"
#include "Pages/IdfDownloadPage.iss"
#include "Eclipse.iss"
#include "Summary.iss"
#include "PreInstall.iss"
#include "PostInstall.iss"
