program TestePowerShell;

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  Process;

var
  Processo: TProcess;
  Saida: TStringList;

begin
  Processo := TProcess.Create(nil);
  Saida := TStringList.Create;

  try
    WriteLn('1 - Criando processo...');

    Processo.Executable := 'powershell.exe';
    Processo.Parameters.Add('-NoProfile');
    Processo.Parameters.Add('-NonInteractive');
    Processo.Parameters.Add('-Command');
    Processo.Parameters.Add('Write-Output "TESTE-LOGICBOB"');

    Processo.Options := [poUsePipes, poWaitOnExit];

    WriteLn('2 - Antes de Execute...');
    Processo.Execute;
    WriteLn('3 - Depois de Execute.');

    Saida.LoadFromStream(Processo.Output);

    WriteLn('4 - Saida recebida:');
    WriteLn(Saida.Text);

  finally
    Saida.Free;
    Processo.Free;
  end;
end.
