unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, uDWAbout, uRESTDWBase;

type
  TFormServidor = class(TForm)
    Label1: TLabel;
    swAtivo: TSwitch;
    RESTServicePooler: TRESTServicePooler;
    procedure FormCreate(Sender: TObject);
    procedure swAtivoSwitch(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormServidor: TFormServidor;

implementation

{$R *.fmx}

uses UDM;

procedure TFormServidor.FormCreate(Sender: TObject);
begin
  RESTServicePooler.ServerMethodClass := TDM;
  RESTServicePooler.Active := swAtivo.IsChecked;
end;

procedure TFormServidor.FormShow(Sender: TObject);
begin
  DM.Conn.Connected := True;
end;

procedure TFormServidor.swAtivoSwitch(Sender: TObject);
begin
  RESTServicePooler.Active := swAtivo.IsChecked;
end;

end.
