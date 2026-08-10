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


function ExecutarPowerShell(const Comando: String): String;
var
  Processo: TProcess;
  Saida: TStringList;
begin
  Result := '';

  Processo := TProcess.Create(nil);
  Saida := TStringList.Create;

  try
    Processo.Executable := 'powershell.exe';

    Processo.Parameters.Add('-NoProfile');
    Processo.Parameters.Add('-NonInteractive');
    Processo.Parameters.Add('-Command');
    Processo.Parameters.Add(Comando);

    Processo.Options := [poUsePipes, poWaitOnExit];

    Processo.Execute;

    Saida.LoadFromStream(Processo.Output);

    Result := Trim(Saida.Text);
  finally
    Saida.Free;
    Processo.Free;
  end;
end;


function DetectarFabricantePC: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_ComputerSystem).Manufacturer'
  );
end;


function DetectarModeloPC: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_ComputerSystem).Model'
  );
end;


function DetectarProcessador: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_Processor).Name'
  );
end;


function DetectarNucleosCPU: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_Processor).NumberOfCores'
  );
end;


function DetectarThreadsCPU: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors'
  );
end;


function DetectarMemoriaRAM: String;
begin
  Result := ExecutarPowerShell(
    '[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2).ToString() + " GB"'
  );
end;


function DetectarArmazenamento: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_DiskDrive | ForEach-Object { $_.Model + " - " + [math]::Round($_.Size / 1GB, 0).ToString() + " GB" }) -join " | "'
  );
end;


function DetectarSistemaOperacional: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_OperatingSystem).Caption'
  );
end;


function DetectarArquiteturaSO: String;
begin
  Result := ExecutarPowerShell(
    '(Get-CimInstance Win32_OperatingSystem).OSArchitecture'
  );
end;


begin
  WriteLn('========================================');
  WriteLn('          LogicB0B - Questionario');
  WriteLn('========================================');
  WriteLn;

  WriteLn('ESTRUTURA DA EMPRESA');
  WriteLn;

  Write('Quantos computadores existem no total? ');
  ReadLn(TotalComputadores);

  Write('Quantos computadores serao utilizados como Caixa? ');
  ReadLn(TotalCaixas);

  Write('Quantos computadores serao utilizados como Retaguarda? ');
  ReadLn(TotalRetaguardas);


  WriteLn;
  WriteLn('FUNCAO DESTE COMPUTADOR');
  WriteLn;

  Write('Este computador sera o servidor do banco de dados? (S/N): ');
  ReadLn(RespostaServidor);

  EhServidor := (RespostaServidor = 'S') or
                (RespostaServidor = 's');


  WriteLn;
  WriteLn('TEF / PINPAD');
  WriteLn;

  Write('O estabelecimento utiliza TEF? (S/N): ');
  ReadLn(RespostaTEF);

  UsaTEF := (RespostaTEF = 'S') or
            (RespostaTEF = 's');

  if UsaTEF then
  begin
    Write('Quantidade de PINPads: ');
    ReadLn(QuantidadePinPads);
  end
  else
    QuantidadePinPads := 0;


  WriteLn;
  WriteLn('IMPRESSORAS TERMICAS');
  WriteLn;

  Write('O estabelecimento utiliza impressoras termicas? (S/N): ');
  ReadLn(RespostaImpressora);

  UsaImpressoraTermica := (RespostaImpressora = 'S') or
                          (RespostaImpressora = 's');

  if UsaImpressoraTermica then
  begin
    Write('Quantidade de impressoras termicas: ');
    ReadLn(QuantidadeImpressoras);

    Write('Modelos das impressoras: ');
    ReadLn(ModelosImpressoras);
  end
  else
  begin
    QuantidadeImpressoras := 0;
    ModelosImpressoras := '';
  end;


  WriteLn;
  WriteLn('========================================');
  WriteLn('       DETECCAO AUTOMATICA');
  WriteLn('========================================');
  WriteLn;

  WriteLn('Coletando informacoes deste computador...');
  WriteLn;


  FabricantePC := DetectarFabricantePC;
  ModeloPC := DetectarModeloPC;

  Processador := DetectarProcessador;
  NucleosCPU := DetectarNucleosCPU;
  ThreadsCPU := DetectarThreadsCPU;

  MemoriaRAM := DetectarMemoriaRAM;

  Armazenamento := DetectarArmazenamento;

  SistemaOperacional := DetectarSistemaOperacional;
  ArquiteturaSO := DetectarArquiteturaSO;


  WriteLn('========================================');
  WriteLn('          DADOS COLETADOS');
  WriteLn('========================================');
  WriteLn;

  WriteLn('ESTRUTURA DA EMPRESA');
  WriteLn('Computadores: ', TotalComputadores);
  WriteLn('Caixas: ', TotalCaixas);
  WriteLn('Retaguardas: ', TotalRetaguardas);

  WriteLn;

  if EhServidor then
    WriteLn('Funcao deste computador: SERVIDOR')
  else
    WriteLn('Funcao deste computador: ESTACAO');


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
  WriteLn;
  WriteLn('Pressione ENTER para sair.');
  ReadLn;
end.
