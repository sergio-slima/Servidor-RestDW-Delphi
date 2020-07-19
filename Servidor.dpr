program Servidor;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {FormServidor},
  UDM in 'UDM.pas' {DM: TDataModule},
  UUsuario in 'UUsuario.pas',
  UItem in 'UItem.pas',
  uMD5 in 'uMD5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormServidor, FormServidor);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
