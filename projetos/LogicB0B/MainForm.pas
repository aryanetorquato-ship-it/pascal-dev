unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  Graphics, HardwareInfo, LBXCrypto;

type
  TfrmMain = class(TForm)
  private
    EdtEstabelecimento: TEdit;
    EdtTotalComputadores: TEdit;
    EdtCaixas: TEdit;
    EdtRetaguardas: TEdit;
    ChkServidor: TCheckBox;
    ChkTEF: TCheckBox;
    EdtPinPads: TEdit;
    ChkImpressoras: TCheckBox;
    EdtQtdImpressoras: TEdit;
    EdtModelosImpressoras: TEdit;
    MemoObservacoes: TMemo;
    LblContadorObs: TLabel;
    LblStatus: TLabel;
    BtnGerar: TButton;

    procedure FormCreate(Sender: TObject);
    procedure ChkTEFChange(Sender: TObject);
    procedure ChkImpressorasChange(Sender: TObject);
    procedure MemoObservacoesChange(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);

    function ValidarInteiro(const Texto, NomeCampo: String; out Valor: Integer): Boolean;
    function SanitizarNomeArquivo(const Nome: String): String;
  public
    procedure MontarInterface;
    constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
  end;

var
  frmMain: TfrmMain;

implementation

const
  LARGURA_FORM = 480;

constructor TfrmMain.CreateNew(AOwner: TComponent; Num: Integer);
begin
  inherited CreateNew(AOwner, Num);
  OnCreate := @FormCreate;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MontarInterface;
end;

procedure TfrmMain.MontarInterface;
var
  Y: Integer;
  Lbl: TLabel;
begin
  Caption := 'LogicB0B Questionario';
  Width := LARGURA_FORM;
  Height := 640;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu];

  Y := 16;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Nome do estabelecimento:';
  Inc(Y, 18);

  EdtEstabelecimento := TEdit.Create(Self);
  EdtEstabelecimento.Parent := Self;
  EdtEstabelecimento.Left := 16;
  EdtEstabelecimento.Top := Y;
  EdtEstabelecimento.Width := LARGURA_FORM - 32;
  Inc(Y, 34);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Total de computadores:';
  Inc(Y, 18);

  EdtTotalComputadores := TEdit.Create(Self);
  EdtTotalComputadores.Parent := Self;
  EdtTotalComputadores.Left := 16;
  EdtTotalComputadores.Top := Y;
  EdtTotalComputadores.Width := 100;
  EdtTotalComputadores.Text := '0';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 140;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Caixas:';

  EdtCaixas := TEdit.Create(Self);
  EdtCaixas.Parent := Self;
  EdtCaixas.Left := 190;
  EdtCaixas.Top := Y;
  EdtCaixas.Width := 70;
  EdtCaixas.Text := '0';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 280;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Retaguarda:';

  EdtRetaguardas := TEdit.Create(Self);
  EdtRetaguardas.Parent := Self;
  EdtRetaguardas.Left := 350;
  EdtRetaguardas.Top := Y;
  EdtRetaguardas.Width := 70;
  EdtRetaguardas.Text := '0';
  Inc(Y, 40);

  ChkServidor := TCheckBox.Create(Self);
  ChkServidor.Parent := Self;
  ChkServidor.Left := 16;
  ChkServidor.Top := Y;
  ChkServidor.Width := LARGURA_FORM - 32;
  ChkServidor.Caption := 'Este computador sera o servidor do banco de dados';
  Inc(Y, 34);

  ChkTEF := TCheckBox.Create(Self);
  ChkTEF.Parent := Self;
  ChkTEF.Left := 16;
  ChkTEF.Top := Y;
  ChkTEF.Caption := 'Utiliza TEF';
  ChkTEF.OnChange := @ChkTEFChange;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 160;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Qtd. PinPads:';

  EdtPinPads := TEdit.Create(Self);
  EdtPinPads.Parent := Self;
  EdtPinPads.Left := 250;
  EdtPinPads.Top := Y;
  EdtPinPads.Width := 70;
  EdtPinPads.Text := '0';
  EdtPinPads.Enabled := False;
  Inc(Y, 34);

  ChkImpressoras := TCheckBox.Create(Self);
  ChkImpressoras.Parent := Self;
  ChkImpressoras.Left := 16;
  ChkImpressoras.Top := Y;
  ChkImpressoras.Caption := 'Utiliza impressoras termicas';
  ChkImpressoras.OnChange := @ChkImpressorasChange;
  Inc(Y, 26);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Quantidade:';

  EdtQtdImpressoras := TEdit.Create(Self);
  EdtQtdImpressoras.Parent := Self;
  EdtQtdImpressoras.Left := 100;
  EdtQtdImpressoras.Top := Y;
  EdtQtdImpressoras.Width := 70;
  EdtQtdImpressoras.Text := '0';
  EdtQtdImpressoras.Enabled := False;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 190;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Modelos:';

  EdtModelosImpressoras := TEdit.Create(Self);
  EdtModelosImpressoras.Parent := Self;
  EdtModelosImpressoras.Left := 250;
  EdtModelosImpressoras.Top := Y;
  EdtModelosImpressoras.Width := LARGURA_FORM - 266;
  EdtModelosImpressoras.Enabled := False;
  Inc(Y, 40);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Observacoes (opcional):';
  Inc(Y, 18);

  MemoObservacoes := TMemo.Create(Self);
  MemoObservacoes.Parent := Self;
  MemoObservacoes.Left := 16;
  MemoObservacoes.Top := Y;
  MemoObservacoes.Width := LARGURA_FORM - 32;
  MemoObservacoes.Height := 100;
  MemoObservacoes.ScrollBars := ssVertical;
  MemoObservacoes.OnChange := @MemoObservacoesChange;
  Inc(Y, 106);

  LblContadorObs := TLabel.Create(Self);
  LblContadorObs.Parent := Self;
  LblContadorObs.Left := 16;
  LblContadorObs.Top := Y;
  LblContadorObs.Caption := '0 / 1500 caracteres';
  LblContadorObs.Font.Color := clGray;
  Inc(Y, 30);

  LblStatus := TLabel.Create(Self);
  LblStatus.Parent := Self;
  LblStatus.Left := 16;
  LblStatus.Top := Y;
  LblStatus.Width := LARGURA_FORM - 32;
  LblStatus.Caption := '';
  LblStatus.Font.Color := clNavy;
  Inc(Y, 30);

  BtnGerar := TButton.Create(Self);
  BtnGerar.Parent := Self;
  BtnGerar.Left := 16;
  BtnGerar.Top := Y;
  BtnGerar.Width := LARGURA_FORM - 32;
  BtnGerar.Height := 36;
  BtnGerar.Caption := 'Gerar Despacho';
  BtnGerar.OnClick := @BtnGerarClick;
end;

procedure TfrmMain.ChkTEFChange(Sender: TObject);
begin
  EdtPinPads.Enabled := ChkTEF.Checked;
  if not ChkTEF.Checked then
    EdtPinPads.Text := '0';
end;

procedure TfrmMain.ChkImpressorasChange(Sender: TObject);
begin
  EdtQtdImpressoras.Enabled := ChkImpressoras.Checked;
  EdtModelosImpressoras.Enabled := ChkImpressoras.Checked;
  if not ChkImpressoras.Checked then
  begin
    EdtQtdImpressoras.Text := '0';
    EdtModelosImpressoras.Text := '';
  end;
end;

procedure TfrmMain.MemoObservacoesChange(Sender: TObject);
begin
  if Length(MemoObservacoes.Text) > 1500 then
    MemoObservacoes.Text := Copy(MemoObservacoes.Text, 1, 1500);
  LblContadorObs.Caption := IntToStr(Length(MemoObservacoes.Text)) + ' / 1500 caracteres';
end;

function TfrmMain.ValidarInteiro(const Texto, NomeCampo: String; out Valor: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(Texto), Valor) and (Valor >= 0);
  if not Result then
    ShowMessage('Campo "' + NomeCampo + '" precisa ser um numero inteiro maior ou igual a zero.');
end;

function TfrmMain.SanitizarNomeArquivo(const Nome: String): String;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(Nome) do
  begin
    C := Nome[I];
    if C in ['A'..'Z', 'a'..'z', '0'..'9', ' ', '-', '_'] then
      Result := Result + C;
  end;
  Result := Trim(Result);
  Result := StringReplace(Result, ' ', '_', [rfReplaceAll]);
  if Result = '' then
    Result := 'Estabelecimento';
end;

procedure TfrmMain.BtnGerarClick(Sender: TObject);
var
  TotalComputadores, Caixas, Retaguardas, PinPads, QtdImpressoras: Integer;
  Pacote: TStringList;
  HW: TStringList;
  I: Integer;
  NomeArquivo, CaminhoCompleto, PastaDesktop: String;
begin
  if Trim(EdtEstabelecimento.Text) = '' then
  begin
    ShowMessage('Informe o nome do estabelecimento.');
    Exit;
  end;

  if not ValidarInteiro(EdtTotalComputadores.Text, 'Total de computadores', TotalComputadores) then Exit;
  if not ValidarInteiro(EdtCaixas.Text, 'Caixas', Caixas) then Exit;
  if not ValidarInteiro(EdtRetaguardas.Text, 'Retaguarda', Retaguardas) then Exit;

  if Caixas > TotalComputadores then
  begin
    ShowMessage('A quantidade de Caixas nao pode ser maior que o total de computadores.');
    Exit;
  end;

  if Retaguardas > TotalComputadores then
  begin
    ShowMessage('A quantidade de Retaguarda nao pode ser maior que o total de computadores.');
    Exit;
  end;

  PinPads := 0;
  if ChkTEF.Checked then
    if not ValidarInteiro(EdtPinPads.Text, 'Qtd. PinPads', PinPads) then Exit;

  QtdImpressoras := 0;
  if ChkImpressoras.Checked then
    if not ValidarInteiro(EdtQtdImpressoras.Text, 'Quantidade de impressoras', QtdImpressoras) then Exit;

  BtnGerar.Enabled := False;
  LblStatus.Caption := 'Coletando informacoes do computador...';
  Application.ProcessMessages;

  Pacote := TStringList.Create;
  HW := HardwareInfo.ColetarHardware;
  try
    Pacote.Add('Estabelecimento=' + Trim(EdtEstabelecimento.Text));
    Pacote.Add('TotalComputadores=' + IntToStr(TotalComputadores));
    Pacote.Add('Caixas=' + IntToStr(Caixas));
    Pacote.Add('Retaguardas=' + IntToStr(Retaguardas));
    Pacote.Add('EhServidor=' + BoolToStr(ChkServidor.Checked, 'S', 'N'));
    Pacote.Add('UtilizaTEF=' + BoolToStr(ChkTEF.Checked, 'S', 'N'));
    Pacote.Add('QtdPinPads=' + IntToStr(PinPads));
    Pacote.Add('UtilizaImpressoras=' + BoolToStr(ChkImpressoras.Checked, 'S', 'N'));
    Pacote.Add('QtdImpressoras=' + IntToStr(QtdImpressoras));
    Pacote.Add('ModelosImpressoras=' + Trim(EdtModelosImpressoras.Text));
    Pacote.Add('Observacoes=' + StringReplace(MemoObservacoes.Text, #13#10, ' | ', [rfReplaceAll]));
    Pacote.Add('DataGeracao=' + DateTimeToStr(Now));

    for I := 0 to HW.Count - 1 do
      Pacote.Add(HW[I]);

    LblStatus.Caption := 'Gravando arquivo...';
    Application.ProcessMessages;

    PastaDesktop := GetEnvironmentVariable('USERPROFILE') + '\Desktop\';
    if not DirectoryExists(PastaDesktop) then
      PastaDesktop := GetEnvironmentVariable('USERPROFILE') + '\';

    NomeArquivo := SanitizarNomeArquivo(EdtEstabelecimento.Text) + '_' +
      FormatDateTime('yyyymmdd_hhnnss', Now) + '.LBX';
    CaminhoCompleto := PastaDesktop + NomeArquivo;

    SalvarArquivoLBX(CaminhoCompleto, Pacote.Text);

    LblStatus.Caption := 'Despacho gerado com sucesso.';
    ShowMessage(
      'Arquivo gerado com sucesso:' + LineEnding + LineEnding +
      CaminhoCompleto + LineEnding + LineEnding +
      'Envie esse arquivo para a Logicbox.'
    );
  finally
    Pacote.Free;
    HW.Free;
    BtnGerar.Enabled := True;
  end;
end;

end.
