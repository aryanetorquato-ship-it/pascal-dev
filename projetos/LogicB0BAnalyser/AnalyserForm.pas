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
    LblSubLogo: TLabel;
    LblTitulo: TLabel;

    PnlResultado: TPanel;
    LblResultado: TLabel;
    LblClassificacao: TLabel;

    PnlFuncoes: TPanel;
    PnlServidor: TPanel;
    PnlPDV: TPanel;
    PnlCaixa: TPanel;

    LblServidor: TLabel;
    LblServidorNivel: TLabel;
    LblServidorStatus: TLabel;

    LblPDV: TLabel;
    LblPDVNivel: TLabel;
    LblPDVStatus: TLabel;

    LblCaixa: TLabel;
    LblCaixaNivel: TLabel;
    LblCaixaStatus: TLabel;

    PnlHardware: TPanel;
    LblHardwareTitulo: TLabel;
    LblProcessador: TLabel;
    LblRAM: TLabel;
    LblSistema: TLabel;
    LblEstabelecimento: TLabel;

    PnlNota: TPanel;
    LblNotaTitulo: TLabel;
    LblNota: TLabel;
    LblNotaTexto: TLabel;

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

    procedure DefinirStatus(ALabel: TLabel; Atende: Boolean);
    procedure LimparResultado;

  public
    procedure MontarInterface;
  end;

var
  frmAnalyser: TfrmAnalyser;

implementation

const
  COR_FUNDO       = $00FAFBFD;
  COR_AZUL        = $00D87800;
  COR_AZUL_ESCURO = $00172B4D;
  COR_VERDE       = $002B9854;
  COR_VERDE_CLARO = $00E5F6EC;
  COR_CINZA       = $006B788C;
  COR_BORDA       = $00DDE4EC;
  COR_BRANCO      = clWhite;
  COR_ROXO        = $00A05A7A;
  COR_LARANJA     = $000080E6;

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

procedure TfrmAnalyser.DefinirStatus(ALabel: TLabel; Atende: Boolean);
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

procedure TfrmAnalyser.MontarInterface;
begin
  Caption := 'Logicbox - Verificador de Requisitos de Hardware';
  Width := 1100;
  Height := 700;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu, biMinimize];
  ShowInTaskBar := stAlways;
  Color := COR_FUNDO;

  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := 'Arquivos LBX (*.lbx)|*.lbx';
  OpenDialog.Title := 'Abrir arquivo .LBX';

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

  PnlResultado := CriarPainel(Self, 45, 128, 1010, 110);

  LblResultado := CriarLabel(PnlResultado,
    'AGUARDANDO ANÁLISE', 35, 22, 940, 40, 22, True);
  LblResultado.Alignment := taCenter;
  LblResultado.Font.Color := COR_CINZA;

  LblClassificacao := CriarLabel(PnlResultado,
    'Abra um arquivo .LBX para iniciar a análise.',
    35, 67, 940, 25, 11);
  LblClassificacao.Alignment := taCenter;
  LblClassificacao.Font.Color := COR_CINZA;

  PnlFuncoes := CriarPainel(Self, 45, 253, 1010, 170);

  CriarLabel(PnlFuncoes, 'CLASSIFICAÇÃO POR FUNÇÃO',
    25, 14, 960, 28, 13, True).Alignment := taCenter;

  PnlServidor := CriarPainel(PnlFuncoes, 25, 52, 300, 105);
  PnlPDV := CriarPainel(PnlFuncoes, 355, 52, 300, 105);
  PnlCaixa := CriarPainel(PnlFuncoes, 685, 52, 300, 105);

  LblServidor := CriarLabel(PnlServidor, 'SERVIDOR',
    25, 20, 250, 25, 13, True);
  LblServidor.Font.Color := COR_AZUL;

  LblServidorNivel := CriarLabel(PnlServidor, 'Não avaliado',
    25, 50, 250, 22, 10);
  LblServidorNivel.Font.Color := COR_CINZA;

  LblServidorStatus := CriarLabel(PnlServidor, 'NÃO AVALIADO',
    25, 77, 120, 22, 9, True);
  LblServidorStatus.Alignment := taCenter;
  LblServidorStatus.Transparent := False;

  LblPDV := CriarLabel(PnlPDV, 'PDV / RETAGUARDA',
    25, 20, 250, 25, 13, True);
  LblPDV.Font.Color := COR_ROXO;

  LblPDVNivel := CriarLabel(PnlPDV, 'Não avaliado',
    25, 50, 250, 22, 10);
  LblPDVNivel.Font.Color := COR_CINZA;

  LblPDVStatus := CriarLabel(PnlPDV, 'NÃO AVALIADO',
    25, 77, 120, 22, 9, True);
  LblPDVStatus.Alignment := taCenter;
  LblPDVStatus.Transparent := False;

  LblCaixa := CriarLabel(PnlCaixa, 'CAIXA / FRENTE',
    25, 20, 250, 25, 13, True);
  LblCaixa.Font.Color := COR_LARANJA;

  LblCaixaNivel := CriarLabel(PnlCaixa, 'Não avaliado',
    25, 50, 250, 22, 10);
  LblCaixaNivel.Font.Color := COR_CINZA;

  LblCaixaStatus := CriarLabel(PnlCaixa, 'NÃO AVALIADO',
    25, 77, 120, 22, 9, True);
  LblCaixaStatus.Alignment := taCenter;
  LblCaixaStatus.Transparent := False;

  PnlHardware := CriarPainel(Self, 45, 438, 635, 190);

  LblHardwareTitulo := CriarLabel(PnlHardware,
    'HARDWARE ENCONTRADO', 25, 18, 580, 30, 14, True);

  LblProcessador := CriarLabel(PnlHardware,
    'Processador: -', 30, 55, 570, 25, 11);

  LblRAM := CriarLabel(PnlHardware,
    'Memória RAM: -', 30, 85, 570, 25, 11);

  LblSistema := CriarLabel(PnlHardware,
    'Sistema Operacional: -', 30, 115, 570, 25, 11);

  LblEstabelecimento := CriarLabel(PnlHardware,
    'Estabelecimento: -', 30, 145, 570, 25, 11);

  PnlNota := CriarPainel(Self, 700, 438, 355, 190);

  LblNotaTitulo := CriarLabel(PnlNota,
    'NOTA DO SISTEMA', 25, 18, 305, 30, 14, True);
  LblNotaTitulo.Alignment := taCenter;

  LblNota := CriarLabel(PnlNota,
    '—', 25, 58, 305, 50, 32, True);
  LblNota.Alignment := taCenter;
  LblNota.Font.Color := COR_VERDE;

  LblNotaTexto := CriarLabel(PnlNota,
    'Aguardando análise', 25, 120, 305, 45, 10);
  LblNotaTexto.Alignment := taCenter;
  LblNotaTexto.WordWrap := True;
  LblNotaTexto.Font.Color := COR_CINZA;

  PnlObservacao := CriarPainel(Self, 45, 638, 1010, 40);

  LblObservacaoTitulo := CriarLabel(PnlObservacao,
    'OBSERVAÇÕES', 15, 8, 120, 22, 9, True);
  LblObservacaoTitulo.Font.Color := COR_AZUL;

  LblObservacao := CriarLabel(PnlObservacao,
    'Nenhuma análise realizada.', 145, 8, 840, 22, 9);
  LblObservacao.Font.Color := COR_CINZA;
end;

procedure TfrmAnalyser.LimparResultado;
begin
  LblResultado.Caption := 'ANALISANDO...';
  LblResultado.Font.Color := COR_AZUL;
  LblClassificacao.Caption := 'Verificando os requisitos do computador...';

  LblServidorNivel.Caption := 'Não avaliado';
  LblServidorStatus.Caption := 'NÃO AVALIADO';
  LblPDVNivel.Caption := 'Não avaliado';
  LblPDVStatus.Caption := 'NÃO AVALIADO';
  LblCaixaNivel.Caption := 'Não avaliado';
  LblCaixaStatus.Caption := 'NÃO AVALIADO';

  LblProcessador.Caption := 'Processador: -';
  LblRAM.Caption := 'Memória RAM: -';
  LblSistema.Caption := 'Sistema Operacional: -';
  LblEstabelecimento.Caption := 'Estabelecimento: -';

  LblNota.Caption := '—';
  LblNotaTexto.Caption := 'Aguardando análise';
  LblObservacao.Caption := 'Analisando os requisitos do sistema...';
end;

procedure TfrmAnalyser.ProcessarConteudo(const Conteudo: String);
var
  Linhas: TStringList;
  I, PosIgual: Integer;
  Chave, Valor: String;
  Processador, MemoriaRAM, SistemaOperacional, Papel,
    Estabelecimento: String;
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
        Estabelecimento := Valor;
    end;

    RAMGB := ExtrairRAMGB(MemoriaRAM);

    { ÚNICA chamada à lógica existente. }
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
      LblResultado.Font.Color := clMaroon;
      LblClassificacao.Caption := Avaliacao.Motivo;
      LblClassificacao.Font.Color := COR_CINZA;
    end
    else
    begin
      if Avaliacao.Nivel = naMinima then
      begin
        LblResultado.Caption := 'APROVADO COM RESSALVAS';
        LblResultado.Font.Color := COR_VERDE;
      end
      else
      begin
        LblResultado.Caption := 'APROVADO';
        LblResultado.Font.Color := COR_VERDE;
      end;

      LblClassificacao.Caption :=
        'Melhor classificação atingida: ' + NivelTexto;
      LblClassificacao.Font.Color := COR_VERDE;
    end;

    { Mostra o resultado somente na função informada pelo LBX. }

    if Papel = 'Servidor' then
    begin
      LblServidorNivel.Caption := NivelTexto;
      DefinirStatus(
        LblServidorStatus,
        Avaliacao.Nivel <> naNaoClassificado
      );
    end
    else if Papel = 'PDV_Retaguarda' then
    begin
      LblPDVNivel.Caption := NivelTexto;
      DefinirStatus(
        LblPDVStatus,
        Avaliacao.Nivel <> naNaoClassificado
      );
    end
    else if Papel = 'Caixa' then
    begin
      LblCaixaNivel.Caption := NivelTexto;
      DefinirStatus(
        LblCaixaStatus,
        Avaliacao.Nivel <> naNaoClassificado
      );
    end;

    LblProcessador.Caption :=
      'Processador: ' + Processador;

    LblRAM.Caption :=
      'Memória RAM: ' + IntToStr(RAMGB) + ' GB';

    LblSistema.Caption :=
      'Sistema Operacional: ' + SistemaOperacional;

    LblEstabelecimento.Caption :=
      'Estabelecimento: ' + Estabelecimento;

    LblNota.Caption := '—';
    LblNotaTexto.Caption :=
      'A nota será adicionada quando houver uma regra de pontuação definida.';

    LblObservacao.Caption := Avaliacao.Motivo;

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
