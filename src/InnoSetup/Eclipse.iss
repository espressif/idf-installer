[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

function GetEclipsePath(FileName:String): String;
begin
  Result := ExpandConstant('{app}\tools\espressif-ide\{#ESPRESSIFIDEVERSION}\') + FileName;
end;

function GetEclipseExePath():String;
begin
  Result := GetEclipsePath('espressif-ide.exe');
end;

function GetEclipseIniPath():String;
begin
  Result := GetEclipsePath('espressif-ide.ini');
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

  Command := GetEclipseExePath();
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
    MessageBox('Failed to create the shortcut: ' + Destination, mbError, MB_OK);
    RaiseException('Failed to create the shortcut');
  end;
end;
