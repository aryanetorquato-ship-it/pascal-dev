unit AnalyserForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Grids;

type
  TfrmAnalyser = class(TForm)
  private
    BtnAbrir: TButton;
    Grid: TStringGrid;
    MemoParecer: TMemo;
    OpenDialog: TOpenDialog;
    procedure BtnAbrirClick(Sender: TObject);
  public
    procedure MontarInterface;
  end;

var
  frmAnalyser: TfrmAnalyser;

implementation

const
  LARGURA_FORM = 700;
  ALTURA_FORM = 560;

procedure TfrmAnalyser.MontarInterface;
begin
  Caption := 'LogicB0B Analyser';
  Width := LARGURA_FORM;
  Height := ALTURA_FORM;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu];
  ShowInTaskBar := stAlways;

  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := 'Arquivos LBX (*.lbx)|*.lbx';
  OpenDialog.Title := 'Abrir arquivo .LBX';

  BtnAbrir := TButton.Create(Self);
  BtnAbrir.Parent := Self;
  BtnAbrir.Left := 16;
  BtnAbrir.Top := 16;
  BtnAbrir.Width := 200;
  BtnAbrir.Height := 32;
  BtnAbrir.Caption := 'Abrir arquivo .LBX';
  BtnAbrir.OnClick := @BtnAbrirClick;

  Grid := TStringGrid.Create(Self);
  Grid.Parent := Self;
  Grid.Left := 16;
  Grid.Top := 60;
  Grid.Width := LARGURA_FORM - 48;
  Grid.Height := 260;
  Grid.ColCount := 2;
  Grid.RowCount := 1;
  Grid.FixedRows := 1;
  Grid.Cells[0, 0] := 'Chave';
  Grid.Cells[1, 0] := 'Valor';
  Grid.ColWidths[0] := 220;
  Grid.ColWidths[1] := 380;

  MemoParecer := TMemo.Create(Self);
  MemoParecer.Parent := Self;
  MemoParecer.Left := 16;
  MemoParecer.Top := 336;
  MemoParecer.Width := LARGURA_FORM - 48;
  MemoParecer.Height := 180;
  MemoParecer.ScrollBars := ssVertical;
  MemoParecer.ReadOnly := True;
  MemoParecer.Text := 'Parecer aparecera aqui apos abrir um arquivo .LBX.';
end;

procedure TfrmAnalyser.BtnAbrirClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    ShowMessage('Arquivo selecionado: ' + OpenDialog.FileName + #13#10 +
      '(descriptografia ainda nao implementada)');
end;

end.
