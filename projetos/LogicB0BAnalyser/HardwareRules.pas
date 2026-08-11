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
function EhCeleronDualCoreCompativel(const NomeCPU: String): Boolean;
function ExtrairRAMGB(const TextoRAM: String): Integer;
function AvaliarPapel(const Papel, NomeCPU: String; RAMGB: Integer;
  const SistemaOperacional: String): TResultadoAvaliacao;
function NivelParaTexto(Nivel: TNivelAdequacao): String;

implementation

function ExtrairGeracaoIntel(const NomeCPU: String): Integer;
var
  Nome: String;
  Pos1, I: Integer;
  Digitos: String;
begin
  Result := -1;
  Nome := UpperCase(NomeCPU);

  Pos1 := 0;
  if Pos('I3', Nome) > 0 then Pos1 := Pos('I3', Nome)
  else if Pos('I5', Nome) > 0 then Pos1 := Pos('I5', Nome)
  else if Pos('I7', Nome) > 0 then Pos1 := Pos('I7', Nome)
  else if Pos('I9', Nome) > 0 then Pos1 := Pos('I9', Nome);

  if Pos1 = 0 then Exit;

  I := Pos1 + 2;
  Digitos := '';
  while (I <= Length(Nome)) and ((Nome[I] = ' ') or (Nome[I] = '-')) do
    Inc(I);

  while (I <= Length(Nome)) and (Nome[I] in ['0'..'9']) and (Length(Digitos) < 5) do
  begin
    Digitos := Digitos + Nome[I];
    Inc(I);
  end;

  if Length(Digitos) = 5 then
    Result := StrToIntDef(Copy(Digitos, 1, 2), -1)
  else if Length(Digitos) >= 4 then
    Result := StrToIntDef(Copy(Digitos, 1, 1), -1);
end;

function EhCeleronDualCoreCompativel(const NomeCPU: String): Boolean;
var
  Nome: String;
begin
  Nome := UpperCase(NomeCPU);
  Result :=
    (Pos('CELERON', Nome) > 0) and
    ((Pos('J1800', Nome) > 0) or (Pos('J1900', Nome) > 0) or (Pos('DUAL', Nome) > 0));
end;

function ExtrairRAMGB(const TextoRAM: String): Integer;
var
  Texto: String;
  I: Integer;
  Digitos: String;
begin
  Result := 0;
  Texto := UpperCase(TextoRAM);
  Digitos := '';
  for I := 1 to Length(Texto) do
  begin
    if Texto[I] in ['0'..'9'] then
      Digitos := Digitos + Texto[I]
    else if Digitos <> '' then
      Break;
  end;
  Result := StrToIntDef(Digitos, 0);
end;

function AvaliarPapel(const Papel, NomeCPU: String; RAMGB: Integer;
  const SistemaOperacional: String): TResultadoAvaliacao;
var
  Geracao: Integer;
begin
  Geracao := ExtrairGeracaoIntel(NomeCPU);

  Result.Nivel := naNaoClassificado;
  Result.Motivo := 'Nao foi possivel classificar (CPU: ' + NomeCPU + ', RAM: ' +
    IntToStr(RAMGB) + 'GB)';

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
    else if ((Geracao >= 4) or EhCeleronDualCoreCompativel(NomeCPU)) and (RAMGB >= 8) then
      Result.Nivel := naMinima;
  end;

  if Result.Nivel <> naNaoClassificado then
    Result.Motivo := NivelParaTexto(Result.Nivel);
end;

function NivelParaTexto(Nivel: TNivelAdequacao): String;
begin
  case Nivel of
    naIdeal:       Result := 'Configuracao Ideal';
    naRecomendada: Result := 'Configuracao Recomendada';
    naMinima:      Result := 'Configuracao Minima (legado suportado)';
    naLegado:      Result := 'Legado';
  else
    Result := 'Nao classificado';
  end;
end;

end.
