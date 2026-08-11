unit AnalyserForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Grids,
  LBXCrypto, HardwareRules;

type
  TfrmAnalyser = class(TForm)
  private
    BtnAbrir: TButton;
    Grid: TStringGrid;
    MemoParecer: TMemo;
    OpenDialog: TOpenDialog;
    procedure BtnAbrirClick(Sender: TObject);
    procedure ProcessarConteudo(const Conteudo: String);
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

procedure TfrmAnalyser.ProcessarConteudo(const Conteudo: String);
var
  Linhas: TStringList;
  I, PosIgual: Integer;
  Chave, Valor: String;
  Processador, MemoriaRAM, SistemaOperacional, Papel, Estabelecimento: String;
  RAMGB: Integer;
  Avaliacao: TResultadoAvaliacao;
  Parecer: TStringList;
begin
  Linhas := TStringList.Create;
  Parecer := TStringList.Create;
  try
    Linhas.Text := Conteudo;

    Grid.RowCount := 1;
    Processador := '';
    MemoriaRAM := '';
    SistemaOperacional := '';
    Papel := '';
    Estabelecimento := '';

    for I := 0 to Linhas.Count - 1 do
    begin
      PosIgual := Pos('=', Linhas[I]);
      if PosIgual = 0 then Continue;

      Chave := Copy(Linhas[I], 1, PosIgual - 1);
      Valor := Copy(Linhas[I], PosIgual + 1, Length(Linhas[I]));

      Grid.RowCount := Grid.RowCount + 1;
      Grid.Cells[0, Grid.RowCount - 1] := Chave;
      Grid.Cells[1, Grid.RowCount - 1] := Valor;

      if Chave = 'Processador' then Processador := Valor
      else if Chave = 'MemoriaRAM' then MemoriaRAM := Valor
      else if Chave = 'SistemaOperacional' then SistemaOperacional := Valor
      else if Chave = 'PapelComputador' then Papel := Valor
      else if Chave = 'Estabelecimento' then Estabelecimento := Valor;
    end;

    RAMGB := ExtrairRAMGB(MemoriaRAM);
    Avaliacao := AvaliarPapel(Papel, Processador, RAMGB, SistemaOperacional);

    Parecer.Add('Estabelecimento: ' + Estabelecimento);
    Parecer.Add('Papel deste computador: ' + Papel);
    Parecer.Add('Processador detectado: ' + Processador);
    Parecer.Add('Memoria RAM: ' + IntToStr(RAMGB) + ' GB');
    Parecer.Add('Sistema Operacional: ' + SistemaOperacional);
    Parecer.Add('');
    Parecer.Add('=== PARECER ===');
    Parecer.Add(NivelParaTexto(Avaliacao.Nivel));
    Parecer.Add(Avaliacao.Motivo);

    MemoParecer.Lines := Parecer;
  finally
    Linhas.Free;
    Parecer.Free;
  end;
end;

procedure TfrmAnalyser.BtnAbrirClick(Sender: TObject);
var
  Conteudo: String;
begin
  if not OpenDialog.Execute then Exit;

  try
    Conteudo := AbrirArquivoLBX(OpenDialog.FileName);
    ProcessarConteudo(Conteudo);
  except
    on E: Exception do
      ShowMessage('Erro ao abrir/descriptografar arquivo: ' + E.Message);
  end;
end;

end.
