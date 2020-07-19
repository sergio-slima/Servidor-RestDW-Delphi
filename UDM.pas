unit UDM;

interface

uses
  System.SysUtils, System.Classes, uDWDataModule, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, uRESTDWPoolerDB, uRestDWDriverFD, uDWAbout,
  uRESTDWServerEvents, uDWJSONObject, UUsuario, System.JSON, FMX.Graphics,
  Soap.EncdDecd, UItem;

type
  TDM = class(TServerMethodDataModule)
    Conn: TFDConnection;
    RESTDWPoolerDB: TRESTDWPoolerDB;
    RESTDWDriverFD: TRESTDWDriverFD;
    dwEvents: TDWServerEvents;
    procedure dwEventsEventshoraReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwEventsEventsValidaLoginReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure dwEventsEventsItemFotoReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses System.IniFiles, FMX.Dialogs, uMD5;

function LoadConfig(): string;
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
//  TMemoryStream;  TBytesStream   TStringStream
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
