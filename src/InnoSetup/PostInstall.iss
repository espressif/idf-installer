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
  Description := '{#IDFCmdExeShortcutDescription}';

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
  Description := '{#IDFPsShortcutDescription}';

  Command := ExpandConstant('-ExecutionPolicy Bypass -NoExit -File ""{app}\idf_cmd_init.ps1"" ') + '"' +  GetPathWithForwardSlashes(GitPath) + '" "' + GetPathWithForwardSlashes(GetPythonVirtualEnvPath()) + '"'
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

<event('CurStepChanged')>
procedure PostInstallSteps(CurStep: TSetupStep);
var
  Err: Integer;
begin
  if CurStep <> ssPostInstall then
    exit;

  ExtractTemporaryFile('7za.exe');

  InstallEmbeddedPython();

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
