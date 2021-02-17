[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

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

    if WizardIsTaskSelected('UseMirror') then
    begin
      SetEnvironmentVariable('IDF_GITHUB_ASSETS', 'dl.espressif.com/github_assets')
    end;

    IDFToolsSetup();


  if WizardIsTaskSelected('CreateLinkStartCmd') then
  begin
    CreateIDFCommandPromptShortcut('{autostartmenu}\Programs\ESP-IDF');
  end;

  if WizardIsTaskSelected('CreateLinkStartPowerShell') then
  begin
    CreateIDFPowershellShortcut('{autostartmenu}\Programs\ESP-IDF' );
  end;

  if WizardIsTaskSelected('CreateLinkDeskCmd') then
  begin
    CreateIDFCommandPromptShortcut('{autodesktop}');
  end;

  if WizardIsTaskSelected('CreateLinkDeskPowerShell') then
  begin
    CreateIDFPowershellShortcut('{autodesktop}');
  end;

  if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    SaveEclipseConfiguration();
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
