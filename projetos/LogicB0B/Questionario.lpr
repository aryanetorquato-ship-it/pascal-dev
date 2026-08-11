program Questionario;

{$mode objfpc}{$H+}
{$apptype GUI}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms,
  MainForm, HardwareInfo, LBXCrypto, BuildInfo;

begin
  RequireDerivedFormResource := False;
  Application.Title := 'LogicB0B Questionario';
  Application.Scaled := True;
  Application.Initialize;

  frmMain := TfrmMain.CreateNew(nil);
  frmMain.MontarInterface;
  frmMain.Show;

  Application.Run;
end.
