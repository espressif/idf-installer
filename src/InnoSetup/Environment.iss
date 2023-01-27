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

function GetIDFZIPFileVersion(Version: String): String;
var
  ReleaseVerPart: String;
  i: Integer;
  Found: Boolean;
begin
  if WildCardMatch(Version, 'v*') or WildCardMatch(Version, 'v*-rc*') then
    Result := Version
  else if Version = 'master' then
    Result := ''
  else if WildCardMatch(Version, 'release/v*') then
  begin
    ReleaseVerPart := Version;
    Log('ReleaseVerPart=' + ReleaseVerPart)
    Delete(ReleaseVerPart, 1, Length('release/'));
    Log('ReleaseVerPart=' + ReleaseVerPart)
    Found := False;
    for i := 0 to GetArrayLength(IDFDownloadAvailableVersions) - 1 do
    begin
      if Pos(ReleaseVerPart, IDFDownloadAvailableVersions[i]) = 1 then
      begin
        Result := IDFDownloadAvailableVersions[i];
        Found := True;
        break;
      end;
    end;
    if not Found then
      Result := '';
  end;
  Log('GetIDFZIPFileVersion(' + Version + ')=' + Result);
end;

procedure IDFAddDownload();
var
  Url, MirrorUrl: String;
begin
  IDFZIPFileVersion := GetIDFZIPFileVersion(IDFDownloadVersion);

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
  Replacement of the '--dissociate' flag of 'git clone', to support older versions of Git.
  '--reference' is supported for submodules since git 2.12, but '--dissociate' only from 2.18.
}
procedure GitRepoDissociate(Path: String);
var
  CmdLine: String;
begin
  CmdLine := GitExecutablePath + ' -C ' + Path + ' repack -d -a'
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('RepackingRepository'), CmdLine);
  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule foreach git repack -d -a'
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('RepackingRepository'), CmdLine);

  FindFileRecursive(Path + '\.git', 'alternates', @RemoveAlternatesFile);
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

  Log('Setting core.fileMode on repository for submodules: ' + CmdLine);
  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule foreach --recursive git config --local core.fileMode false';
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingFileModeInSubmodules'), CmdLine);
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

  Log('Resetting the submodules: ' + CmdLine);
  CmdLine := GitExecutablePath + ' -C ' + Path + ' submodule foreach git reset --hard';
  DoCmdlineInstall(CustomMessage('FinishingEspIdfInstallation'), CustomMessage('UpdatingNewLinesInSubmodules'), CmdLine);
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

  if IDFZIPFileName <> '' then
  begin
    if IDFZIPFileVersion <> IDFDownloadVersion then
    begin
      { The version of .zip file downloaded is not the same as the version the user has requested.
        Will use 'git clone --reference' to obtain the correct version, using the contents
        of the .zip file as reference.
      }
      NeedToClone := True;
    end;

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

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GITEE_MIRROR}')) then begin
        GitUseMirror := True;
        IsGitRecursive := False;
        GitRepository := 'https://gitee.com/EspressifSystems/esp-idf.git';
        GitSubmoduleUrl := 'https://gitee.com/esp-submodules/';
    end;

    CmdLine := GitExecutablePath + ' clone --progress -b ' + IDFDownloadVersion;

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GIT_SHALLOW}')) then begin
      CmdLine := CmdLine + ' --single-branch  --shallow-submodules ';
    end;

    if (IsGitRecursive) then begin
      CmdLine := CmdLine + ' --recursive ';
    end;

    if IDFTempPath <> '' then
      CmdLine := CmdLine + ' --reference ' + IDFTempPath;

    CmdLine := CmdLine + ' ' + GitRepository +' "' + IDFPath + '"';
    Log('Cloning IDF: ' + CmdLine);
    DoCmdlineInstall(CustomMessage('DownloadingEspIdf'), CustomMessage('UsingGitToClone'), CmdLine);

    if IDFTempPath <> '' then
      GitRepoDissociate(IDFPath);

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

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S3}')) then begin
      Targets := Targets + 'esp32-s3,';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S2}')) then begin
      Targets := Targets + 'esp32-s2,';
  end;

  if (Length(Targets) > 1) then begin
    Result := '--targets=' + Copy(Targets, 1, Length(Targets) - 1);
  end else begin
    Result := '';
  end;
end;

function TrimTrailingBackslash(Path: String): String;
begin
  if (Length(Path) > 0) and (Path[Length(Path)] = '\') then  begin
    Result := Copy(Path, 1, Length(Path) - 1);
  end else begin
    Result := Path;
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

  { IDFPath not quoted, as it can not contain spaces }
  IDFToolsPyCmd := PythonExecutablePath + ' "' + IDFToolsPyCmd + '" "--idf-path=' + IdfPathWithBackslashes + '" ' + JSONArg + ' ';

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

  CmdLine := PythonExecutablePath + ' -m virtualenv --version';
  Log('Checking Python virtualenv support:' + CmdLine)
  DoCmdlineInstall(CustomMessage('CheckingPythonVirtualEnvSupport'), '', CmdLine);

  PythonVirtualEnvPath := ExpandConstant('{app}\python_env\')  + GetIDFPythonEnvironmentVersion() + '_env';
  CmdLine := PythonExecutablePath + ' -m virtualenv "' + PythonVirtualEnvPath + '" -p ' + '"' + PythonExecutablePath + '" --seeder pip';
  if (DirExists(PythonVirtualEnvPath)) then begin
    Log('ESP-IDF Python Virtual environment exists, refreshing the environment: ' + CmdLine);
  end else begin
    Log('ESP-IDF Python Virtual environment does not exist, creating the environment: ' + CmdLine);
  end;
  DoCmdlineInstall(CustomMessage('CreatingPythonVirtualEnv'), '', CmdLine);

  CmdLine := IDFToolsPyCmd + ' install-python-env';
  Log('Installing Python environment:' + CmdLine);
  DoCmdlineInstall(CustomMessage('InstallingPythonVirtualEnv'), '', CmdLine);
end;

