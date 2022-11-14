[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Custom steps before the main installation flow ------------------------------ }

var
  SetupAborted: Boolean;

function InstallationSuccessful(): Boolean;
begin
  Result := not SetupAborted;
end;

{ Wrapper function for Run task. Run tasks requires calling function. }
function GetIsWindowsDefenderEnabled(): Boolean;
begin
  if (not InstallationSuccessful()) then begin
    Result := false;
    Exit;
  end;
  Result := IsWindowsDefenderEnabled;
end;

<event('InitializeWizard')>
procedure InitializeDownloader();
begin
  idpDownloadAfter(wpReady);
end;

{ If IDF_TOOLS_PATH is set in the environment,
  set the default installation directory accordingly.
  Note: here we read IDF_TOOLS_PATH using GetEnv rather than
  by getting it from registry, in case the user has set
  IDF_TOOLS_PATH as a system environment variable manually. }
<event('InitializeWizard')>
procedure UpdateInstallDir();
var
  EnvToolsPath: String;
begin
  EnvToolsPath := GetEnv('IDF_TOOLS_PATH');
  if EnvToolsPath <> '' then
  begin
    WizardForm.DirEdit.Text := EnvToolsPath;
  end;
end;

function GetEmbeddedPythonPath():String;
begin
  Result := PythonExecutablePath;
end;

function GetPythonDistZip():String;
begin
  Result := ExpandConstant('{app}\dist\{#PythonInstallerName}');
end;

procedure PrepareIdfPackage(FilePath: String; DistZip: String; DownloadUrl: String);
begin
  if (IsOfflineMode) then begin
    Exit;
  end;

  Log('Checking existence of: ' + FilePath);
  if (FileExists(FilePath)) then begin
    Log('Found.');
    Exit;
  end;

  Log('Checking download cache for: ' + DistZip)
  if (FileExists(DistZip)) then begin
    Log('Found.');
    Exit;
  end;

  Log('Scheduling download of ' + DownloadUrl  + ' to ' + DistZip);
  idpAddFile(DownloadUrl, DistZip);
end;

procedure PrepareEmbeddedPython();
var
  EmbeddedPythonPath:String;
begin
  { Embedded Python always begin with tools since 'app' location is not known. }
  if (Pos('tools',PythonExecutablePath) = 1) then begin
    EmbeddedPythonPath := ExpandConstant('{app}\') + PythonExecutablePath;
  end;

  UpdatePythonVariables(EmbeddedPythonPath);

  PrepareIdfPackage(EmbeddedPythonPath, GetPythonDistZip(), '{#PythonInstallerDownloadURL}');
end;

function GetEmbeddedGitPath():String;
begin
  Result := GitExecutablePath;
end;

function GetGitDistZip():String;
begin
  Result := ExpandConstant('{app}\dist\{#GitInstallerName}');
end;

procedure PrepareEmbeddedGit();
begin
  if (not UseEmbeddedGit) then begin
    Exit;
  end;

  PrepareIdfPackage(GetEmbeddedGitPath(), GetGitDistZip(), '{#GitInstallerDownloadURL}');
  GetPathWithForwardSlashes(GitExecutablePath)
  GitUseExisting := true;
end;

function GetEclipseDistZip():String;
begin
  Result := ExpandConstant('{app}\dist\{#ECLIPSE_INSTALLER}');
end;

function GetJdkDistZip():String;
begin
  Result := ExpandConstant('{app}\dist\{#JDK_INSTALLER}');
end;

procedure PrepareEclipse();
begin
  if (not WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    Exit;
  end;

  PrepareIdfPackage(GetEclipseExePath(), GetEclipseDistZip(), '{#ECLIPSE_DOWNLOADURL}');
  if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_JDK}')) then begin
    PrepareIdfPackage(ExpandConstant('{app}\tools\amazon-corretto-11-x64-windows-jdk\{#JDKVERSION}\bin\java.exe'), GetJdkDistZip(), '{#JDK_DOWNLOADURL}');
  end;
end;

procedure InstallSelectedDrivers();
var
  DriverList: String;
begin
  DriverList := '';
  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_FTDI}')) then begin
    DriverList := DriverList + ' --ftdi'
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_SILABS}')) then begin
    DriverList := DriverList + ' --silabs'
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_ESPRESSIF}')) then begin
    DriverList := DriverList + ' --espressif'
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_WCH}')) then begin
    DriverList := DriverList + ' --wch'
  end;

  if (Length(DriverList) > 0) then begin
    InstallDrivers(DriverList);
  end;
end;

procedure InstallVSBuildTools();
var
  CommandLine: String;
begin
  CommandLine := ' --passive --wait';
  CommandLine := CommandLine + ' --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ';
  CommandLine := CommandLine + ' --add Microsoft.VisualStudio.Component.Windows11SDK';

  if (WizardIsComponentSelected('{#COMPONENT_RUST}')) then begin
    DoCmdlineInstall(CustomMessage('InstallingRust'), CustomMessage('InstallingRust'), GetVsBuildtoolsCommand(CommandLine));
  end;
end;

procedure InstallRust();
var
  CommandLine: String;
begin
  CommandLine := 'install'

  if (WizardIsComponentSelected('{#COMPONENT_RUST_GNU}')) then begin
    {CommandLine := CommandLine + ' --default-host x86_64-pc-windows-gnu'; }
  end else if (WizardIsComponentSelected('{#COMPONENT_RUST_MSVC}')) then begin
    {CommandLine := CommandLine + ' --default-host x86_64-pc-windows-msvc';}
  end;

  if (WizardIsComponentSelected('{#COMPONENT_RUST_GNU_MINGW}')) then begin
    {CommandLine := CommandLine + ' --extra-tools=mingw';}
  end;

  if (WizardIsComponentSelected('{#COMPONENT_RUST_MSVC_VCTOOLS}')) then begin
    InstallVSBuildTools();
  end;

  CommandLine := CommandLine + ' --extra-crates=ldproxy';

  if (WizardIsComponentSelected('{#COMPONENT_RUST}')) then begin
    DoCmdlineInstall(CustomMessage('InstallingRust'), CustomMessage('InstallingRust'), GetEspUpCommand(CommandLine));
  end;
end;

procedure InstallToit();
begin
  if (WizardIsComponentSelected('{#COMPONENT_TOIT_JAGUAR}')) then begin
    DoCmdlineInstall(CustomMessage('InstallingToit'), CustomMessage('InstallingToit'), GetIdfEnvCommand('toit reinstall --jaguar'));
  end;
end;


<event('NextButtonClick')>
function PreInstallSteps(CurPageID: Integer): Boolean;
var
  DestPath: String;
  TmpPath: String;
  UserProfile: String;
begin
  Result := True;
  if CurPageID <> wpReady then begin
    Exit;
  end;

  { Validate Code Page and refuse to install Eclipse in case of tool path with special character or TMP set to special character. }
  if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    if (CodePage = '65001') then begin
      if (not IsDirNameValid(ExpandConstant('{app}'))) then begin
        Result := False;
        MessageBox(CustomMessage('SystemCheckToolsPathSpecialCharacter'), mbError, MB_OK);
        Exit;
      end;

      TmpPath := GetEnv('TMP');
      if (not IsDirNameValid(TmpPath)) then begin
        Result := False;
        MessageBox(CustomMessage('SystemCheckTmpPathSpecialCharacter'), mbError, MB_OK);
        Exit;
      end;

      { Try to expand USERPROFILE variable which might also contain special character. }
      if (Pos('Users', TmpPath) > 0) then begin
        UserProfile := GetEnv('USERPROFILE');
        if (not IsDirNameValid(UserProfile)) then begin
          Result := False;
          MessageBox(CustomMessage('SystemCheckTmpPathSpecialCharacter'), mbError, MB_OK);
          Exit;
        end;
      end;
    end;
  end;

  if not (IsOfflineMode) then begin
    InstallSelectedDrivers();
  end;

  ForceDirectories(ExpandConstant('{app}\dist'));

  PrepareEmbeddedPython();
  PrepareEmbeddedGit();
  PrepareEclipse();

  if not GitUseExisting then
  begin
    DestPath := ExpandConstant('{app}\dist\{#GitInstallerName}');
    if FileExists(DestPath) then
    begin
      Log('Git installer already downloaded: ' + DestPath);
    end else begin
      idpAddFile('{#GitInstallerDownloadURL}', DestPath);
    end;
  end;

  if not IDFUseExisting then
  begin
    IDFAddDownload();
  end;

  { Update path to current instance of Git. }
  ExecIdfEnv('config set --git "' +  GetPathWithForwardSlashes(GitExecutablePath) + '"');
end;

{ ------------------------------ Custom steps after the main installation flow ------------------------------ }

procedure AddPythonGitToPath();
var
  EnvPath: String;
  PythonLibPath: String;
  EnvPythonHome: String;
  PythonNoUserSite: String;
begin
  EnvPath := GetEnv('PATH');

  if (not UseEmbeddedGit) and (not GitUseExisting) then begin
    GitExecutablePathUpdateAfterInstall();
  end;

  EnvPath := PythonPath + ';' + GitPath + ';' + EnvPath;
  Log('Setting PATH for this process: ' + EnvPath);
  SetEnvironmentVariable('PATH', EnvPath);

  { Set PYTHONNOUSERSITE variable True to avoid loading packages from AppData\Roaming. }
  { https://doc.pypy.org/en/latest/man/pypy.1.html#environment }
  { If set to a non-empty value, equivalent to the -s option. Don’t add the user site directory to sys.path. }
  if (IsPythonNoUserSite) then begin
    PythonNoUserSite := 'True';
  end else begin
    PythonNoUserSite := '';
  end;
  Log('PYTHONNOUSERSITE=' + PythonNoUserSite);
  SetEnvironmentVariable('PYTHONNOUSERSITE', PythonNoUserSite);

  { Log and clear PYTHONPATH variable, as it might point to libraries of another Python version}
  PythonLibPath := GetEnv('PYTHONPATH')
  Log('PYTHONPATH=' + PythonLibPath)
  SetEnvironmentVariable('PYTHONPATH', '')

  { Log and clear PYTHONHOME, the existence of PYTHONHOME might cause trouble when creating virtualenv. }
  { The error message when creating virtualenv: }
  {   Fatal Python error: init_fs_encoding: failed to get the Python codec of the filesystem encoding. }
  EnvPythonHome := GetEnv('PYTHONHOME')
  Log('PYTHONHOME=' + EnvPythonHome)
  SetEnvironmentVariable('PYTHONHOME', '')
end;
