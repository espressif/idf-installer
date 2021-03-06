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
  if (Pos('tools', PythonPath) <> 1) then begin
    Exit;
  end;

  EmbeddedPythonPath := ExpandConstant('{app}\') + PythonExecutablePath;
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
  GitUseExisting := true;
end;

function GetEclipseDistZip():String;
begin
  Result := ExpandConstant('{app}\dist\{#ECLIPSE_INSTALLER}');
end;

procedure PrepareEclipse();
begin
  if (not WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    Exit;
  end;

  PrepareIdfPackage(GetEclipseExePath(), GetEclipseDistZip(), '{#ECLIPSE_DOWNLOADURL}');
end;

<event('NextButtonClick')>
function PreInstallSteps(CurPageID: Integer): Boolean;
var
  DestPath: String;
begin
  Result := True;
  if CurPageID <> wpReady then begin
    Exit;
  end;

  ForceDirectories(ExpandConstant('{app}\dist'));

  if (IsOfflineMode) then begin
    ForceDirectories(ExpandConstant('{app}\releases'));
    IDFZIPFileVersion := IDFDownloadVersion;
    IDFZIPFileName := ExpandConstant('{app}\releases\esp-idf-bundle.zip');
    Exit;
  end;

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

  { Set IDF_TOOLS_PATH variable, in case it was set to a different value in the environment.
    The installer will set the variable to the new value in the registry, but we also need the
    new value to be visible to this process. }
  SetEnvironmentVariable('IDF_TOOLS_PATH', ExpandConstant('{app}'))

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
