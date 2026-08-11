
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
    MemoModelosImpressoras: TMemo;
    MemoObservacoes: TMemo;
    LblContadorObs: TLabel;
    LblStatus: TLabel;
    BtnGerar: TButton;
    BtnEncerrar: TButton;

    procedure FormCreate(Sender: TObject);
    procedure ChkTEFChange(Sender: TObject);
    procedure ChkImpressorasChange(Sender: TObject);
    procedure MemoObservacoesChange(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure BtnEncerrarClick(Sender: TObject);

    function ValidarInteiro(const Texto, NomeCampo: String;
      out Valor: Integer): Boolean;
    function SanitizarNomeArquivo(const Nome: String): String;
    function ObterModelosImpressoras: String;
    function ValidarModelosImpressoras: Boolean;
  public
    procedure MontarInterface;
    constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
  end;

var
  frmMain: TfrmMain;

implementation

const
  LARGURA_FORM = 480;
  ALTURA_FORM = 760;

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
  Height := ALTURA_FORM;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu];
  ShowInTaskBar := stAlways;

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
  EdtEstabelecimento.MaxLength := 60;
  Inc(Y, 40);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := 'Total de computadores (equipamentos fisicos):';
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
  Lbl.Caption := 'Caixas / PDVs:';

  EdtCaixas := TEdit.Create(Self);
  EdtCaixas.Parent := Self;
  EdtCaixas.Left := 190;
  EdtCaixas.Top := Y;
  EdtCaixas.Width := 70;
  EdtCaixas.Text := '0';

  Inc(Y, 28);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := 16;
  Lbl.Top := Y + 3;
  Lbl.Caption := 'Retaguarda / ADM:';

  EdtRetaguardas := TEdit.Create(Self);
  EdtRetaguardas.Parent := Self;
  EdtRetaguardas.Left := 120;
  EdtRetaguardas.Top := Y;
  EdtRetaguardas.Width := 70;
  EdtRetaguardas.Text := '0';

  Inc(Y, 28);

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
  Lbl.Caption := 'Detalhamento das impressoras:';
  Inc(Y, 24);

  MemoModelosImpressoras := TMemo.Create(Self);
  MemoModelosImpressoras.Parent := Self;
  MemoModelosImpressoras.Left := 16;
  MemoModelosImpressoras.Top := Y;
  MemoModelosImpressoras.Width := LARGURA_FORM - 32;
  MemoModelosImpressoras.Height := 58;
  MemoModelosImpressoras.ScrollBars := ssVertical;
  MemoModelosImpressoras.Enabled := False;
  MemoModelosImpressoras.MaxLength := 400;
  MemoModelosImpressoras.Hint :=
    'Informe os modelos e as respectivas quantidades. Ex.: 9 Elgin i9; 1 Daruma DR700; 7 Elgin i7.';
  MemoModelosImpressoras.ShowHint := True;
  Inc(Y, 66);

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
  LblContadorObs.AutoSize := True;
  LblContadorObs.Caption := '1500 caracteres restantes';
  LblContadorObs.Font.Color := clGray;
  Inc(Y, 24);

  LblStatus := TLabel.Create(Self);
  LblStatus.Parent := Self;
  LblStatus.Left := 16;
  LblStatus.Top := Y;
  LblStatus.Width := LARGURA_FORM - 32;
  LblStatus.AutoSize := False;
  LblStatus.Caption := '';
  LblStatus.Font.Color := clNavy;
  Inc(Y, 32);

  BtnGerar := TButton.Create(Self);
  BtnGerar.Parent := Self;
  BtnGerar.Left := 16;
  BtnGerar.Top := Y;
  BtnGerar.Width := LARGURA_FORM - 32;
  BtnGerar.Height := 36;
  BtnGerar.Caption := 'Gerar Relatorio';
  BtnGerar.OnClick := @BtnGerarClick;
  Inc(Y, 46);

  BtnEncerrar := TButton.Create(Self);
  BtnEncerrar.Parent := Self;
  BtnEncerrar.Left := 16;
  BtnEncerrar.Top := Y;
  BtnEncerrar.Width := LARGURA_FORM - 32;
  BtnEncerrar.Height := 36;
  BtnEncerrar.Caption := 'Encerrar Questionario';
  BtnEncerrar.Enabled := False;
  BtnEncerrar.OnClick := @BtnEncerrarClick;
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
  MemoModelosImpressoras.Enabled := ChkImpressoras.Checked;

  if not ChkImpressoras.Checked then
  begin
    EdtQtdImpressoras.Text := '0';
    MemoModelosImpressoras.Clear;
  end;
end;

procedure TfrmMain.MemoObservacoesChange(Sender: TObject);
begin
  if Length(MemoObservacoes.Text) > 1500 then
    MemoObservacoes.Text := Copy(MemoObservacoes.Text, 1, 1500);

  LblContadorObs.Caption :=
    IntToStr(1500 - Length(MemoObservacoes.Text)) +
    ' caracteres restantes';
end;

function TfrmMain.ValidarInteiro(const Texto, NomeCampo: String;
  out Valor: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(Texto), Valor) and (Valor >= 0);

  if not Result then
    ShowMessage('Campo "' + NomeCampo +
      '" precisa ser um numero inteiro maior ou igual a zero.');
end;

function TfrmMain.ObterModelosImpressoras: String;
begin
  Result := Trim(MemoModelosImpressoras.Text);
  Result := StringReplace(Result, #13#10, ' | ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' | ', [rfReplaceAll]);
end;

function TfrmMain.ValidarModelosImpressoras: Boolean;
begin
  Result := Trim(MemoModelosImpressoras.Text) <> '';

  if not Result then
    ShowMessage(
      'Informe os modelos e as quantidades das impressoras termicas.' +
      LineEnding + LineEnding +
      'Exemplo: 9 Elgin i9; 1 Daruma DR700; 7 Elgin i7.'
    );
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

  if not ValidarInteiro(EdtTotalComputadores.Text,
    'Total de computadores', TotalComputadores) then Exit;

  if not ValidarInteiro(EdtCaixas.Text, 'Caixas', Caixas) then Exit;

  if not ValidarInteiro(EdtRetaguardas.Text,
    'Retaguarda', Retaguardas) then Exit;

  if Caixas > TotalComputadores then
  begin
    ShowMessage(
      'A quantidade de Caixas nao pode ser maior que o total de computadores.'
    );
    Exit;
  end;

  if Retaguardas > TotalComputadores then
  begin
    ShowMessage(
      'A quantidade de Retaguarda nao pode ser maior que o total de computadores.'
    );
    Exit;
  end;

  PinPads := 0;

  if ChkTEF.Checked then
  begin
    if not ValidarInteiro(EdtPinPads.Text,
      'Qtd. PinPads', PinPads) then Exit;

    if PinPads < 1 then
    begin
      ShowMessage(
        'Como o estabelecimento utiliza TEF, a quantidade de PinPads deve ser 1 ou mais.'
      );
      Exit;
    end;
  end;

  QtdImpressoras := 0;

  if ChkImpressoras.Checked then
  begin
    if not ValidarInteiro(EdtQtdImpressoras.Text,
      'Quantidade de impressoras', QtdImpressoras) then Exit;

    if QtdImpressoras < 1 then
    begin
      ShowMessage(
        'Como o estabelecimento utiliza impressoras termicas, a quantidade deve ser 1 ou mais.'
      );
      Exit;
    end;

    if not ValidarModelosImpressoras then
      Exit;
  end;

  BtnGerar.Enabled := False;
  BtnEncerrar.Enabled := False;
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

    if ChkImpressoras.Checked then
      Pacote.Add('ModelosImpressoras=' + ObterModelosImpressoras)
    else
      Pacote.Add('ModelosImpressoras=');

    Pacote.Add('Observacoes=' +
      StringReplace(MemoObservacoes.Text, #13#10, ' | ', [rfReplaceAll]));
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

    LblStatus.Caption := 'Relatorio gerado com sucesso.';
    BtnEncerrar.Enabled := True;

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

procedure TfrmMain.BtnEncerrarClick(Sender: TObject);
begin
  Close;
end;

end.
