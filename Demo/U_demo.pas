unit U_demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SMSModule;

type
  Tfrm_demo = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    edt_port: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    cmb_baudrate: TComboBox;
    Button1: TButton;
    lbl_status: TLabel;
    mem_pesan: TMemo;
    edt_nomor: TEdit;
    Button2: TButton;
    Memo1: TMemo;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    img_no_signal: TImage;
    SMS: TSMSModule;
    Timer1: TTimer;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lbl_brand: TLabel;
    lbl_model: TLabel;
    lbl_versi: TLabel;
    Label7: TLabel;
    lbl_opr: TLabel;
    Memo2: TMemo;
    Label8: TLabel;
    btn_pulsa: TButton;
    edt_pulsa: TEdit;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_pulsaClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SMSNewMessage(Sender: TObject; Isi, Pengirim,
      Tanggal: String);
  private
    { Private declarations }
    StillCheck:boolean;
    hit:integer;
    smsc:string;
    procedure ConnectModem(Port, BaudRate:string; TipeModem:TModemType);
    procedure SendSMS(smsc, Tujuan, Msg: string);
  public
    { Public declarations }
  end;

var
  frm_demo: Tfrm_demo;

implementation

{$R *.dfm}

procedure Tfrm_demo.Timer1Timer(Sender: TObject);
var signal:integer;
  procedure GetBack;
  begin
    Shape1.Brush.Color:=clWhite;
    Shape2.Brush.Color:=clWhite;
    Shape3.Brush.Color:=clWhite;
    Shape4.Brush.Color:=clWhite;
    Shape5.Brush.Color:=clWhite;
  end;
begin
  if StillCheck=False then
  begin
    StillCheck:=True;
    if SMS.Connected=True then
      hit:=hit+1;
    if SMS.ModemType=mtGsm then
      SMS.CheckSMS
    else
      SMS.CheckSMSCDMA;
    if (hit=60) AND (SMS.Connected=True) then
    begin
      signal:=SMS.GetSignal;
      //ShowMessage(IntToStr(signal));
      GetBack;
      if (signal>=-113) AND (signal<-107) then
      begin
        Shape1.Brush.Color:=clRed;
        img_no_signal.Visible:=False;
      end else if (signal>=-107) AND (signal<-104) then
      begin
        Shape1.Brush.Color:=$000080FF;
        Shape2.Brush.Color:=$000080FF;
        img_no_signal.Visible:=False;
      end else if (signal>=-104) AND (signal<-100) then
      begin
        Shape1.Brush.Color:=clYellow;
        Shape2.Brush.Color:=clYellow;
        Shape3.Brush.Color:=clYellow;
        img_no_signal.Visible:=False;
      end else if (signal>=-100) AND (signal<-91) then
      begin
        Shape1.Brush.Color:=clMoneyGreen;
        Shape2.Brush.Color:=clMoneyGreen;
        Shape3.Brush.Color:=clMoneyGreen;
        Shape4.Brush.Color:=clMoneyGreen;
        img_no_signal.Visible:=False;
      end else if (signal>=-91) AND (signal<-51) then
      begin
        Shape1.Brush.Color:=clGreen;
        Shape2.Brush.Color:=clGreen;
        Shape3.Brush.Color:=clGreen;
        Shape4.Brush.Color:=clGreen;
        Shape5.Brush.Color:=clGreen;
        img_no_signal.Visible:=False;
      end;
      hit:=0;
    end;
    StillCheck:=False;
  end;
end;

procedure Tfrm_demo.ConnectModem(Port, BaudRate: string;
  TipeModem: TModemType);
begin
  SMS.ComPort:=Port;
  SMS.BaudRate:=BaudRate;
  SMS.Mode:=smPDU;
  SMS.ModemType:=TipeModem;
  SMS.Connect;
end;

procedure Tfrm_demo.Button1Click(Sender: TObject);
begin
  if SMS.Connected=False then
  begin
    Button1.Caption:='Connecting ...';
    Button1.Enabled:=False;
    try
      if RadioButton1.Checked then
      begin
        ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtGSM);
        if SMS.Connected=False then ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtGSM);
      end else if RadioButton2.Checked then
      begin
        ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtCDMA);
        if SMS.Connected=False then ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtCDMA);
      end else
      begin
        ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtGSM);
        if SMS.Connected=False then ConnectModem('COM'+edt_port.Text,cmb_baudrate.Text,mtGSM);
      end;
      Memo2.Lines.Add(SMS.BufferOut);
      if SMS.Connected=True then
      begin
        try
          Button1.Caption:='Disconnect';
          Button1.Enabled:=True;
          lbl_status.Font.Color:=clGreen;
          lbl_status.Caption:=wraptext('Terkoneksi dengan port: COM'+edt_port.Text);
          if SMS.ModemType=mtGSM then
          begin
            if SMS.Mode=smPDU then
              SMS.SendGetData('AT+CMGF=0'#13, 'OK', False)
            else
              SMS.SendGetData('AT+CMGF=1'#13, 'OK', False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+CNMI=3,1,0,2,0'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+CSCS="GSM"'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+COPS=0'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+COPS=3,0'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+CMEE=1'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+CPMS="MT","ME","MT"'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            btn_pulsa.Enabled:=SMS.USSDCompatible;
            Memo2.Lines.Add(SMS.BufferOut);
            smsc:=SMS.GetSMSC;
            if pos('+CSCA',smsc)>0 then
              smsc:=copy(smsc,1,pos('+CSCA',smsc)-1);
            while pos('AT',smsc)>0 do
              smsc:=SMS.GetSMSC;
          end else
          begin
            btn_pulsa.Enabled:=SMS.USSDCompatible;
            SMS.SendGetData('AT+CSCS="CDMA"'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
            SMS.SendGetData('AT+CNMI=2,1,0,0,0'#13, sOK, False);
            Memo2.Lines.Add(SMS.BufferOut);
          end;
          lbl_brand.Caption:=SMS.GetModemBrand;
          Memo2.Lines.Add(SMS.BufferOut);
          lbl_model.Caption:=SMS.GetModemModel;
          Memo2.Lines.Add(SMS.BufferOut);
          lbl_versi.Caption:=SMS.GetModemVersion;
          Memo2.Lines.Add(SMS.BufferOut);
          lbl_opr.Caption:=SMS.GetModemOperator;
          Memo2.Lines.Add(SMS.BufferOut);
          Timer1.Enabled:=True;
        except

        end;
      end else
      begin
        Button1.Caption:='Connect';
        lbl_status.Font.Color:=clRed;
        lbl_status.Caption:='Gagal terkoneksi'+#13+'silahkan tekan tombol Connect untuk mengkoneksikan';
        lbl_brand.Caption:='-';
        lbl_model.Caption:='-';
        lbl_versi.Caption:='-';
        lbl_opr.Caption:='-';
      end;
    except
      SMS.Disconnect;
      MessageDlg('Port modem tidak terdeteksi !',mtError,[mbOk],0);
      Button1.Caption:='Connect';
      Button1.Enabled:=True;
      lbl_status.Font.Color:=clRed;
      lbl_status.Caption:='Modem belum terkoneksi'+#13+'silahkan tekan tombol Connect untuk mengkoneksikan';
      lbl_brand.Caption:='-';
      lbl_model.Caption:='-';
      lbl_versi.Caption:='-';
      lbl_opr.Caption:='-';
      Exit;
    end;
  end else
  begin
    try
      SMS.Disconnect;
      Button1.Caption:='Connect';
      lbl_status.Font.Color:=clRed;
      lbl_status.Caption:='Modem belum terkoneksi'+#13+'silahkan tekan tombol Connect untuk mengkoneksikan';
      lbl_brand.Caption:='-';
      lbl_model.Caption:='-';
      lbl_versi.Caption:='-';
      lbl_opr.Caption:='-';
      Exit;
    except

    end;
  end;
end;

procedure Tfrm_demo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SMS.TerminateProcess;
  Action:=caFree;
end;

procedure Tfrm_demo.btn_pulsaClick(Sender: TObject);
var Pulsa:string;
begin
  if trim(edt_pulsa.Text)='' then
  begin
    MessageDlg('Nomor dial harus diisi',mtError,[mbOk],0);
    edt_pulsa.SetFocus;
    Exit;
  end;
  if SMS.Connected then
  begin
    Timer1.Enabled:=False;
    btn_pulsa.Caption:='Checking ...';
    btn_pulsa.Enabled:=False;
    Pulsa:=SMS.CekPulsa(edt_pulsa.Text);
    Memo2.Lines.Add(SMS.BufferOut);
    btn_pulsa.Enabled:=True;
    btn_pulsa.Caption:='Cek Pulsa';
    if length(trim(Pulsa))=0 then
    begin
      MessageDlg('Request cek pulsa gagal',mtError,[mbOK],0);
    end else if (trim(Pulsa)<>'Timeout') OR (trim(Pulsa)<>'-') then
    begin
      MessageDlg(copy(Pulsa,1,length(pulsa) div 2)+#13+copy(Pulsa,(length(pulsa) div 2)+1,length(pulsa)),mtInformation,[mbOk],0);
    end else if trim(Pulsa)='Timeout' then
    begin
      MessageDlg('Timeout, modem tidak merespon',mtError,[mbOk],0);
    end else
    begin
      MessageDlg('Request cek pulsa gagal',mtError,[mbOK],0);
    end;
    Timer1.Enabled:=True;
  end else MessageDlg('Modem belum terkoneksi',mtError,[mbOk],0);
end;

procedure Tfrm_demo.SendSMS(smsc, Tujuan, Msg: string);
begin
  if RadioButton1.Checked then
  begin
    if SMS.Connected=True then
    begin
      if SMS.SendSMS(smsc,Tujuan,Msg) then
      begin
        Memo2.Lines.Add(SMS.BufferOut);
        MessageDlg('Message sent ',mtInformation,[mbOK],0);
      end else
      begin
        Memo2.Lines.Add(SMS.BufferOut);
        MessageDlg('Message not sent ',mtInformation,[mbOK],0);
      end;
    end else MessageDlg('Modem tidak terkoneksi ',mtError,[mbOK],0);
  end else
  begin
    if SMS.Connected=True then
    begin
      if SMS.SendSMSText(Tujuan,Msg) then
      begin
        Memo2.Lines.Add(SMS.BufferOut);
        MessageDlg('Message sent ',mtInformation,[mbOK],0);
      end else
      begin
        Memo2.Lines.Add(SMS.BufferOut);
        MessageDlg('Message not sent ',mtInformation,[mbOK],0);
      end;
    end;
  end;
end;

procedure Tfrm_demo.Button2Click(Sender: TObject);
begin
  Timer1.Enabled:=False;
  Button2.Caption:='Sending ... ';
  SendSMS(smsc,edt_nomor.Text,mem_pesan.Lines.Text);
  Button2.Caption:='Send';
  Timer1.Enabled:=True;
end;

procedure Tfrm_demo.SMSNewMessage(Sender: TObject; Isi, Pengirim,
  Tanggal: String);
var nomor:string;
begin
  if (pos('+',Pengirim)>0) then
    nomor:='0'+copy(Pengirim,4,length(Pengirim))
  else if (pos('62',copy(Pengirim,1,4))>0) then
    nomor:='0'+copy(Pengirim,3,length(Pengirim))
  else
    nomor:=Pengirim;
  Memo1.Lines.Add('Pesan baru dari : '+nomor);
  Memo1.Lines.Add(Tanggal);
  Memo1.Lines.Add(Isi);
end;

end.
