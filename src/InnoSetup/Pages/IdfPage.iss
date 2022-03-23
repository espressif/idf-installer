[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

{ ------------------------------ Page to select whether to download ESP-IDF, or use an existing copy ------------------------------ }

var
  IDFPage: TInputOptionWizardPage;
  IDFSelectionDownloadIndex: Integer;
  IDFSelectionCustomPathIndex: Integer;

function IDFDownloadRequired(): Boolean;
begin
  if (IsOfflineMode) then begin
    Result := false;
  end else begin
    Result := not IDFUseExisting;
  end;
end;

procedure IDFPageUpdateInput();
var
  Enable: Boolean;
begin
  if IDFPage.SelectedValueIndex = IDFSelectionCustomPathIndex then
    Enable := True;

  ChoicePageSetInputEnabled(IDFPage, Enable);
end;

procedure OnIDFPagePrepare(Sender: TObject);
var
  Page: TInputOptionWizardPage;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnIDFPagePrepare');
  if Page.CheckListBox.Items.Count > 0 then
    exit;

  IDFSelectionDownloadIndex := Page.Add(CustomMessage('DownloadEspIdf'))
  IDFSelectionCustomPathIndex := Page.Add(CustomMessage('UsingExistingEspIdfDirectory'));

  if (IDFUseExisting) then begin
    Page.SelectedValueIndex := 1;

    { IDF directory specified from command line. }
    if (IDFDirectory <> '') then begin
      ChoicePageSetInputText(Page, IDFDirectory);
    end;
  end else begin
    Page.SelectedValueIndex := 0;
  end;
  IDFPageUpdateInput();
end;

procedure OnIDFSelectionChange(Sender: TObject);
var
  Page: TInputOptionWizardPage;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnIDFSelectionChange index=' + IntToStr(Page.SelectedValueIndex));
  IDFPageUpdateInput();
end;



function OnIDFPageValidate(Sender: TWizardPage): Boolean;
var
  Page: TInputOptionWizardPage;
  NotSupportedMsg, IDFPath, IDFPyPath, RequirementsPath: String;
  RequirementsPathV5: String;
  RequirementsPathV5Tools: String;
begin
  Page := TInputOptionWizardPage(Sender);
  Log('OnIDFPageValidate index=' + IntToStr(Page.SelectedValueIndex));

  if Page.SelectedValueIndex = IDFSelectionDownloadIndex then
  begin
    IDFUseExisting := False;
    Result := True;
  end else begin
    IDFUseExisting := True;
    Result := False;
    NotSupportedMsg := 'The selected version of ESP-IDF is not supported:' + #13#10;
    IDFPath := ChoicePageGetInputText(Page);

    if not DirExists(IDFPath) then
    begin
      MessageBox(CustomMessage('DirectoryDoesNotExist') +' ' + IDFPath + #13#10 +
             CustomMessage('ChooseExistingEspIdfDirectory'), mbError, MB_OK);
      exit;
    end;

    if Pos(' ', IDFPath) <> 0 then
    begin
      MessageBox(CustomMessage('SpacesInPathNotSupported') + #13#10 +
             CustomMessage('ChooseExistingEspIdfDirectory'), mbError, MB_OK);
      exit;
    end;

    if (Length(IDFPath) > 90) then begin
      MessageBox(CustomMessage('ErrorTooLongIdfPath'), mbError, MB_OK);
      Result := False;
      exit;
    end;

    IDFPyPath := IDFPath + '\tools\idf.py';
    if not FileExists(IDFPyPath) then
    begin
      MessageBox(NotSupportedMsg +
             CustomMessage('UnableToFindIdfpy') + ' ' + IDFPath + '\tools', mbError, MB_OK);
      exit;
    end;

    RequirementsPath := IDFPath + '\requirements.txt';
    RequirementsPathV5 := IDFPath + '\requirements.core.txt';
    RequirementsPathV5Tools := IDFPath + '\tools\requirements\requirements.core.txt';
    if (not FileExists(RequirementsPath)) and (not FileExists(RequirementsPathV5))
      and (not FileExists(RequirementsPathV5Tools)) then
    begin
      MessageBox(NotSupportedMsg +
             CustomMessage('UnableToFindRequirementsTxt') + ' ' + IDFPath, mbError, MB_OK);
      exit;
    end;

    IDFExistingPath := IDFPath;
    Result := True;
  end;
end;

<event('ShouldSkipPage')>
function ShouldSkipIDFPage(PageID: Integer): Boolean;
begin
  { The page does not make sense in offline mode }
  if (PageID = IDFPage.ID) and IsOfflineMode then begin
    Result := True;
  end;
end;


<event('InitializeWizard')>
procedure CreateIDFPage();
begin
  IDFPage := ChoicePageCreate(
    wpLicense,
    CustomMessage('DownloadOrUseExistingEspIdf'),
    CustomMessage('DownloadOrUseExistingEspIdfDetail'),
    CustomMessage('AvailableEspIdfVersions'),
    CustomMessage('ChooseExistingEspIdfDirectory'),
    True,
    @OnIDFPagePrepare,
    @OnIDFSelectionChange,
    @OnIDFPageValidate);
end;

{ Validate screen with Tools after ESP-IDF selection. }
{ Tools directory should not be under a directory with ESP-IDF source code, }
{ because git reset on source code repository will erase tools. }
<event('NextButtonClick')>
function ToolsLocationPageValidate(CurPageID: Integer): Boolean;
var
  ToolsDir: String;
  IDFDir: String;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    ToolsDir := WizardForm.DirEdit.Text;

    if (Length(ToolsDir) > 90) then begin
      MessageBox(CustomMessage('ErrorTooLongToolsPath'), mbError, MB_OK);
      Result := False;
      exit;
    end;

    if Pos(' ', ToolsDir) <> 0 then
    begin
      MessageBox(CustomMessage('SpacesInPathNotSupported') + #13#10 +
             CustomMessage('ChooseDifferentDirectory'), mbError, MB_OK);
      exit;
    end;

#ifdef OFFLINEBRANCH
    if (IsOfflineMode) then begin
      IDFDownloadVersion := '{#OFFLINEBRANCH}';
      IDFDownloadPath := ExpandConstant('{app}\frameworks\esp-idf-v' + IDFDownloadVersion);
      Log('Offline mode active');
      Log('IDFDownloadVersion: ' + IDFDownloadVersion);
      Log('IDFDownloadPath: ' + IDFDownloadPath);
    end;
#endif

    IDFDir := GetIDFPath('');
    Log('Checking location of ToolsDir ' + ToolsDir + ' is not a subdirectory of ' + IDFDir);
    if Pos(IDFDir, ToolsDir) = 1 then
    begin
      MessageBox(CustomMessage('EspIdfToolsShouldNotBeLocatedUnderSource'), mbError, MB_OK);
      Result := False;
    end;
  end;
end;
