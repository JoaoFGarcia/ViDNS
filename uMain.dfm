object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'ViDNS'
  ClientHeight = 369
  ClientWidth = 224
  Color = clWhite
  Constraints.MaxHeight = 416
  Constraints.MaxWidth = 242
  Constraints.MinHeight = 416
  Constraints.MinWidth = 242
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMinimized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 100
    Height = 15
    Caption = 'X-Ovh-Application'
  end
  object Label2: TLabel
    Left = 8
    Top = 138
    Width = 94
    Height = 15
    Caption = 'X-Ovh-Consumer'
  end
  object Label3: TLabel
    Left = 8
    Top = 85
    Width = 71
    Height = 15
    Caption = 'X-Ovh-Secret'
  end
  object Label4: TLabel
    Left = 9
    Top = 218
    Width = 32
    Height = 15
    Caption = 'Name'
  end
  object Label5: TLabel
    Left = 8
    Top = 8
    Width = 208
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'KEYS'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 8
    Top = 199
    Width = 208
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'ZONE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object lblRID: TLabel
    Left = 10
    Top = 266
    Width = 54
    Height = 15
    Caption = 'Record ID:'
  end
  object lblIP: TLabel
    Left = 8
    Top = 316
    Width = 208
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtAK: TEdit
    Left = 8
    Top = 53
    Width = 209
    Height = 23
    TabOrder = 0
  end
  object edtCK: TEdit
    Left = 8
    Top = 159
    Width = 209
    Height = 23
    TabOrder = 2
  end
  object edtAS: TEdit
    Left = 8
    Top = 106
    Width = 209
    Height = 23
    TabOrder = 1
  end
  object spt: TPanel
    Left = 0
    Top = 188
    Width = 230
    Height = 5
    Caption = 'spt'
    ShowCaption = False
    TabOrder = 3
  end
  object edtZone: TEdit
    Left = 8
    Top = 239
    Width = 209
    Height = 23
    TabOrder = 4
  end
  object edtRecordID: TEdit
    Left = 8
    Top = 287
    Width = 209
    Height = 23
    TabOrder = 5
  end
  object btnSave: TButton
    Left = 8
    Top = 340
    Width = 208
    Height = 25
    Caption = 'Save'
    TabOrder = 6
    OnClick = btnSaveClick
  end
  object tray: TJvTrayIcon
    Active = True
    Animated = True
    IconIndex = 0
    Visibility = [tvVisibleTaskBar, tvVisibleTaskList, tvAutoHide, tvRestoreClick, tvMinimizeClick, tvAnimateToTray]
    Left = 120
    Top = 152
  end
  object appEvents: TApplicationEvents
    OnMinimize = appEventsMinimize
    Left = 120
    Top = 64
  end
end
