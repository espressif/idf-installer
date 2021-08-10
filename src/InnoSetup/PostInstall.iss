[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Start menu shortcut ------------------------------ }

{ Store launcher paths so they can be invoked in post install phase declared in Run section. }
var LauncherPathPowerShell: String;
var LauncherPathCMD: String;

{ Helper function to retrieve value from variable in Run section. }
function GetLauncherPathPowerShell(Param: String):String;
begin
  Result := LauncherPathPowerShell;
end;

{ Helper function to retrieve value from variable in Run section. }
function GetLauncherPathCMD(Param: String):String;
begin
  Result := LauncherPathCMD;
end;

{ Get suffix of the text for link so that user can see multiple IDF installed. }
function GetLinkDestination(LinkString: String; Title: String): String;
begin
  Result := ExpandConstant(LinkString) + '\{#IDF_SHORTCUT_PREFIX} ' + GetIDFShortVersion() + ' ' + Title + '.lnk';
end;

procedure CreateIDFWindowsTerminalShortcut();
var
  Command: String;
  IdfPathWithForwardSlashes: String;
  ResultCode: Integer;
begin
  IdfPathWithForwardSlashes := GetPathWithForwardSlashes(GetIDFPath(''));

  Command := 'launcher add --shell powershell --to windows-terminal';
  Command := Command + ' --title "ESP-IDF ' + GetIDFVersionFromHeaderFile() + '"';
  Command := Command + ' --idf-path "' + IdfPathWithForwardSlashes + '"';

  Log(ExpandConstant('{app}\{#IDF_ENV}') + ' ' + Command);
  if Exec(ExpandConstant('{app}\{#IDF_ENV}'), Command, '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode) then begin
     Log('{#IDF_ENV} success');
  end else begin
    Log('{#IDF_ENV} failed');
  end;
end;

procedure CreateIDFCommandPromptShortcut(LinkString: String);
var
  Description: String;
  Command: String;
begin
  ForceDirectories(ExpandConstant(LinkString));
  LauncherPathCMD := GetLinkDestination(LinkString, 'CMD');
  Description := '{#IDFCmdExeShortcutDescription}';

  { If cmd.exe command argument starts with a quote, the first and last quote chars in the command
    will be removed by cmd.exe; each argument needs to be surrounded by quotes as well. }
  Command := '/k ""' + ExpandConstant('{app}\idf_cmd_init.bat') + '" ' + GetIdfId() + '"';
  Log('CreateShellLink Destination=' + LauncherPathCMD + ' Description=' + Description + ' Command=' + Command)
  try
    CreateShellLink(
      LauncherPathCMD,
      Description,
      'cmd.exe',
      Command,
      GetIDFPath(''),
      '', 0, SW_SHOWNORMAL);
  except
    MessageBox('Failed to create the shortcut: ' + LauncherPathCMD, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;

procedure CreateIDFPowershellShortcut(LinkString: String);
var
  Description: String;
  Command: String;
begin
  ForceDirectories(ExpandConstant(LinkString));
  LauncherPathPowerShell := GetLinkDestination(LinkString, 'PowerShell');
  Description := '{#IDFPsShortcutDescription}';

  Command := ExpandConstant('-ExecutionPolicy Bypass -NoExit -File "{app}/Initialize-Idf.ps1" -IdfId ' + GetIdfId() );
  Log('CreateShellLink Destination=' + LauncherPathPowerShell + ' Description=' + Description + ' Command=' + Command)
  try
    CreateShellLink(
      LauncherPathPowerShell,
      Description,
      'powershell.exe',
      Command,
      GetIDFPath(''),
      '', 0, SW_SHOWNORMAL);
  except
    MessageBox('Failed to create the shortcut: ' + LauncherPathPowerShell, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;

procedure InstallEmbeddedPython();
var
  EmbeddedPythonPath: String;
  PythonDistZip: String;
  CmdLine: String;
begin
  if (not UseEmbeddedPython) then begin
    Exit;
  end;

  EmbeddedPythonPath := GetEmbeddedPythonPath();
  PythonDistZip := GetPythonDistZip();

  Log('Checking existence of Embedded Python: ' + EmbeddedPythonPath);
  if (FileExists(EmbeddedPythonPath)) then begin
    Log('Embedded Python found.');
    Exit;
  end;

  CmdLine := ExpandConstant('"{tmp}\7za.exe" x "-o{app}\tools\idf-python\' + PythonVersion + '\" -r -aoa "' + PythonDistZip + '"');
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

  CmdLine := ExpandConstant('"{tmp}\7za.exe" x "-o{app}\tools\idf-git\{#GITVERSION}\" -r -aoa "' + GitDistZip + '"');
  DoCmdlineInstall('Extracting Git', 'Using Embedded Git', CmdLine);
end;

procedure InstallIdfPackage(FilePath:String; DistZip:String; Destination:String);
var
  CmdLine: String;
begin
  Log('Checking existence of: ' + FilePath);
  if (FileExists(FilePath)) then begin
    Log('Found.');
    Exit;
  end;

  CmdLine := ExpandConstant('"{tmp}\7za.exe" x "-o' + Destination + '" -r -aoa "' + DistZip + '"');
  DoCmdlineInstall('Extracting...', 'Extracting...', CmdLine);
end;

procedure InstallEclipse();
begin
  if (not WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    Exit;
  end;

  InstallIdfPackage(GetEclipseExePath(), GetEclipseDistZip(), GetEclipsePath(''));
end;

<event('CurStepChanged')>
procedure PostInstallSteps(CurStep: TSetupStep);
var
  Err: Integer;
begin
  if CurStep <> ssPostInstall then
    exit;

  ExtractTemporaryFile('7za.exe');

  if (IsOfflineMode) then begin
    InstallSelectedDrivers();
  end else begin
    InstallEmbeddedPython();
    InstallEmbeddedGit();
    InstallEclipse();
  end;

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
    SaveIdfConfiguration(ExpandConstant('{app}\esp_idf.json'));

    if (WizardIsComponentSelected('{#COMPONENT_POWERSHELL_WINDOWS_TERMINAL}')) then begin
      CreateIDFWindowsTerminalShortcut();
    end;

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
      SaveIdfEclipseConfiguration(GetEclipsePath('esp_idf.json'));
    end;

    if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_DESKTOP}')) then begin
      CreateIDFEclipseShortcut('{autodesktop}');
    end;

  except
    SetupAborted := True;
    if MessageBox('Installation log has been created, it may contain more information about the problem.' + #13#10
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
