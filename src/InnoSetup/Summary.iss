[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Installation summary page ------------------------------ }

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := ''

  if (FileExists(PythonExecutablePath)) then
  begin
    Result := Result + CustomMessage('UsingPython') + ' ' + PythonVersion + ':' + NewLine
              + Space + PythonExecutablePath + NewLine + NewLine;
  end else begin
    Result := Result + CustomMessage('UsingEmbeddedPython') + ' ' + PythonVersion + NewLine + NewLine;
  end;

  if (UseEmbeddedGit) then begin
    { app is know only in this section, it's not possible to set it in Page }
    GitPath := ExpandConstant('{app}\tools\idf-git\2.34.2\cmd\');
    GitExecutablePath := GitPath + 'git.exe';

    Result := Result + CustomMessage('UsingEmbeddedGit') + ' ' + GitVersion + ':' + NewLine
            + Space + GitExecutablePath + NewLine + NewLine;
  end else if (GitUseExisting) then begin
    Result := Result + CustomMessage('UsingGit') + ' ' + GitVersion + ':' + NewLine
              + Space + GitExecutablePath + NewLine + NewLine;
  end else begin
    Result := Result + CustomMessage('DownloadGitForWindows') + ' ' + GitVersion + NewLine + NewLine;
  end;

  if IDFUseExisting then
  begin
    Result := Result + CustomMessage('UsingExistingEspIdf') + ' ' + NewLine
              + Space + IDFExistingPath + NewLine + NewLine;
  end else begin
    Result := Result + CustomMessage('InstallingNewEspIdf') + ' ' + IDFDownloadVersion + ' into:' + NewLine
              + Space + IDFDownloadPath + NewLine + NewLine;
  end;

  Result := Result + CustomMessage('EspIdfToolsDirectory') + ' ' + NewLine +
            Space + ExpandConstant('{app}') + NewLine + NewLine;

  Result := Result + CustomMessage('SummaryComponents') + ': ';

  if (WizardIsComponentSelected('{#COMPONENT_ECLIPSE}')) then begin
    Result := Result + 'Eclipse ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_RUST}')) then begin
    Result := Result + 'Rust ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TOIT_JAGUAR}')) then begin
    Result := Result + 'Toit Jaguar ';
  end;

  Result := Result + NewLine;
  Result := Result + CustomMessage('SummaryDrivers') + ': ';

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_FTDI}')) then begin
    Result := Result + 'FTDI ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_SILABS}')) then begin
    Result := Result + 'Sillicon Labs ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_ESPRESSIF}')) then begin
    Result := Result + 'Espressif ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_DRIVER_WCH}')) then begin
    Result := Result + 'WCH ';
  end;

  Result := Result + NewLine;
  Result := Result + CustomMessage('SummaryTargets') + ': ';

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32}')) then begin
    Result := Result + 'ESP32 ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C2}')) then begin
    Result := Result + 'ESP32-C2 ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C3}')) then begin
    Result := Result + 'ESP32-C3 ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_C6}')) then begin
    Result := Result + 'ESP32-C6 ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S2}')) then begin
    Result := Result + 'ESP32-S2 ';
  end;

  if (WizardIsComponentSelected('{#COMPONENT_TARGET_ESP32_S3}')) then begin
    Result := Result + 'ESP32-S3 ';
  end;

  Result := Result + NewLine;
  Result := Result + CustomMessage('SummaryOptimization') + ': ';
  if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_ESPRESSIF_DOWNLOAD}')) then begin
    Result := Result + 'Assets (Espressif); ';
  end;
  if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GITEE_MIRROR}')) then begin
    Result := Result + 'Mirror (Gitee.com); ';
  end;
  if (WizardIsComponentSelected('{#COMPONENT_OPTIMIZATION_GIT_SHALLOW}')) then begin
    Result := Result + 'Shallow (Git) ';
  end;

  Log('Summary message: ' + NewLine + Result);
end;
