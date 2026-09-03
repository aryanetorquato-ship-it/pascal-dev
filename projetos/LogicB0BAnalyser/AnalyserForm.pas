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
    LblTitulo: TLabel;
    LblSubtitulo: TLabel;

    PnlResultado: TPanel;
    LblResultado: TLabel;
    LblClassificacao: TLabel;
    LblNota: TLabel;

    PnlIndicadores: TPanel;
    Indicador: array[1..10] of TPanel;
    IndicadorTitulo: array[1..10] of TLabel;
    IndicadorStatus: array[1..10] of TLabel;
    IndicadorPontos: array[1..10] of TLabel;

    PnlHardware: TPanel;
    LblHardwareTitulo: TLabel;
    LblProcessador: TLabel;
    LblRAM: TLabel;
    LblSistema: TLabel;
    LblArmazenamento: TLabel;
    LblEstabelecimento: TLabel;

    PnlObservacao: TPanel;
    LblObservacaoTitulo: TLabel;
    LblObservacao: TLabel;

    procedure BtnAbrirClick(Sender: TObject);
    procedure ProcessarConteudo(const Conteudo: String);

    function CriarLabel(AParent: TWinControl;
      const ATexto: String; AX, AY, AW, AH: Integer;
      ATamanho: Integer; ANegrito: Boolean = False): TLabel;

    function CriarPainel(AParent: TWinControl;
      AX, AY, AW, AH: Integer): TPanel;

    procedure PrepararIndicador(AIndex: Integer;
      const ATitulo: String);
    procedure DefinirIndicador(AIndex: Integer;
      const AStatus: String; APontos: Integer);
    procedure LimparResultado;
  public
    procedure MontarInterface;
  end;

var
  frmAnalyser: TfrmAnalyser;

implementation

const
  COR_FUNDO       = $00F5F7FA;
  COR_AZUL        = $00D87800;
  COR_AZUL_ESCURO = $00172B4D;
  COR_VERDE       = $002B9854;
  COR_VERDE_CLARO = $00E5F6EC;
  COR_AMARELO     = $0000B5E6;
  COR_AMARELO_CLARO = $00EAF6FC;
  COR_VERMELHO    = $003D3DCB;
  COR_VERMELHO_CLARO = $00E6E6F5;
  COR_CINZA       = $006B788C;
  COR_BORDA       = $00DDE4EC;
  COR_BRANCO      = clWhite;

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

procedure TfrmAnalyser.PrepararIndicador(AIndex: Integer;
  const ATitulo: String);
begin
  Indicador[AIndex] := CriarPainel(PnlIndicadores, 0, 0, 0, 0);
  IndicadorTitulo[AIndex] := CriarLabel(Indicador[AIndex],
    ATitulo, 12, 10, 150, 25, 10, True);
  IndicadorTitulo[AIndex].Font.Color := COR_AZUL_ESCURO;

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
  end
  else if APontos > 0 then
  begin
    IndicadorStatus[AIndex].Color := COR_AMARELO_CLARO;
    IndicadorStatus[AIndex].Font.Color := COR_AMARELO;
  end
  else
  begin
    IndicadorStatus[AIndex].Color := COR_VERMELHO_CLARO;
    IndicadorStatus[AIndex].Font.Color := COR_VERMELHO;
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
begin
  Caption := 'LogicB0B Analyser';
  Width := 1120;
  Height := 790;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  ShowInTaskBar := stAlways;
  Color := COR_FUNDO;

  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := 'Arquivos LBX (*.lbx)|*.lbx';
  OpenDialog.Title := 'Abrir arquivo .LBX';

  LblLogo := CriarLabel(Self, 'LogicB0B', 40, 22, 250, 38, 23, True);
  LblLogo.Font.Color := COR_AZUL_ESCURO;

  LblSubtitulo := CriarLabel(Self,
    'ANÁLISE DE CONFIGURAÇÃO', 42, 56, 260, 20, 9, True);
  LblSubtitulo.Font.Color := COR_AZUL;

  LblTitulo := CriarLabel(Self, 'RESULTADO DA ANÁLISE',
    320, 24, 620, 38, 22, True);
  LblTitulo.Alignment := taCenter;

  BtnAbrir := TButton.Create(Self);
  BtnAbrir.Parent := Self;
  BtnAbrir.Left := 880;
  BtnAbrir.Top := 28;
  BtnAbrir.Width := 190;
  BtnAbrir.Height := 34;
  BtnAbrir.Caption := 'Abrir arquivo .LBX';
  BtnAbrir.Font.Name := 'Segoe UI';
  BtnAbrir.Font.Size := 10;
  BtnAbrir.Font.Style := [fsBold];
  BtnAbrir.OnClick := @BtnAbrirClick;

  PnlResultado := CriarPainel(Self, 40, 92, 1030, 105);

  LblResultado := CriarLabel(PnlResultado,
    'AGUARDANDO ANÁLISE', 25, 17, 660, 38, 21, True);
  LblResultado.Alignment := taCenter;
  LblResultado.Font.Color := COR_CINZA;

  LblClassificacao := CriarLabel(PnlResultado,
    'Abra um arquivo .LBX para iniciar a análise.',
    25, 58, 660, 25, 10);
  LblClassificacao.Alignment := taCenter;
  LblClassificacao.Font.Color := COR_CINZA;

  LblNota := CriarLabel(PnlResultado,
    '— / 100', 735, 20, 245, 58, 27, True);
  LblNota.Alignment := taCenter;
  LblNota.Font.Color := COR_CINZA;

  PnlIndicadores := CriarPainel(Self, 40, 212, 1030, 265);

  CriarLabel(PnlIndicadores, 'INDICADORES DA ANÁLISE',
    20, 12, 990, 25, 13, True).Alignment := taCenter;

  for I := 1 to 10 do
  begin
    Coluna := (I - 1) mod 5;
    Linha := (I - 1) div 5;

    X := 18 + Coluna * 198;
    Y := 48 + Linha * 105;

    PrepararIndicador(I, Titulos[I]);
    Indicador[I].Left := X;
    Indicador[I].Top := Y;
    Indicador[I].Width := 188;
    Indicador[I].Height := 92;
  end;

  PnlHardware := CriarPainel(Self, 40, 492, 670, 190);

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

  PnlObservacao := CriarPainel(Self, 730, 492, 340, 190);

  LblObservacaoTitulo := CriarLabel(PnlObservacao,
    'OBSERVAÇÕES', 18, 16, 300, 25, 13, True);

  LblObservacao := CriarLabel(PnlObservacao,
    'Nenhuma análise realizada.', 18, 52, 300, 115, 10);
  LblObservacao.WordWrap := True;
  LblObservacao.Font.Color := COR_CINZA;

  LimparResultado;
end;

procedure TfrmAnalyser.LimparResultado;
var
  I: Integer;
begin
  LblResultado.Caption := 'AGUARDANDO ANÁLISE';
  LblResultado.Font.Color := COR_CINZA;

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
  end;

  LblProcessador.Caption := 'Processador: -';
  LblRAM.Caption := 'Memória RAM: -';
  LblSistema.Caption := 'Sistema Operacional: -';
  LblArmazenamento.Caption := 'Armazenamento: -';
  LblEstabelecimento.Caption := 'Estabelecimento: -';

  LblObservacao.Caption := 'Nenhuma análise realizada.';
end;

procedure TfrmAnalyser.ProcessarConteudo(const Conteudo: String);
var
  Linhas: TStringList;
  I, PosIgual: Integer;
  Chave, Valor: String;
  Processador, MemoriaRAM, SistemaOperacional, Papel,
    Estabelecimento, Armazenamento: String;
  RAMGB: Integer;
  Avaliacao: TResultadoAvaliacao;
  NivelTexto: String;
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

    for I := 0 to Linhas.Count - 1 do
    begin
      PosIgual := Pos('=', Linhas[I]);
      if PosIgual = 0 then
        Continue;

      Chave := Copy(Linhas[I], 1, PosIgual - 1);
      Valor := Copy(Linhas[I], PosIgual + 1,
        Length(Linhas[I]));

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
        Armazenamento := Valor;
    end;

    RAMGB := ExtrairRAMGB(MemoriaRAM);

    { Mantida a lógica atual: uma única avaliação do papel informado. }
    Avaliacao := AvaliarPapel(
      Papel,
      Processador,
      RAMGB,
      SistemaOperacional
    );

    NivelTexto := NivelParaTexto(Avaliacao.Nivel);

    if Avaliacao.Nivel = naNaoClassificado then
    begin
      LblResultado.Caption := 'NÃO CLASSIFICADO';
      LblResultado.Font.Color := COR_VERMELHO;
      LblClassificacao.Caption := Avaliacao.Motivo;
      LblClassificacao.Font.Color := COR_CINZA;
    end
    else
    begin
      if Avaliacao.Nivel = naMinima then
      begin
        LblResultado.Caption := 'ANÁLISE COM RESSALVAS';
        LblResultado.Font.Color := COR_AMARELO;
      end
      else
      begin
        LblResultado.Caption := 'CONFIGURAÇÃO ADEQUADA';
        LblResultado.Font.Color := COR_VERDE;
      end;

      LblClassificacao.Caption :=
        'Classificação da função informada: ' + NivelTexto;
      LblClassificacao.Font.Color := COR_VERDE;
    end;

    { O layout já possui os 10 indicadores.
      A pontuação será ligada às regras posteriormente. }

    LblProcessador.Caption :=
      'Processador: ' + Processador;

    LblRAM.Caption :=
      'Memória RAM: ' + IntToStr(RAMGB) + ' GB';

    LblSistema.Caption :=
      'Sistema Operacional: ' + SistemaOperacional;

    LblArmazenamento.Caption :=
      'Armazenamento: ' + Armazenamento;

    LblEstabelecimento.Caption :=
      'Estabelecimento: ' + Estabelecimento;

    LblNota.Caption := '— / 100';
    LblNota.Font.Color := COR_CINZA;

    LblObservacao.Caption := Avaliacao.Motivo;

    { Mostra visualmente o papel atual no indicador correspondente.
      Os demais permanecem disponíveis para a futura pontuação dos 10 itens. }
    if Papel = 'Servidor' then
      DefinirIndicador(1, 'ATENDE', 10)
    else if Papel = 'PDV_Retaguarda' then
      DefinirIndicador(2, 'ATENDE', 10)
    else if Papel = 'Caixa' then
      DefinirIndicador(3, 'ATENDE', 10);
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
        E.Message
      );
  end;
end;

end.
