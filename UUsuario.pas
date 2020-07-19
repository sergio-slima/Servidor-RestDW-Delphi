unit UUsuario;

interface

uses Firedac.Comp.Client, System.SysUtils, Firedac.DApt;

type
  TUsuario = class
  private
    FConn : TFDConnection;
    FUsuario: Integer;
    FLoja: String;
    FCodigo: String;
    FSenha: String;
    FToken: String;
  public
    constructor Create(conn: TFDConnection);
    property Usuario : Integer read FUsuario write FUsuario;
    property Loja : String read FLoja write FLoja;
    property Codigo : String read FCodigo write FCodigo;
    property Senha : String read FSenha write FSenha;
    property Token : String read FToken write FToken;
    function ValidaLogin(out erro : string) : Boolean;
  end;

implementation

{ TUsuario }

constructor TUsuario.Create(conn: TFDConnection);
begin
  FConn := conn;
end;

function TUsuario.ValidaLogin(out erro: string): Boolean;
var
  Qry : TFDQuery;
begin
  try
    Qry := TFDQuery.Create(nil);
    Qry.Connection := FConn;

    with Qry do
    begin
      Active := False;
      Sql.Clear;
      Sql.Add('Select * From Usuarios');
      Sql.Add('Where Loja=:Loja and Codigo=:Codigo and Senha=:Senha and Token=:Token');
      ParamByName('Loja').Value := Loja;
      ParamByName('Codigo').Value := Codigo;
      ParamByName('Senha').Value := Senha;
      ParamByName('Token').Value := Token;
      Active := True;

      if RecordCount > 0 then
      begin
        Usuario := FieldByName('CODIGO').AsInteger;
        erro := '';
        Result := True;
      end else
      begin
        Usuario := 0;
        erro := 'Senha inválida';
        Result := False;
      end;

      DisposeOf;
    end;
  except on ex:exception do
  begin
    erro := 'Erro ao Validar Login: ' + ex.Message;
    Result := False;
  end;
  end;
end;

end.
