unit LBXCrypto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  // Chave compartilhada entre Questionario e Analyser.
  // Trocar aqui reflete nos dois programas (recompilar ambos).
  LBX_CHAVE = 'LogicB0B-2026-ChaveInterna-TrocarDepois';
  LBX_MAGIC = 'LBX1'; // assinatura no inicio do arquivo, usada para validar

// Criptografa/descriptografa um bloco de bytes com RC4 (simetrico:
// a mesma funcao serve para os dois sentidos).
procedure RC4Aplicar(const Chave: String; var Dados: array of Byte);

// Monta o pacote (texto puro) e grava criptografado em disco,
// com um cabecalho simples para validacao no Analyser.
procedure SalvarArquivoLBX(const CaminhoArquivo: String; const Conteudo: String);

// Le e descriptografa um arquivo .LBX. Levanta excecao se o
// arquivo nao tiver a assinatura esperada (arquivo invalido/corrompido).
function AbrirArquivoLBX(const CaminhoArquivo: String): String;

implementation

procedure RC4Aplicar(const Chave: String; var Dados: array of Byte);
var
  S: array[0..255] of Byte;
  I, J, K, TempByte: Integer;
  ChaveBytes: array of Byte;
  TamanhoChave: Integer;
begin
  TamanhoChave := Length(Chave);
  SetLength(ChaveBytes, TamanhoChave);

  for I := 0 to TamanhoChave - 1 do
    ChaveBytes[I] := Ord(Chave[I + 1]);

  // Inicializacao da S-box
  for I := 0 to 255 do
    S[I] := I;

  J := 0;
  for I := 0 to 255 do
  begin
    J := (J + S[I] + ChaveBytes[I mod TamanhoChave]) mod 256;
    TempByte := S[I];
    S[I] := S[J];
    S[J] := TempByte;
  end;

  // Fluxo de chave (keystream) aplicado via XOR nos dados
  I := 0;
  J := 0;
  for K := Low(Dados) to High(Dados) do
  begin
    I := (I + 1) mod 256;
    J := (J + S[I]) mod 256;

    TempByte := S[I];
    S[I] := S[J];
    S[J] := TempByte;

    Dados[K] := Dados[K] xor S[(S[I] + S[J]) mod 256];
  end;
end;

procedure SalvarArquivoLBX(const CaminhoArquivo: String; const Conteudo: String);
var
  Utf8Texto: UTF8String;
  Dados: array of Byte;
  I: Integer;
  Arquivo: TFileStream;
  MagicBytes: array[0..3] of Byte;
begin
  Utf8Texto := UTF8Encode(Conteudo);

  SetLength(Dados, Length(Utf8Texto));
  for I := 1 to Length(Utf8Texto) do
    Dados[I - 1] := Ord(Utf8Texto[I]);

  RC4Aplicar(LBX_CHAVE, Dados);

  Arquivo := TFileStream.Create(CaminhoArquivo, fmCreate);
  try
    // Grava a assinatura (nao criptografada) para o Analyser
    // conseguir validar rapidamente que o arquivo e um .LBX valido.
    for I := 0 to 3 do
      MagicBytes[I] := Ord(LBX_MAGIC[I + 1]);
    Arquivo.WriteBuffer(MagicBytes, 4);

    if Length(Dados) > 0 then
      Arquivo.WriteBuffer(Dados[0], Length(Dados));
  finally
    Arquivo.Free;
  end;
end;

function AbrirArquivoLBX(const CaminhoArquivo: String): String;
var
  Arquivo: TFileStream;
  MagicBytes: array[0..3] of Byte;
  MagicTexto: String;
  Dados: array of Byte;
  TamanhoDados: Int64;
  I: Integer;
  Utf8Texto: UTF8String;
begin
  Arquivo := TFileStream.Create(CaminhoArquivo, fmOpenRead or fmShareDenyNone);
  try
    if Arquivo.Size < 4 then
      raise Exception.Create('Arquivo invalido: tamanho insuficiente.');

    Arquivo.ReadBuffer(MagicBytes, 4);

    MagicTexto := '';
    for I := 0 to 3 do
      MagicTexto := MagicTexto + Chr(MagicBytes[I]);

    if MagicTexto <> LBX_MAGIC then
      raise Exception.Create('Arquivo invalido: assinatura LBX nao encontrada.');

    TamanhoDados := Arquivo.Size - 4;
    SetLength(Dados, TamanhoDados);

    if TamanhoDados > 0 then
      Arquivo.ReadBuffer(Dados[0], TamanhoDados);
  finally
    Arquivo.Free;
  end;

  RC4Aplicar(LBX_CHAVE, Dados);

  SetLength(Utf8Texto, Length(Dados));
  for I := 0 to High(Dados) do
    Utf8Texto[I + 1] := Chr(Dados[I]);

  Result := UTF8Decode(Utf8Texto);
end;

end.
