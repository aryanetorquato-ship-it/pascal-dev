unit AnalyserForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, ExtCtrls,
  Graphics, LBXCrypto, HardwareRules;

type
  TfrmAnalyser = class(TForm)
  private
    BtnAbrir: TButton;
    OpenDialog: TOpenDialog;

    LblLogo: TLabel;
    LblSubtitulo: TLabel;
    LblTitulo: TLabel;
    LblAjudaAbrir: TLabel;

    PnlResultado: TPanel;
    ResultadoDot: TShape;
    LblResultado: TLabel;
    LblClassificacao: TLabel;
    LblNota: TLabel;

    PnlImportante: TPanel;
    ShpImportanteIcone: TShape;
    LblImportanteIcone: TLabel;
    LblImportanteTitulo: TLabel;
    LblImportanteTexto: TLabel;

    PnlIndicadores: TPanel;
    Indicador: array[1..10] of TPanel;
    IndicadorTitulo: array[1..10] of TLabel;
    IndicadorStatus: array[1..10] of TLabel;
    IndicadorPontos: array[1..10] of TLabel;
    IndicadorDot: array[1..10] of TShape;

    PnlHardware: TPanel;
    LblHardwareTitulo: TLabel;
    LblProcessador: TLabel;
    LblRAM: TLabel;
    LblSistema: TLabel;
    LblArmazenamento: TLabel;
    LblEstabelecimento: TLabel;
    LblPapelInformado: TLabel;

    PnlObservacao: TPanel;
    LblObservacaoTitulo: TLabel;
    LblObservacao: TLabel;

    LblRodapeEsq: TLabel;
    LblRodapeDir: TLabel;

    procedure BtnAbrirClick(Sender: TObject);
    procedure ProcessarConteudo(const Conteudo: String);

    function CriarLabel(AParent: TWinControl;
      const ATexto: String; AX, AY, AW, AH: Integer;
      ATamanho: Integer; ANegrito: Boolean = False): TLabel;
    function CriarPainel(AParent: TWinControl;
      AX, AY, AW, AH: Integer): TPanel;
    function CriarCirculo(AParent: TWinControl;
      AX, AY, ASize: Integer): TShape;
    procedure MontarCabecalho;

    procedure PrepararIndicador(AIndex: Integer; const ATitulo: String);
    procedure DefinirIndicador(AIndex: Integer;
      const AStatus: String; APontos: Integer);
    procedure ClassificarNoIndicador(AIndex: Integer;
      const AAvaliacao: TResultadoAvaliacao);
    function NivelPeso(ANivel: TNivelAdequacao): Integer;

    procedure LimparResultado;
  public
    procedure MontarInterface;
  end;

var
  frmAnalyser: TfrmAnalyser;

implementation

const
  COR_FUNDO         = $00F5F7FA;
  COR_AZUL          = $00D87800;
  COR_AZUL_ESCURO   = $00172B4D;
  COR_VERDE         = $002B9854;
  COR_VERDE_CLARO   = $00E5F6EC;
  COR_AMARELO       = $0000B5E6;
  COR_AMARELO_CLARO = $00EAF6FC;
  COR_VERMELHO      = $003D3DCB;
  COR_VERMELHO_CLARO = $00E6E6F5;
  COR_CINZA         = $006B788C;
  COR_CINZA_DOT     = $00C0C0C0;
  COR_BORDA         = $00DDE4EC;
  COR_BRANCO        = clWhite;

  { Layout: colunas de conteudo alinhadas em duas faixas de largura
    identica (banner/importante e hardware/observacoes), pra manter
    o visual consistente entre as linhas. }
  MARGEM_ESQ   = 40;
  LARG_COL_A   = 650;
  GAP_COLUNAS  = 20;
  MARGEM_DIR_X = MARGEM_ESQ + LARG_COL_A + GAP_COLUNAS; // 710
  LARG_COL_B   = 350;

  { ==========================================================
    Logo LogicB0B embutida no executavel como PNG codificado em
    Base64 (96x96px, paleta reduzida, ~1.7KB). Nao depende de
    nenhum arquivo externo: o .exe fica autossuficiente.
    ========================================================== }
  LOGO_B64: array[0..30] of String = (
    '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',
    'QmCC'
  );

type
  TBytesArr = array of Byte;

{ Decodificador Base64 proprio, sem depender de nenhuma unit externa
  alem das ja usadas no projeto (SysUtils/Classes). Evita risco de
  a unit "base64" da FCL nao estar no path de compilacao usado pelo
  workflow do GitHub Actions (que compila via chamada direta ao fpc,
  nao via lazbuild/.lpi). }
function DecodificarBase64(const Texto: String): TBytesArr;
const
  Tabela: String =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  Limpo: String;
  I, IdxSaida: Integer;
  C: Char;
  Valor: array[0..3] of Integer;
  QtdValidos: Integer;
  B0, B1, B2: Byte;
begin
  // Remove eventuais quebras de linha/espacos (defensivo).
  Limpo := '';
  for I := 1 to Length(Texto) do
  begin
    C := Texto[I];
    if (C <> #13) and (C <> #10) and (C <> ' ') then
      Limpo := Limpo + C;
  end;

  SetLength(Result, (Length(Limpo) div 4) * 3 + 3);
  IdxSaida := 0;
  QtdValidos := 0;

  for I := 1 to Length(Limpo) do
  begin
    C := Limpo[I];
    if C = '=' then Continue; // padding: nao gera byte de saida

    Valor[QtdValidos] := Pos(C, Tabela) - 1;
    if Valor[QtdValidos] < 0 then Continue; // caractere invalido, ignora
    Inc(QtdValidos);

    if QtdValidos = 4 then
    begin
      B0 := (Valor[0] shl 2) or (Valor[1] shr 4);
      B1 := ((Valor[1] and $0F) shl 4) or (Valor[2] shr 2);
      B2 := ((Valor[2] and $03) shl 6) or Valor[3];
      Result[IdxSaida] := B0; Inc(IdxSaida);
      Result[IdxSaida] := B1; Inc(IdxSaida);
      Result[IdxSaida] := B2; Inc(IdxSaida);
      QtdValidos := 0;
    end;
  end;

  // Grupo final incompleto (base64 sem padding "=" explicito).
  if QtdValidos = 2 then
  begin
    B0 := (Valor[0] shl 2) or (Valor[1] shr 4);
    Result[IdxSaida] := B0; Inc(IdxSaida);
  end
  else if QtdValidos = 3 then
  begin
    B0 := (Valor[0] shl 2) or (Valor[1] shr 4);
    B1 := ((Valor[1] and $0F) shl 4) or (Valor[2] shr 2);
    Result[IdxSaida] := B0; Inc(IdxSaida);
    Result[IdxSaida] := B1; Inc(IdxSaida);
  end;

  SetLength(Result, IdxSaida);
end;

function MontarBase64Logo: String;
var
  I: Integer;
begin
  Result := '';
  for I := Low(LOGO_B64) to High(LOGO_B64) do
    Result := Result + LOGO_B64[I];
end;

{ Decodifica o PNG embutido e devolve um TPortableNetworkGraphic
  pronto pra uso (o chamador deve dar Free nele depois de atribuir
  a um TPicture, ja que TPicture.Graphic faz copia interna).
  Retorna nil se, por qualquer motivo, a decodificacao falhar -
  o chamador deve tratar esse caso com um fallback visual. }
function CarregarLogoEmbutido: TPortableNetworkGraphic;
var
  Bytes: TBytesArr;
  MS: TMemoryStream;
begin
  Result := nil;
  Bytes := DecodificarBase64(MontarBase64Logo);
  if Length(Bytes) = 0 then Exit;

  MS := TMemoryStream.Create;
  try
    MS.WriteBuffer(Bytes[0], Length(Bytes));
    MS.Position := 0;
    Result := TPortableNetworkGraphic.Create;
    try
      Result.LoadFromStream(MS);
    except
      FreeAndNil(Result);
    end;
  finally
    MS.Free;
  end;
end;

function TfrmAnalyser.CriarLabel(AParent: TWinControl;
  const ATexto: String; AX, AY, AW, AH: Integer;
  ATamanho: Integer; ANegrito: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
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

function TfrmAnalyser.CriarPainel(AParent: TWinControl;
  AX, AY, AW, AH: Integer): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Parent := AParent;
  Result.Left := AX;
  Result.Top := AY;
  Result.Width := AW;
  Result.Height := AH;
  Result.BevelOuter := bvNone;
  Result.BorderStyle := bsSingle;
  Result.Color := COR_BRANCO;
end;

function TfrmAnalyser.CriarCirculo(AParent: TWinControl;
  AX, AY, ASize: Integer): TShape;
begin
  Result := TShape.Create(Self);
  Result.Parent := AParent;
  Result.Shape := stCircle;
  Result.Left := AX;
  Result.Top := AY;
  Result.Width := ASize;
  Result.Height := ASize;
  Result.Pen.Color := COR_BORDA;
  Result.Brush.Color := COR_CINZA_DOT;
end;

{ Monta o cabecalho (logo + titulo + botao). Tenta usar a logo real
  embutida em Base64; se a decodificacao falhar por qualquer motivo,
  cai para um quadrado azul com "B0B" como antes - a tela nunca
  quebra por causa da logo. }
procedure TfrmAnalyser.MontarCabecalho;
var
  ImgLogo: TImage;
  Logo: TPortableNetworkGraphic;
  ShpLogoFallback: TShape;
  LblLogoFallback: TLabel;
begin
  ImgLogo := TImage.Create(Self);
  ImgLogo.Parent := Self;
  ImgLogo.Left := MARGEM_ESQ;
  ImgLogo.Top := 16;
  ImgLogo.Width := 56;
  ImgLogo.Height := 56;
  ImgLogo.Stretch := True;
  ImgLogo.Proportional := True;
  ImgLogo.Center := True;
  ImgLogo.Transparent := True;

  Logo := CarregarLogoEmbutido;
  if Assigned(Logo) then
  begin
    ImgLogo.Picture.Graphic := Logo;
    FreeAndNil(Logo); // Picture.Graphic ja copiou os dados
  end
  else
  begin
    ImgLogo.Visible := False;

    ShpLogoFallback := TShape.Create(Self);
    ShpLogoFallback.Parent := Self;
    ShpLogoFallback.Shape := stRoundSquare;
    ShpLogoFallback.Left := MARGEM_ESQ;
    ShpLogoFallback.Top := 16;
    ShpLogoFallback.Width := 56;
    ShpLogoFallback.Height := 56;
    ShpLogoFallback.Pen.Color := COR_AZUL_ESCURO;
    ShpLogoFallback.Brush.Color := COR_AZUL_ESCURO;

    LblLogoFallback := CriarLabel(Self, 'B0B',
      MARGEM_ESQ, 34, 56, 20, 13, True);
    LblLogoFallback.Alignment := taCenter;
    LblLogoFallback.Font.Color := COR_BRANCO;
  end;

  LblLogo := CriarLabel(Self, 'LogicB0B',
    MARGEM_ESQ + 66, 16, 260, 32, 20, True);
  LblLogo.Font.Color := COR_AZUL_ESCURO;

  LblSubtitulo := CriarLabel(Self,
    'VERIFICADOR DE HARDWARE', MARGEM_ESQ + 68, 50, 260, 18, 8, True);
  LblSubtitulo.Font.Color := COR_AZUL;

  LblTitulo := CriarLabel(Self, 'RESULTADO DA ANÁLISE',
    390, 24, 480, 34, 20, True);
  LblTitulo.Alignment := taCenter;

  BtnAbrir := TButton.Create(Self);
  BtnAbrir.Parent := Self;
  BtnAbrir.Left := 880;
  BtnAbrir.Top := 24;
  BtnAbrir.Width := 190;
  BtnAbrir.Height := 34;
  BtnAbrir.Caption := 'Abrir arquivo .LBX';
  BtnAbrir.Font.Name := 'Segoe UI';
  BtnAbrir.Font.Size := 10;
  BtnAbrir.Font.Style := [fsBold];
  BtnAbrir.OnClick := @BtnAbrirClick;

  LblAjudaAbrir := CriarLabel(Self,
    'Selecione um arquivo de inventário do sistema',
    700, 62, 380, 16, 8);
  LblAjudaAbrir.Alignment := taRightJustify;
  LblAjudaAbrir.Font.Color := COR_CINZA;
end;

procedure TfrmAnalyser.PrepararIndicador(AIndex: Integer;
  const ATitulo: String);
begin
  Indicador[AIndex] := CriarPainel(PnlIndicadores, 0, 0, 0, 0);

  IndicadorTitulo[AIndex] := CriarLabel(Indicador[AIndex],
    ATitulo, 12, 10, 128, 25, 10, True);
  IndicadorTitulo[AIndex].Font.Color := COR_AZUL_ESCURO;

  IndicadorDot[AIndex] := CriarCirculo(Indicador[AIndex], 150, 12, 16);

  IndicadorStatus[AIndex] := CriarLabel(Indicador[AIndex],
    'NÃO AVALIADO', 12, 38, 150, 22, 9, True);
  IndicadorStatus[AIndex].Alignment := taCenter;
  IndicadorStatus[AIndex].Transparent := False;
  IndicadorStatus[AIndex].Color := $00EEF1F5;
  IndicadorStatus[AIndex].Font.Color := COR_CINZA;

  IndicadorPontos[AIndex] := CriarLabel(Indicador[AIndex],
    '— / 10', 12, 65, 150, 22, 9, True);
  IndicadorPontos[AIndex].Alignment := taCenter;
  IndicadorPontos[AIndex].Font.Color := COR_CINZA;
end;

procedure TfrmAnalyser.DefinirIndicador(AIndex: Integer;
  const AStatus: String; APontos: Integer);
begin
  IndicadorStatus[AIndex].Caption := AStatus;
  IndicadorPontos[AIndex].Caption := IntToStr(APontos) + ' / 10';

  if APontos >= 10 then
  begin
    IndicadorStatus[AIndex].Color := COR_VERDE_CLARO;
    IndicadorStatus[AIndex].Font.Color := COR_VERDE;
    IndicadorDot[AIndex].Brush.Color := COR_VERDE;
  end
  else if APontos > 0 then
  begin
    IndicadorStatus[AIndex].Color := COR_AMARELO_CLARO;
    IndicadorStatus[AIndex].Font.Color := COR_AMARELO;
    IndicadorDot[AIndex].Brush.Color := COR_AMARELO;
  end
  else
  begin
    IndicadorStatus[AIndex].Color := COR_VERMELHO_CLARO;
    IndicadorStatus[AIndex].Font.Color := COR_VERMELHO;
    IndicadorDot[AIndex].Brush.Color := COR_VERMELHO;
  end;
end;

{ Converte o resultado de AvaliarPapel (definido em HardwareRules.pas,
  nao alterado aqui) na pontuacao de 0/5/10 combinada com o dot
  colorido do indicador correspondente. }
procedure TfrmAnalyser.ClassificarNoIndicador(AIndex: Integer;
  const AAvaliacao: TResultadoAvaliacao);
begin
  case AAvaliacao.Nivel of
    naIdeal, naRecomendada:
      DefinirIndicador(AIndex, 'ATENDE', 10);
    naMinima:
      DefinirIndicador(AIndex, 'COM RESSALVAS', 5);
  else
    DefinirIndicador(AIndex, 'NÃO ATENDE', 0);
  end;
end;

function TfrmAnalyser.NivelPeso(ANivel: TNivelAdequacao): Integer;
begin
  case ANivel of
    naIdeal:       Result := 4;
    naRecomendada: Result := 3;
    naMinima:      Result := 2;
    naLegado:      Result := 1;
  else
    Result := 0; // naNaoClassificado
  end;
end;

procedure TfrmAnalyser.MontarInterface;
const
  Titulos: array[1..10] of String = (
    'SERVIDOR',
    'PDV / RETAGUARDA',
    'CAIXA / FRENTE',
    'PROCESSADOR',
    'MEMÓRIA RAM',
    'ESPAÇO LIVRE',
    'SAÚDE DO DISCO',
    'WINDOWS',
    'ARMAZENAMENTO',
    'SISTEMA OPERACIONAL'
  );
var
  I, Coluna, Linha: Integer;
  X, Y: Integer;
  LargCard, GapCard: Integer;
begin
  Caption := 'LogicB0B Analyser';
  Width := 1120;
  Height := 900;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  ShowInTaskBar := stAlways;
  Color := COR_FUNDO;

  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := 'Arquivos LBX (*.lbx)|*.lbx';
  OpenDialog.Title := 'Abrir arquivo .LBX';

  MontarCabecalho;

  { ===== Linha 2: resultado geral + aviso ===== }
  PnlResultado := CriarPainel(Self, MARGEM_ESQ, 96, LARG_COL_A, 110);

  ResultadoDot := CriarCirculo(PnlResultado, 20, 30, 42);

  LblResultado := CriarLabel(PnlResultado,
    'AGUARDANDO ANÁLISE', 75, 16, 440, 34, 18, True);
  LblResultado.Font.Color := COR_CINZA;

  LblClassificacao := CriarLabel(PnlResultado,
    'Abra um arquivo .LBX para iniciar a análise.',
    75, 54, 440, 44, 9);
  LblClassificacao.WordWrap := True;
  LblClassificacao.Font.Color := COR_CINZA;

  LblNota := CriarLabel(PnlResultado,
    '— / 100', 470, 22, 165, 54, 24, True);
  LblNota.Alignment := taCenter;
  LblNota.Font.Color := COR_CINZA;

  PnlImportante := CriarPainel(Self, MARGEM_DIR_X, 96, LARG_COL_B, 110);
  PnlImportante.Color := $00FCF6EC;

  ShpImportanteIcone := CriarCirculo(PnlImportante, 18, 18, 28);
  ShpImportanteIcone.Brush.Color := COR_AZUL;
  ShpImportanteIcone.Pen.Color := COR_AZUL;

  LblImportanteIcone := CriarLabel(PnlImportante, 'i', 18, 20, 28, 24, 12, True);
  LblImportanteIcone.Alignment := taCenter;
  LblImportanteIcone.Font.Color := COR_BRANCO;

  LblImportanteTitulo := CriarLabel(PnlImportante,
    'IMPORTANTE', 58, 16, 270, 22, 11, True);
  LblImportanteTitulo.Font.Color := COR_AZUL_ESCURO;

  LblImportanteTexto := CriarLabel(PnlImportante,
    'Esta análise é apenas referencial. A decisão final de ' +
    'instalação é comercial, não técnica.',
    58, 40, 272, 64, 8);
  LblImportanteTexto.WordWrap := True;
  LblImportanteTexto.Font.Color := COR_CINZA;

  { ===== Indicadores ===== }
  PnlIndicadores := CriarPainel(Self, MARGEM_ESQ, 222,
    LARG_COL_A + GAP_COLUNAS + LARG_COL_B, 270);
  CriarLabel(PnlIndicadores, 'INDICADORES DA ANÁLISE',
    20, 12, 990, 25, 13, True).Alignment := taCenter;

  LargCard := 184;
  GapCard := 14;

  for I := 1 to 10 do
  begin
    Coluna := (I - 1) mod 5;
    Linha := (I - 1) div 5;
    X := 18 + Coluna * (LargCard + GapCard);
    Y := 48 + Linha * (92 + GapCard);
    PrepararIndicador(I, Titulos[I]);
    Indicador[I].Left := X;
    Indicador[I].Top := Y;
    Indicador[I].Width := LargCard;
    Indicador[I].Height := 92;
  end;

  { ===== Hardware detectado + Observacoes ===== }
  PnlHardware := CriarPainel(Self, MARGEM_ESQ, 512, LARG_COL_A, 230);
  LblHardwareTitulo := CriarLabel(PnlHardware,
    'HARDWARE ENCONTRADO', 22, 16, 620, 28, 13, True);
  LblProcessador := CriarLabel(PnlHardware,
    'Processador: -', 25, 50, 620, 23, 10);
  LblRAM := CriarLabel(PnlHardware,
    'Memória RAM: -', 25, 78, 620, 23, 10);
  LblSistema := CriarLabel(PnlHardware,
    'Sistema Operacional: -', 25, 106, 620, 23, 10);
  LblArmazenamento := CriarLabel(PnlHardware,
    'Armazenamento: -', 25, 134, 620, 23, 10);
  LblEstabelecimento := CriarLabel(PnlHardware,
    'Estabelecimento: -', 25, 162, 620, 23, 10);
  LblPapelInformado := CriarLabel(PnlHardware,
    'Papel informado no arquivo: -', 25, 190, 620, 23, 10);
  LblPapelInformado.Font.Color := COR_CINZA;

  PnlObservacao := CriarPainel(Self, MARGEM_DIR_X, 512, LARG_COL_B, 230);
  LblObservacaoTitulo := CriarLabel(PnlObservacao,
    'OBSERVAÇÕES', 18, 16, 300, 25, 13, True);
  LblObservacao := CriarLabel(PnlObservacao,
    'Nenhuma análise realizada.', 18, 52, 300, 155, 10);
  LblObservacao.WordWrap := True;
  LblObservacao.Font.Color := COR_CINZA;

  { ===== Rodape ===== }
  LblRodapeEsq := CriarLabel(Self, 'LogicB0B v1.0',
    MARGEM_ESQ, 764, 300, 18, 8);
  LblRodapeEsq.Font.Color := COR_CINZA;

  LblRodapeDir := CriarLabel(Self,
    'Ferramenta interna de verificação de hardware · Uso restrito',
    610, 764, 460, 18, 8);
  LblRodapeDir.Alignment := taRightJustify;
  LblRodapeDir.Font.Color := COR_CINZA;

  LimparResultado;
end;

procedure TfrmAnalyser.LimparResultado;
var
  I: Integer;
begin
  LblResultado.Caption := 'AGUARDANDO ANÁLISE';
  LblResultado.Font.Color := COR_CINZA;
  ResultadoDot.Brush.Color := COR_CINZA_DOT;

  LblClassificacao.Caption :=
    'Abra um arquivo .LBX para iniciar a análise.';
  LblClassificacao.Font.Color := COR_CINZA;

  LblNota.Caption := '— / 100';
  LblNota.Font.Color := COR_CINZA;

  for I := 1 to 10 do
  begin
    IndicadorStatus[I].Caption := 'NÃO AVALIADO';
    IndicadorStatus[I].Color := $00EEF1F5;
    IndicadorStatus[I].Font.Color := COR_CINZA;
    IndicadorPontos[I].Caption := '— / 10';
    IndicadorPontos[I].Font.Color := COR_CINZA;
    IndicadorDot[I].Brush.Color := COR_CINZA_DOT;
  end;

  LblProcessador.Caption := 'Processador: -';
  LblRAM.Caption := 'Memória RAM: -';
  LblSistema.Caption := 'Sistema Operacional: -';
  LblArmazenamento.Caption := 'Armazenamento: -';
  LblEstabelecimento.Caption := 'Estabelecimento: -';
  LblPapelInformado.Caption := 'Papel informado no arquivo: -';
  LblObservacao.Caption := 'Nenhuma análise realizada.';
end;

procedure TfrmAnalyser.ProcessarConteudo(const Conteudo: String);
var
  Linhas: TStringList;
  I, PosIgual: Integer;
  Chave, Valor: String;
  Processador, MemoriaRAM, SistemaOperacional, Papel,
    Estabelecimento, Armazenamento, TipoArmazenamento: String;
  RAMGB: Integer;
  TemSSD: Boolean;
  AvalServidor, AvalPDV, AvalCaixa, AvalProcessador: TResultadoAvaliacao;
  MelhorNivel: TNivelAdequacao;
begin
  Linhas := TStringList.Create;
  try
    Linhas.Text := Conteudo;
    Processador := '';
    MemoriaRAM := '';
    SistemaOperacional := '';
    Papel := '';
    Estabelecimento := '';
    Armazenamento := '';
    TipoArmazenamento := '';

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
        Estabelecimento := Valor
      else if Chave = 'Armazenamento' then
        Armazenamento := Valor
      else if Chave = 'TipoArmazenamento' then
        TipoArmazenamento := Valor;
    end;

    RAMGB := ExtrairRAMGB(MemoriaRAM);

    { Indicador #4: capacidade da CPU.
      O TipoArmazenamento e usado apenas para a regra das CPUs
      de entrada. Compatibilidade com Windows 11 permanece
      separada e nao participa desta avaliacao. }
    TemSSD :=
      (Pos('SSD', UpperCase(TipoArmazenamento)) > 0) or
      (Pos('NVME', UpperCase(TipoArmazenamento)) > 0) or
      (Pos('M.2', UpperCase(TipoArmazenamento)) > 0);

    AvalProcessador :=
      AvaliarProcessadorIsolado(Processador, RAMGB, TemSSD);

    { Os tres papeis sao avaliados sempre, contra o mesmo hardware,
      independente de qual papel foi informado no .LBX. }
    AvalServidor := AvaliarPapel('Servidor', Processador, RAMGB, SistemaOperacional);
    AvalPDV      := AvaliarPapel('PDV_Retaguarda', Processador, RAMGB, SistemaOperacional);
    AvalCaixa    := AvaliarPapel('Caixa', Processador, RAMGB, SistemaOperacional);

    ClassificarNoIndicador(1, AvalServidor);
    ClassificarNoIndicador(2, AvalPDV);
    ClassificarNoIndicador(3, AvalCaixa);
    ClassificarNoIndicador(4, AvalProcessador);
    { Indicadores 5 a 10 seguem "NAO AVALIADO" ate as regras deles
      serem definidas. }

    MelhorNivel := AvalServidor.Nivel;
    if NivelPeso(AvalPDV.Nivel) > NivelPeso(MelhorNivel) then
      MelhorNivel := AvalPDV.Nivel;
    if NivelPeso(AvalCaixa.Nivel) > NivelPeso(MelhorNivel) then
      MelhorNivel := AvalCaixa.Nivel;

    case MelhorNivel of
      naIdeal, naRecomendada:
        begin
          LblResultado.Caption := 'CONFIGURAÇÃO ADEQUADA';
          LblResultado.Font.Color := COR_VERDE;
          ResultadoDot.Brush.Color := COR_VERDE;
        end;
      naMinima:
        begin
          LblResultado.Caption := 'ANÁLISE COM RESSALVAS';
          LblResultado.Font.Color := COR_AMARELO;
          ResultadoDot.Brush.Color := COR_AMARELO;
        end;
    else
      begin
        LblResultado.Caption := 'NÃO CLASSIFICADO';
        LblResultado.Font.Color := COR_VERMELHO;
        ResultadoDot.Brush.Color := COR_VERMELHO;
      end;
    end;

    LblClassificacao.Caption :=
      'Melhor classificação atingida: ' + NivelParaTexto(MelhorNivel);
    LblClassificacao.Font.Color := COR_CINZA;

    { A nota /100 depende dos indicadores 4-10 ainda nao definidos. }
    LblNota.Caption := '— / 100';
    LblNota.Font.Color := COR_CINZA;

    LblProcessador.Caption := 'Processador: ' + Processador;
    LblRAM.Caption := 'Memória RAM: ' + IntToStr(RAMGB) + ' GB';
    LblSistema.Caption := 'Sistema Operacional: ' + SistemaOperacional;
    LblArmazenamento.Caption := 'Armazenamento: ' + Armazenamento;
    LblEstabelecimento.Caption := 'Estabelecimento: ' + Estabelecimento;
    LblPapelInformado.Caption := 'Papel informado no arquivo: ' + Papel;

    LblObservacao.Caption :=
      'Servidor: ' + NivelParaTexto(AvalServidor.Nivel) + sLineBreak +
      'PDV / Retaguarda: ' + NivelParaTexto(AvalPDV.Nivel) + sLineBreak +
      'Caixa / Frente: ' + NivelParaTexto(AvalCaixa.Nivel);
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
      ShowMessage('Erro ao abrir/descriptografar arquivo: ' + E.Message);
  end;
end;

end.
