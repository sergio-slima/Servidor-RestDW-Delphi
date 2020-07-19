object DM: TDM
  OldCreateOrder = False
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esASCII
  Height = 368
  Width = 336
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\Infosys\BD.FDB'
      'User_Name=sysdba'
      'Password=senhasys'
      'Server=localhost'
      'DriverID=FB')
    LoginPrompt = False
    Left = 40
    Top = 24
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
    Left = 128
    Top = 24
  end
  object RESTDWDriverFD: TRESTDWDriverFD
    CommitRecords = 100
    Connection = Conn
    Left = 128
    Top = 88
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
      end>
    Left = 128
    Top = 160
  end
end
