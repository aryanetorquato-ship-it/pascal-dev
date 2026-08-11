program Analyser;

{$mode objfpc}{$H+}
{$apptype GUI}

uses
  Interfaces, Forms, AnalyserForm;

begin
  Application.Initialize;
  frmAnalyser := TfrmAnalyser.CreateNew(nil);
  frmAnalyser.MontarInterface;
  frmAnalyser.Show;
  Application.Run;
end.
