[Code]
{ Copyright 2019-2021 Espressif Systems (Shanghai) CO LTD
  SPDX-License-Identifier: Apache-2.0 }

const
  EVENT_BEFORE_NAVIGATE = 1;
  EVENT_FRAME_COMPLETE = 2;
  EVENT_DOCUMENT_COMPLETE = 3;
var
  CustomPage: TWizardPage;
type
  TWebBrowserEventProc = procedure(EventCode: Integer; URL: WideString);
procedure WebBrowserCreate(ParentWnd: HWND; Left, Top, Width, Height: Integer; 
  CallbackProc: TWebBrowserEventProc);
  external 'WebBrowserCreate@files:webbrowser.dll stdcall';
procedure WebBrowserDestroy;
  external 'WebBrowserDestroy@files:webbrowser.dll stdcall';
procedure WebBrowserShow(Visible: Boolean);
  external 'WebBrowserShow@files:webbrowser.dll stdcall';
procedure WebBrowserNavigate(URL: WideString);
  external 'WebBrowserNavigate@files:webbrowser.dll stdcall';
function WebBrowserGetOleObject: Variant;
  external 'WebBrowserGetOleObject@files:webbrowser.dll stdcall';
procedure OnWebBrowserEvent(EventCode: Integer; URL: WideString); 
begin
  {if EventCode = EVENT_DOCUMENT_COMPLETE then
    MessageBox('Navigation completed. ' + URL, mbInformation, MB_OK);}
end;

procedure InitializeWizard;
var
  ResultCode: Integer;
begin
  ExtractTemporaryFile('index.html');
  {ExtractTemporaryFile('vue.js');
  ExtractTemporaryFile('vuex.js');
  ExtractTemporaryFile('vue-router.js');
  ExtractTemporaryFile('roboto.css');
  ExtractTemporaryFile('roboto.ttf');}
  ExtractTemporaryFile('Curator.exe');
  ExtractTemporaryFile('Microsoft.Toolkit.Wpf.UI.Controls.WebView.dll');
  if Exec(ExpandConstant('{tmp}\Curator.exe'), '', '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode) then
  begin
    // handle success if necessary; ResultCode contains the exit code
  end
  else begin
    // handle failure if necessary; ResultCode contains the error code
  end;
  CustomPage := CreateCustomPage(wpWelcome, 'Web Browser Page', 
    'This page contains web browser');
  {WebBrowserCreate(WizardForm.InnerPage.Handle, 0, WizardForm.Bevel1.Top, 
    WizardForm.InnerPage.ClientWidth, WizardForm.InnerPage.ClientHeight - WizardForm.Bevel1.Top,
    @OnWebBrowserEvent);}
  //WebBrowserNavigate(ExpandConstant('file://{tmp}/index.html'));
end;

procedure DeinitializeSetup;
begin
  WebBrowserDestroy;
end;
procedure CurPageChanged(CurPageID: Integer);
begin
  WebBrowserShow(CurPageID = CustomPage.ID);
end;
