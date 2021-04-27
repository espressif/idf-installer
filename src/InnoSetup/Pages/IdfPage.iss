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
  Result := not IDFUseExisting;
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

  IDFSelectionDownloadIndex := Page.Add('Download ESP-IDF')
  IDFSelectionCustomPathIndex := Page.Add('Use an existing ESP-IDF directory');

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
      MessageBox('Directory doesn''t exist: ' + IDFPath + #13#10 +
             'Please choose an existing ESP-IDF directory', mbError, MB_OK);
      exit;
    end;

    if Pos(' ', IDFPath) <> 0 then
    begin
      MessageBox('ESP-IDF build system does not support spaces in paths.' + #13#10
             'Please choose a different directory.', mbError, MB_OK);
      exit;
    end;

    IDFPyPath := IDFPath + '\tools\idf.py';
    if not FileExists(IDFPyPath) then
    begin
      MessageBox(NotSupportedMsg +
             'Can not find idf.py in ' + IDFPath + '\tools', mbError, MB_OK);
      exit;
    end;

    RequirementsPath := IDFPath + '\requirements.txt';
    if not FileExists(RequirementsPath) then
    begin
      MessageBox(NotSupportedMsg +
             'Can not find requirements.txt in ' + IDFPath, mbError, MB_OK);
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
    'Download or use ESP-IDF', 'Please choose ESP-IDF version to download, or use an existing ESP-IDF copy',
    'Available ESP-IDF versions',
    'Choose existing ESP-IDF directory',
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
  Msg: string;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    ToolsDir := WizardForm.DirEdit.Text;
    IDFDir := GetIDFPath('');
    Log('Checking location of ToolsDir ' + ToolsDir + ' is not a subdirectory of ' + IDFDir);
    if Pos(IDFDir, ToolsDir) = 1 then
    begin
      MessageBox('Tools should not be located under ESP-IDF source code directory selected on the previous page. Please select a different location for Tools directory.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
