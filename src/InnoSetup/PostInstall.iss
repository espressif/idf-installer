[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

procedure AppendEnvironmentVariable(VariableName: String; Value: String);
var
  Command: String;
begin
  Command := GetIdfEnvCommand('shell append --variable "' + VariableName + '" --path ' + Value + ' ')
  DoCmdlineInstall(CustomMessage('SettingEnvironmentVariable'), CustomMessage('SettingEnvironmentVariable'), Command);
end;

procedure SetEspressifIdeVM(IniPath: String; VmPah: String);
var
  Command: String;
begin
  Command := GetIdfEnvCommand('ide configure --ini "' + IniPath + '" --vm "' + VmPah + '"')
  DoCmdlineInstall(CustomMessage('SettingEnvironmentVariable'), CustomMessage('SettingEnvironmentVariable'), Command);
end;


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
    MessageBox(CustomMessage('FailedToCreateShortcut') + ' ' + LauncherPathCMD, mbError, MB_OK);
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
    MessageBox(CustomMessage('FailedToCreateShortcut') + ' ' + LauncherPathPowerShell, mbError, MB_OK);
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
  DoCmdlineInstall(CustomMessage('ExtractingPython'), CustomMessage('UsingEmbeddedPython'), CmdLine);
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
  DoCmdlineInstall(CustomMessage('ExtractingGit'), CustomMessage('UsingEmbeddedGit'), CmdLine);
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
  DoCmdlineInstall(CustomMessage('Extracting'), CustomMessage('Extracting'), CmdLine);
end;

procedure InstallEclipse();
var
  FilePath: String;
begin
  if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_JDK}')) then begin
    InstallIdfPackage(ExpandConstant('{app}\tools\amazon-corretto-11-x64-windows-jdk\{#JDKVERSION}\bin\java.exe'), GetJdkDistZip(), ExpandConstant('{app}\tools\amazon-corretto-11-x64-windows-jdk\') );
  end;

  if (not WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    Exit;
  end;

  FilePath := GetEclipseExePath();
  Log('Checking existence of: ' + FilePath);
  if (FileExists(FilePath)) then begin
    Log('Found.');
    Exit;
  end;

  DoCmdlineInstall(CustomMessage('ComponentEclipse'), CustomMessage('ComponentEclipse'), GetIdfEnvCommand(ExpandConstant('ide install --url "{#ECLIPSE_DOWNLOADURL}" --file "{#ECLIPSE_INSTALLER}" --destination "') + GetPathWithForwardSlashes(GetEclipsePath('')) + '"'));
end;

<event('CurStepChanged')>
procedure PostInstallSteps(CurStep: TSetupStep);
var
  Err: Integer;
begin
  if CurStep <> ssPostInstall then
    exit;

  { Set IDF_TOOLS_PATH variable, in case it was set to a different value in the environment.
    The installer will set the variable to the new value in the registry, but we also need the
    new value to be visible to this process. }
  SetEnvironmentVariable('IDF_TOOLS_PATH', ExpandConstant('{app}'));

  ;SetEnvironmentVariable('IDF_COMPONENT_STORAGE_URL',  GetPathWithForwardSlashes(ExpandConstant('file:///{app}/registry;default')));

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

    if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}')) then
    begin
      SetEnvironmentVariable('IDF_GITHUB_ASSETS', 'dl.espressif.com/github_assets')
    end;

    if (WizardIsComponentSelected('{#COMPONENT_FRAMEWORK}')) then begin
      if not IDFUseExisting then begin
        if not (IsOfflineMode) then begin
            IDFDownloadInstall();
        end;
      end;

      GitRepoFixFileMode(IDFDownloadPath);
      GitResetHard(IDFDownloadPath);
      GitUpdateSubmodules(IDFDownloadPath);
      IDFToolsSetup();
      SaveIdfConfiguration(ExpandConstant('{app}\esp_idf.json'));
    end;

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

    if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_JDK}')) then begin
      SetEspressifIdeVM(GetEclipseIniPath(), ExpandConstant('{app}\tools\amazon-corretto-11-x64-windows-jdk\{#JDKVERSION}\bin\javaw.exe'));
    end;

    if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE_DESKTOP}')) then begin
      CreateIDFEclipseShortcut('{autodesktop}');
    end;

    InstallRust();
    InstallToit();

  except
    SetupAborted := True;
    if MessageBox(CustomMessage('InstallationLogCreated') + #13#10
              + CustomMessage('DisplayInstallationLog'), mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDYES then
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

// Installation completed check
var
  InstallSuccess: Boolean;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  // This event is called when the setup moves to a new step
  if CurStep = ssPostInstall then
  begin
    // Set InstallSuccess to True after the installation has finished.
    InstallSuccess := True;
  end;
end;

function IsInstallSuccess: Boolean;
begin
  Result := InstallSuccess;
end;

<event('InitializeWizard')>
procedure InitializeInstallSuccessVar;
begin
  // Initialize InstallSuccess to False
  InstallSuccess := False;
end;