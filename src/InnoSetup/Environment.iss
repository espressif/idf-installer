[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Downloading ESP-IDF ------------------------------ }

var
  IDFZIPFileVersion, IDFZIPFileName: String;
  IDFDownloadAvailableVersions: TArrayOfString;

{ Get path to IdfEnv process for managing installed instances of ESP-IDF. }
function GetIdfEnvCommand(Command: String):String;
begin
  Result := ExpandConstant('{tmp}\{#IDF_ENV} ') + Command;
end;

function GetEspupPath():String;
begin
  Result := ExpandConstant('{app}\tools\espup\');
end;

function GetEspupExe():String;
begin
  Result := GetEspupPath() + 'espup.exe';
end;

function GetEspupCommand(Command: String):String;
begin
  Result := GetEspupExe() + ' ' + Command;
end;

function GetRustupPath():String;
begin
  Result := ExpandConstant('{app}\tools\rustup\');
end;

function GetRustupExe():String;
begin
  Result := GetRustupPath() + 'rustup-init.exe';
end;

function GetRustupCommand(Command: String):String;
begin
  Result := GetRustupExe() + ' ' + Command;
end;

function GetVSBuildToolsPath():String;
begin
  Result := ExpandConstant('{app}\tools\vs_build_tools\');
end;

function GetVSBuildToolsExe():String;
begin
  Result := GetVSBuildToolsPath() + 'vs_build_tools.exe';
end;

function GetVSBuildToolsCommand(Command: String):String;
begin
  Result := GetVSBuildToolsExe() + ' ' + Command;
end;

function GetVCRedistPath():String;
begin
  Result := ExpandConstant('{app}\tools\vc_redist\');
end;

function GetVCRedistExe():String;
begin
  Result := GetVCRedistPath() + 'vc_redist.exe';
end;

function GetVCRedistCommand(Command: String):String;
begin
  Result := GetVCRedistExe() + ' ' + Command;
end;

function GetCargoBinPath():String;
begin
  Result := ExpandConstant('{userdesktop}\..\.cargo\bin\');
end;

function GetRustToolchainPath():String;
begin
  Result := ExpandConstant('{userdesktop}\..\.rustup\toolchains\esp\');
end;

function GetCargoExe():String;
begin
  Result := GetCargoBinPath() + 'cargo.exe';
end;

function GetCargoCommand(Command: String):String;
begin
  Result := GetCargoExe() + ' ' + Command;
end;

function GetCargoEspflashZip():String;
begin
  Result := GetCargoBinPath() + 'cargo-espflash.zip';
end;

function GetCargoEspflashExe():String;
begin
  Result := GetCargoBinPath() + 'cargo-espflash.exe';
end;

function GetCargoGenerateTarGzip():String;
begin
  Result := GetCargoBinPath() + 'cargo-generate.tar.gz';
end;

function GetCargoGenerateTar():String;
begin
  Result := GetCargoBinPath() + 'cargo-generate.tar';
end;

function GetCargoGenerateExe():String;
begin
  Result := GetCargoBinPath() + 'cargo-generate.exe';
end;

function GetLdproxyZip():String;
begin
  Result := GetCargoBinPath() + 'ldproxy.zip';
end;

function GetLdproxyExe():String;
begin
  Result := GetCargoBinPath() + 'ldproxy.exe';
end;

function GetMsys2Path():String;
begin
  Result := ExpandConstant('{app}\tools\msys2\');
end;

function GetMsys2Exe():String;
begin
  Result := GetMsys2Path() + 'msys2.exe';
end;

function GetMsys2Command(Command: String):String;
begin
  Result := GetMsys2Exe() + ' ' + Command;
end;

function ExecIdfEnv(Parameters: String):String;
var
  Command: String;
begin
  Command := GetIdfEnvCommand(Parameters);
  Result := ExecuteProcess(Command);
  Log('Result: ' + Result);
end;

function GetAntivirusName():String;
begin
  Result := ExecIdfEnv('antivirus get --property displayName');
end;

procedure InstallDrivers(DriverList: String);
begin
  DoCmdlineInstall(CustomMessage('InstallingDrivers'), CustomMessage('InstallingDrivers'), GetIdfEnvCommand('driver install ' + DriverList));
end;

procedure IDFAddDownload();
{ Download zip archive - only for .zip options (otherwise using git clone) }
var
  Url, MirrorUrl: String;
begin
  IDFZIPFileVersion := IDFDownloadVersion;

  Log('IDFZIPFileVersion: ' + IDFZIPFileVersion);

  if IDFZIPFileVersion <> '' then
  begin
    Url := 'https://github.com/espressif/esp-idf/releases/download/' + IDFZIPFileVersion + '/esp-idf-' + IDFZIPFileVersion + '.zip';
    MirrorUrl := 'https://dl.espressif.com/github_assets/espressif/esp-idf/releases/download/' + IDFZIPFileVersion + '/esp-idf-' + IDFZIPFileVersion + '.zip';
    IDFZIPFileName := ExpandConstant('{app}\releases\esp-idf-' + IDFZIPFileVersion + '.zip');

    if not FileExists(IDFZIPFileName) then
    begin
      Log('IDFZIPFileName: ' + IDFZIPFileName + ' exists');
      ForceDirectories(ExpandConstant('{app}\releases'))
      Log('Adding download: ' + Url + ', mirror: ' + MirrorUrl + ', destination: ' + IDFZIPFileName);
      idpAddFile(Url, IDFZIPFileName);
      idpAddMirror(Url, MirrorUrl);
    end else begin
      Log('IDFZIPFileName: ' + IDFZIPFileName + ' does not exist');
    end;
  end;
end;

procedure RemoveAlternatesFile(Path: String);
begin
  Log('Removing ' + Path);
  DeleteFile(Path);
end;

{
  Initialize submodules - required to call when switching branches in existing repo.
  E.g. created by offline installer
}
procedure GitUpdateSubmodules(Path: String);
var
  CmdLine: String;
begin
  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule update --init --recursive';
  Log('Updating submodules: ' + CmdLine);
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingSubmodules'), CmdLine);
end;

{
  Run git config fileMode is repairing problem when git repo was zipped on Linux and extracted on Windows.
  The repo and submodules are marked as dirty which confuses users that fresh installation already contains changes.
  More information: https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-config.html
}
procedure GitRepoFixFileMode(Path: String);
var
  CmdLine: String;
begin
  CmdLine := GitExecutablePath + ' -C ' + Path + ' config --local core.fileMode false';
  Log('Setting core.fileMode on repository: ' + CmdLine);
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingFileMode'), CmdLine);

  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule foreach --recursive git config --local core.fileMode false';
  Log('Setting core.fileMode on repository for submodules: ' + CmdLine);
  PerformCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingFileModeInSubmodules'), CmdLine);
end;

{ Run git reset --hard in the repo and in the submodules, to fix the newlines. }
procedure GitResetHard(Path: String);
var
  CmdLine: String;
begin
  if (not IsGitResetAllowed) then begin
    Log('Git reset disabled by command line option /GITRESET=no.');
    Exit;
  end;

  CmdLine := GitExecutablePath + ' -C ' + Path + ' reset --hard';
  Log('Resetting the repository: ' + CmdLine);
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingNewLines'), CmdLine);

  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule foreach git reset --hard';
  Log('Resetting the submodules: ' + CmdLine);
  PerformCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingNewLinesInSubmodules'), CmdLine);
end;

{ Run git clean - clean leftovers after switching between tags }
{ The repo should be created with: git config --local clean.requireForce false}
procedure GitCleanForceDirectory(Path: String);
var
  CmdLine: String;
begin
  if (not IsGitCleanAllowed) then begin
    Log('Git clean disabled by command line option /GITCLEAN=no.');
    Exit;
  end;

  CmdLine := GitExecutablePath + ' -C ' + Path + ' clean --force -d';
  Log('Resetting the repository: ' + CmdLine);
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('CleaningUntrackedDirectories'), CmdLine);
end;


{
  There are 3 possible ways how an ESP-IDF copy can be obtained:
  - Download the .zip archive with submodules included, extract to destination directory,
    then do 'git reset --hard' and 'git submodule foreach git reset --hard' to correct for
    possibly different newlines. This is done for release versions.
  - Do a git clone of the Github repository into the destination directory.
    This is done for the master branch.
  - Download the .zip archive of a "close enough" release version, extract into a temporary
    directory. Then do a git clone of the Github repository, using the temporary directory
    as a '--reference'. This is done for other versions (such as release branches).
}

procedure ApplyIdfMirror(Path: String; Url: String; SubmoduleUrl: String);
var
  Command: String;
begin
  Command := GetIdfEnvCommand('idf mirror --idf-path "' + Path + '" --url "' + Url + '" --submodule-url "' + SubmoduleUrl + '" --progress')
  if (Length(GitDepth) > 0) then begin
    Command := Command + ' --depth ' + GitDepth;
  end;
  DoCmdlineInstall(CustomMessage('UpdatingSubmodules'), CustomMessage('UpdatingSubmodules'), Command);
end;

procedure IDFDownloadInstall();
var
  CmdLine: String;
  IDFTempPath: String;
  IDFPath: String;
  NeedToClone: Boolean;
begin
  IDFPath := IDFDownloadPath;
  { If there is a release archive to download, IDFZIPFileName and IDFZIPFileVersion will be set.
    See GetIDFZIPFileVersion function.
  }
  NeedToClone := False;

  if WildCardMatch(IDFDownloadVersion, 'release*') then
  begin
    { Instead of downloading .zip archive and then fast forward, performing clone for the release branches }
    NeedToClone := True;
    Log('Performing full clone for the release branch.');
  end;
  
  if (not NeedToClone) and (IDFZIPFileName <> '') then
  begin
    CmdLine := ExpandConstant('"{tmp}\7za.exe" x "-o' + ExpandConstant('{tmp}') + '" -r -aoa "' + IDFZIPFileName + '"');
    IDFTempPath := ExpandConstant('{tmp}\esp-idf-') + IDFZIPFileVersion;
    Log('Extracting ESP-IDF reference repository: ' + CmdLine);
    Log('Reference repository path: ' + IDFTempPath);
    DoCmdlineInstall(CustomMessage('ExtractingEspIdf'), CustomMessage('SettingUpReferenceRepository'), CmdLine);
  end else begin
    { IDFZIPFileName is not set, meaning that we will rely on 'git clone'. }
    NeedToClone := True;
    Log('Not .zip release archive. Will do full clone.');
  end;

  if NeedToClone then
  begin

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GIT_MIRROR_GITEE}')) then begin
        GitUseMirror := True;
        IsGitRecursive := False;
        GitRepository := 'https://gitee.com/EspressifSystems/esp-idf.git';
        GitSubmoduleUrl := 'https://gitee.com/esp-submodules/';
    end;

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GIT_MIRROR_JIHULAB}')) then begin
        { The jihulab using same relative path as the official mirror,
          process the same way as from the GitHub }
        GitUseMirror := False;
        IsGitRecursive := True;
        GitRepository := 'https://jihulab.com/esp-mirror/espressif/esp-idf.git';
    end;

    CmdLine := GitExecutablePath + ' clone --progress -b ' + IDFDownloadVersion;

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GIT_SHALLOW}')) then begin
      CmdLine := CmdLine + ' --single-branch --shallow-submodules ';
    end;

    if (IsGitRecursive) then begin
      CmdLine := CmdLine + ' --recursive ';
    end;

    CmdLine := CmdLine + ' ' + GitRepository +' "' + IDFPath + '"';
    Log('Cloning IDF: ' + CmdLine);
    DoCmdlineInstall(CustomMessage('DownloadingEspIdf'), CustomMessage('UsingGitToClone'), CmdLine);

    if (GitUseMirror) then begin
      ApplyIdfMirror(IDFPath, GitRepository, GitSubmoduleUrl);
    end;

  end else begin

    Log('Copying ' + IDFTempPath + ' to ' + IDFPath);
    if DirExists(IDFPath) then
    begin
      if not DirIsEmpty(IDFPath) then
      begin
        MessageBox('Destination directory exists and is not empty: ' + IDFPath, mbError, MB_OK);
        RaiseException('Failed to copy ESP-IDF')
      end;
    end;

    { If cmd.exe command argument starts with a quote, the first and last quote chars in the command
      will be removed by cmd.exe.
      Keys explanation: /s+/e includes all subdirectories, /i assumes that destination is a directory,
      /h copies hidden files, /q disables file name logging (making copying faster!)
    }

    CmdLine := ExpandConstant('cmd.exe /c ""xcopy.exe" /s /e /i /h /q "' + IDFTempPath + '" "' + IDFPath + '""');
    DoCmdlineInstall(CustomMessage('ExtractingEspIdf'), CustomMessage('CopyingEspIdf'), CmdLine);

    GitRepoFixFileMode(IDFPath);
    GitResetHard(IDFPath);

    DelTree(IDFTempPath, True, True, True);
  end;
end;

{ ------------------------------ IDF Tools setup, Python environment setup ------------------------------ }

function UseBundledIDFToolsPy(Version: String) : Boolean;
begin
  Result := False;
  { Use bundled copy of idf_tools.py, as the copy shipped with these IDF versions can not work due to
    the --no-site-packages bug.
  }
  if (Version = 'v4.0') or (Version = 'v3.3.1') then
  begin
    Log('UseBundledIDFToolsPy: version=' + Version + ', using bundled idf_tools.py');
    Result := True;
  end;
end;

{ Get list of selected IDF targets as a command line option for IDF installer. }
{ Result: '--targets=esp32,esp32-c3'}
function GetSelectedIdfTargets(): String;
var
  Targets: String;
begin
  Targets := '';

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32}')) then begin
      Targets := Targets + 'esp32,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C2}')) then begin
      Targets := Targets + 'esp32-c2,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C3}')) then begin
      Targets := Targets + 'esp32-c3,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C6}')) then begin
      Targets := Targets + 'esp32-c6,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_H2}')) then begin
      Targets := Targets + 'esp32-h2,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S3}')) then begin
      Targets := Targets + 'esp32-s3,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S2}')) then begin
      Targets := Targets + 'esp32-s2,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_P4}')) then begin
      Targets := Targets + 'esp32-p4,';
  end;

  if (Length(Targets) > 1) then begin
    Result := '--targets=' + Copy(Targets, 1, Length(Targets) - 1);
  end else begin
    Result := '';
  end;
end;

procedure IDFToolsSetup();
var
  CmdLine: String;
  IdfPathWithBackslashes: String;
  IDFToolsPyPath: String;
  IDFToolsPyCmd: String;
  BundledIDFToolsPyPath: String;
  JSONArg: String;
  PythonVirtualEnvPath: String;
  PipExecutable: String;
  ResultCode: Integer;
  TargetSupportTestCommand: String;
begin
  IdfPathWithBackslashes := TrimTrailingBackslash(GetPathWithBackslashes(GetIDFPath('')));
  IDFToolsPyPath := GetIDFPath('tools\idf_tools.py');
  BundledIDFToolsPyPath := ExpandConstant('{app}\idf_tools_fallback.py');
  JSONArg := '';

  Log('Checking whether file exists ' + IDFToolsPyPath);
  if FileExists(IDFToolsPyPath) then
  begin
    Log('idf_tools.py exists in IDF directory');
    if UseBundledIDFToolsPy(IDFDownloadVersion) then
    begin
      Log('Using the bundled idf_tools.py copy');
      IDFToolsPyCmd := BundledIDFToolsPyPath;
    end else begin
      IDFToolsPyCmd := IDFToolsPyPath;
    end;
  end else begin
    Log('idf_tools.py does not exist in IDF directory, using a fallback version');
    IDFToolsPyCmd := BundledIDFToolsPyPath;
    JSONArg := ExpandConstant('--tools "{app}\tools_fallback.json"');
  end;

  { Check the support for --targets command}
  TargetSupportTestCommand := '"' + IDFToolsPyCmd + '" install --targets=""';

  { Set IDF Path as environment variable. }
  IDFToolsPyCmd := PythonExecutablePath + ' "' + IDFToolsPyCmd + '" "--idf-path" "' + IdfPathWithBackslashes + '" ' + JSONArg + ' ';

  SetEnvironmentVariable('PYTHONUNBUFFERED', '1');

  if (IsOfflineMode) then begin
    SetEnvironmentVariable('IDF_PYTHON_CHECK_CONSTRAINTS', 'no');

    SetEnvironmentVariable('PIP_NO_INDEX', 'true');
    Log('Offline installation selected. Setting environment variable PIP_NO_INDEX=1');
    SetEnvironmentVariable('PIP_FIND_LINKS', ExpandConstant('{app}\tools\idf-python-wheels\' + PythonWheelsVersion));
  end else begin
    SetEnvironmentVariable('PIP_EXTRA_INDEX_URL', PythonWheelsUrl);
    Log('Adding extra Python wheels location. Setting environment variable PIP_EXTRA_INDEX_URL=' + PythonWheelsUrl);
  end;

  Log('idf_tools.py command: ' + IDFToolsPyCmd);


  Log('Selection of targets testing command: ' + PythonExecutablePath + ' ' + TargetSupportTestCommand);
  Exec(PythonExecutablePath, TargetSupportTestCommand, '', SW_SHOW,
    ewWaitUntilTerminated, ResultCode);
  if (ResultCode = 1) then begin
    Log('Selection of targets: Supported');
    CmdLine := IDFToolsPyCmd + ' install ' + GetSelectedIdfTargets();
  end else begin
    Log('Selection of targets: Not supported in this version idf_tools.py');
    CmdLine := IDFToolsPyCmd + ' install';
  end;

  Log('Installing tools:' + CmdLine);
  DoCmdlineInstall(CustomMessage('InstallingEspIdfTools'), '', CmdLine);

  PythonVirtualEnvPath := ExpandConstant('{app}\python_env\')  + GetIDFPythonEnvironmentVersion() + '_env';
  CmdLine := PythonExecutablePath + ' -m venv "' + PythonVirtualEnvPath + '"';
  if (DirExists(PythonVirtualEnvPath)) then begin
    Log('ESP-IDF Python Virtual environment exists, refreshing the environment: ' + CmdLine);
  end else begin
    Log('ESP-IDF Python Virtual environment does not exist, creating the environment: ' + CmdLine);
  end;
  DoCmdlineInstall(CustomMessage('CreatingPythonVirtualEnv'), '', CmdLine);

  CmdLine := IDFToolsPyCmd + ' install-python-env';
  Log('Installing Python environment:' + CmdLine);
  DoCmdlineInstall(CustomMessage('InstallingPythonVirtualEnv'), '', CmdLine);

  { Install addional wheels which are not covered by default tooling }
  PipExecutable := GetPythonVirtualEnvPipExecutable()
  CmdLine := PipExecutable + ' install windows-curses';
  Log('Installing additional wheels:' + CmdLine);
  DoCmdlineInstall(CustomMessage('InstallingPythonVirtualEnv'), '', CmdLine);

end;
