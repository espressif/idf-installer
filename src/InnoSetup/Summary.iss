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
    GitPath := ExpandConstant('{app}\tools\idf-git\2.30.1\cmd\');
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

  Log('Summary message: ' + NewLine + Result);
end;
