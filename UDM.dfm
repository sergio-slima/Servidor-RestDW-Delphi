object DM: TDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esASCII
  Height = 368
  Width = 354
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\Infosys\BD.FDB'
      'User_Name=sysdba'
      'Password=senhasys'
      'Server=localhost'
      'DriverID=FB')
    LoginPrompt = False
    Left = 40
    Top = 8
  end
  object RESTDWPoolerDB: TRESTDWPoolerDB
    RESTDriver = RESTDWDriverFD
    Compression = True
    Encoding = esUtf8
    StrsTrim = False
    StrsEmpty2Null = False
    StrsTrim2Len = True
    Active = True
    PoolerOffMessage = 'RESTPooler not active.'
    ParamCreate = True
    Left = 40
    Top = 64
  end
  object RESTDWDriverFD: TRESTDWDriverFD
    CommitRecords = 100
    Connection = Conn
    Left = 40
    Top = 128
  end
  object dwEvents: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'hora'
        OnReplyEvent = dwEventsEventshoraReplyEvent
      end
      item
        Routes = [crGet]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'codigo'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'loja'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'senha'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'token'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ValidaLogin'
        OnReplyEvent = dwEventsEventsValidaLoginReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'codigo'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'loja'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'foto'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ItemFoto'
        OnReplyEvent = dwEventsEventsItemFotoReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'lote'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'loja'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'usuario'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'tipo'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'token'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'Lotes'
        OnReplyEvent = dwEventsEventsLotesReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'lote'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'loja'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'cod_barra'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'qtd'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'tipo'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'token'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ItensLotes'
        OnReplyEvent = dwEventsEventsItensLotesReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'loja'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'UltimoCodigo'
        OnReplyEvent = dwEventsEventsUltimoCodigoReplyEvent
      end>
    Left = 120
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 136
    Top = 304
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 264
    Top = 304
  end
  object FDQuery: TFDQuery
    Connection = Conn
    Left = 296
    Top = 32
  end
end
