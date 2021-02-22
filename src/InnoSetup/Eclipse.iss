[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

function GetEclipsePath(FileName:String): String;
begin
  Result := ExpandConstant('{app}\tools\eclipse\2020-12\') + FileName;
end;

procedure SaveEclipseConfiguration();
var
    FilePath: String;
    Content: String;
    IdfId: String;
    IdfPathWithForwardSlashes: String;
    IdfVersion: String;
begin
  IdfPathWithForwardSlashes := GetPathWithForwardSlashes(GetIDFPath(''))
  IdfId := 'esp-idf-' + GetMD5OfString(IdfPathWithForwardSlashes);
  IdfVersion := GetIDFVersionFromHeaderFile();

  Content := '{' + #13#10;
  Content := Content + '  "_comment": "Configuration file for ESP-IDF Eclipse plugin.",' + #13#10;
  Content := Content + '  "_warning": "Use / or \\ when specifying path. Single backslash is not allowed by JSON format.",' + #13#10;
  Content := Content + '  "gitPath": "' + GetPathWithForwardSlashes(GitExecutablePath) + '",' + #13#10;
  Content := Content + '  "idfToolsPath": "' + GetPathWithForwardSlashes(ExpandConstant('{app}')) + '",' + #13#10;
  Content := Content + '  "idfSelectedId": "' + IdfId + '",' + #13#10;
  Content := Content + '  "idfInstalled": {' + #13#10;
  Content := Content + '    "' + IdfId + '": {' + #13#10;
  Content := Content + '      "version": "' + IdfVersion + '",' + #13#10;
  Content := Content + '      "path": "' + IdfPathWithForwardSlashes + '",' + #13#10;
  Content := Content + '      "python": "' + GetPathWithForwardSlashes(GetPythonVirtualEnvPath()) + '/python.exe"' + #13#10;
  Content := Content + '    }' + #13#10;
  Content := Content + '  }' + #13#10;
  Content := Content + '}' + #13#10;

  FilePath := GetEclipsePath('esp_idf.json');
  Log('Writing Eclipse configuration to file ' + FilePath);
  Log(Content);
  if (SaveStringToFile(FilePath, Content, False)) then begin
    Log('Configuration stored.');
  end else begin
     MsgBox('Unable to write Eclipse configuration to ' + FilePath + #13#10
              + 'Please check the file access and retry the installation.',
              mbInformation, MB_OK);
    Log('Unable to write configuration!');
  end;
end;

procedure CreateIDFEclipseShortcut(LnkString: String);
var
  Destination: String;
  Description: String;
  Command: String;
begin
  ForceDirectories(ExpandConstant(LnkString));
  Destination := ExpandConstant(LnkString + '\{#IDFEclipseShortcutFile}');
  Description := '{#IDFEclipseShortcutDescription}';

  Command := GetEclipsePath('eclipse.exe');
  Log('CreateShellLink Destination=' + Destination + ' Description=' + Description + ' Command=' + Command)
  try
    CreateShellLink(
      Destination,
      Description,
      Command,
      '',
      GetIDFPath(''),
      '', 0, SW_SHOWNORMAL);
  except
    MsgBox('Failed to create the shortcut: ' + Destination, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;
