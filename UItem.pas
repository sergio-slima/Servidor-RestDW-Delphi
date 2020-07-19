unit UItem;

interface

uses Firedac.Comp.Client, System.SysUtils, Firedac.DApt, FMX.Graphics;

type
  TItem = class
  private
    FConn : TFDConnection;
    FItem: Integer;
    FLoja: String;
    FCodigo: String;
    FFoto: TBitmap;
  public
    constructor Create(conn: TFDConnection);
    property Item : Integer read FItem write FItem;
    property Codigo : String read FCodigo write FCodigo;
    property Loja : String read FLoja write FLoja;
    property Foto : TBitmap read FFoto write FFoto;
    function ItemFoto(out erro : string) : Boolean;
  end;

implementation

{ TItem }

constructor TItem.Create(conn: TFDConnection);
begin
  FConn := conn;
end;

function TItem.ItemFoto(out erro: string): Boolean;
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
      Sql.Add('Insert into ITENS_ARQUIVOS (item, loja, tipo, indice, arquivo)');
      Sql.Add('Values (:Codigo, :Loja, :Tipo, :Indice, :Foto)');
      ParamByName('Codigo').Value := Codigo;
      ParamByName('Loja').Value := Loja;
      ParamByName('Tipo').Value := 0;
      ParamByName('Indice').Value := 0;
      ParamByName('Foto').Assign(Foto);
      ExecSQL;

      Active := False;
      SQL.Clear;
      SQL.Add('Select * from Itens where codigo = :codigo');
      ParamByName('Codigo').Value := Codigo;
      Active := True;

      Item := FieldByName('Codigo').AsInteger;
      erro := '';
      Result := True;

      DisposeOf;
    end;
  except on ex:exception do
  begin
    erro := 'Erro ao enviar foto: ' + ex.Message;
    Result := False;
  end;
  end;
end;

end.
