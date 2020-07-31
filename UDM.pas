unit UDM;

interface

uses
  System.SysUtils, System.Classes, uDWDataModule, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, uRESTDWPoolerDB, uRestDWDriverFD, uDWAbout,
  uRESTDWServerEvents, uDWJSONObject, UUsuario, System.JSON, FMX.Graphics,
  Soap.EncdDecd, UItem, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDM = class(TServerMethodDataModule)
    Conn: TFDConnection;
    RESTDWPoolerDB: TRESTDWPoolerDB;
    RESTDWDriverFD: TRESTDWDriverFD;
    dwEvents: TDWServerEvents;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDQuery: TFDQuery;
    procedure dwEventsEventshoraReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwEventsEventsValidaLoginReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure dwEventsEventsItemFotoReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwEventsEventsItensLotesReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwEventsEventsLotesReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwEventsEventsUltimoCodigoReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
  public
    { Public declarations }
    Ultimo_Codigo : Integer;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses System.IniFiles, FMX.Dialogs, uMD5, UColeta, UUltimoCodigo, uDWConsts;

function LoadConfig(): string;      //Configuracao INI
var
  ArqINI, base: string;
  ini : TIniFile;
begin
  try
    ArqINI := System.SysUtils.GetCurrentDir + '\Servidor.ini';

    if not FileExists(ArqINI) then
    begin
      Result := 'Arquivo INI não encontrado: ' + ArqINI;
      exit;
    end;

    ini := TIniFile.Create(ArqINI);
    base := ini.ReadString('Banco de Dados', 'DataBase', '');
    DM.Conn.Params.Values['Database'] := base;

    try
      DM.Conn.Connected := True;
      Result := 'OK';
    except on ex:exception do
      Result := 'Erro na conexão: ' + ex.Message;
    end;

  finally
    ini.DisposeOf;
  end;
end;

function BitmapFromBase64(const base64: String): TBitmap;
var
  Input: TStringStream;
  Output: TBytesStream;
begin
  Input := TStringStream.Create(base64, TEncoding.ASCII);
  try
    Output := TBytesStream.Create;
    try
      Soap.EncdDecd.DecodeStream(Input, Output);
      Output.Position := 0;
      Result := TBitmap.Create;
      try
        Result.LoadFromStream(Output);
      except
        Result.Free;
        raise;
      end;
    finally
      Output.Free;
    end;
  finally
    Input.Free;
  end;
end;

procedure TDM.dwEventsEventshoraReplyEvent(var Params: TDWParams;
  var Result: string);
begin
  Result := '{"hora": "' + FormatDateTime('hh:mm:ss', now) + '"}';
end;

procedure TDM.dwEventsEventsItemFotoReplyEvent(var Params: TDWParams;
  var Result: string);
var
  codigo, loja, foto64, erro : string;
  foto_bmp : TBitmap;
  item : TItem;
  json : TJsonObject;
begin
  try
    //sleep(2000);
    codigo := Params.ItemsString['codigo'].AsString;
    loja := Params.ItemsString['loja'].AsString;
    foto64 := Params.ItemsString['foto'].AsString;

    json := TJsonObject.Create;

    // Validações
    if (codigo = '') or (loja = '') or (foto64 = '') then
    begin
      json.AddPair('sucesso', 'N');
      json.AddPair('erro', 'Informe todos os campos.');
      json.AddPair('usuario', '0');
      Result := json.ToString;
      Exit;
    end;

    // Criar foto bitmap..
    try
      foto_bmp := BitmapFromBase64(foto64);
    except on ex:exception do
    begin
      json.AddPair('sucesso', 'N');
      json.AddPair('erro', 'Erro ao criar img no servidor: '+ ex.Message);
      json.AddPair('usuario', '0');
      Result := json.ToString;
      Exit;
    end;
    end;

    try
      item := TItem.Create(DM.Conn);
      item.Codigo := codigo;
      item.Loja := loja;
      item.Foto := foto_bmp;

      if not item.ItemFoto(erro) then
      begin
        json.AddPair('sucesso', 'N');
        json.AddPair('erro', erro);
        json.AddPair('usuario', '0');
      end else
      begin
        json.AddPair('sucesso', 'S');
        json.AddPair('erro', '');
        json.AddPair('usuario', item.Item.ToString);
      end;
    finally
      foto_bmp.DisposeOf;
      item.DisposeOf;
    end;

    Result := json.ToString;
  finally
    json.DisposeOf;
  end;
end;

procedure TDM.dwEventsEventsItensLotesReplyEvent(var Params: TDWParams;
  var Result: string);
//var
//  cod_barra, loja, tipo, token: string;
//  lote, qtd: integer;
//  erro : string;
//  coleta : TColeta;
//  json : TJsonObject;
begin
//  try
//    lote := Params.ItemsString['lote'].AsInteger;
//    loja := Params.ItemsString['loja'].AsString;
//    cod_barra := Params.ItemsString['cod_barra'].AsString;
//    qtd := Params.ItemsString['qtd'].AsInteger;
//    tipo := Params.ItemsString['tipo'].AsString;
//    token := Params.ItemsString['token'].AsString;
//
//    json := TJsonObject.Create;
//
//    // Validações
//    if (cod_barra='') or (qtd=0) then
//    begin
//      json.AddPair('sucesso', 'N');
//      json.AddPair('erro', 'Informe todos os campos!');
//      json.AddPair('itens-coleta', '0');
//      Result := json.ToString;
//      Exit;
//    end;
//
//    try
//      coleta := TColeta.Create(DM.Conn);
//      coleta.Lote := lote;
//      coleta.Loja := loja;
//      coleta.Tipo := tipo;
//      coleta.Token := token;
//      coleta.Itens := itens_Coleta;
//
//      if not coleta.ItensColetas(erro) then
//      begin
//        json.AddPair('sucesso', 'N');
//        json.AddPair('erro', erro);
//        json.AddPair('itens-coleta', '0');
//      end else
//      begin
//        json.AddPair('sucesso', 'S');
//        json.AddPair('erro', '');
//        json.AddPair('itens-coleta', coleta.Cod_Coleta.ToString);
//      end;
//    finally
//      coleta.DisposeOf;
//    end;
//
//    Result := json.ToString;
//  finally
//    json.DisposeOf;
//  end;
end;

procedure TDM.dwEventsEventsLotesReplyEvent(var Params: TDWParams;
  var Result: string);
var
  loja, usuario, tipo, token: string;
  lote: integer;
  erro : string;
  coleta : TColeta;
  json : TJsonObject;
  ob, js: TJsonObject;
  ja: TJsonArray;
  pair: TJsonPair;
  itens: String;
  i: integer;
  ItensColeta : TArray<TColeta_Itens>;
  ItemColeta: TColeta_Itens;
  s: string;
begin
  try
    lote := Params.ItemsString['lote'].AsInteger;
    loja := Params.ItemsString['loja'].AsString;
    usuario := Params.ItemsString['usuario'].AsString;
    tipo := Params.ItemsString['tipo'].AsString;
    token := Params.ItemsString['token'].AsString;
    itens := Params.ItemsString['itens'].AsString;

    json := TJsonObject.Create;
    js := TJSONObject.ParseJSONValue(itens) as TJsonObject;
    ja := js.GetValue('itens') as TJSONArray;

    setLength(ItensColeta, ja.count);

    for i := 0 to ja.count-1 do
    begin
//      ob := TJsonObject.Create;
      try
        s := ja.Items[i].ToJSON;
        ob := ja.Items[i] as TJsonObject;

        ItemColeta := TColeta_Itens.Create;
        ItemColeta.CodBarra := ob.GetValue('cod_barra').Value;
        ItemColeta.qtd := ob.GetValue('qtd').Value.ToInteger;

        ItensColeta[i] := ItemColeta;
      finally
        ob.Free;
      end;
    end;


    // Validações
    if (loja='') or (usuario='') then
    begin
      json.AddPair('sucesso', 'N');
      json.AddPair('erro', 'Informe todos os campos!');
      json.AddPair('coleta', '0');
      Result := json.ToString;
      Exit;
    end;

    try
      coleta := TColeta.Create(DM.Conn);
      coleta.Lote := lote;
      coleta.Loja := loja;
      coleta.Usuario := usuario;
      coleta.Tipo := tipo;
      coleta.Token := token;
      coleta.itens := itenscoleta;

      if not coleta.Coletas(erro) then
      begin
        json.AddPair('sucesso', 'N');
        json.AddPair('erro', erro);
        json.AddPair('coleta', '0');
      end else
      begin
        json.AddPair('sucesso', 'S');
        json.AddPair('erro', '');
        json.AddPair('coleta', coleta.Cod_Coleta.ToString);
      end;
    finally
      coleta.DisposeOf;
    end;

    Result := json.ToString;
  finally
    json.DisposeOf;
  end;
end;

procedure TDM.dwEventsEventsUltimoCodigoReplyEvent(var Params: TDWParams;
  var Result: string);
var
  jsondw : uDWJSONObject.TJSONValue;
  json : TJSONObject;
  erro, loja : String;
  ultimo : TUltimoCodigo;
begin
  try
    loja := Params.ItemsString['loja'].AsString;

    json := TJsonObject.Create;

    ultimo := TUltimoCodigo.Create(DM.Conn);
    ultimo.Loja := loja;

    if not ultimo.UltimoCodigo(erro) then
    begin
      json.AddPair('sucesso', 'N');
      json.AddPair('erro', erro);
      json.AddPair('ultimo', '0');
    end else
    begin
      json.AddPair('sucesso', 'S');
      json.AddPair('erro', '');
      json.AddPair('ultimo', ultimo.Ultimo_Codigo.ToString);

      with DM.FDQuery do
      begin
        Active := False;
        Sql.Clear;
        Sql.Add('SELECT CODIGO FROM CODIGOS');
        Sql.Add('Where LOJA = :LOJA AND TABELA = :TABELA');
        ParamByName('LOJA').Value := loja;
        ParamByName('TABELA').Value := 'APP_COLETAS';
        Active := True;
      end;

      try
        jsondw := uDWJSONObject.TJSONValue.Create;
        jsondw.LoadFromDataset('',DM.FDQuery, false, jmPureJSON);

        Result := jsondw.ToJSON;
      finally
        jsondw.DisposeOf;
      end;
    end;
  finally
    ultimo.DisposeOf;
  end;
end;

procedure TDM.dwEventsEventsValidaLoginReplyEvent(var Params: TDWParams;
  var Result: string);
var
  loja, codigo, senha, token : string;
  erro : string;
  usuario : TUsuario;
  json : TJsonObject;
begin
  try
    //sleep(3000);
    loja := Params.ItemsString['loja'].AsString;
    codigo := Params.ItemsString['codigo'].AsString;
    senha := encripta(Params.ItemsString['senha'].AsString);
    token := Params.ItemsString['token'].AsString;

    json := TJsonObject.Create;

    usuario := TUsuario.Create(DM.Conn);
    usuario.Loja := loja;
    usuario.Codigo := codigo;
    usuario.Senha := senha;
    usuario.Token := token;

    if not usuario.ValidaLogin(erro) then
    begin
      json.AddPair('sucesso', 'N');
      json.AddPair('erro', erro);
      json.AddPair('usuario', '0');
    end else
    begin
      json.AddPair('sucesso', 'S');
      json.AddPair('erro', '');
      json.AddPair('usuario', usuario.Usuario.ToString);
    end;

    Result := json.ToString;
  finally
    json.DisposeOf;
    usuario.DisposeOf;
  end;

end;

procedure TDM.ServerMethodDataModuleCreate(Sender: TObject);
var
  retorno : string;
begin
  retorno := LoadConfig;

  if retorno <> 'OK' then
    ShowMessage(retorno);
end;

end.
