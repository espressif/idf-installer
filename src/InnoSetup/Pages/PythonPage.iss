[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Find installed Python interpreters in Windows Registry (see PEP 514) ------------------------------ }

var
  InstalledPythonVersions: TStringList;
  InstalledPythonDisplayNames: TStringList;
  InstalledPythonExecutables: TStringList;

procedure PythonVersionAdd(Version, DisplayName, Executable: String);
begin
  Log('Adding Python version=' + Version + ' name='+DisplayName+' executable='+Executable);
  InstalledPythonVersions.Append(Version);
  InstalledPythonDisplayNames.Append(DisplayName);
  InstalledPythonExecutables.Append(Executable);
end;

function GetPythonVersionInfoFromKey(RootKey: Integer; SubKeyName, CompanyName, TagName: String;
                                     var Version: String;
                                     var DisplayName: String;
                                     var ExecutablePath: String;
                                     var BaseDir: String): Boolean;
var
  TagKey, InstallPathKey, DefaultPath: String;
begin
  TagKey := SubKeyName + '\' + CompanyName + '\' + TagName;
  InstallPathKey := TagKey + '\InstallPath';

  if not RegQueryStringValue(RootKey, InstallPathKey, '', DefaultPath) then
  begin
    Log('No (Default) key, skipping');
    Result := False;
    exit;
  end;

  if not RegQueryStringValue(RootKey, InstallPathKey, 'ExecutablePath', ExecutablePath) then
  begin
    Log('No ExecutablePath, using the default');
    ExecutablePath := DefaultPath + '\python.exe';
  end;

  BaseDir := DefaultPath;

  if not RegQueryStringValue(RootKey, TagKey, 'SysVersion', Version) then
  begin
    if CompanyName = 'PythonCore' then
    begin
      Version := TagName;
      Delete(Version, 4, Length(Version));
    end else begin
      Log('Can not determine SysVersion');
      Result := False;
      exit;
    end;
  end;

  if not RegQueryStringValue(RootKey, TagKey, 'DisplayName', DisplayName) then
  begin
    DisplayName := 'Python ' + Version;
  end;

  Result := True;
end;


var
  PythonPage: TInputOptionWizardPage;

function GetPythonPath(Unused: String): String;
begin
  Result := PythonPath;
end;

function PythonVersionSupported(Version: String): Boolean;
var
  Major, Minor: Integer;
begin
  Result := False;
  if not VersionExtractMajorMinor(Version, Major, Minor) then
  begin
    Log('PythonVersionSupported: Could not parse version=' + Version);
    exit;
  end;

  if (Major = 2) and (Minor = 7) then Result := True;
  if (Major = 3) and (Minor >= 5) then Result := True;
end;

procedure OnPythonPagePrepare(Sender: TObject);
var
  Page: TInputOptionWizardPage;
  FullName: String;
  i, Index, FirstEnabledIndex: Integer;
  OfferToInstall: Boolean;
  VersionToInstall: String;
  VersionSupported: Boolean;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnPythonPagePrepare');
  if Page.CheckListBox.Items.Count > 0 then
    exit;

  VersionToInstall := '{#PythonVersion}';
  OfferToInstall := True;
  FirstEnabledIndex := -1;

  for i := 0 to InstalledPythonVersions.Count - 1 do
  begin
    VersionSupported := PythonVersionSupported(InstalledPythonVersions[i]);
    FullName := InstalledPythonDisplayNames.Strings[i];
    if not VersionSupported then
    begin
      FullName := FullName + ' (unsupported)';
    end;
    FullName := FullName + #13#10 + InstalledPythonExecutables.Strings[i];
    Index := Page.Add(FullName);
    if not VersionSupported then
    begin
      Page.CheckListBox.ItemEnabled[Index] := False;
    end else begin
      if FirstEnabledIndex < 0 then FirstEnabledIndex := Index;
    end;
    if InstalledPythonVersions[i] = VersionToInstall then
    begin
      OfferToInstall := False;
    end;
  end;

  if OfferToInstall then
  begin
    Index := Page.Add('Install Python ' + VersionToInstall);
    if FirstEnabledIndex < 0 then FirstEnabledIndex := Index;
  end;

  Page.SelectedValueIndex := FirstEnabledIndex;
end;

procedure OnPythonSelectionChange(Sender: TObject);
var
  Page: TInputOptionWizardPage;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnPythonSelectionChange index=' + IntToStr(Page.SelectedValueIndex));
end;

procedure ApplyPythonConfigurationByIndex(Index:Integer);
begin
  Log('ApplyPythonConfigurationByIndex index=' + IntToStr(Index));
  PythonExecutablePath := InstalledPythonExecutables[Index];
  PythonPath := ExtractFilePath(PythonExecutablePath);
  PythonVersion := InstalledPythonVersions[Index];
  Log('ApplyPythonConfigurationByIndex: PythonPath='+PythonPath+' PythonExecutablePath='+PythonExecutablePath);
end;

function OnPythonPageValidate(Sender: TWizardPage): Boolean;
var
  Page: TInputOptionWizardPage;
begin
  Page := TInputOptionWizardPage(Sender);
  ApplyPythonConfigurationByIndex(Page.SelectedValueIndex);
  Result := True;
end;

procedure UpdatePythonVariables(ExecutablePath: String);
begin
  PythonExecutablePath := ExecutablePath;
  PythonPath := ExtractFilePath(PythonExecutablePath);
  Log('PythonExecutablePathUpdateAfterInstall: PythonPath='+PythonPath+' PythonExecutablePath='+PythonExecutablePath);
end;

<event('InitializeWizard')>
procedure CreatePythonPage();
begin
  PythonPage := ChoicePageCreate(
    wpLicense,
    'Python choice', 'Please choose Python version',
    'Available Python versions',
    '',
    False,
    @OnPythonPagePrepare,
    @OnPythonSelectionChange,
    @OnPythonPageValidate);
end;

<event('ShouldSkipPage')>
function ShouldSkipPythonPage(PageID: Integer): Boolean;
begin
  if (PageID = PythonPage.ID) then begin
    { Skip in case of embedded Python. }
    if (UseEmbeddedPython) then begin
      ApplyPythonConfigurationByIndex(0);
      Result := True;
    end;
  end;
end;
