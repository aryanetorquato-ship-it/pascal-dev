program Questionario;

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  Process;

var
  TotalComputadores: Integer;
  TotalCaixas: Integer;
  TotalRetaguardas: Integer;

  EhServidor: Boolean;
  RespostaServidor: Char;

  UsaTEF: Boolean;
  RespostaTEF: Char;
  QuantidadePinPads: Integer;

  UsaImpressoraTermica: Boolean;
  RespostaImpressora: Char;
  QuantidadeImpressoras: Integer;
  ModelosImpressoras: String;

  FabricantePC: String;
  ModeloPC: String;

  Processador: String;
  NucleosCPU: String;
  ThreadsCPU: String;
  MemoriaRAM: String;

  Armazenamento: String;

  SistemaOperacional: String;
  ArquiteturaSO: String;

procedure GravarLogDiagnostico(const Mensagem: String);
var
  ArquivoLog: TextFile;
  CaminhoLog: String;
begin
  CaminhoLog := GetEnvironmentVariable('USERPROFILE');

  if CaminhoLog <> '' then
    CaminhoLog := CaminhoLog + '\Desktop\LogicB0B-debug.log'
  else
    CaminhoLog := 'LogicB0B-debug.log';

  AssignFile(ArquivoLog, CaminhoLog);

  if FileExists(CaminhoLog) then
    Append(ArquivoLog)
  else
    Rewrite(ArquivoLog);

  try
    WriteLn(ArquivoLog, Mensagem);
    Flush(ArquivoLog);
  finally
    CloseFile(ArquivoLog);
  end;
end;


function ExecutarPowerShell(const Comando: String): String;
var
  Processo: TProcess;
  Saida: TStringList;
  ExecutavelPowerShell: String;
begin
  Result := '';

  {$IFDEF WINDOWS}

  Processo := TProcess.Create(nil);
  Saida := TStringList.Create;

  try
    { Localizacao padrao do Windows PowerShell.
      Usamos o WINDIR para evitar depender de PATH. }
    ExecutavelPowerShell :=
      GetEnvironmentVariable('WINDIR') +
      '\System32\WindowsPowerShell\v1.0\powershell.exe';

    if not FileExists(ExecutavelPowerShell) then
      ExecutavelPowerShell := 'powershell.exe';

    GravarLogDiagnostico('[LOG] Executavel encontrado: ' + ExecutavelPowerShell);

Processo.Executable := ExecutavelPowerShell;

    Processo.Parameters.Add('-NoProfile');
    Processo.Parameters.Add('-NonInteractive');
    Processo.Parameters.Add('-ExecutionPolicy');
    Processo.Parameters.Add('Bypass');
    Processo.Parameters.Add('-Command');
    Processo.Parameters.Add(Comando);

    Processo.Options := [
      poUsePipes,
      poWaitOnExit,
      poStderrToOutPut
    ];

    try
      GravarLogDiagnostico('[LOG] Antes de Processo.Execute');

Processo.Execute;

GravarLogDiagnostico('[LOG] Depois de Processo.Execute');
    except
      on E: Exception do
      begin
        Result := 'Nao foi possivel coletar: ' + E.Message;
        Exit;
      end;
    end;

    GravarLogDiagnostico('[LOG] Antes de LoadFromStream');

Saida.LoadFromStream(Processo.Output);

GravarLogDiagnostico('[LOG] Depois de LoadFromStream');

    Result := Trim(Saida.Text);

    if Processo.ExitStatus <> 0 then
    begin
      if Result = '' then
        Result := 'Nao foi possivel coletar os dados.';
    end;

    if Result = '' then
      Result := 'Nao informado';

  finally
    Saida.Free;
    Processo.Free;
  end;

  {$ELSE}

  { O Questionario sera distribuido somente para Windows.
    O Codespace Linux serve apenas para desenvolvimento. }
  Result := 'Coleta disponivel somente no Windows';

  {$ENDIF}
end;


function DetectarFabricantePC: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_ComputerSystem).Manufacturer'
  );
end;


function DetectarModeloPC: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_ComputerSystem).Model'
  );
end;


function DetectarProcessador: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_Processor).Name'
  );
end;


function DetectarNucleosCPU: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_Processor).NumberOfCores'
  );
end;


function DetectarThreadsCPU: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_Processor).NumberOfLogicalProcessors'
  );
end;


function DetectarMemoriaRAM: String;
begin
  Result := ExecutarPowerShell(
    '[math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)'
  ) + ' GB';
end;

function DetectarArmazenamento: String;
begin
  GravarLogDiagnostico('[LOG] Entrou em DetectarArmazenamento');
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ' +
    'ForEach-Object { ' +
    '$_.DeviceID + " - " + ' +
    '[math]::Round($_.Size / 1GB, 2).ToString() + " GB total - " + ' +
    '[math]::Round($_.FreeSpace / 1GB, 2).ToString() + " GB livre" ' +
    '}) -join " | "'
  );
  GravarLogDiagnostico('[LOG] Saiu de DetectarArmazenamento');
end;

function DetectarSistemaOperacional: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_OperatingSystem).Caption'
  );
end;


function DetectarArquiteturaSO: String;
begin
  Result := ExecutarPowerShell(
    '(Get-WmiObject Win32_OperatingSystem).OSArchitecture'
  );
end;


function LerInteiro(const Pergunta: String): Integer;
var
  Texto: String;
  Valor: Integer;
begin
  repeat
    Write(Pergunta);
    ReadLn(Texto);

    Texto := Trim(Texto);

    if TryStrToInt(Texto, Valor) and (Valor >= 0) then
    begin
      Result := Valor;
      Exit;
    end;

    WriteLn;
    WriteLn('Valor invalido.');
    WriteLn('Digite apenas um numero inteiro maior ou igual a zero.');
    WriteLn;

  until False;
end;


function LerSimNao(const Pergunta: String): Boolean;
var
  Resposta: String;
begin
  repeat
    Write(Pergunta);
    ReadLn(Resposta);

    Resposta := LowerCase(Trim(Resposta));

    if Resposta = 's' then
    begin
      Result := True;
      Exit;
    end;

    if Resposta = 'n' then
    begin
      Result := False;
      Exit;
    end;

    WriteLn;
    WriteLn('Resposta invalida.');
    WriteLn('Digite S para Sim ou N para Nao.');
    WriteLn;

  until False;
end;


procedure ColetarHardware;
begin
  WriteLn;
  WriteLn('========================================');
  WriteLn('       DETECCAO AUTOMATICA');
  WriteLn('========================================');
  WriteLn;

  WriteLn('Coletando informacoes deste computador...');
  WriteLn;

  Write('[1/8] Fabricante do computador... ');
  FabricantePC := DetectarFabricantePC;
  WriteLn('OK');

  Write('[2/8] Modelo do computador... ');
  ModeloPC := DetectarModeloPC;
  WriteLn('OK');

  Write('[3/8] Processador... ');
  Processador := DetectarProcessador;
  WriteLn('OK');

  Write('[4/8] Nucleos e threads... ');
  NucleosCPU := DetectarNucleosCPU;
  ThreadsCPU := DetectarThreadsCPU;
  WriteLn('OK');

  Write('[5/8] Memoria RAM... ');
  MemoriaRAM := DetectarMemoriaRAM;
  WriteLn('OK');

  Write('[6/8] Armazenamento... ');
  Armazenamento := DetectarArmazenamento;
  WriteLn('OK');

  Write('[7/8] Sistema operacional... ');
  SistemaOperacional := DetectarSistemaOperacional;
  WriteLn('OK');

  Write('[8/8] Arquitetura do sistema... ');
  ArquiteturaSO := DetectarArquiteturaSO;
  WriteLn('OK');

  WriteLn;
  WriteLn('Coleta automatica concluida.');
end;


procedure ExibirResultado;
begin
  WriteLn;
  WriteLn('========================================');
  WriteLn('          DADOS COLETADOS');
  WriteLn('========================================');
  WriteLn;

  WriteLn('ESTRUTURA DA EMPRESA');
  WriteLn('Computadores: ', TotalComputadores);
  WriteLn('Caixas: ', TotalCaixas);
  WriteLn('Retaguardas: ', TotalRetaguardas);

  WriteLn;
  WriteLn('FUNCAO DESTE COMPUTADOR');

  if EhServidor then
    WriteLn('Funcao: SERVIDOR')
  else
    WriteLn('Funcao: ESTACAO');

  WriteLn;
  WriteLn('TEF / PINPAD');

  if UsaTEF then
  begin
    WriteLn('TEF: SIM');
    WriteLn('PINPads: ', QuantidadePinPads);
  end
  else
    WriteLn('TEF: NAO');

  WriteLn;
  WriteLn('IMPRESSORAS TERMICAS');

  if UsaImpressoraTermica then
  begin
    WriteLn('Utiliza impressoras: SIM');
    WriteLn('Quantidade: ', QuantidadeImpressoras);
    WriteLn('Modelos: ', ModelosImpressoras);
  end
  else
    WriteLn('Utiliza impressoras: NAO');

  WriteLn;
  WriteLn('HARDWARE DETECTADO');
  WriteLn;

  WriteLn('Fabricante: ', FabricantePC);
  WriteLn('Modelo: ', ModeloPC);

  WriteLn;
  WriteLn('Processador: ', Processador);
  WriteLn('Nucleos: ', NucleosCPU);
  WriteLn('Threads: ', ThreadsCPU);

  WriteLn;
  WriteLn('Memoria RAM: ', MemoriaRAM);

  WriteLn;
  WriteLn('Armazenamento:');
  WriteLn(Armazenamento);

  WriteLn;
  WriteLn('Sistema operacional: ', SistemaOperacional);
  WriteLn('Arquitetura: ', ArquiteturaSO);

  WriteLn;
  WriteLn('========================================');
  WriteLn('Coleta concluida.');
  WriteLn('========================================');
end;


begin
  WriteLn('========================================');
  WriteLn('          LogicB0B - Questionario');
  WriteLn('========================================');
  WriteLn;

  WriteLn('ESTRUTURA DA EMPRESA');
  WriteLn;

  TotalComputadores :=
    LerInteiro('Quantos computadores existem no total? ');

  repeat
    TotalCaixas :=
      LerInteiro('Quantos computadores serao utilizados como Caixa? ');

    if TotalCaixas > TotalComputadores then
    begin
      WriteLn;
      WriteLn('Quantidade invalida.');
      WriteLn('A quantidade de Caixas nao pode ser maior que o total de computadores.');
      WriteLn;
    end;
  until TotalCaixas <= TotalComputadores;

  repeat
    TotalRetaguardas :=
      LerInteiro('Quantos computadores serao utilizados como Retaguarda? ');

    if TotalRetaguardas > TotalComputadores then
    begin
      WriteLn;
      WriteLn('Quantidade invalida.');
      WriteLn('A quantidade de Retaguardas nao pode ser maior que o total de computadores.');
      WriteLn;
    end;
  until TotalRetaguardas <= TotalComputadores;

  WriteLn;
  WriteLn('FUNCAO DESTE COMPUTADOR');
  WriteLn;

  EhServidor :=
    LerSimNao(
      'Este computador sera o servidor do banco de dados? (S/N): '
    );

  WriteLn;
  WriteLn('TEF / PINPAD');
  WriteLn;

  UsaTEF :=
    LerSimNao(
      'O estabelecimento utiliza TEF? (S/N): '
    );

  if UsaTEF then
    QuantidadePinPads :=
      LerInteiro('Quantidade de PINPads: ')
  else
    QuantidadePinPads := 0;

  WriteLn;
  WriteLn('IMPRESSORAS TERMICAS');
  WriteLn;

  UsaImpressoraTermica :=
    LerSimNao(
      'O estabelecimento utiliza impressoras termicas? (S/N): '
    );

  if UsaImpressoraTermica then
  begin
    QuantidadeImpressoras :=
      LerInteiro('Quantidade de impressoras termicas: ');

    Write('Modelos das impressoras: ');
    ReadLn(ModelosImpressoras);
  end
  else
  begin
    QuantidadeImpressoras := 0;
    ModelosImpressoras := '';
  end;

  ColetarHardware;

  ExibirResultado;

  WriteLn;
  WriteLn('Pressione ENTER para sair.');
  ReadLn;
end.
