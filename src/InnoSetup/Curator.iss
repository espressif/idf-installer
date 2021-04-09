[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ Get path to Curator process for managing installed instances of ESP-IDF. }
function GetCuratorCommand(Command: String):String;
begin
  Result := ExpandConstant('{tmp}\curator.exe ') + Command;
end;

function ExecCurator(Parameters: String):String;
var
  Command: String;
begin
  Command := GetCuratorCommand(Parameters);
  Result := ExecuteProcess(Command);
  Log('Result: ' + Result);
end;

function GetAntivirusName():String;
begin
  Result := ExecCurator('antivirus get --property displayName');
end;

function InstallDrivers(DriverList: String):String;
begin
  Result := ExecCurator('driver install ' + DriverList)
end;