unit HardwareRules;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TNivelAdequacao = (naNaoClassificado, naLegado, naMinima, naRecomendada, naIdeal);

  TResultadoAvaliacao = record
    Nivel: TNivelAdequacao;
    Motivo: String;
  end;

function ExtrairGeracaoIntel(const NomeCPU: String): Integer;
function ExtrairGeracaoAMD(const NomeCPU: String): Integer;
function ExtrairGeracaoEquivalente(const NomeCPU: String): Integer;
function ExtrairClasseCpu(const NomeCPU: String): Integer;
function EhCeleronDualCoreCompativel(const NomeCPU: String): Boolean;
function ArredondarRamComercial(MedidoGB: Double): Integer;
function ExtrairRAMGB(const TextoRAM: String): Integer;
function AvaliarProcessadorIsolado(const NomeCPU: String; RAMGB: Integer;
  TemSSD: Boolean): TResultadoAvaliacao;
function AvaliarPapel(const Papel, NomeCPU: String; RAMGB: Integer;
  const SistemaOperacional: String): TResultadoAvaliacao;
function NivelParaTexto(Nivel: TNivelAdequacao): String;

implementation

const
  TamanhosRamComerciaisGB: array[0..13] of Integer =
    (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128);

function ExtrairGeracaoIntel(const NomeCPU: String): Integer;
var
  Nome: String;
  Pos1, I: Integer;
  Digitos: String;
begin
  Result := -1;
  Nome := UpperCase(NomeCPU);
  Pos1 := 0;

  if Pos('I3', Nome) > 0 then
    Pos1 := Pos('I3', Nome)
  else if Pos('I5', Nome) > 0 then
    Pos1 := Pos('I5', Nome)
  else if Pos('I7', Nome) > 0 then
    Pos1 := Pos('I7', Nome)
  else if Pos('I9', Nome) > 0 then
    Pos1 := Pos('I9', Nome);

  if Pos1 = 0 then
    Exit;

  I := Pos1 + 2;
  Digitos := '';

  while (I <= Length(Nome)) and
        ((Nome[I] = ' ') or (Nome[I] = '-')) do
    Inc(I);

  while (I <= Length(Nome)) and
        (Nome[I] in ['0'..'9']) and
        (Length(Digitos) < 5) do
  begin
    Digitos := Digitos + Nome[I];
    Inc(I);
  end;

  if Length(Digitos) = 5 then
    Result := StrToIntDef(Copy(Digitos, 1, 2), -1)
  else if Length(Digitos) >= 4 then
    Result := StrToIntDef(Copy(Digitos, 1, 1), -1);
end;

function ExtrairGeracaoAMD(const NomeCPU: String): Integer;
var
  Nome: String;
  PosRyzen, I: Integer;
  Digitos: String;
begin
  Result := -1;
  Nome := UpperCase(NomeCPU);

  PosRyzen := Pos('RYZEN', Nome);
  if PosRyzen = 0 then
    Exit;

  I := PosRyzen + 5;
  Digitos := '';

  while I <= Length(Nome) do
  begin
    if Nome[I] in ['0'..'9'] then
    begin
      Digitos := Digitos + Nome[I];
      Inc(I);

      if Length(Digitos) = 4 then
        Break;
    end
    else
    begin
      if (Length(Digitos) > 0) and (Length(Digitos) < 4) then
        Digitos := '';

      Inc(I);
    end;
  end;

  if Length(Digitos) <> 4 then
    Exit;

  if (Digitos = '2200') or (Digitos = '2400') then
  begin
    Result := 7;
    Exit;
  end;

  case Digitos[1] of
    '1': Result := 7;
    '2': Result := 8;
    '3': Result := 10;
    '4': Result := 10;
    '5': Result := 11;
    '6': Result := 11;
    '7', '8', '9': Result := 13;
  else
    Result := -1;
  end;
end;

function ExtrairGeracaoEquivalente(const NomeCPU: String): Integer;
begin
  Result := ExtrairGeracaoIntel(NomeCPU);

  if Result = -1 then
    Result := ExtrairGeracaoAMD(NomeCPU);
end;

function ExtrairClasseCpu(const NomeCPU: String): Integer;
var
  Nome: String;
begin
  Nome := UpperCase(NomeCPU);
  Result := 0;

  if (Pos('I9', Nome) > 0) or (Pos('RYZEN 9', Nome) > 0) then
    Result := 9
  else if (Pos('I7', Nome) > 0) or (Pos('RYZEN 7', Nome) > 0) then
    Result := 7
  else if (Pos('I5', Nome) > 0) or (Pos('RYZEN 5', Nome) > 0) then
    Result := 5
  else if (Pos('I3', Nome) > 0) or (Pos('RYZEN 3', Nome) > 0) then
    Result := 3;
end;

function EhCeleronDualCoreCompativel(const NomeCPU: String): Boolean;
var
  Nome: String;
begin
  Nome := UpperCase(NomeCPU);

  Result :=
    (Pos('CELERON', Nome) > 0) and
    ((Pos('J1800', Nome) > 0) or
     (Pos('J1900', Nome) > 0) or
     (Pos('DUAL', Nome) > 0));
end;

function ArredondarRamComercial(MedidoGB: Double): Integer;
var
  I: Integer;
begin
  for I := Low(TamanhosRamComerciaisGB) to High(TamanhosRamComerciaisGB) do
  begin
    if (MedidoGB <= TamanhosRamComerciaisGB[I]) and
       (MedidoGB >= TamanhosRamComerciaisGB[I] * 0.85) then
    begin
      Result := TamanhosRamComerciaisGB[I];
      Exit;
    end;
  end;

  Result := Round(MedidoGB);
end;

function ExtrairRAMGB(const TextoRAM: String): Integer;
var
  Texto, Numero: String;
  I: Integer;
  ValorGB: Double;
  FS: TFormatSettings;
begin
  Result := 0;
  Texto := Trim(TextoRAM);
  Numero := '';

  for I := 1 to Length(Texto) do
  begin
    if Texto[I] in ['0'..'9', '.', ','] then
      Numero := Numero + Texto[I]
    else if Numero <> '' then
      Break;
  end;

  Numero := StringReplace(Numero, ',', '.', [rfReplaceAll]);

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  ValorGB := StrToFloatDef(Numero, 0, FS);

  if ValorGB <= 0 then
    Exit(0);

  Result := ArredondarRamComercial(ValorGB);
end;

function AvaliarProcessadorIsolado(const NomeCPU: String; RAMGB: Integer;
  TemSSD: Boolean): TResultadoAvaliacao;
var
  Nome: String;
  Geracao: Integer;
  Classe: Integer;
  RequisitosBasicosOK: Boolean;
  EhFaixaEntrada: Boolean;
  Reconhecido: Boolean;
begin
  Nome := UpperCase(Trim(NomeCPU));

  Result.Nivel := naNaoClassificado;
  Result.Motivo := 'CPU nao reconhecida ou abaixo do piso minimo (' +
    NomeCPU + ')';

  if Nome = '' then
    Exit;

  Geracao := ExtrairGeracaoEquivalente(NomeCPU);
  Classe := ExtrairClasseCpu(NomeCPU);

  Reconhecido := False;

  if Geracao >= 4 then
    Reconhecido := True;

  EhFaixaEntrada :=
    (Classe = 3) or
    (Pos('CELERON', Nome) > 0) or
    (Pos('PENTIUM GOLD', Nome) > 0);

  if EhFaixaEntrada then
    Reconhecido := True;

  if EhCeleronDualCoreCompativel(NomeCPU) then
    Reconhecido := True;

  if not Reconhecido then
    Exit;

  if EhFaixaEntrada or EhCeleronDualCoreCompativel(NomeCPU) then
  begin
    RequisitosBasicosOK :=
      TemSSD and (RAMGB >= 8);

    if not RequisitosBasicosOK then
    begin
      Result.Nivel := naNaoClassificado;
      Result.Motivo :=
        'CPU de entrada sem SSD + 8GB RAM - nao atende';
      Exit;
    end;

    Result.Nivel := naMinima;
    Result.Motivo :=
      'CPU de entrada (i3/Celeron/Pentium Gold), funcional com SSD + 8GB RAM';
    Exit;
  end;

  if (Classe = 5) or
     (Classe = 7) or
     (Classe = 9) then
  begin
    Result.Nivel := naIdeal;
    Result.Motivo := 'CPU robusta para o uso proposto';
    Exit;
  end;

  if Geracao >= 4 then
  begin
    Result.Nivel := naIdeal;
    Result.Motivo := 'CPU de geracao adequada para o uso proposto';
  end;
end;

function AvaliarPapel(const Papel, NomeCPU: String; RAMGB: Integer;
  const SistemaOperacional: String): TResultadoAvaliacao;
var
  Geracao: Integer;
begin
  Geracao := ExtrairGeracaoIntel(NomeCPU);

  Result.Nivel := naNaoClassificado;
  Result.Motivo := 'Nao foi possivel classificar (CPU: ' + NomeCPU +
    ', RAM: ' + IntToStr(RAMGB) + 'GB)';

  if (Papel = 'Servidor') or (Papel = 'PDV_Retaguarda') then
  begin
    if (Geracao >= 12) and (RAMGB >= 16) then
      Result.Nivel := naIdeal
    else if (Geracao >= 8) and (RAMGB >= 16) then
      Result.Nivel := naRecomendada
    else if (Geracao >= 4) and (RAMGB >= 8) then
      Result.Nivel := naMinima;
  end
  else if Papel = 'Caixa' then
  begin
    if (Geracao >= 12) and (RAMGB >= 16) then
      Result.Nivel := naIdeal
    else if (Geracao >= 8) and (RAMGB >= 16) then
      Result.Nivel := naRecomendada
    else if ((Geracao >= 4) or
             EhCeleronDualCoreCompativel(NomeCPU)) and
            (RAMGB >= 8) then
      Result.Nivel := naMinima;
  end;

  if Result.Nivel <> naNaoClassificado then
    Result.Motivo := NivelParaTexto(Result.Nivel);
end;

function NivelParaTexto(Nivel: TNivelAdequacao): String;
begin
  case Nivel of
    naIdeal:
      Result := 'Configuracao Ideal';
    naRecomendada:
      Result := 'Configuracao Recomendada';
    naMinima:
      Result := 'Configuracao Minima (legado suportado)';
    naLegado:
      Result := 'Legado';
  else
    Result := 'Nao classificado';
  end;
end;

end.
