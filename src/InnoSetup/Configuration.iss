[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Load configuration of the installer ------------------------------ }

var
    ConfigurationFile: String;
    GitRepository: String;
    IsGitRecursive: Boolean;
    IsGitResetAllowed: Boolean;
    IsGitCleanAllowed: Boolean;
    IsCheckPathEnabled: Boolean;
    IsPythonNoUserSite: Boolean;
    IsOfflineMode: Boolean;
    IDFDirectory: String;
    IDFVersion: String;
    IDFVersionUrl: String;
    PythonWheelsUrl: String;
    PythonWheelsVersion: String;
    SkipSystemCheck: Boolean;
    UseEmbeddedGit: Boolean;
    UseEmbeddedPython: Boolean;
    IDFUseExisting: Boolean;
    IDFExistingPath: String;
    IDFDownloadPath: String;
    IDFDownloadVersion: String;
    GitPath:String;
    GitExecutablePath:String;
    GitVersion: String;
    GitSubmoduleUrl: String;
    GitUseMirror: Boolean;
    GitDepth: String;
    PythonVersion:String;
    PythonPath:String;
    PythonExecutablePath: String;
    CodePage: String;
    IsEspressifSiteReachable: Boolean;
    IsGithubSiteReachable: Boolean;
    IsAmazonS3SiteReachable: Boolean;
    IsGiteeSiteReachable: Boolean;
    IsJihulabSiteReachable: Boolean;

function GetConfigurationString(Key: String; Default: String):String;
var Value: String;
begin
    Value := GetIniString('DEFAULT', Key, Default, ConfigurationFile);
    Value := ExpandConstant('{param:' + Key + '|' + Value + '}');
    Log('Configuration /' + Key + '=' + Value);
    Result := Value;
end;

function GetConfigurationBoolean(Key: String; DefaultString: String):Boolean;
begin
    Result := (GetConfigurationString(Key, DefaultString) = 'yes');
end;

{ Initialize configuration of the installer. }
{ Default configuration is encoded in installer. }
{ The configuration can be changed by configuration.ini file. }
{ The configuration can be changed by command line options which have highest priority. }
<event('InitializeWizard')>
procedure InitializeConfiguration();
begin
    ConfigurationFile := ExpandConstant('{param:CONFIG|}');

    if (ConfigurationFile <> '') then begin
        if (not FileExists(ConfigurationFile)) then begin
            Log('Configuration file does not exist, using default values.');
        end;
    end;

    Log('Configuration /CONFIG=' + ConfigurationFile);

    IsCheckPathEnabled := GetConfigurationBoolean('CHECKPATH', 'yes');
    IsGitCleanAllowed := GetConfigurationBoolean('GITCLEAN', 'yes');
    IsGitRecursive := GetConfigurationBoolean('GITRECURSIVE', 'yes');
    IsGitResetAllowed := GetConfigurationBoolean('GITRESET', 'yes');
    GitDepth := GetConfigurationString('GITDEPTH', '');
    GitRepository := GetConfigurationString('GITREPO', 'https://github.com/espressif/esp-idf.git');
    GitSubmoduleUrl := GetConfigurationString('GITSUBMODULEURL', '');
    GitUseMirror := GetConfigurationBoolean('GITUSEMIRROR', 'no');
    IDFDirectory := GetConfigurationString('IDFDIR', '');
    IDFUseExisting := GetConfigurationBoolean('IDFUSEEXISTING', 'no');
    IDFVersion := GetConfigurationString('IDFVERSION', '');
    IDFVersionUrl := GetConfigurationString('IDFVERSIONSURL', 'https://dl.espressif.com/dl/esp-idf/idf_versions.txt');
    IsOfflineMode := GetConfigurationBoolean('OFFLINE', '{#OFFLINE}');
    IsPythonNoUserSite := GetConfigurationBoolean('PYTHONNOUSERSITE', 'yes');
    PythonWheelsUrl := GetConfigurationString('PYTHONWHEELSURL', 'https://dl.espressif.com/pypi');
    PythonWheelsVersion := GetConfigurationString('PYTHONWHEELSVERSION', '{#PYTHONWHEELSVERSION}');
    SkipSystemCheck := GetConfigurationBoolean('SKIPSYSTEMCHECK', 'no');
    UseEmbeddedGit := GetConfigurationBoolean('USEEMBEDDEDGIT', 'yes');
    UseEmbeddedPython := GetConfigurationBoolean('USEEMBEDDEDPYTHON', 'yes');
end;


{ Required to display option for installation configuration. }
function IsOnlineMode():Boolean;
begin
    Result := not IsOfflineMode;
end;

function GetIDFPath(FileName: String): String;
begin
  if IDFUseExisting then begin
    Result := IDFExistingPath;
  end else begin
    Result := IDFDownloadPath;
  end;
  if (Result[Length(Result)] <> '\') then begin
    Result := Result + '\';
  end;
  Result := Result + FileName;
end;


function GetPathWithForwardSlashes(Path: String): String;
var
  ResultPath: String;
begin
  ResultPath := Path;
  StringChangeEx(ResultPath, '\', '/', True);
  Result := ResultPath;
end;

function GetPathWithBackslashes(Path: String): String;
var
  ResultPath: String;
begin
  ResultPath := Path;
  StringChangeEx(ResultPath, '/', '\', True);
  Result := ResultPath;
end;


{ Find Major and Minor version in esp_idf_version.h file. }
function GetIDFVersionFromHeaderFile():String;
var
  HeaderFileName: String;
  HeaderLines: TArrayOfString;
  LineIndex: Integer;
  LineCount: Longint;
  Line: String;
  MajorVersion: String;
  MinorVersion: String;
begin
  HeaderFileName := GetIDFPath('components\esp_common\include\esp_idf_version.h');
  Log('Parsing version from header file: ' + HeaderFileName);
  if (not FileExists(HeaderFileName)) then begin
    Result := '';
    Log('Unable to determine version');
    Exit;
  end;

  LoadStringsFromFile(HeaderFileName, HeaderLines);
  LineCount := GetArrayLength(HeaderLines);
  for LineIndex := 0 to LineCount - 1 do begin
    Line := HeaderLines[LineIndex];
    if (pos('define ESP_IDF_VERSION_MAJOR', Line) > 0) then begin
      Delete(Line, 1, 29);
      MajorVersion := Trim(Line);
    end else if (pos('define ESP_IDF_VERSION_MINOR', Line) > 0) then begin
      Delete(Line, 1, 29);
      MinorVersion := Trim(Line);
      Result := MajorVersion + '.' + MinorVersion;
      Log('Detected version: ' + Result);
      Exit;
    end
  end;
end;

{ Get short version from long version e.g. 3.7.9 -> 3.7 }
function GetShortVersion(VersionString:String):String;
var
  VersionIndex: Integer;
  MajorString: String;
  MinorString: String;
  DotIndex: Integer;
  DashIndex: Integer;
begin
  { Transform version vx.y or release/vx.y to x.y }
  VersionIndex := pos('v', VersionString);
  if (VersionIndex > 0) then begin
    Delete(VersionString, 1, VersionIndex);
  end;

  { Transform version x.y.z to x.y }
  DotIndex := pos('.', VersionString);
  if (DotIndex > 0) then begin
    MajorString := Copy(VersionString, 1, DotIndex - 1);
    Delete(VersionString, 1, DotIndex);
    { Trim trailing version numbers. }
    DotIndex := pos('.', VersionString);
    if (DotIndex > 0) then begin
      MinorString := Copy(VersionString, 1, DotIndex - 1);
      VersionString := MajorString + '.' + MinorString;
    end else begin
     VersionString :=  MajorString + '.' + VersionString;
    end;
  end;

  { Trim trailing dash }
  DashIndex := pos('-', VersionString);
  if (DashIndex > 0) then begin
    VersionString := Copy(VersionString, 1, DashIndex - 1)
  end;

  Result := VersionString;
end;

function TrimTrailingBackslash(Path: String): String;
begin
  if (Path[Length(Path)] = '\') then begin
    Delete(Path, Length(Path), 1);
  end;
  Result := Path;
end;

function AddTrailingBackslash(Path: String): String;
begin
  if (Path[Length(Path)] <> '\') then begin
    Path := Path + '\';
  end;
  Result := Path;
end;

function GetIDFShortVersion(): String;
begin
  { Transform main or master to x.y }
  if (Pos('main', IDFDownloadVersion) > 0) or (Pos('master', IDFDownloadVersion) > 0) or IDFUseExisting then begin
    Result := GetIDFVersionFromHeaderFile();
  end else begin
    Result := GetShortVersion(IDFDownloadVersion);
  end;
end;

{ Get IDF version string in combination with Python version. }
{ Result e.g.: idf4.1_py38 }
function GetIDFPythonEnvironmentVersion():String;
begin
  Result := 'idf' + GetIDFShortVersion() + '_py' + GetShortVersion(PythonVersion);
end;

function GetPythonVirtualEnvPath(): String;
var
  PythonVirtualEnvPath: String;
begin
  { The links should contain reference to Python vitual env }
  PythonVirtualEnvPath := ExpandConstant('{app}\python_env\') + GetIDFPythonEnvironmentVersion() + '_env\Scripts';
  Log('Path to Python in virtual env: ' + PythonVirtualEnvPath);

  { Fallback in case of not existing environment. }
  if (not FileExists(PythonVirtualEnvPath + '\python.exe')) then begin
    PythonVirtualEnvPath := PythonPath;
    Log('python.exe not found, reverting to:' + PythonPath);
  end;
  Result := PythonVirtualEnvPath;
end;

{ Get Path to virtual environment Python executable }
function GetPythonVirtualEnvExecutable(): String;
begin
  Result := GetPythonVirtualEnvPath() + '\python.exe';
end;

{ Get Path to virtual environment pip executable }
function GetPythonVirtualEnvPipExecutable(): String;
begin
  Result := GetPythonVirtualEnvPath() + '\pip.exe';
end;

{ Get Path to virtual environment pip executable }
{ Wrap MsgBox function and hide message box in silent mode, otherwise it blocks silent installation. }
function MessageBox(const Text: String; const Typ: TMsgBoxType; const Buttons: Integer): Integer;
begin
  if (WizardSilent()) then begin
    Result := 0;
    Log('Silenced messagebox: ' + Text);
    Log('Returning value: 0');
    Exit;
  end;
  Result := MsgBox(Text, Typ, Buttons);
end;

function GetIdfId():String;
var
  IdfPathWithForwardSlashes: String;
begin
  IdfPathWithForwardSlashes := GetPathWithForwardSlashes(GetIDFPath(''))
  Result := 'esp-idf-' + GetMD5OfString(IdfPathWithForwardSlashes);
end;

procedure SaveIdfEclipseConfiguration(FilePath: String);
var
    Content: String;
    IdfId: String;
    IdfPathWithForwardSlashes: String;
    IdfVersion: String;
begin
  IdfPathWithForwardSlashes := GetPathWithForwardSlashes(GetIDFPath(''))
  IdfId := GetIdfId();
  IdfVersion := GetIDFVersionFromHeaderFile();

  Content := '{' + #13#10;
  Content := Content + '  "$schema": "http://json-schema.org/schema#",' + #13#10;
  Content := Content + '  "$id": "http://dl.espressif.com/dl/schemas/esp_idf",' + #13#10;
  Content := Content + '  "_comment": "Configuration file for idf-env.",' + #13#10;
  Content := Content + '  "_warning": "Use / or \\ when specifying path. Single backslash is not allowed by JSON format.",' + #13#10;
  Content := Content + '  "gitPath": "' + GetPathWithForwardSlashes(GitExecutablePath) + '",' + #13#10;
  Content := Content + '  "idfToolsPath": "' + GetPathWithForwardSlashes(ExpandConstant('{app}')) + '",' + #13#10;
  Content := Content + '  "idfSelectedId": "' + IdfId + '",' + #13#10;
  Content := Content + '  "idfInstalled": {' + #13#10;
  Content := Content + '    "' + IdfId + '": {' + #13#10;
  Content := Content + '      "version": "' + IdfVersion + '",' + #13#10;
  Content := Content + '      "path": "' + IdfPathWithForwardSlashes + '",' + #13#10;
  Content := Content + '      "python": "' + GetPathWithForwardSlashes(GetPythonVirtualEnvExecutable()) + '"' + #13#10;
  Content := Content + '    }' + #13#10;
  Content := Content + '  }' + #13#10;
  Content := Content + '}' + #13#10;


  Log('Writing ESP-IDF configuration to file ' + FilePath);
  Log(Content);
  if (SaveStringToFile(FilePath, Content, False)) then begin
    Log('Configuration stored.');
  end else begin
     MessageBox(CustomMessage('UnableToWriteConfiguration') + ' ' + FilePath + #13#10
              + CustomMessage('CheckPermissionToFile'),
              mbInformation, MB_OK);
    Log('Unable to write configuration!');
  end;
end;

procedure SaveIdfConfiguration(FilePath: String);
var
    Content: String;
    IdfId: String;
    IdfPathWithForwardSlashes: String;
    IdfVersion: String;
    Command: String;
    ResultCode: Integer;
begin
  IdfPathWithForwardSlashes := GetPathWithForwardSlashes(GetIDFPath(''))
  IdfId := 'esp-idf-' + GetMD5OfString(IdfPathWithForwardSlashes);
  IdfVersion := GetIDFVersionFromHeaderFile();

  if (not FileExists(FilePath)) then begin

    Content := '{' + #13#10;
    Content := Content + '  "$schema": "http://json-schema.org/schema#",' + #13#10;
    Content := Content + '  "$id": "http://dl.espressif.com/dl/schemas/esp_idf",' + #13#10;
    Content := Content + '  "_comment": "Configuration file for ESP-IDF Eclipse plugin.",' + #13#10;
    Content := Content + '  "_warning": "Use / or \\ when specifying path. Single backslash is not allowed by JSON format.",' + #13#10;
    Content := Content + '  "gitPath": "' + GetPathWithForwardSlashes(GitExecutablePath) + '",' + #13#10;
    Content := Content + '  "idfToolsPath": "' + GetPathWithForwardSlashes(ExpandConstant('{app}')) + '",' + #13#10;
    Content := Content + '  "idfSelectedId": "' + IdfId + '",' + #13#10;
    Content := Content + '  "idfInstalled": {' + #13#10;
    Content := Content + '  }' + #13#10;
    Content := Content + '}' + #13#10;


    Log('Writing ESP-IDF configuration to file ' + FilePath);
    Log(Content);
    if (SaveStringToFile(FilePath, Content, False)) then begin
      Log('Configuration stored.');
    end else begin
      MessageBox(CustomMessage('UnableToWriteConfiguration') + ' ' + FilePath + #13#10
                + CustomMessage('CheckPermissionToFile'),
                mbInformation, MB_OK);
      Log('Unable to write configuration!');
    end;
  end;

  Command := 'config add';
  Command := Command + ' --idf-version "' + IdfVersion + '"';
  Command := Command + ' --idf-path "' + IdfPathWithForwardSlashes + '"';
  Command := Command + ' --python "' + GetPathWithForwardSlashes(GetPythonVirtualEnvPath()) + '/python.exe"';

  Log(ExpandConstant('{app}\{#IDF_ENV}') + ' ' + Command);
  if Exec(ExpandConstant('{app}\{#IDF_ENV}'), Command, '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode) then begin
     Log('{#IDF_ENV} success');
  end else begin
    Log('{#IDF_ENV} failed');
  end;

end;
