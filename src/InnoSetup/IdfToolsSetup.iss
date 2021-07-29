; Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>

#define MyAppName "ESP-IDF Tools"
#define MyAppVersion "2.10"
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

#define ECLIPSE_VERSION "2021-04"
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
Name: "english"; MessagesFile: "compiler:Default.isl,Languages/IdfToolsSetup_en-US.islu"

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
Name: "full"; Description: "Full installation"
Name: "minimal"; Description: "Minimal installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "ide"; Description: "IDE support"; Types: full custom; Flags: fixed
Name: "{#COMPONENT_ECLIPSE}"; Description: "Eclipse"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_ECLIPSE_DESKTOP}"; Description: "Desktop shortcut"; Types: full custom
Name: "{#COMPONENT_POWERSHELL}"; Description: "PowerShell"; Types: full custom; Flags: checkablealone
Name: "{#COMPONENT_POWERSHELL_WINDOWS_TERMINAL}"; Description: "Windows Terminal Dropdown Menu"; Types: full custom
Name: "{#COMPONENT_POWERSHELL_DESKTOP}"; Description: "Desktop shortcut"; Types: full custom minimal
Name: "{#COMPONENT_POWERSHELL_STARTMENU}"; Description: "Start Menu shortcut"; Types: full
Name: "{#COMPONENT_CMD}"; Description: "Command Prompt"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_CMD_DESKTOP}"; Description: "Desktop shortcut"; Types: full
Name: "{#COMPONENT_CMD_STARTMENU}"; Description: "Start Menu shortcut"; Types: full
Name: "{#COMPONENT_DRIVER}"; Description: "Drivers - Requires elevation of privileges"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_ESPRESSIF}"; Description: "Espressif - WinUSB support for JTAG (ESP32-C3/S3)"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_FTDI}"; Description: "FTDI Chip - Virtual COM Port for USB (WROVER, WROOM)"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_SILABS}"; Description: "Silicon Labs - Virtual COM Port for USB CP210x (ESP boards)"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET}"; Description: "Chip Targets - more details at https://products.espressif.com/"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32}"; Description: "ESP32"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_C3}"; Description: "ESP32-C3"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S}"; Description: "ESP32-S Series"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S3}"; Description: "ESP32-S3"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_S2}"; Description: "ESP32-S2"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_OPTIMIZATION}"; Description: "Optimization"; Flags: fixed
Name: "{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}"; Description: "Use Espressif download mirror instead of GitHub";
;Name: "{#COMPONENT_TOOLS}"; Description: "Tools"; Types: full custom; Flags: fixed;
;Name: "{#COMPONENT_TOOLS_GIT}"; Description: "Git"; Types: full custom;
;Name: "optimization\windowsdefender"; Description: "Register Windows Defender exceptions"; Types: full

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
Filename: "{app}\dist\{#GitInstallerName}"; Parameters: "/silent /tasks="""" /norestart"; Description: "Installing Git"; Check: GitInstallRequired
Filename: "{autodesktop}\{#IDFEclipseShortcutFile}"; Flags: runascurrentuser postinstall shellexec unchecked; Description: "Run ESP-IDF Eclipse Environment"; Components: "{#COMPONENT_ECLIPSE_DESKTOP}"
Filename: "{code:GetLauncherPathPowerShell}"; Flags: postinstall shellexec; Description: "Run ESP-IDF PowerShell Environment"; Components: "{#COMPONENT_POWERSHELL_DESKTOP} {#COMPONENT_CMD_STARTMENU}"
Filename: "{code:GetLauncherPathCMD}"; Flags: postinstall shellexec; Description: "Run ESP-IDF Command Prompt Environment"; Components: "{#COMPONENT_CMD_DESKTOP} {#COMPONENT_CMD_STARTMENU}";

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
