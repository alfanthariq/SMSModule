object frm_demo: Tfrm_demo
  Left = 305
  Top = 254
  Width = 574
  Height = 438
  Caption = 'Demo'
  Color = clWindow
  Ctl3D = False
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 14
  object Label3: TLabel
    Left = 357
    Top = 19
    Width = 72
    Height = 14
    Caption = 'Modem Detail : '
    Transparent = True
  end
  object Label4: TLabel
    Left = 368
    Top = 40
    Width = 38
    Height = 14
    Alignment = taRightJustify
    Caption = 'Brand : '
    Transparent = True
  end
  object Label5: TLabel
    Left = 369
    Top = 59
    Width = 37
    Height = 14
    Alignment = taRightJustify
    Caption = 'Model : '
    Transparent = True
  end
  object Label6: TLabel
    Left = 372
    Top = 78
    Width = 34
    Height = 14
    Alignment = taRightJustify
    Caption = 'Versi : '
    Transparent = True
  end
  object lbl_brand: TLabel
    Left = 415
    Top = 40
    Width = 4
    Height = 14
    Caption = '-'
    Transparent = True
  end
  object lbl_model: TLabel
    Left = 415
    Top = 59
    Width = 4
    Height = 14
    Caption = '-'
    Transparent = True
  end
  object lbl_versi: TLabel
    Left = 415
    Top = 78
    Width = 4
    Height = 14
    Caption = '-'
    Transparent = True
  end
  object Label7: TLabel
    Left = 354
    Top = 97
    Width = 52
    Height = 14
    Alignment = taRightJustify
    Caption = 'Operator : '
    Transparent = True
  end
  object lbl_opr: TLabel
    Left = 415
    Top = 97
    Width = 4
    Height = 14
    Caption = '-'
    Transparent = True
  end
  object Label8: TLabel
    Left = 12
    Top = 282
    Width = 18
    Height = 14
    Caption = 'Log'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 118
    Caption = ' Modem Setup '
    TabOrder = 0
    object Label1: TLabel
      Left = 144
      Top = 25
      Width = 28
      Height = 14
      Alignment = taRightJustify
      Caption = 'Port : '
    end
    object Label2: TLabel
      Left = 120
      Top = 51
      Width = 53
      Height = 14
      Alignment = taRightJustify
      Caption = 'Baudrate : '
    end
    object lbl_status: TLabel
      Left = 11
      Top = 98
      Width = 31
      Height = 14
      Caption = 'Status'
    end
    object Shape1: TShape
      Left = 12
      Top = 84
      Width = 5
      Height = 10
    end
    object Shape2: TShape
      Left = 18
      Top = 81
      Width = 5
      Height = 13
    end
    object Shape3: TShape
      Left = 24
      Top = 78
      Width = 5
      Height = 16
    end
    object Shape4: TShape
      Left = 30
      Top = 75
      Width = 5
      Height = 19
    end
    object Shape5: TShape
      Left = 36
      Top = 72
      Width = 5
      Height = 22
    end
    object img_no_signal: TImage
      Left = 23
      Top = 74
      Width = 21
      Height = 20
      Picture.Data = {
        07544269746D6170E6040000424DE60400000000000036000000280000001400
        0000140000000100180000000000B0040000130B0000130B0000000000000000
        0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFE4E5F1B4B8E3D6D6E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        F2F2F798A0ED8B9FFF5E6CE0E7E7EDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFE8E8F3FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFD4D5F476
        81FF576CFF2641FCB6B9E1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFC0C1F47C7FE2FEFEFEFFFFFFFFFFFFFFFFFFFFFFFFD1D2F7444BFE2030
        FF091EFFADB1E0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFBFC3F
        48EF979AEAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1F1FB3539F7060EFF0411FF
        5F66DAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8C92F2212FEEEBEC
        F4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9898F50102FF0208FF060FF5A6
        A7D8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCACDF20A20F78C93EAFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFD5657F60101FF0206FF2024E7DCDC
        E5FFFFFFFFFFFFFFFFFFE3E4F12B41F32E43F1F3F3F5FFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFFA3D3EF70000FF0104FF4C4EDAF7F7F7
        FFFFFFEAEBF34254EF0C2DFFB7BBE8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFE7E7F93E3EF70000FF0001FF7B7BD9DBDCEB41
        49F0081DFF6C76E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFEEEEFA4F50F70001FF0405F6191AEC0209FF343B
        F0EDEDF2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFCFCFC393AEF0102FF0000FF0D0FF2CACAE4FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFE3E3F46A70ED1118F80208FF0103FF0101F87D7ED9FCFCFCFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F6F69FA6EC
        2C40F3091EFF0617FF131BF58586F12C2DFC090BFF6767DBF1F1F1FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFCC4C6EA7F8AEC4761FF2747FF12
        30FF192AF5B5B8F0FFFFFFE7E8FA6163F82527FF5D5EE2D6D6E5FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFAFAFDBCBEEDA7B0FF8F9FFF6E84FF4A66FF4258F3C7C9
        F1FFFFFFFFFFFFFFFFFFFFFFFFADADF85254FB5758E7ABACDFF8F8F8FFFFFFFF
        FFFFFFFFFFFBFBFECBCDF8C8CEFFAFB9FF8591F899A1F2EDEDF8FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFECECFAA6A6FA797CF08484DEC3C3E1FAFAFAFFFF
        FFFFFFFFFCFCFDDFDFF6D2D4F4E1E1F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFEEEEFBCBCBF9B1B1EAF0F0F7FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Transparent = True
    end
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 83
      Height = 17
      Caption = 'GSM'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 42
      Width = 83
      Height = 17
      Caption = 'CDMA'
      TabOrder = 1
    end
    object edt_port: TEdit
      Left = 184
      Top = 22
      Width = 49
      Height = 20
      TabOrder = 2
    end
    object cmb_baudrate: TComboBox
      Left = 184
      Top = 47
      Width = 130
      Height = 22
      BevelKind = bkFlat
      BevelOuter = bvRaised
      Style = csDropDownList
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ItemHeight = 14
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 3
      Items.Strings = (
        '110'
        '300'
        '600'
        '1200'
        '2400'
        '4800'
        '9600'
        '14400'
        '19200'
        '38400'
        '56000'
        '57600'
        '115200'
        '128000'
        '256000'
        '')
    end
    object Button1: TButton
      Left = 240
      Top = 80
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 4
      OnClick = Button1Click
    end
  end
  object mem_pesan: TMemo
    Left = 9
    Top = 160
    Width = 337
    Height = 89
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object edt_nomor: TEdit
    Left = 9
    Top = 135
    Width = 336
    Height = 20
    TabOrder = 2
  end
  object Button2: TButton
    Left = 271
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 352
    Top = 135
    Width = 201
    Height = 114
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object Memo2: TMemo
    Left = 9
    Top = 300
    Width = 544
    Height = 89
    TabOrder = 5
  end
  object btn_pulsa: TButton
    Left = 8
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Cek Pulsa'
    TabOrder = 6
    OnClick = btn_pulsaClick
  end
  object edt_pulsa: TEdit
    Left = 88
    Top = 259
    Width = 121
    Height = 20
    TabOrder = 7
  end
  object SMS: TSMSModule
    Mode = smText
    ModemType = mtGSM
    Author = 'M. Nafi` Alfanthariq'
    Version = '1.0'
    OnNewMessage = SMSNewMessage
    Left = 103
    Top = 255
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 136
    Top = 256
  end
end
