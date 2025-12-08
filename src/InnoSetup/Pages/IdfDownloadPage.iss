{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Page to select the version of ESP-IDF to download ------------------------------ }

var
  IDFDownloadPage: TInputOptionWizardPage;

function GetSuggestedIDFDirectory(SelectedIdfVersion:String): String;
var
  BaseName: String;
  RepeatIndex: Integer;
begin
  if (IDFDirectory <> '') then begin
    Result := IDFDirectory
    Exit;
  end;

  { Start with Desktop\esp-idf name and if it already exists,
    keep trying with Desktop\esp-idf-N for N=2 and above. }
  if Pos('release', SelectedIdfVersion) > 0 then begin
    Delete(SelectedIdfVersion, 1, 8);
  end;
  BaseName := ExpandConstant('C:\Espressif\frameworks\esp-idf-' + SelectedIdfVersion);
  Result := BaseName;
  RepeatIndex := 1;
  while DirExists(Result) do
  begin
    RepeatIndex := RepeatIndex + 1;
    Result := BaseName + '-' + IntToStr(RepeatIndex);
  end;
end;

function GetIDFVersionDescription(Version: String): String;
begin
  if WildCardMatch(Version, 'v*-beta*') then
    Result := 'beta version'
  else if WildCardMatch(Version, 'v*-rc*') then
    Result := 'pre-release version'
  else if WildCardMatch(Version, 'v*') then
    Result := 'release version - .zip archive download'
  else if WildCardMatch(Version, 'release/v*') then
    Result := 'release branch - git clone'
  else if WildCardMatch(Version, 'master') then
    Result := 'development branch'
  else
    Result := '';
end;

procedure ExtractIDFVersionList();
begin
  ExtractTemporaryFile('idf_versions.txt');
end;

{ Filter out unsupported versions (master, v6.*, release/v6.*) }
procedure FilterIDFVersions();
var
  i, j: Integer;
  Version: String;
begin
  j := 0;
  for i := 0 to GetArrayLength(IDFDownloadAvailableVersions) - 1 do
  begin
    Version := IDFDownloadAvailableVersions[i];
    if (Version <> 'master') and 
       not WildCardMatch(Version, 'v6.*') and 
       not WildCardMatch(Version, 'release/v6.*') then
    begin
      IDFDownloadAvailableVersions[j] := Version;
      j := j + 1;
    end;
  end;
  SetArrayLength(IDFDownloadAvailableVersions, j);
end;

procedure DownloadIDFVersionsList();
var
  VersionFile: String;
begin
  VersionFile := ExpandConstant('{tmp}\idf_versions.txt');
  if idpDownloadFile(IDFVersionUrl, VersionFile) then
  begin
    Log('Downloaded ' + IDFVersionUrl + ' to ' + VersionFile);
  end else begin
    Log('Download of ' + IDFVersionUrl + ' failed, using a fallback versions list');
    ExtractIDFVersionList();
  end;
end;

procedure OnIDFDownloadPagePrepare(Sender: TObject);
var
  Page: TInputOptionWizardPage;
  VersionFile: String;
  i: Integer;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnIDFDownloadPagePrepare');
  if Page.CheckListBox.Items.Count > 0 then
    exit;

  if (IsOfflineMode) then begin
    Log('Offline Mode: using embedded idf_versions.txt')
    ExtractIDFVersionList();
  end else begin
    DownloadIDFVersionsList();
  end;

  VersionFile := ExpandConstant('{tmp}\idf_versions.txt');
  if not LoadStringsFromFile(VersionFile, IDFDownloadAvailableVersions) then
  begin
    Log('Failed to load versions from ' + VersionFile);
    exit;
  end;

  { Filter out unsupported versions }
  FilterIDFVersions();

  Log('Versions count: ' + IntToStr(GetArrayLength(IDFDownloadAvailableVersions)))
  for i := 0 to GetArrayLength(IDFDownloadAvailableVersions) - 1 do
  begin
    Log('Version ' + IntToStr(i) + ': ' + IDFDownloadAvailableVersions[i]);
    Page.Add(IDFDownloadAvailableVersions[i] + ' ('
             + GetIDFVersionDescription(IDFDownloadAvailableVersions[i]) + ')');
  end;
  Page.SelectedValueIndex := 0;

  ChoicePageSetInputText(Page, GetSuggestedIDFDirectory(IDFDownloadAvailableVersions[Page.SelectedValueIndex]));
end;

{ Validation of PATH for IDF releases which does not support special characters. }
{ Source: https://stackoverflow.com/questions/21623515/is-it-possible-to-filter-require-installation-path-to-be-ascii-in-innosetup }
function IsCharValid(Value: Char): Boolean;
begin
  Result := Ord(Value) <= $007F;
end;

function IsDirNameValid(const Value: string): Boolean;
var
  I: Integer;
begin
  if not IsCheckPathEnabled then begin
    Result := True;
    Exit;
  end;

  Result := False;
  for I := 1 to Length(Value) do
    if not IsCharValid(Value[I]) then
      Exit;
  Result := True;
end;

procedure OnIDFDownloadSelectionChange(Sender: TObject);
var
  Page: TInputOptionWizardPage;
begin
  Page := TInputOptionWizardPage(Sender);
  ChoicePageSetInputText(Page, GetSuggestedIDFDirectory( IDFDownloadAvailableVersions[Page.SelectedValueIndex]));
  Log('OnIDFDownloadSelectionChange index=' + IntToStr(Page.SelectedValueIndex));
end;

function OnIDFDownloadPageValidate(Sender: TWizardPage): Boolean;
var
  Page: TInputOptionWizardPage;
  IDFPath: String;
begin
  Result := False;
  Page := TInputOptionWizardPage(Sender);
  Log('OnIDFDownloadPageValidate index=' + IntToStr(Page.SelectedValueIndex));

  IDFPath := ChoicePageGetInputText(Page);
  if DirExists(IDFPath) and not DirIsEmpty(IDFPath) then
  begin
    MessageBox(CustomMessage('DirectoryAlreadyExists') + #13#10 +
           IDFPath + #13#10 + CustomMessage('ChooseDifferentDirectory'), mbError, MB_OK);
    exit;
  end;

  if (Pos(' ', IDFPath) <> 0) and IsCheckPathEnabled then
  begin
    MessageBox(CustomMessage('SpacesInPathNotSupported') + #13#10 +
           CustomMessage('ChooseDifferentDirectory'), mbError, MB_OK);
    exit;
  end;

  if (Length(IDFPath) > 90) and IsCheckPathEnabled then begin
    MessageBox(CustomMessage('ErrorTooLongIdfPath'), mbError, MB_OK);
    Result := False;
    exit;
  end;

  IDFDownloadPath := IDFPath;

  { Use parameter /IDFVERSION=x to override selection in the box. }
  IDFDownloadVersion := IDFVersion;
  if (IDFDownloadVersion = '') then begin
    IDFDownloadVersion := IDFDownloadAvailableVersions[Page.SelectedValueIndex];
  end;

  { Following ZIP versions of IDF does not support installation on path with special characters. }
  { Issue: https://github.com/espressif/esp-idf/issues/5996 }
  if ((IDFDownloadVersion = 'v4.2') or (IDFDownloadVersion = 'v4.0.2') or
    (IDFDownloadVersion = 'v3.3.4')) then begin
    if (not IsDirNameValid(IDFPath)) then begin
      MessageBox(CustomMessage('SpecialCharactersInPathNotSupported') + #13#10 +
            CustomMessage('ChooseDifferentDirectory'), mbError, MB_OK);
      exit;
    end;
  end;

  Result := True;
end;

<event('ShouldSkipPage')>
function ShouldSkipIDFDownloadPage(PageID: Integer): Boolean;
begin
  if (PageID = IDFDownloadPage.ID) and not IDFDownloadRequired() then
    Result := True;
end;

<event('InitializeWizard')>
procedure CreateIDFDownloadPage();
begin
  IDFDownloadPage := ChoicePageCreate(
    IDFPage.ID,
    CustomMessage('EspIdfVersion'), CustomMessage('ChooseEspIdfVersion'),
    CustomMessage('MoreInformation') + #13#10 +
      CustomMessage('EspIdfVersionInformationUrl'),
    CustomMessage('ChooseEspIdfDirectory'),
    True,
    @OnIDFDownloadPagePrepare,
    @OnIDFDownloadSelectionChange,
    @OnIDFDownloadPageValidate);
end;
