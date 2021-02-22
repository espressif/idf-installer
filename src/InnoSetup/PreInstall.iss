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

  if (UseEmbeddedGit) then begin
    GitUseExisting := true;
  end;

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

  if (UseEmbeddedGit) then begin
    GitPath := ExpandConstant('{app}\tools\git\2.30.1\cmd\');
    GitExecutablePath := GitPath + 'git.exe';
  end else begin
    if not GitUseExisting then begin
      GitExecutablePathUpdateAfterInstall();
    end;
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

procedure InstallEmbeddedPython();
var
  EmbeddedPythonPath: String;
  CmdLine: String;
begin
  if (Pos('tools', PythonPath) <> 1) then begin
    Exit;
  end;

  EmbeddedPythonPath := ExpandConstant('{app}\') + PythonExecutablePath;
  UpdatePythonVariables(EmbeddedPythonPath);
  Log('Checking existence of Embedded Python: ' + EmbeddedPythonPath);
  if (FileExists(EmbeddedPythonPath)) then begin
    Log('Embedded Python found.');
    Exit;
  end;

  CmdLine := ExpandConstant('{tmp}\7za.exe x -o{app}\tools\idf-python\' + PythonVersion + '\ -r -aoa "{app}\dist\idf-python-' + PythonVersion + '-embed-win64.zip"');
  DoCmdlineInstall('Extracting Python Interpreter', 'Using Embedded Python', CmdLine);
end;
