program Questionario;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms;

type
  TFormPrincipal = class(TForm)
  end;

var
  FormPrincipal: TFormPrincipal;

begin
  Application.Initialize;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
