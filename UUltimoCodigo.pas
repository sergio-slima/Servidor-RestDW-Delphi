unit UUltimoCodigo;

interface

uses Firedac.Comp.Client, System.SysUtils, Firedac.DApt;

type
  TUltimoCodigo = class
  private
    FConn : TFDConnection;
    FUltimo_Codigo : Integer;
    FTabela : String;
    FLoja : String;
    FCodigo : String;
    FTamanho : String;
    FDescricao : String;
  public
    constructor Create(conn: TFDConnection);
    property Ultimo_Codigo : Integer read FUltimo_Codigo write FUltimo_Codigo;
    property Tabela : String read FTabela write FTabela;
    property Loja : String read FLoja write FLoja;
    property Codigo : String read FCodigo write FCodigo;
    property Tamanho : String read FTamanho write FTamanho;
    property Descricao : String read FDescricao write FDescricao;
    function UltimoCodigo(out erro : string) : Boolean;
//    function ItensColetas(out erro : string) : Boolean;
    function Zeros(vZero: string; vQtd: integer): string;
  end;

implementation

{ TColeta }

function TUltimoCodigo.Zeros(vZero: string; vQtd: integer): string;
var
  i, vTam: integer;
  vAux: string;
begin
  vAux := vZero;
  vTam := length( vZero );
  vZero := '';
  for i := 1 to vQtd - vTam do
  vZero := '0' + vZero;
  vAux := vZero + vAux;
  result := vAux;
end;

constructor TUltimoCodigo.Create(conn: TFDConnection);
begin
  FConn := conn;
end;

function TUltimoCodigo.UltimoCodigo(out erro: string): Boolean;
var
  Qry : TFDQuery;
  i: integer;
begin
  try
    Qry := TFDQuery.Create(nil);
    Qry.Connection := FConn;

    with Qry do
    begin
      // Buscar ultimo codigo
      Active := False;
      Sql.Clear;
      Sql.Add('SELECT CODIGO FROM CODIGOS');
      Sql.Add('Where TABELA = :TABELA');
      ParamByName('TABELA').Value := 'APP_COLETAS';
      Active := True;
      if IsEmpty then
      begin
        // Criando registro tabela codigos
        Active := False;
        Sql.Clear;
        Sql.Add('INSERT INTO CODIGOS (TABELA,LOJA,CODIGO,TAMANHO,DESCRICAO)');
        Sql.Add('VALUES (:TABELA,:LOJA,:CODIGO,:TAMANHO,:DESCRICAO)');
        ParamByName('TABELA').Value := 'APP_COLETAS';
        ParamByName('LOJA').Value := Loja;
        ParamByName('CODIGO').Value := 1;
        ParamByName('TAMANHO').Value := 6;
        ParamByName('DESCRICAO').Value := 'App de Coletas';
        ExecSQL;
        Ultimo_Codigo := 1;
      end else
        Ultimo_Codigo := FieldByName('CODIGO').AsInteger + 1;

      erro := '';
      Result := True;

      // Atualizando ultimo codigo
      Active := False;
      Sql.Clear;
      Sql.Add('UPDATE CODIGOS SET CODIGO = :CODIGO');
      Sql.Add('WHERE TABELA = :TABELA AND LOJA = :LOJA');
      ParamByName('CODIGO').Value := Ultimo_Codigo;
      ParamByName('TABELA').Value := 'APP_COLETAS';
      ParamByName('LOJA').Value := Loja;
      ExecSQL;

      DisposeOf;
    end;
  except on ex:exception do
  begin
    erro := 'Erro ao Gerar Ultimo Codigo: ' + ex.Message;
    Result := False;
  end;
  end;
end;

end.
