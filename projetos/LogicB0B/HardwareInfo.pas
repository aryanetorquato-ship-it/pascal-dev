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

{$IFDEF WINDOWS}

type
  TMemoryStatusExCompat = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: QWord;
    ullAvailPhys: QWord;
    ullTotalPageFile: QWord;
    ullAvailPageFile: QWord;
    ullTotalVirtual: QWord;
    ullAvailVirtual: QWord;
    ullAvailExtendedVirtual: QWord;
  end;

  TStorageDeviceNumberCompat = record
    DeviceType: DWORD;
    DeviceNumber: DWORD;
    PartitionNumber: DWORD;
  end;

  TStoragePropertyQueryCompat = record
    PropertyId: DWORD;
    QueryType: DWORD;
    AdditionalParameters: array[0..3] of Byte;
  end;

  TStorageDeviceDescriptorCompat = record
    Version: DWORD;
    Size: DWORD;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Byte;
    CommandQueueing: Byte;
    VendorIdOffset: DWORD;
    ProductIdOffset: DWORD;
    ProductRevisionOffset: DWORD;
    SerialNumberOffset: DWORD;
    BusType: DWORD;
    RawPropertiesLength: DWORD;
  end;

  TStorageDeviceSeekPenaltyDescriptorCompat = record
    Version: DWORD;
    Size: DWORD;
    IncursSeekPenalty: BOOL;
  end;

  TStoragePredictFailureCompat = record
    PredictFailure: DWORD;
    VendorSpecific: array[0..511] of Byte;
  end;

function GlobalMemoryStatusExCompat(
  var lpBuffer: TMemoryStatusExCompat
): BOOL; stdcall; external 'kernel32' name 'GlobalMemoryStatusEx';

const
  PROCESSOR_ARCHITECTURE_INTEL_COMPAT = 0;
  PROCESSOR_ARCHITECTURE_ARM_COMPAT    = 5;
  PROCESSOR_ARCHITECTURE_AMD64_COMPAT  = 9;
  PROCESSOR_ARCHITECTURE_ARM64_COMPAT  = 12;

  // DeviceIoControl - armazenamento
  IOCTL_STORAGE_GET_DEVICE_NUMBER      = $002D1080;
  IOCTL_STORAGE_QUERY_PROPERTY         = $002D1400;
  IOCTL_STORAGE_PREDICT_FAILURE        = $002D1100;

  // STORAGE_PROPERTY_ID
  StorageDeviceProperty                 = 0;
  StorageDeviceSeekPenaltyProperty      = 7;

  // STORAGE_QUERY_TYPE
  PropertyStandardQuery                 = 0;

  // STORAGE_BUS_TYPE
  BusTypeScsi                           = 1;
  BusTypeAtapi                          = 2;
  BusTypeAta                            = 3;
  BusType1394                           = 4;
  BusTypeSsa                            = 5;
  BusTypeFibre                           = 6;
  BusTypeUsb                            = 7;
  BusTypeRAID                           = 8;
  BusTypeiSCSI                          = 9;
  BusTypeSas                            = 10;
  BusTypeSata                           = 11;
  BusTypeSd                             = 12;
  BusTypeMmc                            = 13;
  BusTypeVirtual                        = 14;
  BusTypeFileBackedVirtual              = 15;
  BusTypeSpaces                         = 16;
  BusTypeNvme                           = 17;
  BusTypeSCM                            = 18;
  BusTypeUfs                            = 19;

{$ENDIF}


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
  Result := LerRegistroWindows(
    'HARDWARE\DESCRIPTION\System\BIOS',
    'SystemManufacturer'
  );

  if Result = '' then
    Result := 'Nao informado';
end;


function DetectarModelo: String;
begin
  Result := LerRegistroWindows(
    'HARDWARE\DESCRIPTION\System\BIOS',
    'SystemProductName'
  );

  if Result = '' then
    Result := 'Nao informado';
end;


function DetectarProcessador: String;
begin
  Result := LerRegistroWindows(
    'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
    'ProcessorNameString'
  );

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
  GetNativeSystemInfo(@Info);

  if Info.dwNumberOfProcessors > 0 then
    Result := IntToStr(Info.dwNumberOfProcessors);
{$ENDIF}
end;


function DetectarMemoriaRAM: String;
{$IFDEF WINDOWS}
var
  Memoria: TMemoryStatusExCompat;
{$ENDIF}
begin
  Result := 'Nao informado';

{$IFDEF WINDOWS}
  FillChar(Memoria, SizeOf(Memoria), 0);
  Memoria.dwLength := SizeOf(Memoria);

  if GlobalMemoryStatusExCompat(Memoria) then
    Result := FormatFloat(
      '0.00',
      Memoria.ullTotalPhys / 1073741824.0
    ) + ' GB';
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
    if (Drives and (DWORD(1) shl
      (Ord(Letra) - Ord('A')))) <> 0 then
    begin
      Unidade := Letra + ':\';

      if GetDriveType(PChar(Unidade)) = DRIVE_FIXED then
      begin
        TotalBytes := 0;
        BytesLivres := 0;

        if GetDiskFreeSpaceEx(
          PChar(Unidade),
          nil,
          PInt64(@TotalBytes),
          PInt64(@BytesLivres)
        ) then
        begin
          if Result <> '' then
            Result := Result + ' | ';

          Result := Result + Letra + ': - ' +
            FormatFloat(
              '0.00',
              TotalBytes / 1073741824.0
            ) + ' GB total - ' +
            FormatFloat(
              '0.00',
              BytesLivres / 1073741824.0
            ) + ' GB livre';
        end;
      end;
    end;
  end;

  if Result = '' then
    Result := 'Nao informado';
{$ENDIF}
end;


{$IFDEF WINDOWS}

function ObterNumeroDiscoDoC: Integer;
var
  HandleC: THandle;
  DeviceNumber: TStorageDeviceNumberCompat;
  BytesReturned: DWORD;
begin
  Result := -1;

  HandleC := CreateFile(
    '\\.\C:',
    0,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    0,
    0
  );

  if HandleC = INVALID_HANDLE_VALUE then
    Exit;

  try
    FillChar(DeviceNumber, SizeOf(DeviceNumber), 0);
    BytesReturned := 0;

    if DeviceIoControl(
      HandleC,
      IOCTL_STORAGE_GET_DEVICE_NUMBER,
      nil,
      0,
      @DeviceNumber,
      SizeOf(DeviceNumber),
      @BytesReturned,
      nil
    ) then
    begin
      Result := Integer(DeviceNumber.DeviceNumber);
    end;
  finally
    CloseHandle(HandleC);
  end;
end;


function AbrirDiscoFisico(NumeroDisco: Integer): THandle;
var
  Caminho: String;
begin
  Result := INVALID_HANDLE_VALUE;

  if NumeroDisco < 0 then
    Exit;

  Caminho := '\\.\PhysicalDrive' + IntToStr(NumeroDisco);

  Result := CreateFile(
    PChar(Caminho),
    0,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    0,
    0
  );
end;


function ObterBusTypeDoDisco(HandleDisco: THandle): DWORD;
var
  Query: TStoragePropertyQueryCompat;
  Buffer: array[0..1023] of Byte;
  BytesReturned: DWORD;
  Descriptor: ^TStorageDeviceDescriptorCompat;
begin
  Result := 0;

  if HandleDisco = INVALID_HANDLE_VALUE then
    Exit;

  FillChar(Query, SizeOf(Query), 0);
  Query.PropertyId := StorageDeviceProperty;
  Query.QueryType := PropertyStandardQuery;

  FillChar(Buffer, SizeOf(Buffer), 0);
  BytesReturned := 0;

  if DeviceIoControl(
    HandleDisco,
    IOCTL_STORAGE_QUERY_PROPERTY,
    @Query,
    SizeOf(Query),
    @Buffer,
    SizeOf(Buffer),
    @BytesReturned,
    nil
  ) then
  begin
    if BytesReturned >= SizeOf(TStorageDeviceDescriptorCompat) then
    begin
      Descriptor := @Buffer[0];

      Result := Descriptor^.BusType;
    end;
  end;
end;


function ObterSeekPenaltyDoDisco(
  HandleDisco: THandle;
  out TemSeekPenalty: Boolean
): Boolean;
var
  Query: TStoragePropertyQueryCompat;
  Descriptor: TStorageDeviceSeekPenaltyDescriptorCompat;
  BytesReturned: DWORD;
begin
  Result := False;
  TemSeekPenalty := True;

  if HandleDisco = INVALID_HANDLE_VALUE then
    Exit;

  FillChar(Query, SizeOf(Query), 0);
  Query.PropertyId := StorageDeviceSeekPenaltyProperty;
  Query.QueryType := PropertyStandardQuery;

  FillChar(Descriptor, SizeOf(Descriptor), 0);
  BytesReturned := 0;

  if DeviceIoControl(
    HandleDisco,
    IOCTL_STORAGE_QUERY_PROPERTY,
    @Query,
    SizeOf(Query),
    @Descriptor,
    SizeOf(Descriptor),
    @BytesReturned,
    nil
  ) then
  begin
    if BytesReturned >= SizeOf(Descriptor) then
    begin
      TemSeekPenalty := Descriptor.IncursSeekPenalty <> FALSE;
      Result := True;
    end;
  end;
end;


function DetectarTipoArmazenamento: String;
var
  NumeroDisco: Integer;
  HandleDisco: THandle;
  BusType: DWORD;
  TemSeekPenalty: Boolean;
begin
  Result := 'Nao informado';

  NumeroDisco := ObterNumeroDiscoDoC;

  if NumeroDisco < 0 then
    Exit;

  HandleDisco := AbrirDiscoFisico(NumeroDisco);

  if HandleDisco = INVALID_HANDLE_VALUE then
    Exit;

  try
    // NVMe e explicitamente identificado pelo Windows.
    BusType := ObterBusTypeDoDisco(HandleDisco);

    if BusType = BusTypeNvme then
    begin
      Result := 'SSD/NVMe';
      Exit;
    end;

    // Para SATA/SAS e outros dispositivos, usamos a propriedade
    // SeekPenalty. SSD normalmente nao possui penalidade de busca;
    // HDD possui.
    if ObterSeekPenaltyDoDisco(
      HandleDisco,
      TemSeekPenalty
    ) then
    begin
      if TemSeekPenalty then
        Result := 'HDD'
      else
        Result := 'SSD/NVMe';
    end;
  finally
    CloseHandle(HandleDisco);
  end;
end;


function DetectarSaudeArmazenamento: String;
var
  NumeroDisco: Integer;
  HandleDisco: THandle;
  PredictFailure: TStoragePredictFailureCompat;
  BytesReturned: DWORD;
begin
  Result := 'Nao informado';

  NumeroDisco := ObterNumeroDiscoDoC;

  if NumeroDisco < 0 then
    Exit;

  HandleDisco := AbrirDiscoFisico(NumeroDisco);

  if HandleDisco = INVALID_HANDLE_VALUE then
    Exit;

  try
    FillChar(PredictFailure, SizeOf(PredictFailure), 0);
    BytesReturned := 0;

    if DeviceIoControl(
      HandleDisco,
      IOCTL_STORAGE_PREDICT_FAILURE,
      nil,
      0,
      @PredictFailure,
      SizeOf(PredictFailure),
      @BytesReturned,
      nil
    ) then
    begin
      if BytesReturned >= SizeOf(PredictFailure) then
      begin
        if PredictFailure.PredictFailure = 0 then
          Result := 'Saudavel'
        else
          Result := 'Falha prevista';
      end;
    end;
  finally
    CloseHandle(HandleDisco);
  end;
end;

{$ELSE}

function DetectarTipoArmazenamento: String;
begin
  Result := 'Nao informado';
end;


function DetectarSaudeArmazenamento: String;
begin
  Result := 'Nao informado';
end;

{$ENDIF}


function DetectarSistemaOperacional: String;
begin
  Result := LerRegistroWindows(
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion',
    'ProductName'
  );

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
  GetNativeSystemInfo(@Info);

  case Info.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_AMD64_COMPAT:
      Result := 'x64';

    PROCESSOR_ARCHITECTURE_INTEL_COMPAT:
      Result := 'x86';

    PROCESSOR_ARCHITECTURE_ARM64_COMPAT:
      Result := 'ARM64';

    PROCESSOR_ARCHITECTURE_ARM_COMPAT:
      Result := 'ARM';
  else
    Result := 'Desconhecida';
  end;
{$ENDIF}
end;


function DetectarVersaoWindows: String;
begin
  Result := LerRegistroWindows(
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion',
    'DisplayVersion'
  );

  if Result = '' then
    Result := 'Nao informado';
end;


function DetectarResolucaoTela: String;
{$IFDEF WINDOWS}
var
  Largura, Altura: Integer;
{$ENDIF}
begin
  Result := 'Nao informado';

{$IFDEF WINDOWS}
  Largura := GetSystemMetrics(SM_CXSCREEN);
  Altura := GetSystemMetrics(SM_CYSCREEN);

  if (Largura > 0) and (Altura > 0) then
    Result := IntToStr(Largura) + 'x' + IntToStr(Altura);
{$ENDIF}
end;


function ColetarHardware: TStringList;
begin
  Result := TStringList.Create;

  // Campos existentes - preservados.
  Result.Add('Fabricante=' + DetectarFabricante);
  Result.Add('Modelo=' + DetectarModelo);
  Result.Add('Processador=' + DetectarProcessador);
  Result.Add('ProcessadoresLogicos=' + DetectarProcessadoresLogicos);
  Result.Add('MemoriaRAM=' + DetectarMemoriaRAM);

  // Campo existente - preservado.
  Result.Add('Armazenamento=' + DetectarArmazenamento);

  // Novos campos.
  Result.Add('TipoArmazenamento=' + DetectarTipoArmazenamento);
  Result.Add('SaudeArmazenamento=' + DetectarSaudeArmazenamento);

  // Campos existentes - preservados.
  Result.Add('SistemaOperacional=' + DetectarSistemaOperacional);
  Result.Add('VersaoWindows=' + DetectarVersaoWindows);
  Result.Add('ResolucaoTela=' + DetectarResolucaoTela);
  Result.Add('Arquitetura=' + DetectarArquitetura);
end;


end.
