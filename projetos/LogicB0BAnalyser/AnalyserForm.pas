unit AnalyserForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, ExtCtrls,
  Graphics, LBXCrypto, HardwareRules;

type
  TCardPanel = class(TPanel)
  protected
    procedure Paint; override;
  end;

  TfrmAnalyser = class(TForm)
  private
    BtnAbrir: TButton;
    OpenDialog: TOpenDialog;

    LblLogo: TLabel;
    LblSubLogo: TLabel;
    LblTitulo: TLabel;

    CardResultado: TCardPanel;
    LblResultado: TLabel;
    LblClassificacao: TLabel;

    CardFuncoes: TCardPanel;
    CardServidor: TCardPanel;
    CardPDV: TCardPanel;
    CardCaixa: TCardPanel;

    LblServidor: TLabel;
    LblServidorNivel: TLabel;
    LblServidorStatus: TLabel;

    LblPDV: TLabel;
    LblPDVNivel: TLabel;
    LblPDVStatus: TLabel;

    LblCaixa: TLabel;
    LblCaixaNivel: TLabel;
    LblCaixaStatus: TLabel;

    CardHardware: TCardPanel;
    LblHardwareTitulo: TLabel;
    LblProcessador: TLabel;
    LblRAM: TLabel;
    LblSistema: TLabel;
    LblEstabelecimento: TLabel;

    CardNota: TCardPanel;
    LblNotaTitulo: TLabel;
    LblNota: TLabel;
    LblNotaTexto: TLabel;

    CardObservacao: TCardPanel;
    LblObservacaoTitulo: TLabel;
    LblObservacao: TLabel;

    procedure BtnAbrirClick(Sender: TObject);
    procedure ProcessarConteudo(const Conteudo: String);

    function CriarLabel(AParent: TWinControl;
      const ATexto: String; AX, AY, AW, AH: Integer;
      ATamanho: Integer; ANegrito: Boolean = False): TLabel;

    function CriarCard(AParent: TWinControl;
      AX, AY, AW, AH: Integer): TCardPanel;

    procedure ConfigurarStatus(ALabel: TLabel; Atende: Boolean);
    procedure ConfigurarCardFuncao(ACard: TCardPanel;
      const Nome, Nivel: String; Status: TLabel;
      CorTitulo: TColor);

    procedure LimparResultado;

  public
    procedure MontarInterface;
  end;

var
  frmAnalyser: TfrmAnalyser;

implementation

const
  COR_FUNDO        = $00FAFBFD;
  COR_AZUL         = $00D87800;
  COR_AZUL_ESCURO  = $00172B4D;
  COR_VERDE        = $002B9854;
  COR_VERDE_CLARO  = $00E5F6EC;
  COR_CINZA        = $006B788C;
  COR_BORDA        = $00DDE4EC;
  COR_BRANCO       = clWhite;
  COR_ROXO         = $00A05A7A;
  COR_LARANJA      = $000080E6;

procedure TCardPanel.Paint;
begin
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := COR_BORDA;
  Canvas.RoundRect(0, 0, Width - 1, Height - 1, 14, 14);
end;

function TfrmAnalyser.CriarLabel(AParent: TWinControl;
  const ATexto: String; AX, AY, AW, AH: Integer;
  ATamanho: Integer; ANegrito: Boolean): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Left := AX;
  Result.Top := AY;
  Result.Width := AW;
  Result.Height := AH;
  Result.Caption := ATexto;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := ATamanho;

  if ANegrito then
    Result.Font.Style := [fsBold]
  else
    Result.Font.Style := [];

  Result.Font.Color := COR_AZUL_ESCURO;
  Result.Transparent := True;
end;

function TfrmAnalyser.CriarCard(AParent: TWinControl;
  AX, AY, AW, AH: Integer): TCardPanel;
begin
  Result := TCardPanel.Create(AParent);
  Result.Parent := AParent;
  Result.Left := AX;
  Result.Top := AY;
  Result.Width := AW;
  Result.Height := AH;
  Result.Color := COR_BRANCO;
  Result.BevelOuter := bvNone;
end;

procedure TfrmAnalyser.ConfigurarStatus(ALabel: TLabel; Atende: Boolean);
begin
  if Atende then
  begin
    ALabel.Caption := 'ATENDE';
    ALabel.Font.Color := COR_VERDE;
    ALabel.Color := COR_VERDE_CLARO;
  end
  else
  begin
    ALabel.Caption := 'NÃO ATENDE';
    ALabel.Font.Color := clMaroon;
    ALabel.Color := $00F3E2E2;
  end;
end;

procedure TfrmAnalyser.ConfigurarCardFuncao(ACard: TCardPanel;
  const Nome, Nivel: String; Status: TLabel; CorTitulo: TColor);
var
  L: TLabel;
begin
  L := CriarLabel(ACard, Nome, 65, 22, 300, 28, 13, True);
  L.Font.Color := CorTitulo;

  L := CriarLabel(ACard, Nivel, 65, 55, 300, 28, 11, False);
  L.Font.Color := COR_CINZA;

  Status.Parent := ACard;
  Status.Left := 65;
  Status.Top := 88;
  Status.Width := 105;
  Status.Height := 25;
  Status.Font.Name := 'Segoe UI';
  Status.Font.Size := 9;
  Status.Font.Style := [fsBold];
  Status.Alignment := taCenter;
  Status.Transparent := False;
end;

procedure TfrmAnalyser.MontarInterface;
var
  L: TLabel;
begin
  Caption := 'Logicbox - Verificador de Requisitos de Hardware';

  Width := 1100;
  Height := 780;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  ShowInTaskBar := stAlways;
  Color := COR_FUNDO;

  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := 'Arquivos LBX (*.lbx)|*.lbx';
  OpenDialog.Title := 'Abrir arquivo .LBX';

  { CABEÇALHO }

  LblLogo := CriarLabel(Self, 'LOGICBOX', 45, 24, 280, 36, 23, True);
  LblLogo.Font.Color := COR_AZUL_ESCURO;

  LblSubLogo := CriarLabel(Self, 'S I S T E M A S', 47, 58, 230, 20, 9, True);
  LblSubLogo.Font.Color := COR_AZUL;

  LblTitulo := CriarLabel(Self, 'RESULTADO DA ANÁLISE',
    300, 30, 750, 42, 23, True);
  LblTitulo.Alignment := taCenter;

  BtnAbrir := TButton.Create(Self);
  BtnAbrir.Parent := Self;
  BtnAbrir.Left := 45;
  BtnAbrir.Top := 82;
  BtnAbrir.Width := 180;
  BtnAbrir.Height := 34;
  BtnAbrir.Caption := 'Abrir arquivo .LBX';
  BtnAbrir.Font.Name := 'Segoe UI';
  BtnAbrir.Font.Size := 10;
  BtnAbrir.Font.Style := [fsBold];
  BtnAbrir.OnClick := @BtnAbrirClick;

  { RESULTADO }

  CardResultado := CriarCard(Self, 45, 128, 1010, 110);

  LblResultado := CriarLabel(CardResultado,
    'AGUARDANDO ANÁLISE', 35, 22, 940, 40, 22, True);
  LblResultado.Alignment := taCenter;
  LblResultado.Font.Color := COR_CINZA;

  LblClassificacao := CriarLabel(CardResultado,
    'Abra um arquivo .LBX para iniciar a análise.',
    35, 67, 940, 25, 11, False);
  LblClassificacao.Alignment := taCenter;
  LblClassificacao.Font.Color := COR_CINZA;

  { CLASSIFICAÇÃO POR FUNÇÃO }

  CardFuncoes := CriarCard(Self, 45, 253, 1010, 170);

  L := CriarLabel(CardFuncoes, 'CLASSIFICAÇÃO POR FUNÇÃO',
    25, 14, 960, 28, 13, True);
  L.Alignment := taCenter;

  CardServidor := CriarCard(CardFuncoes, 25, 52, 300, 105);
  CardPDV := CriarCard(CardFuncoes, 355, 52, 300, 105);
  CardCaixa := CriarCard(CardFuncoes, 685, 52, 300, 105);

  LblServidorStatus := TLabel.Create(Self);
  ConfigurarCardFuncao(CardServidor, 'SERVIDOR',
    'Aguardando análise', LblServidorStatus, COR_AZUL);

  LblPDVStatus := TLabel.Create(Self);
  ConfigurarCardFuncao(CardPDV, 'PDV / RETAGUARDA',
    'Aguardando análise', LblPDVStatus, COR_ROXO);

  LblCaixaStatus := TLabel.Create(Self);
  ConfigurarCardFuncao(CardCaixa, 'CAIXA / FRENTE',
    'Aguardando análise', LblCaixaStatus, COR_LARANJA);

  { HARDWARE }

  CardHardware := CriarCard(Self, 45, 438, 635, 220);

  LblHardwareTitulo := CriarLabel(CardHardware,
    'HARDWARE ENCONTRADO', 25, 18, 580, 30, 14, True);

  LblProcessador := CriarLabel(CardHardware,
    'Processador: -', 30, 58, 570, 28, 11);

  LblRAM := CriarLabel(CardHardware,
    'Memória RAM: -', 30, 91, 570, 28, 11);

  LblSistema := CriarLabel(CardHardware,
    'Sistema Operacional: -', 30, 124, 570, 28, 11);

  LblEstabelecimento := CriarLabel(CardHardware,
    'Estabelecimento: -', 30, 157, 570, 28, 11);

  { NOTA }

  CardNota := CriarCard(Self, 700, 438, 355, 220);

  LblNotaTitulo := CriarLabel(CardNota,
    'NOTA DO SISTEMA', 25, 18, 305, 30, 14, True);
  LblNotaTitulo.Alignment := taCenter;

  LblNota := CriarLabel(CardNota,
    '—', 25, 62, 305, 55, 36, True);
  LblNota.Alignment := taCenter;
  LblNota.Font.Color := COR_VERDE;

  LblNotaTexto := CriarLabel(CardNota,
    'Aguardando análise', 25, 125, 305, 55, 11, False);
  LblNotaTexto.Alignment := taCenter;
  LblNotaTexto.WordWrap := True;
  LblNotaTexto.Font.Color := COR_CINZA;

  { OBSERVAÇÕES }

  CardObservacao := CriarCard(Self, 45, 675, 1010, 70);

  LblObservacaoTitulo := CriarLabel(CardObservacao,
    'OBSERVAÇÕES', 20, 12, 150, 25, 10, True);
  LblObservacaoTitulo.Font.Color := COR_AZUL;

  LblObservacao := CriarLabel(CardObservacao,
    'Nenhuma análise realizada.', 155, 12, 820, 42, 10, False);
  LblObservacao.WordWrap := True;
  LblObservacao.Font.Color := COR_CINZA;
end;

procedure TfrmAnalyser.LimparResultado;
begin
  LblResultado.Caption := 'ANALISANDO...';
  LblResultado.Font.Color := COR_AZUL;

  LblClassificacao.Caption := 'Verificando os requisitos do computador...';

  LblServidorNivel.Caption := 'Analisando...';
  LblPDVNivel.Caption := 'Analisando...';
  LblCaixaNivel.Caption := 'Analisando...';

  LblProcessador.Caption := 'Processador: -';
  LblRAM.Caption := 'Memória RAM: -';
  LblSistema.Caption := 'Sistema Operacional: -';
  LblEstabelecimento.Caption := 'Estabelecimento: -';

  LblNota.Caption := '—';
  LblNotaTexto.Caption := 'Analisando os requisitos...';

  LblObservacao.Caption := 'Analisando os requisitos do sistema...';
end;

procedure TfrmAnalyser.ProcessarConteudo(const Conteudo: String);
var
  Linhas: TStringList;
  I, PosIgual: Integer;
  Chave, Valor: String;

  Processador: String;
  MemoriaRAM: String;
  SistemaOperacional: String;
  Papel: String;
  Estabelecimento: String;

  RAMGB: Integer;
  AvServidor, AvPDV, AvCaixa: TResultadoAvaliacao;
  Melhor: TNivelAdequacao;
  MelhorTexto: String;
begin
  Linhas := TStringList.Create;

  try
    Linhas.Text := Conteudo;

    Processador := '';
    MemoriaRAM := '';
    SistemaOperacional := '';
    Papel := '';
    Estabelecimento := '';

    for I := 0 to Linhas.Count - 1 do
    begin
      PosIgual := Pos('=', Linhas[I]);
      if PosIgual = 0 then
        Continue;

      Chave := Copy(Linhas[I], 1, PosIgual - 1);
      Valor := Copy(Linhas[I], PosIgual + 1, Length(Linhas[I]));

      if Chave = 'Processador' then
        Processador := Valor
      else if Chave = 'MemoriaRAM' then
        MemoriaRAM := Valor
      else if Chave = 'SistemaOperacional' then
        SistemaOperacional := Valor
      else if Chave = 'PapelComputador' then
        Papel := Valor
      else if Chave = 'Estabelecimento' then
        Estabelecimento := Valor;
    end;

    { A lógica existente continua sendo usada sem alteração. }

    RAMGB := ExtrairRAMGB(MemoriaRAM);

    AvServidor := AvaliarPapel(
      'Servidor', Processador, RAMGB, SistemaOperacional);

    AvPDV := AvaliarPapel(
      'PDV_Retaguarda', Processador, RAMGB, SistemaOperacional);

    AvCaixa := AvaliarPapel(
      'Caixa', Processador, RAMGB, SistemaOperacional);

    { Resultado geral: usa a pior classificação entre as funções. }

    Melhor := AvServidor.Nivel;

    if AvPDV.Nivel < Melhor then
      Melhor := AvPDV.Nivel;

    if AvCaixa.Nivel < Melhor then
      Melhor := AvCaixa.Nivel;

    { Para a apresentação, se pelo menos uma função estiver classificada,
      mostramos a classificação mais alta atingida. }

    Melhor := AvServidor.Nivel;

    if AvPDV.Nivel > Melhor then
      Melhor := AvPDV.Nivel;

    if AvCaixa.Nivel > Melhor then
      Melhor := AvCaixa.Nivel;

    MelhorTexto := NivelParaTexto(Melhor);

    if Melhor = naNaoClassificado then
    begin
      LblResultado.Caption := 'NÃO CLASSIFICADO';
      LblResultado.Font.Color := clMaroon;
      LblClassificacao.Caption :=
        'Não foi possível enquadrar este computador nas configurações suportadas.';
    end
    else if Melhor = naMinima then
    begin
      LblResultado.Caption := 'APROVADO COM RESSALVAS';
      LblResultado.Font.Color := COR_VERDE;
      LblClassificacao.Caption :=
        'Melhor classificação atingida: ' + MelhorTexto;
      LblClassificacao.Font.Color := COR_VERDE;
    end
    else
    begin
      LblResultado.Caption := 'APROVADO';
      LblResultado.Font.Color := COR_VERDE;
      LblClassificacao.Caption :=
        'Melhor classificação atingida: ' + MelhorTexto;
      LblClassificacao.Font.Color := COR_VERDE;
    end;

    { Funções }

    LblServidorNivel.Caption := NivelParaTexto(AvServidor.Nivel);
    LblPDVNivel.Caption := NivelParaTexto(AvPDV.Nivel);
    LblCaixaNivel.Caption := NivelParaTexto(AvCaixa.Nivel);

    ConfigurarStatus(
      LblServidorStatus,
      AvServidor.Nivel <> naNaoClassificado);

    ConfigurarStatus(
      LblPDVStatus,
      AvPDV.Nivel <> naNaoClassificado);

    ConfigurarStatus(
      LblCaixaStatus,
      AvCaixa.Nivel <> naNaoClassificado);

    { Hardware }

    LblProcessador.Caption :=
      'Processador: ' + Processador;

    LblRAM.Caption :=
      'Memória RAM: ' + IntToStr(RAMGB) + ' GB';

    LblSistema.Caption :=
      'Sistema Operacional: ' + SistemaOperacional;

    LblEstabelecimento.Caption :=
      'Estabelecimento: ' + Estabelecimento;

    { A nota permanece neutra até existir uma regra real de pontuação. }

    LblNota.Caption := '—';
    LblNotaTexto.Caption :=
      'Classificação baseada nas regras de hardware do sistema.';

    { Observação }

    if Papel <> '' then
      LblObservacao.Caption :=
        'Função informada no arquivo: ' + Papel + '. ' +
        'Resultado: ' + NivelParaTexto(
          AvaliarPapel(Papel, Processador, RAMGB,
            SistemaOperacional).Nivel)
    else
      LblObservacao.Caption :=
        'O arquivo não informou a função deste computador. ' +
        'A classificação foi apresentada por função.';

  finally
    Linhas.Free;
  end;
end;

procedure TfrmAnalyser.BtnAbrirClick(Sender: TObject);
var
  Conteudo: String;
begin
  if not OpenDialog.Execute then
    Exit;

  try
    LimparResultado;

    Conteudo := AbrirArquivoLBX(OpenDialog.FileName);

    ProcessarConteudo(Conteudo);

  except
    on E: Exception do
      ShowMessage(
        'Erro ao abrir/descriptografar arquivo: ' +
        E.Message);
  end;
end;

end.
