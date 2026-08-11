unit HardwareInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils
  {$IFDEF WINDOWS}
  , Windows, Registry
  {$ENDIF}
  ;

// Retorna todas as informacoes de hardware coletadas, uma por linha,
// no formato Chave=Valor. Pronto para ser incluido no pacote do .LBX.
function ColetarHardware: TStringList;

implementation

function LerRegistroWindows(const Chave, Valor: String): String;
{$IFDEF WINDOWS}
var
  Reg: TRegistry;
{$ENDIF}
begin
  Result := '';

{$IFDEF WINDOWS}
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if Reg.OpenKeyReadOnly(Chave) then
    begin
      if Reg.ValueExists(Valor) then
        Result := Trim(Reg.ReadString(Valor));
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
{$ENDIF}
end;

function DetectarFabricante: String;
begin
  Result := LerRegistroWindows('HARDWARE\DESCRIPTION\System\BIOS', 'SystemManufacturer');
  if Result = '' then
    Result := 'Nao informado';
end;

function DetectarModelo: String;
begin
  Result := LerRegistroWindows('HARDWARE\DESCRIPTION\System\BIOS', 'SystemProductName');
  if Result = '' then
    Result := 'Nao informado';
end;

function DetectarProcessador: String;
begin
  Result := LerRegistroWindows('HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString');
  if Result = '' then
    Result := 'Nao informado';
end;

function DetectarProcessadoresLogicos: String;
{$IFDEF WINDOWS}
var
  Info: SYSTEM_INFO;
{$ENDIF}
begin
  Result := 'Nao informado';
{$IFDEF WINDOWS}
  GetNativeSystemInfo(Info);
  if Info.dwNumberOfProcessors > 0 then
    Result := IntToStr(Info.dwNumberOfProcessors);
{$ENDIF}
end;

function DetectarMemoriaRAM: String;
{$IFDEF WINDOWS}
var
  Memoria: TMemoryStatusEx;
{$ENDIF}
begin
  Result := 'Nao informado';
{$IFDEF WINDOWS}
  FillChar(Memoria, SizeOf(Memoria), 0);
  Memoria.dwLength := SizeOf(Memoria);

  if GlobalMemoryStatusEx(Memoria) then
    Result := FormatFloat('0.00', Memoria.ullTotalPhys / 1073741824.0) + ' GB';
{$ENDIF}
end;

function DetectarArmazenamento: String;
{$IFDEF WINDOWS}
var
  Drives: DWORD;
  Letra: Char;
  Unidade: String;
  TotalBytes, BytesLivres: Int64;
{$ENDIF}
begin
  Result := 'Nao informado';

{$IFDEF WINDOWS}
  Drives := GetLogicalDrives;
  if Drives = 0 then
    Exit;

  Result := '';

  for Letra := 'A' to 'Z' do
  begin
    if (Drives and (DWORD(1) shl (Ord(Letra) - Ord('A')))) <> 0 then
    begin
      Unidade := Letra + ':\';

      if GetDriveType(PChar(Unidade)) = DRIVE_FIXED then
      begin
        TotalBytes := 0;
        BytesLivres := 0;

        if GetDiskFreeSpaceEx(PChar(Unidade), nil,
             PInt64(@TotalBytes), PInt64(@BytesLivres)) then
        begin
          if Result <> '' then
            Result := Result + ' | ';

          Result := Result + Letra + ': - ' +
            FormatFloat('0.00', TotalBytes / 1073741824.0) + ' GB total - ' +
            FormatFloat('0.00', BytesLivres / 1073741824.0) + ' GB livre';
        end;
      end;
    end;
  end;

  if Result = '' then
    Result := 'Nao informado';
{$ENDIF}
end;

function DetectarSistemaOperacional: String;
var
  Nome, Versao: String;
begin
  Nome := LerRegistroWindows('SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'ProductName');
  Versao := LerRegistroWindows('SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'CurrentVersion');

  Result := Nome;
  if (Result <> '') and (Versao <> '') then
    Result := Result + ' (NT ' + Versao + ')';

  if Result = '' then
    Result := 'Nao informado';
end;

function DetectarArquitetura: String;
{$IFDEF WINDOWS}
var
  Info: SYSTEM_INFO;
{$ENDIF}
begin
  Result := 'Nao informado';
{$IFDEF WINDOWS}
  GetNativeSystemInfo(Info);

  case Info.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_AMD64: Result := 'x64';
    PROCESSOR_ARCHITECTURE_INTEL: Result := 'x86';
    PROCESSOR_ARCHITECTURE_ARM64: Result := 'ARM64';
    PROCESSOR_ARCHITECTURE_ARM:   Result := 'ARM';
  else
    Result := 'Desconhecida';
  end;
{$ENDIF}
end;

function ColetarHardware: TStringList;
begin
  Result := TStringList.Create;

  Result.Add('Fabricante=' + DetectarFabricante);
  Result.Add('Modelo=' + DetectarModelo);
  Result.Add('Processador=' + DetectarProcessador);
  Result.Add('ProcessadoresLogicos=' + DetectarProcessadoresLogicos);
  Result.Add('MemoriaRAM=' + DetectarMemoriaRAM);
  Result.Add('Armazenamento=' + DetectarArmazenamento);
  Result.Add('SistemaOperacional=' + DetectarSistemaOperacional);
  Result.Add('Arquitetura=' + DetectarArquitetura);
end;

end.
