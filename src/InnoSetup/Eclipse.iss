[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

procedure SaveEclipseConfiguration();
var
    FilePath: String;
    Content: String;
    IdfId: String;
begin
  IdfId := 'esp-idf-' + IDFDownloadVersion;

  Content := '{';
  Content := Content + '  "_comment": "Configuration file for ESP-IDF Eclipse plugin.",' + #13#10;
  Content := Content + '  "_warning": "Use / or \\ when specifying path. Single backslash is not allowed by JSON format.",' + #13#10;
  Content := Content + '  "gitPath": "' + GetPathWithForwardSlashes(GitPath) + '",' + #13#10;
  Content := Content + '  "idfToolsPath": "' + GetPathWithForwardSlashes(ExpandConstant('{app}')) + '",' + #13#10;
  Content := Content + '  "idfSelectedId": "' + IdfId + '",' + #13#10;
  Content := Content + '  "idfInstalled": {' + #13#10;
  Content := Content + '    "' + IdfId + '": {' + #13#10;
  Content := Content + '      "version": "' + IDFDownloadVersion + '",' + #13#10;
  Content := Content + '      "path": "' + GetPathWithForwardSlashes(GetIDFPath('')) + '",' + #13#10;
  Content := Content + '      "python": "' + GetPathWithForwardSlashes(GetPythonVirtualEnvPath()) + '"' + #13#10;
  Content := Content + '    },' + #13#10;
  Content := Content + '  }' + #13#10;
  Content := Content + '}' + #13#10;

  FilePath := ExpandConstant('{app}\tools\eclipse\2020-12\esp_idf.json');
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