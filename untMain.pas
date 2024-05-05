//------------------------------------------------------------------------------
// UNIT           : untMain.pas
// CONTENTS       : Radio Code Calculator for Fiat Continental VP1 and VP2
// VERSION        : 1.0
// TARGET         : Embarcadero Delphi 11 or higher
// AUTHOR         : Ernst Reidinga (ERDesigns)
// STATUS         : Open Source - Copyright © Ernst Reidinga
// COMPATIBILITY  : Windows 7, 8/8.1, 10, 11
// RELEASE DATE   : 05/05/2024
//------------------------------------------------------------------------------
unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

//------------------------------------------------------------------------------
// CLASSES
//------------------------------------------------------------------------------
type
  /// <summary>
  ///   Radio Code Calculator Main Form
  /// </summary>
  TfrmMain = class(TForm)
    bvImageLine: TBevel;
    imgLogo: TImage;
    pnlBottom: TPanel;
    bvPnlLine: TBevel;
    btnAbout: TButton;
    btnCalculate: TButton;
    pnlSerialNumber: TPanel;
    lblSerialNumber: TLabel;
    edtSerialNumber: TEdit;
    pnlRadioCode: TPanel;
    lblRadioCode: TLabel;
    edtRadioCode: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

//------------------------------------------------------------------------------
// FORM ON CREATE
//------------------------------------------------------------------------------
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Set the caption
  Caption := Application.Title;
  // Set the labels captions
  lblSerialNumber.Caption := 'Serial Number:';
  lblRadioCode.Caption    := 'Radio Code:';
  // Set the button captions
  btnCalculate.Caption := 'Calculate..';
  btnAbout.Caption := 'About..';
end;

//------------------------------------------------------------------------------
// CALCULATE RADIO CODE
//------------------------------------------------------------------------------
procedure TfrmMain.btnCalculateClick(Sender: TObject);

  function Validate(const Input: string; var ErrorMessage: string): Boolean;
  begin
    // Initialize result
    Result := True;
    // Clear the error message
    ErrorMessage := '';

    // Make sure the input is 4 characters long
    if not (Length(Input) = 4) then
    begin
      ErrorMessage := 'Must be 4 characters long!';
      Exit(False);
    end;

    // Make sure the input starts with a digit
    if not CharInSet(Input[1], ['0'..'9']) then
    begin
      ErrorMessage := 'First character must be a digit!';
      Exit(False);
    end;

    // Make sure the second character is a digit
    if not (CharInSet(Input[2], ['0'..'9'])) then
    begin
      ErrorMessage := 'Second character must be a digit!';
      Exit(False);
    end;

    // Make sure the third character is a digit
    if not (CharInSet(Input[3], ['0'..'9'])) then
    begin
      ErrorMessage := 'Third character must be a digit!';
      Exit(False);
    end;

    // Make sure the fourth character is a digit
    if not (CharInSet(Input[4], ['0'..'9'])) then
    begin
      ErrorMessage := 'Fourth character must be a digit!';
      Exit(False);
    end;
  end;

  function GetFourthByte(Input: Integer): Integer;
  begin
    if (Input > 10) then Result := 0 else
    case Input of
      6,
      7: Result := 3;
      8: Result := 0;
      9: Result := 1;
    else
      Result := Input;
    end;
  end;

  function GetThirdByte(Input: Integer): Integer;
  begin
    if (Input > 10) then Result := 0 else
    case Input of
      6,
      7: Result := 2;
      8: Result := 0;
      9: Result := 1;
    else
      Result := Input;
    end;
  end;

  function GetSecondByte(Input: Integer): Integer;
  begin
    if (Input > 10) then Result := 0 else
    case Input of
      6,
      7: Result := 1;
      8: Result := 0;
      9: Result := 1;
    else
      Result := Input;
    end;
  end;

  function GetFirstByte(Input: Integer): Integer;
  begin
    if (Input > 10) then Result := 0 else
    case Input of
      6,
      7,
      8: Result := 0;
      9: Result := 1;
    else
      Result := Input;
    end;
  end;

var
  ErrorMessage: string;
  InputCode, OutputCode: Integer;
  SNArr: array[0..3] of Integer;
begin
  // Clear the error message
  ErrorMessage := '';

  // Check if the serial number is valid
  if not Validate(edtSerialNumber.Text, ErrorMessage) then
  begin
    MessageBox(Handle, PChar(ErrorMessage), PChar(Application.Title), MB_ICONWARNING + MB_OK);
    Exit;
  end;

  // Set the input code
  InputCode := StrToInt(edtSerialNumber.Text);

  // Calculate the code
  OutputCode := 1111;

  SNArr[0] := (InputCode div 1000) and $0F;
  SNArr[1] := (InputCode mod 1000) div 100 and $0F;
  SNArr[2] := (InputCode mod 100) div 10 and $0F;
  SNArr[3] := InputCode mod 10 and $0F;

  OutputCode := OutputCode + GetThirdByte(SNArr[3]) * 10;
  OutputCode := OutputCode + GetFirstByte(SNArr[2]) * 1000;
  OutputCode := OutputCode + GetFourthByte(SNArr[1]);
  OutputCode := OutputCode + GetSecondByte(SNArr[0]) * 100;

  // Format the code for the output
  edtRadioCode.Text := Format('%.*d', [4, OutputCode]);
end;

//------------------------------------------------------------------------------
// SHOW ABOUT DIALOG
//------------------------------------------------------------------------------
procedure TfrmMain.btnAboutClick(Sender: TObject);
const
  AboutText: string =
    'Fiat Continental VP1 VP2 Radio Code Calculator' + sLineBreak + sLineBreak +
    'by Ernst Reidinga - ERDesigns'                  + sLineBreak +
    'Version 1.0 (05/2024)'                          + sLineBreak + sLineBreak +
    'Usage:'                                         + sLineBreak +
    'Enter the last 4 digits of the serial number'   + sLineBreak +
    'and press "calculate".';
begin
  MessageBox(Handle, PChar(AboutText), PChar(Caption), MB_ICONINFORMATION + MB_OK);
end;

end.
