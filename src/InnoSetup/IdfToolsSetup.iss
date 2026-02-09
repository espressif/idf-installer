; Copyright 2019-2022 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>

; Following languages are supported only in online version
#ifndef APPNAME
#define MyAppName "ESP-IDF Tools"
#else
#define MyAppName APPNAME
#endif

#ifdef VERSION
#define MyAppVersion VERSION
#else
#define MyAppVersion "2.3.4"
#endif

#define MyAppPublisher "Espressif Systems (Shanghai) Co. Ltd."
#define MyAppURL "https://github.com/espressif/esp-idf"

#define ESPUP_DOWNLOADURL "https://github.com/esp-rs/espup/releases/latest/download/espup-x86_64-pc-windows-msvc.exe"
#define RUSTUP_DOWNLOADURL "https://win.rustup.rs/x86_64"
#define VS_BUILD_TOOLS_DOWNLOADURL "https://aka.ms/vs/17/release/vs_buildtools.exe"
#define VC_REDIST_DOWNLOADURL "https://aka.ms/vs/17/release/vc_redist.x64.exe"
#define MSYS2_DOWNLOADURL "https://repo.msys2.org/distrib/msys2-x86_64-latest.sfx.exe"
#define CARGO_ESPFLASH_DOWNLOADURL "https://github.com/esp-rs/espflash/releases/latest/download/cargo-espflash-x86_64-pc-windows-msvc.zip"
#define CARGO_GENERATE_DOWNLOADURL "https://github.com/cargo-generate/cargo-generate/releases/download/v0.17.6/cargo-generate-v0.17.6-x86_64-pc-windows-msvc.tar.gz"
#define LDPROXY_DOWNLOADURL "https://github.com/esp-rs/embuild/releases/latest/download/ldproxy-x86_64-pc-windows-msvc.zip"

#ifndef PYTHONVERSION
  #define PYTHONVERSION "3.11.2"
#endif
#define PythonInstallerName "idf-python-" + PYTHONVERSION + "-embed-win64.zip"
#define PythonInstallerDownloadURL "https://dl.espressif.com/dl/idf-python/idf-python-" + PYTHONVERSION + "-embed-win64.zip"
;#define PythonInstallerDownloadURL "https://github.com/espressif/idf-python/releases/download/v" + PYTHONVERSION + "/idf-python-" + PYTHONVERSION + "-embed-win64.zip"

#ifndef GITVERSION
  #define GITVERSION "2.44.0"
#endif
#define GitInstallerName "idf-git-" + GITVERSION + "-win64.zip"
#define GitInstallerDownloadURL "https://dl.espressif.com/dl/idf-git/" + GitInstallerName

#ifndef ESPRESSIFIDEVERSION
  #define ESPRESSIFIDEVERSION "3.1.0"
#endif

#define ECLIPSE_INSTALLER "Espressif-IDE-" + ESPRESSIFIDEVERSION + "-win32.win32.x86_64.zip"
#define ECLIPSE_DOWNLOADURL "https://dl.espressif.com/dl/idf-eclipse-plugin/ide/" + ECLIPSE_INSTALLER

#define JDK_INSTALLER "amazon-corretto-11-x64-windows-jdk.zip"
#ifndef JDKVERSION
  #define JDKVERSION "jdk17.0.6_10"
#endif

#ifndef JDKARTIFACTVERSION
  #define JDKARTIFACTVERSION  "17.0.6.10.1"
#endif
#define JDK_DOWNLOADURL "https://corretto.aws/downloads/resources/" + JDKARTIFACTVERSION + "/amazon-corretto-" + JDKARTIFACTVERSION + "-windows-x64-jdk.zip"

#define IDFVersionsURL "https://dl.espressif.com/dl/esp-idf/idf_versions.txt"

; Example of file name on desktop "ESP-IDF 4.2 Powershell"
#define IDF_SHORTCUT_PREFIX "ESP-IDF"

#define IDFCmdExeShortcutDescription "Open ESP-IDF CMD Environment"
#define IDFPsShortcutDescription "Open ESP-IDF PowerShell Environment"

#define IDFEclipseShortcutDescription "Open Espressif-IDE"
#define IDFEclipseShortcutFile "Espressif-IDE.lnk"

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
  #define PYTHONWHEELSVERSION = '3.11-2023-03-05'
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

#define COMPONENT_FRAMEWORK "framework"
#define COMPONENT_FRAMEWORK_ESP_IDF = "framework/esp_idf"

#define COMPONENT_REGISTRY "registry"

#define COMPONENT_TOOLS = 'tools'
#define COMPONENT_TOOLS_GIT = 'tools/git'
#define COMPONENT_IDE = 'ide'
#define COMPONENT_ECLIPSE = 'ide/eclipse'
#define COMPONENT_ECLIPSE_JDK = 'ide/eclipse/jdk'
#define COMPONENT_ECLIPSE_DESKTOP = 'ide/eclipse/desktop'
#define COMPONENT_RUST = 'ide/rust'
#define COMPONENT_RUST_GNU = 'ide/rust/gnu'
#define COMPONENT_RUST_GNU_MINGW = 'ide/rust/gnu/mingw'
#define COMPONENT_RUST_MSVC = 'ide/rust/msvc'
#define COMPONENT_RUST_MSVC_VCTOOLS = 'ide/rust/msvc/vctools'
#define COMPONENT_RUST_BINARY_CRATES = 'ide/rust/binary_crates'
#define COMPONENT_TOIT_JAGUAR = 'ide/toitjaguar'
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
#define COMPONENT_DRIVER_WCH = "driver/wch"
#define COMPONENT_TARGET = "target"
#define COMPONENT_TARGET_ESP32 = "target/esp32"
#define COMPONENT_TARGET_ESP32_C = "target/esp32c"
#define COMPONENT_TARGET_ESP32_C2 = "target/esp32c/esp32c2"
#define COMPONENT_TARGET_ESP32_C3 = "target/esp32c/esp32c3"
#define COMPONENT_TARGET_ESP32_C6 = "target/esp32c/esp32c6"
#define COMPONENT_TARGET_ESP32_C5 = "target/esp32c/esp32c5"
#define COMPONENT_TARGET_ESP32_C61 = "target/esp32c/esp32c61"
#define COMPONENT_TARGET_ESP32_H = "target/esp32h"
#define COMPONENT_TARGET_ESP32_H2 = "target/esp32c/esp32h2"
#define COMPONENT_TARGET_ESP32_S = "target/esp32s"
#define COMPONENT_TARGET_ESP32_S3 = "target/esp32s/s3"
#define COMPONENT_TARGET_ESP32_S2 = "target/esp32s/s2"
#define COMPONENT_TARGET_ESP32_P = "target/esp32p"
#define COMPONENT_TARGET_ESP32_P4 = "target/esp32p/p4"
#define COMPONENT_OPTIMIZATION = 'optimization'
#define COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD = 'optimization/espressif_download'
#define COMPONENT_OPTIMIZATION_GIT_MIRROR = 'optimization/git_mirror'
#define COMPONENT_OPTIMIZATION_GIT_MIRROR_JIHULAB = 'optimization/git_mirror/jihulab_mirror'
#define COMPONENT_OPTIMIZATION_GIT_MIRROR_GITEE = 'optimization/git_mirror/gitee_mirror'
#define COMPONENT_OPTIMIZATION_GIT_SHALLOW = 'optimization/git_shallow'

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
DefaultDirName={sd}\Espressif
UsePreviousAppDir=no
DiskSpanning=no
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
SetupIconFile=..\Resources\espressif.ico

; Testing build with larger disk size requires DiskSpanning - e.g. Offline without compression
#ifdef DISKSPANNING
DiskSpanning=yes
#endif

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
Source: "{#BUILD}\espidf.constraints.v*.txt"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;

; IDF Documentation
#if OFFLINE == 'yes'
Source: "{#BUILD}\IDFdocumentation.html"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#BUILD}\IDFdocumentation.pdf"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
#endif

; createallsubdirs is necessary for git repo. Otherwise empty directories disappears
#ifdef FRAMEWORK_ESP_IDF
Source: "{#BUILD}\frameworks\*"; DestDir: "\\?\{app}\frameworks\"; Components: "{#COMPONENT_FRAMEWORK_ESP_IDF}"; Flags: recursesubdirs createallsubdirs skipifsourcedoesntexist;
#endif

Source: "{#BUILD}\tools\*"; DestDir: "\\?\{app}\tools";  Components: "{#COMPONENT_FRAMEWORK}"; Flags: recursesubdirs skipifsourcedoesntexist;

; Helper Python files for sanity check of Python environment - used by system_check_page
Source: "..\Python\system_check\system_check_download.py"; Flags: dontcopy
Source: "..\Python\system_check\system_check_subprocess.py"; Flags: dontcopy
Source: "..\Python\system_check\system_check_virtualenv.py"; Flags: dontcopy

;Source: "{#BUILD}\registry\*"; DestDir: "\\?\{app}\registry\"; Components: "{#COMPONENT_REGISTRY}"; Flags: recursesubdirs createallsubdirs skipifsourcedoesntexist;

[Types]
Name: "full"; Description: {cm:InstallationFull}
Name: "minimal"; Description: {cm:InstallationMinimal}
Name: "custom"; Description: {cm:InstallationCustom}; Flags: iscustom

[Components]
Name: "{#COMPONENT_FRAMEWORK}"; Description: "Frameworks"; Types: full minimal custom;

;Name: "{#COMPONENT_REGISTRY}"; Description: "IDF components"; Types: full custom;

#ifdef FRAMEWORK_ESP_IDF
Name: "{#COMPONENT_FRAMEWORK_ESP_IDF}"; Description: "ESP-IDF {#FRAMEWORK_ESP_IDF}"; Types: full custom; Flags: checkablealone
#endif

Name: "{#COMPONENT_IDE}"; Description: {cm:ComponentIde}; Types: full custom;

#ifdef ESPRESSIFIDE
  #if OFFLINE == 'yes'
    Name: "{#COMPONENT_ECLIPSE}"; Description: {cm:ComponentEclipse}; Types: custom; Flags: checkablealone
    Name: "{#COMPONENT_ECLIPSE_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full custom
    Name: "{#COMPONENT_ECLIPSE_JDK}"; Description: {cm:ComponentJdk}; Types: full custom
  #endif
  #if OFFLINE == 'no'
    Name: "{#COMPONENT_ECLIPSE}"; Description: {cm:ComponentEclipse}; Types: custom; Flags: checkablealone
    Name: "{#COMPONENT_ECLIPSE_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: custom
    Name: "{#COMPONENT_ECLIPSE_JDK}"; Description: {cm:ComponentJdk}; Types: custom
  #endif
#endif

; Following languages are supported only in online version
#if OFFLINE == 'no'
Name: "{#COMPONENT_RUST}"; Description: {cm:ComponentRust}; Types: custom
Name: "{#COMPONENT_RUST_MSVC}"; Description: {cm:ComponentRustMsvc}; Types: custom; Flags: checkablealone exclusive
Name: "{#COMPONENT_RUST_MSVC_VCTOOLS}"; Description: {cm:ComponentRustMsvcVctools}; Types: custom; Flags: checkablealone
Name: "{#COMPONENT_RUST_GNU}"; Description: {cm:ComponentRustGnu}; Types: custom; Flags: checkablealone exclusive
Name: "{#COMPONENT_RUST_GNU_MINGW}"; Description: {cm:ComponentRustGnuMinGW}; Types: custom; Flags: checkablealone dontinheritcheck
Name: "{#COMPONENT_RUST_BINARY_CRATES}"; Description: {cm:ComponentRustBinaryCrates}; Types: custom; Flags: checkablealone
Name: "{#COMPONENT_TOIT_JAGUAR}"; Description: {cm:ComponentToitJaguar}; Types: custom
#endif

Name: "{#COMPONENT_POWERSHELL}"; Description: {cm:ComponentPowerShell}; Types: full custom; Flags: checkablealone
Name: "{#COMPONENT_POWERSHELL_WINDOWS_TERMINAL}"; Description: {cm:ComponentPowerShellWindowsTerminal}; Types: full custom
Name: "{#COMPONENT_POWERSHELL_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full custom minimal
Name: "{#COMPONENT_POWERSHELL_STARTMENU}"; Description: {cm:ComponentStartMenuShortcut}; Types: full
Name: "{#COMPONENT_CMD}"; Description: {cm:ComponentCommandPrompt}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_CMD_DESKTOP}"; Description: {cm:ComponentDesktopShortcut}; Types: full
Name: "{#COMPONENT_CMD_STARTMENU}"; Description: {cm:ComponentStartMenuShortcut}; Types: full
Name: "{#COMPONENT_DRIVER}"; Description: {cm:ComponentDrivers}; Types: full;
Name: "{#COMPONENT_DRIVER_ESPRESSIF}"; Description: {cm:ComponentDriverEspressif}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_FTDI}"; Description: {cm:ComponentDriverFtdi}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_SILABS}"; Description: {cm:ComponentDriverSilabs}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_DRIVER_WCH}"; Description: {cm:ComponentDriverWch}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET}"; Description: {cm:ComponentTarget}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32}"; Description: {cm:ComponentTargetEsp32}; Types: full; Flags: checkablealone

#ifndef DISABLE_TARGET_ESP32_C3
Name: "{#COMPONENT_TARGET_ESP32_C}"; Description: {cm:ComponentTargetEsp32c}; Types: full; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_C2
Name: "{#COMPONENT_TARGET_ESP32_C2}"; Description: {cm:ComponentTargetEsp32c2}; Types: custom; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_C3
Name: "{#COMPONENT_TARGET_ESP32_C3}"; Description: {cm:ComponentTargetEsp32c3}; Types: full; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_C6
Name: "{#COMPONENT_TARGET_ESP32_C6}"; Description: {cm:ComponentTargetEsp32c6}; Types: full; Flags: checkablealone
Name: "{#COMPONENT_TARGET_ESP32_H}"; Description: {cm:ComponentTargetEsp32h}; Types: full;
Name: "{#COMPONENT_TARGET_ESP32_H2}"; Description: {cm:ComponentTargetEsp32h2}; Types: custom; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_C5
Name: "{#COMPONENT_TARGET_ESP32_C5}"; Description: {cm:ComponentTargetEsp32c5}; Types: full; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_C61
Name: "{#COMPONENT_TARGET_ESP32_C61}"; Description: {cm:ComponentTargetEsp32c61}; Types: full; Flags: checkablealone
#endif

Name: "{#COMPONENT_TARGET_ESP32_S}"; Description: {cm:ComponentTargetEsp32s}; Types: full;
Name: "{#COMPONENT_TARGET_ESP32_S2}"; Description: {cm:ComponentTargetEsp32s2}; Types: full; Flags: checkablealone

#ifndef DISABLE_TARGET_ESP32_S3
Name: "{#COMPONENT_TARGET_ESP32_S3}"; Description: {cm:ComponentTargetEsp32s3}; Types: full; Flags: checkablealone
#endif

#ifndef DISABLE_TARGET_ESP32_P4
Name: "{#COMPONENT_TARGET_ESP32_P}"; Description: {cm:ComponentTargetEsp32p}; Types: full;

Name: "{#COMPONENT_TARGET_ESP32_P4}"; Description: {cm:ComponentTargetEsp32p4}; Types: full; Flags: checkablealone
#endif

; Following optimization are supported only in online version
#if OFFLINE == 'no'
Name: "{#COMPONENT_OPTIMIZATION}"; Description: {cm:ComponentOptimization}; Types: custom;
Name: "{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}"; Description: {cm:ComponentOptimizationEspressifDownload}; Types: full custom; Flags: checkablealone
Name: "{#COMPONENT_OPTIMIZATION_GIT_MIRROR}"; Description: {cm:ComponentOptimizationGitMirror}; Types: custom;
Name: "{#COMPONENT_OPTIMIZATION_GIT_MIRROR_JIHULAB}"; Description: {cm:ComponentOptimizationJihulabMirror}; Types: custom; Flags: checkablealone exclusive
Name: "{#COMPONENT_OPTIMIZATION_GIT_MIRROR_GITEE}"; Description: {cm:ComponentOptimizationGiteeMirror}; Types: custom; Flags: checkablealone exclusive
Name: "{#COMPONENT_OPTIMIZATION_GIT_SHALLOW}"; Description: {cm:ComponentOptimizationGitShallow}; Types: full custom; Flags: checkablealone
#endif

[UninstallDelete]
Type: filesandordirs; Name: "{app}\dist"
Type: filesandordirs; Name: "{app}\releases"
Type: filesandordirs; Name: "{app}\tools"
Type: filesandordirs; Name: "{app}\python_env"
Type: filesandordirs; Name: "{app}"
Type: filesandordirs; Name: "{autostartmenu}\Programs\ESP-IDF"
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

;#ifdef ESPRESSIFIDE
;Filename: "{autodesktop}\{#IDFEclipseShortcutFile}"; Flags: runascurrentuser postinstall shellexec; Description: {cm:RunEclipse}; Components: "{#COMPONENT_ECLIPSE_DESKTOP}"
;#endif

Filename: "{code:GetLauncherPathPowerShell}"; Flags: postinstall shellexec; Description: {cm:RunPowerShell}; Components: "{#COMPONENT_POWERSHELL_DESKTOP} {#COMPONENT_CMD_STARTMENU}"; Check: IsInstallSuccess;
Filename: "{code:GetLauncherPathCMD}"; Flags: postinstall shellexec; Description: {cm:RunCmd}; Components: "{#COMPONENT_CMD_DESKTOP} {#COMPONENT_CMD_STARTMENU}"; Check: IsInstallSuccess;

#if OFFLINE == 'no'
Filename: "cmd"; Parameters: "/c start https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html"; Flags: nowait postinstall; Description: {cm:PointToDocumentation}; Check: IsInstallSuccess;
#endif

#if OFFLINE == 'yes'
Filename: "cmd"; Parameters: "/c start """" ""{app}\IDFdocumentation.html"""; Flags: nowait postinstall; Description: {cm:PointToDocumentation}; Check: IsInstallSuccess and FileExists(ExpandConstant('{app}\IDFdocumentation.html'));
Filename: "cmd"; Parameters: "/c start """" ""{app}\IDFdocumentation.pdf"""; Flags: nowait postinstall; Description: {cm:PointToDocumentation}; Check: IsInstallSuccess and FileExists(ExpandConstant('{app}\IDFdocumentation.pdf'));
#endif

; WD registration checkbox is identified by 'Windows Defender' substring anywhere in its caption, not by the position index in WizardForm.TasksList.Items
; Please, keep this in mind when making changes to the item's description - WD checkbox is to be disabled on systems without the Windows Defender installed
Filename: "{app}\idf-env.exe"; Parameters: "antivirus exclusion add --all"; Flags: postinstall shellexec runhidden; Description: "{cm:OptimizationWindowsDefender}"; Check: GetIsWindowsDefenderEnabled


[UninstallRun]
Filename: "{cmd}"; Parameters: "/C del /q ""{autodesktop}\ESP-IDF*PowerShell*"" ""{autodesktop}\ESP-IDF*CMD*"""
Filename: "{app}\idf-env.exe"; \
  Parameters: "antivirus exclusion remove --all"; \
  WorkingDir: {app}; Flags: runhidden

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "IDF_TOOLS_PATH"; \
    ValueData: "{app}"; Flags: preservestringtype createvalueifdoesntexist uninsdeletevalue deletevalue;
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "IDF_COMPONENT_STORAGE_URL"; \
    ;ValueData: "file:///{code:GetPathWithForwardSlashes|{app}}/registry;default"; Flags: preservestringtype createvalueifdoesntexist uninsdeletevalue deletevalue;
Root: HKCU; Subkey: "Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x64"; \
    Check: NeedsAddPathToVCTools('C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x64')
Root: HKCU; Subkey: "Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};C:\msys64\mingw64\bin"; \
    Check: NeedsAddPathToMinGW('C:\msys64\mingw64\bin')

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
