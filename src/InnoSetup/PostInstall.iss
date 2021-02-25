[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Start menu shortcut ------------------------------ }

procedure CreateIDFCommandPromptShortcut(LnkString: String);
var
  Destination: String;
  Description: String;
  Command: String;
begin
  ForceDirectories(ExpandConstant(LnkString));
  Destination := ExpandConstant(LnkString + '\{#IDFCmdExeShortcutFile}');
  Description := '{#IDFCmdExeShortcutDescription} ' + IDFDownloadVersion;

  { If cmd.exe command argument starts with a quote, the first and last quote chars in the command
    will be removed by cmd.exe; each argument needs to be surrounded by quotes as well. }
  Command := ExpandConstant('/k ""{app}\idf_cmd_init.bat" "') + GetPythonVirtualEnvPath() + '" "' + GitPath + '""';
  Log('CreateShellLink Destination=' + Destination + ' Description=' + Description + ' Command=' + Command)
  try
    CreateShellLink(
      Destination,
      Description,
      'cmd.exe',
      Command,
      GetIDFPath(''),
      '', 0, SW_SHOWNORMAL);
  except
    MsgBox('Failed to create the shortcut: ' + Destination, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;

procedure CreateIDFPowershellShortcut(LnkString: String);
var
  Destination: String;
  Description: String;
  Command: String;
begin
  ForceDirectories(ExpandConstant(LnkString));
  Destination := ExpandConstant(LnkString + '\{#IDFPsShortcutFile}');
  Description := '{#IDFPsShortcutDescription} ' + IDFDownloadVersion;

  Command := ExpandConstant('-ExecutionPolicy Bypass -NoExit -File ""{app}\Initialize-IDF.ps1"" ') + '"' +  GetPathWithForwardSlashes(GitPath) + '" "' + GetPathWithForwardSlashes(GetPythonVirtualEnvPath()) + '"'
  Log('CreateShellLink Destination=' + Destination + ' Description=' + Description + ' Command=' + Command)
  try
    CreateShellLink(
      Destination,
      Description,
      'powershell.exe',
      Command,
      GetIDFPath(''),
      '', 0, SW_SHOWNORMAL);
  except
    MsgBox('Failed to create the shortcut: ' + Destination, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;

procedure InstallEmbeddedPython();
var
  EmbeddedPythonPath: String;
  PythonDistZip: String;
  CmdLine: String;
begin
  if (Pos('tools', PythonPath) <> 1) then begin
    Exit;
  end;

  EmbeddedPythonPath := GetEmbeddedPythonPath();
  PythonDistZip := GetPythonDistZip();

  Log('Checking existence of Embedded Python: ' + EmbeddedPythonPath);
  if (FileExists(EmbeddedPythonPath)) then begin
    Log('Embedded Python found.');
    Exit;
  end;

  CmdLine := ExpandConstant('{tmp}\7za.exe x -o{app}\tools\idf-python\' + PythonVersion + '\ -r -aoa "' + PythonDistZip + '"');
  DoCmdlineInstall('Extracting Python Interpreter', 'Using Embedded Python', CmdLine);
end;

procedure InstallEmbeddedGit();
var
  EmbeddedGitPath: String;
  GitDistZip: String;
  CmdLine: String;
begin
  if (not UseEmbeddedGit) then begin
    Exit;
  end;

  EmbeddedGitPath := GetEmbeddedGitPath();
  GitDistZip := GetGitDistZip();

  Log('Checking existence of Embedded Git: ' + EmbeddedGitPath);
  if (FileExists(EmbeddedGitPath)) then begin
    Log('Embedded Git found.');
    Exit;
  end;

  CmdLine := ExpandConstant('{tmp}\7za.exe x -o{app}\tools\idf-git\{#GITVERSION}\ -r -aoa "' + GitDistZip + '"');
  DoCmdlineInstall('Extracting Git', 'Using Embedded Git', CmdLine);
end;


<event('CurStepChanged')>
procedure PostInstallSteps(CurStep: TSetupStep);
var
  Err: Integer;
begin
  if CurStep <> ssPostInstall then
    exit;

  ExtractTemporaryFile('7za.exe');

  InstallEmbeddedPython();
  InstallEmbeddedGit();

  try
    AddPythonGitToPath();

    if not IDFUseExisting then begin
      if (IsOfflineMode) then begin
        IDFOfflineInstall();
      end else begin
        IDFDownloadInstall();
      end;
    end;

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}')) then
    begin
      SetEnvironmentVariable('IDF_GITHUB_ASSETS', 'dl.espressif.com/github_assets')
    end;

    IDFToolsSetup();

    if (WizardIsComponentSelected('{#COMPONENT_CMD_STARTMENU}')) then begin
      CreateIDFCommandPromptShortcut('{autostartmenu}\Programs\ESP-IDF');
    end;

    if (WizardIsComponentSelected('{#COMPONENT_POWERSHELL_STARTMENU}')) then begin
      CreateIDFPowershellShortcut('{autostartmenu}\Programs\ESP-IDF' );
    end;

    if (WizardIsComponentSelected('{#COMPONENT_CMD_DESKTOP}')) then begin
      CreateIDFCommandPromptShortcut('{autodesktop}');
    end;

    if (WizardIsComponentSelected('{#COMPONENT_POWERSHELL_DESKTOP}')) then begin
      CreateIDFPowershellShortcut('{autodesktop}');
    end;

    if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
      SaveEclipseConfiguration();
    end;

    if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_DESKTOP}')) then begin
      CreateIDFEclipseShortcut('{autodesktop}');
    end;

  except
    SetupAborted := True;
    if MsgBox('Installation log has been created, it may contain more information about the problem.' + #13#10
              + 'Display the installation log now?', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDYES then
    begin
      ShellExec('', 'notepad.exe', ExpandConstant('{log}'), ExpandConstant('{tmp}'), SW_SHOW, ewNoWait, Err);
    end;
    Abort();
  end;
end;

<event('ShouldSkipPage')>
function SkipFinishedPage(PageID: Integer): Boolean;
begin
  Result := False;

  if PageID = wpFinished then
  begin
    Result := SetupAborted;
  end;
end;


function IsPowerShellInstalled(): Boolean;
begin
  Result := ((not SetupAborted) and (WizardIsTaskSelected('CreateLinkDeskPowerShell') or WizardIsTaskSelected('CreateLinkStartPowerShell')));
end;

function IsCmdInstalled(): Boolean;
begin
  Result := ((not SetupAborted) and (WizardIsTaskSelected('CreateLinkDeskCmd') or WizardIsTaskSelected('CreateLinkStartCmd')));
end;
