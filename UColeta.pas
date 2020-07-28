unit UColeta;

interface

uses Firedac.Comp.Client, System.SysUtils, Firedac.DApt;

type
  TColeta_Itens = class
    FCodBarra : String;
    FQtd : Integer;
  private
  public
    property CodBarra : String read FCodBarra write FCodBarra;
    property Qtd : Integer read FQtd write FQtd;
  end;

  TColeta = class
  private
    FConn : TFDConnection;
    FCod_Coleta : Integer;
    FLoja : String;
    FUsuario : String;
    FLote : Integer;
    FTipo : String;
    FToken : String;
    FItens: TArray<TColeta_itens>;
  public
    constructor Create(conn: TFDConnection);
    property Cod_Coleta : Integer read FCod_Coleta write FCod_Coleta;
    property Lote : Integer read FLote write FLote;
    property Loja : String read FLoja write FLoja;
    property Usuario : String read FUsuario write FUsuario;
    property Tipo : String read FTipo write FTipo;
    property Itens : TArray<TColeta_itens> read FItens write FItens;
    property Token : String read FToken write FToken;
    function Coletas(out erro : string) : Boolean;
//    function ItensColetas(out erro : string) : Boolean;
    function Zeros(vZero: string; vQtd: integer): string;
  end;

implementation

{ TColeta }

function TColeta.Zeros(vZero: string; vQtd: integer): string;
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

constructor TColeta.Create(conn: TFDConnection);
begin
  FConn := conn;
end;

function TColeta.Coletas(out erro: string): Boolean;
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
        Cod_Coleta := 1;
      end else
        Cod_Coleta := FieldByName('CODIGO').AsInteger + 1;

      //Inserindo registro de transferencia
      Active := False;
      Sql.Clear;
      Sql.Add('INSERT INTO APP_COLETAS (CODIGO,LOJA,LOTE,USUARIO,DATA,STATUS,TIPO,TOKEN)');
      Sql.Add('VALUES (:CODIGO,:LOJA,:LOTE,:USUARIO,:DATA,:STATUS,:TIPO,:TOKEN)');
      ParamByName('CODIGO').Value := Zeros(IntToStr(Cod_Coleta),6);
      ParamByName('LOJA').Value := Loja;
      ParamByName('LOTE').Value := Lote;
      ParamByName('USUARIO').Value := Usuario;
      ParamByName('DATA').Value := Date;
      ParamByName('STATUS').Value := 'N';
      ParamByName('TIPO').Value := Tipo;
      ParamByName('TOKEN').Value := Token;
      ExecSQL;

      // Inserindo Itens da Transferencia
      Active := False;
      for i := low(FItens) to high(fItens) do
      begin
        Sql.Clear;
        Sql.Add('INSERT INTO APP_ITENS_COLETAS (COLETA,LOJA,COD_BARRA,QTD_SAIDA)');
        Sql.Add('VALUES (:COLETA,:LOJA,:COD_BARRA,:QTD_SAIDA)');
        ParamByName('COLETA').Value := Zeros(IntToStr(Cod_Coleta),6);
        ParamByName('LOJA').Value := Loja;
        ParamByName('COD_BARRA').Value := FItens[i].CodBarra;
        ParamByName('QTD_SAIDA').Value := FItens[i].Qtd;
        ExecSQL;
      end;

      erro := '';
      Result := True;

      // Atualizando ultimo codigo
      Active := False;
      Sql.Clear;
      Sql.Add('UPDATE CODIGOS SET CODIGO = :CODIGO');
      Sql.Add('WHERE TABELA = :TABELA AND LOJA = :LOJA');
      ParamByName('CODIGO').Value := Cod_Coleta;
      ParamByName('TABELA').Value := 'APP_COLETAS';
      ParamByName('LOJA').Value := Loja;
      ExecSQL;

      DisposeOf;
    end;
  except on ex:exception do
  begin
    erro := 'Erro ao Gerar Coleta: ' + ex.Message;
    Result := False;
  end;
  end;
end;

//function TColeta.ItensColetas(out erro: string): Boolean;
//var
//  Qry : TFDQuery;
//  i: integer;
//begin
//  try
//    Qry := TFDQuery.Create(nil);
//    Qry.Connection := FConn;
//
//    with Qry do
//    begin
//      //Buscando codigo da coleta
//      Active := False;
//      Sql.Clear;
//      Sql.Add('SELECT CODIGO FROM APP_COLETAS');
//      Sql.Add('Where LOJA = :LOJA AND LOTE = :LOTE AND TIPO = :TIPO AND TOKEN = :TOKEN');
//      ParamByName('LOJA').Value := Loja;
//      ParamByName('LOTE').Value := Lote;
//      ParamByName('TIPO').Value := Tipo;
//      ParamByName('TOKEN').Value := Token;
//      Active := True;
//      Cod_Coleta := FieldByName('CODIGO').AsInteger;
//
//      // Inserindo Itens da Transferencia
//      Active := False;
//      for i := low(FItens) to high(fItens) do
//      begin
//        Sql.Clear;
//        Sql.Add('INSERT INTO APP_ITENS_COLETAS (COLETA,LOJA,COD_BARRA,QTD_SAIDA)');
//        Sql.Add('VALUES (:COLETA,:LOJA,:COD_BARRA,:QTD_SAIDA)');
//        ParamByName('COLETA').Value := Zeros(IntToStr(Cod_Coleta),6);
//        ParamByName('LOJA').Value := Loja;
//        ParamByName('COD_BARRA').Value := FItens[i].CodBarra;
//        ParamByName('QTD_SAIDA').Value := FItens[i].Qtd;
//        ExecSQL;
//      end;
//
//      erro := '';
//      Result := True;
//
//      DisposeOf;
//    end;
//  except on ex:exception do
//  begin
//    erro := 'Erro ao Gerar Itens da Coleta: ' + ex.Message;
//    Result := False;
//  end;
//  end;
//end;

end.
