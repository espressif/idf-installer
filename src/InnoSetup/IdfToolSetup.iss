; Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>

#define MyAppName "ESP-IDF Tools"
#define MyAppVersion "2.6"
#define MyAppPublisher "Espressif Systems (Shanghai) Co. Ltd."
#define MyAppURL "https://github.com/espressif/esp-idf"

#ifndef PYTHONVERSION
  #define PYTHONVERSION "3.8.7"
#endif
#define PythonInstallerName "idf-python-" + PYTHONVERSION + "-embed-win64.zip"
#define PythonInstallerDownloadURL "https://dl.espressif.com/dl/idf-python/idf-python-" + PYTHONVERSION + "-embed-win64.zip"

#ifndef GITVERSION
  #define GITVERSION "2.30.0.2"
#endif
; The URL where git is stored is not equal to it's version. Minor build has prefixes with windows
#ifndef GITVERSIONDIR
  #define GITVERSIONDIR "v2.30.0.windows.2"
#endif
#define GitInstallerName "Git-" + GITVERSION + "-64-bit.exe"
#define GitInstallerDownloadURL "https://github.com/git-for-windows/git/releases/download/" + GITVERSIONDIR + "/Git-" + GITVERSION + "-64-bit.exe"

#define IDFVersionsURL "https://dl.espressif.com/dl/esp-idf/idf_versions.txt"

#define IDFCmdExeShortcutDescription "Open ESP-IDF Command Prompt (cmd.exe) Environment"
#define IDFCmdExeShortcutFile "ESP-IDF Command Prompt (cmd.exe).lnk"

#define IDFPsShortcutDescription "Open ESP-IDF PowerShell Environment"
#define IDFPsShortcutFile "ESP-IDF PowerShell.lnk"

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
  #define PYTHONWHEELSVERSION = '3.8-2021-01-21'
#endif

#define EXT = '..\..\ext'

#define COMPONENT_ECLIPSE = 'ide\eclipse'
#define COMPONENT_ECLIPSE_DESKTOP = 'ide\eclipse\desktop'
#define COMPONENT_POWERSHELL = 'ide\powershell'
#define COMPONENT_POWERSHELL_DESKTOP = 'ide\powershell\desktop'
#define COMPONENT_POWERSHELL_STARTMENU = 'ide\powershell\startmenu'
#define COMPONENT_CMD = 'ide\cmd'
#define COMPONENT_CMD_DESKTOP = 'ide\cmd\desktop'
#define COMPONENT_CMD_STARTMENU = 'ide\cmd\startmenu'
#define COMPONENT_OPTIMIZATION = 'optimization'
#define COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD = 'optimization\espressif_download'

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
Source: "..\..\lib\cmdlinerunner.dll"; Flags: dontcopy 
Source: "..\..\lib\WebBrowser.dll"; Flags: dontcopy 
;Source: "..\..\lib\Microsoft.Toolkit.Wpf.UI.Controls.WebView.dll"; Flags: dontcopy 
Source: "{#EXT}\unzip\7za.exe"; Flags: dontcopy
Source: "idf_versions.txt"; Flags: dontcopy skipifsourcedoesntexist
Source: "..\..\idf_tools.py"; DestDir: "{app}"; DestName: "idf_tools_fallback.py" ; Flags: skipifsourcedoesntexist
; Note: this tools.json matches the requirements of IDF v3.x versions.
Source: "tools_fallback.json"; DestDir: "{app}"; DestName: "tools_fallback.json" ;Flags: skipifsourcedoesntexist
Source: "idf_cmd_init.bat"; DestDir: "{app}"; Flags: skipifsourcedoesntexist
Source: "idf_cmd_init.ps1"; DestDir: "{app}"; Flags: skipifsourcedoesntexist
Source: "dist\*"; DestDir: "{app}\dist"; Flags: skipifsourcedoesntexist;
;Source: "..\Resources\IdfSelector\*"; Flags: dontcopy
;Source:  "{#EXT}\Curator\*"; Flags: dontcopy recursesubdirs
Source:  "{#EXT}\tools\eclipse\*"; DestDir: "\\?\{app}\tools\eclipse"; Components: "{#COMPONENT_ECLIPSE}"; Flags: recursesubdirs 

; esp-idf-bundle - bundle only in case it exists, it's used only in offline installer
Source: "releases\esp-idf-bundle\*"; DestDir: "{code:GetIDFPath}"; Flags: recursesubdirs skipifsourcedoesntexist;

Source: "{#EXT}\tools\idf-python\*"; DestDir: "{app}\tools\idf-python\"; Flags: recursesubdirs;
Source: "{#EXT}\tools\idf-python-wheels\*"; DestDir: "{app}\tools\idf-python-wheels\"; Flags: recursesubdirs skipifsourcedoesntexist;
; Helper Python files for sanity check of Python environment - used by system_check_page
Source: "..\Python\system_check\system_check_download.py"; Flags: dontcopy skipifsourcedoesntexist
Source: "..\Python\system_check\system_check_subprocess.py"; Flags: dontcopy                      skipifsourcedoesntexist
Source: "..\Python\system_check\system_check_virtualenv.py"; Flags: dontcopy                                             skipifsourcedoesntexist
; Helper PowerShell scripts for managing exceptions in Windows Defender
Source: "tools_WD_excl.ps1"; DestDir: "{app}\dist"; Flags: skipifsourcedoesntexist
Source: "tools_WD_clean.ps1"; DestDir: "{app}\dist"; Flags: skipifsourcedoesntexist

[Components]
Name: "ide"; Description: "IDE support"; Types: full custom; Flags: fixed
Name: "{#COMPONENT_ECLIPSE}"; Description: "Eclipse"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_ECLIPSE_DESKTOP}"; Description: "Desktop shortcut"; Types: full
Name: "{#COMPONENT_POWERSHELL}"; Description: "PowerShell"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_POWERSHELL_DESKTOP}"; Description: "Desktop shortcut"; Types: full
Name: "{#COMPONENT_POWERSHELL_STARTMENU}"; Description: "Start Menu shortcut"; Types: full
Name: "{#COMPONENT_CMD}"; Description: "Command Prompt"; Types: full; Flags: checkablealone
Name: "{#COMPONENT_CMD_DESKTOP}"; Description: "Desktop shortcut"; Types: full
Name: "{#COMPONENT_CMD_STARTMENU}"; Description: "Start Menu shortcut"; Types: full
Name: "{#COMPONENT_OPTIMIZATION}"; Description: "Optimization"; Types: full custom; Flags: fixed
Name: "{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}"; Description: "Use Espressif download mirror instead of GitHub"; Types: full
;Name: "optimization\windowsdefender"; Description: "Register Windows Defender exceptions"; Types: full


;Name: "ide\eclipse\openjdk"; Description: "OpenJDK"; Types: full
;Name: "idf"; Description: "ESP-IDF"; Types: full
;Name: "idf\tools"; Description: "Chip"; Types: full
;Name: "idf\tools\chip_esp32"; Description: "ESP32"; Types: full
;Name: "idf\tools\chip_esp32\esp_idf_v4_2"; Description: "ESP-IDF v4.2"; Types: full
;Name: "idf\tools\chip_esp32\esp_idf_v4_1"; Description: "ESP-IDF v4.1"; Types: full
;Name: "idf\tools\chip_esp8266"; Description: "ESP32"; Types: full
;Name: "idf\tools\chip_esp8266\esp_idf_v3_3_4"; Description: "ESP-IDF v3.3.4"; Types: full
;Name: "idf\tools\chip_esp8266\esp_idf_v4_1"; Description: "ESP-IDF v4.1"; Types: full


;Name: "idf\tools\git"; Description: "Git"; Types: full

[UninstallDelete]
Type: filesandordirs; Name: "{app}\dist"
Type: filesandordirs; Name: "{app}\releases"
Type: filesandordirs; Name: "{app}\tools"
Type: filesandordirs; Name: "{app}\python_env"
Type: files; Name: "{group}\{#IDFCmdExeShortcutFile}"
Type: files; Name: "{group}\{#IDFPsShortcutFile}"
Type: files; Name: "{autodesktop}\{#IDFCmdExeShortcutFile}"
Type: files; Name: "{autodesktop}\{#IDFPsShortcutFile}"

;[Tasks]
;Name: CreateLinkStartPowerShell; GroupDescription: "{cm:CreateShortcutPowerShell}"; Description: "{cm:CreateShortcutStartMenu}";
;Name: CreateLinkDeskPowerShell; GroupDescription: "{cm:CreateShortcutPowerShell}"; Description: "{cm:CreateShortcutDesktop}";

;Name: CreateLinkStartCmd; GroupDescription: "{cm:CreateShortcutCMD}"; Description: "{cm:CreateShortcutStartMenu}";
;Name: CreateLinkDeskCmd; GroupDescription: "{cm:CreateShortcutCMD}"; Description: "{cm:CreateShortcutDesktop}";

; Optimization for Online mode
;Name: UseMirror;  GroupDescription:"{cm:OptimizationTitle}"; Description: "{cm:OptimizationDownloadMirror}"; Flags: unchecked; Check: IsOnlineMode

[Run]
Filename: "{app}\dist\{#GitInstallerName}"; Parameters: "/silent /tasks="""" /norestart"; Description: "Installing Git"; Check: GitInstallRequired
Filename: "{autodesktop}\{#IDFEclipseShortcutFile}"; Flags: postinstall shellexec unchecked; Description: "Run ESP-IDF Eclipse Environment"; Components: "{#COMPONENT_ECLIPSE_DESKTOP}"
Filename: "{autodesktop}\{#IDFPsShortcutFile}"; Flags: postinstall shellexec unchecked; Description: "Run ESP-IDF PowerShell Environment"; Components: "{#COMPONENT_POWERSHELL_DESKTOP}"
Filename: "{autodesktop}\{#IDFCmdExeShortcutFile}"; Flags: postinstall shellexec unchecked; Description: "Run ESP-IDF Command Prompt Environment"; Components: "{#COMPONENT_CMD_DESKTOP}"

;Filename: "{group}\{#IDFPsShortcutFile}"; Flags: postinstall shellexec unchecked; Description: "Run ESP-IDF PowerShell Environment"; Check: IsPowerShellInstalled
;Filename: "{group}\{#IDFCmdExeShortcutFile}"; Flags: postinstall shellexec unchecked; Description: "Run ESP-IDF Command Prompt Environment"; Check: IsCmdInstalled
; WD registration checkbox is identified by 'Windows Defender' substring anywhere in its caption, not by the position index in WizardForm.TasksList.Items
; Please, keep this in mind when making changes to the item's description - WD checkbox is to be disabled on systems without the Windows Defender installed
Filename: "powershell"; Parameters: "-ExecutionPolicy ByPass -File ""{app}\dist\tools_WD_excl.ps1"" -AddExclPath ""{app}\*.exe"""; Flags: postinstall shellexec runhidden; Description: "{cm:OptimizationWindowsDefender}"; Check: GetIsWindowsDefenderEnabled


[UninstallRun]
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{app}\dist\tools_WD_clean.ps1"" -RmExclPath ""{app}"""; \
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
#include "Pages/SystemCheckPage.iss"
#include "Pages/IdfDownloadPage.iss"
#include "Environment.iss"
#include "Eclipse.iss"
#include "Summary.iss"
#include "PreInstall.iss"
#include "PostInstall.iss"
