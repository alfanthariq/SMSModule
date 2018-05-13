unit SMSModule;

interface
Uses Classes, SysUtils, DateUtils, StrUtils, Forms, CPort;

type
  TModeOperation = (smText,smPDU);
  TModemType = (mtGSM,mtCDMA);
  TNewMsgEvent = procedure(Sender: TObject; Isi, Pengirim, Tanggal: string) of object;
  TGetMsgEvent = procedure(Sender: TObject; Isi, Pengirim, Tanggal: string; Index:integer) of object;
  TSMSModule = class(TComponent)
  private
    LComPort, LBaudRate, LAuthor, LVersion: string;
    MsgSent, Stop, ValidPort: boolean;
    LBufferOut : WideString;
    SModeOperation: TModeOperation;
    SModemType: TModemType;
    FOnNewMessage: TNewMsgEvent;
    FOnGetMessage: TGetMsgEvent;
    function PDU2Text(pdudata: string): string;
    procedure ConvertMSG(var datasms,smsc,tipe,pengirim,bentuk,skema,tanggal,batas,isi: string);
    procedure ConvertMSGEx(var datasms,pengirim,tanggal,isi: string);
    function text2PDU(text:string):string;
    function ConvertText(smsc,tipe,ref,tujuan,bentuk,skema,validitas,isi:string):string;
    procedure RxChar(Sender: TObject; Count: Integer);
    procedure SetupModem;
    function HexToString(H: string): WideString;
    function ReplaceStr(S: string) : String;
    procedure split(const Delimiter: Char; Input: string; const Strings: TStrings);
    procedure SetUtils(Value : String);
  public
    Connected : boolean;
    lkirim:integer;
    // SMSModule Component ===============================================================
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // SMSModule Utils ===================================================================
    function CekValidPort:boolean;
    function Connect: boolean;
    function Disconnect: boolean;
    function SendSMS(SMSC, Tujuan: string; Isi: WideString): boolean;
    function SendSMSText(Tujuan: string; Isi: WideString): boolean;
    function SendGetData(teks: string; tOK: string; Msg:Boolean): string;
    function CekPulsa(Nomor: string):string;
    function GetModemBrand:string;
    function GetModemModel:string;
    function GetModemVersion:string;
    function GetModemOperator:string;
    function GetSignal:integer;
    function GetSMSC:string;
    procedure CheckSMS;
    procedure CheckSMSCDMA;
    procedure GetAllSMS;
    procedure GetAllSMSCDMA;
    function USSDCompatible:boolean;
    procedure TerminateProcess;
    procedure DoNewMessage(Isi, Pengirim, Tanggal: string);
    procedure DoGetMessage(Isi, Pengirim, Tanggal: string; Index:integer);
  published
    // SMSModule Properties ============================================================
    property ComPort:String read LComPort write LComPort;
    property BaudRate:string read LBaudRate write LBaudRate;
    property BufferOut:WideString read LBufferOut write LBufferOut;
    property Mode:TModeOperation read SModeOperation write SModeOperation;
    property ModemType:TModemType read SModemType write SModemType;
    property Author:String read LAuthor write SetUtils;
    property Version:String read LVersion write SetUtils;

    // SMSModule Event =================================================================
    property OnNewMessage:TNewMsgEvent read FOnNewMessage write FOnNewMessage;
    property OnGetMessage:TGetMsgEvent read FOnGetMessage write FOnGetMessage;
  end;

const
  sOK = 'OK';
	sERROR = 'ERROR';

var
  comm : TComPort;
  Operator:string;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SMSModule',[TSMSModule]);
end;

{ TSMSModule }

function TSMSModule.CekValidPort:boolean;
var Str, buffer:string;
    waktu: tdatetime;
begin
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      LBufferOut:='';
      buffer:='';
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('ATE1'#13);
      comm.WriteStr(#26);
      buffer:=LBufferOut + Str;
    until (Pos('OK', buffer) > 0) or (Pos('ERROR', buffer) > 0)
              or (secondsbetween(waktu, now) > 20);
    Result:=(Pos('OK', buffer) > 0);
  end else
  begin
    repeat
      if Stop=True then Exit;
      LBufferOut:='';
      buffer:='';
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('ATE1'#13);
      comm.WriteStr(#26);
      buffer:=LBufferOut + Str;
    until (Pos('OK', buffer) > 0) or (Pos('ERROR', buffer) > 0)
              or (secondsbetween(waktu, now) > 20);
    Result:=(Pos('OK', buffer) > 0);
  end;
end;

function TSMSModule.CekPulsa(Nomor: string): string;
var waktu: tdatetime;
    buffer, tampung: string;
    a,b,c,d,e:integer;
begin
  LBufferOut := '';
  comm.Open;
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      Sleep(1000);
      Application.ProcessMessages;
      comm.WriteStr('AT+CUSD=1,'+Nomor+',15'+#13);
      comm.WriteStr(#26);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(1000);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      buffer := '';
      waktu := now;
      Application.ProcessMessages;
      repeat
        if Stop=True then Exit;
        Sleep(10000);
        Application.ProcessMessages;
        buffer := buffer + LBufferOut;
      until (Pos('+CUSD', buffer) > 0) or (secondsbetween(waktu, now) > 40);
      Sleep(7000);
      Application.ProcessMessages;
      if (Pos('+CUSD:', buffer) > 0) then
      begin
        tampung:=buffer;
        a:=Pos('+CUSD', tampung);
        b:=posex('"',tampung,a+1);
        c:=PosEx('"',tampung,b+1);
        d:=Pos('",', tampung);
        if trim(copy(tampung,d+2,2))='72' then
          Result:=HexToString(copy(tampung,b+1,c-b-1))
        else
          Result:=copy(tampung,b+1,c-b-1);
      end else if (secondsbetween(waktu, now) > 20) then
        Result:='Timeout'
      else Result:='-';
    end else Result:='-';
  end else
  begin
    repeat
      if Stop=True then Exit;
      Application.ProcessMessages;
      comm.WriteStr('AT+CUSD=1,'+Nomor+#13);
      comm.WriteStr(#26);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      buffer := '';
      LBufferOut := '';
      waktu := now;
      Application.ProcessMessages;
      repeat
        if Stop=True then Exit;
        Sleep(1000);
        Application.ProcessMessages;
        buffer := buffer + LBufferOut;
      until (Pos('+CUSD', buffer) > 0) or (secondsbetween(waktu, now) > 40);
      Sleep(1000);
      Application.ProcessMessages;
      if (Pos('+CUSD:', buffer) > 0) then
      begin
        tampung:=buffer;
        a:=Pos('+CUSD', tampung);
        b:=posex('"',tampung,a+1);
        c:=PosEx('"',tampung,b+1);
        Result:=copy(tampung,b+1,c-b-1);
      end else if (secondsbetween(waktu, now) > 20) then
        Result:='Timeout'
      else Result:='-';
    end else
    begin
      Result:='-';
    end;
  end;
end;

procedure TSMSModule.CheckSMSCDMA;
var
    pengirim, tanggal,isi,
    nama, TextQuery,
    s, status, index : string;
    waktu: TDateTime;
    a, b, c, d, e, i, max, brand : integer;
    back:boolean;
begin
  comm.Open;
  if (pos('HUAWEI',GetModemBrand)>0) OR (pos('China TeleCom',GetModemBrand)>0) then
    brand:=1
  else
    brand:=0;
  try
    a:=pos('+CMTI',LBufferOut);
    if a>0 then
    begin
      s:=LBufferOut;
      b:=posex(',',s,a);
      c:=posex(#13,s,b+1);
      index:=copy(s,b+1,c-b-1);
    end;
    s:='';
    if brand=1 then
      comm.WriteStr('AT+^HCMGR='+ index +#13)
    else
      comm.WriteStr('AT+CMGR='+ index +#13);
    waktu := now;
    repeat
      if Stop=True then Exit;
      Sleep(100);
      Application.ProcessMessages;
      s := LBufferOut;
    until (pos(sOK, s) > 0) or (pos(sERROR, s) > 0) or (SecondsBetween(waktu,now) > 30);
    if brand=1 then
      a:=pos('^HCMGR:',s)
    else
      a:=pos('+CMGR:',s);
    b:=posex('"',s,a);
    c:=posex('"',s,b+1);
    if copy(s, b+1, c-b-1)='REC READ' then
      status:='1'
    else if copy(s, b+1, c-b-1)='REC UNREAD' then
      status:='0'
    else
      status:='1';

    ConvertMSGEx(s,pengirim,tanggal,isi);
    if status='0' then
    begin
      DoNewMessage(isi,pengirim,tanggal);
    end;
    //DeleteFile(ExtractFilePath(Application.ExeName)+'temp.fin');
  except
  end;
end;

procedure TSMSModule.split(const Delimiter: Char; Input: string;
  const Strings: TStrings);
var
  i: integer;
  s: string;
begin
  Assert(Assigned(Strings)) ;
{
  Strings.Clear;
  Strings.Delimiter := Delimiter;
  Strings.DelimitedText := Input;
}
  s:='';
  for i:=1 to length(input) do
  begin
    if input[i]=delimiter then
    begin
      strings.Add(s);
      s:='';
    end else
    begin
      s:=s+input[i];
    end;
  end;
  strings.add(s);
end;


procedure TSMSModule.CheckSMS;
var
    smsc, tipe, pengirim, bentuk, skema, tanggal, batas,
    isi,
    nomer, nama, TextQuery,
    s, status : string;
    n : textfile;
    waktu: TDateTime;
    i : integer;
    back:boolean;
begin
  LBufferOut:='';
  comm.Open;
  try
    back:=False;
    if Mode<>smPDU then
    begin
      Mode:=smPDU;
      back:=True;
    end;
    assignfile(n,'temp2.fin');
    rewrite(n);
    //for i := 0 to 1 do begin
      comm.WriteStr('AT+CMGL=0'#13);
      waktu := now;
      repeat
        if Stop=True then Exit;
        Sleep(100);
        Application.ProcessMessages;
        s := LBufferOut;
        write(n, s);
      until (pos(sOK, s) > 0) or (pos(sERROR, s) > 0) or (SecondsBetween(waktu,now) > 30);
    //end;
    closefile(n);
    reset(n);
    readln(n, s);
    while (not eof(n)) do
    begin
      readln(n, s);
      if copy(s, 1, 7) = '+CMGL: ' then
      begin
         nomer := copy(s, 8, pos(',', s) - 8);
         status := copy(s, 10, posex(',', s,10) - 10);

         readln(n, s);
         ConvertMSG(s, smsc, tipe, pengirim, bentuk, skema, tanggal, batas, isi);
         if status='0' then
         begin
           DoNewMessage(isi,pengirim,tanggal);
         end;
      end;
    end;
    closefile(n);
    if back=True then
    begin
      Mode:=smText;
      back:=False;
    end;
    //DeleteFile(ExtractFilePath(Application.ExeName)+'temp.fin');
  except
  end;
end;

procedure TSMSModule.GetAllSMS;
var
    smsc, tipe, pengirim, bentuk, skema, tanggal, batas,
    isi,
    nomer, nama, TextQuery,
    s, status : string;
    n : textfile;
    waktu: TDateTime;
    i : integer;
    back:boolean;
begin
  LBufferOut:='';
  comm.Open;
  try
    back:=False;
    if Mode<>smPDU then
    begin
      Mode:=smPDU;
      back:=True;
    end;
    assignfile(n,'temp3.fin');
    rewrite(n);
    //for i := 0 to 1 do begin
      LBufferOut:='';
      comm.WriteStr('AT+CMGL=1'#13); // + IntToStr(i) +
      waktu := now;
      repeat
        if Stop=True then Exit;
        Sleep(100);
        Application.ProcessMessages;
        s := LBufferOut;
        write(n, s);
      until (pos(sOK, s) > 0) or (pos(sERROR, s) > 0) or (SecondsBetween(waktu,now) > 30);
    //end;
    closefile(n);
    reset(n);
    readln(n, s);
    while (not eof(n)) do
    begin
      readln(n, s);
      if copy(s, 1, 7) = '+CMGL: ' then
      begin
         nomer := copy(s, 8, pos(',', s) - 8);
         status := copy(s, 10, posex(',', s,10) - 10);

         readln(n, s);
         ConvertMSG(s, smsc, tipe, pengirim, bentuk, skema, tanggal, batas, isi);
         DoGetMessage(isi,pengirim,tanggal,StrToInt(nomer));
      end;
    end;
    closefile(n);
    if back=True then
    begin
      Mode:=smText;
      back:=False;
    end;
    //DeleteFile(ExtractFilePath(Application.ExeName)+'temp3.fin');
  except
  end;
end;

procedure TSMSModule.GetAllSMSCDMA;
var
    pengirim, tanggal,isi,
    nama, TextQuery,
    s, status : string;
    waktu: TDateTime;
    a, b, c, d, e, i, max, brand : integer;
    back:boolean;
begin
  LBufferOut:='';
  comm.Open;
  if (pos('HUAWEI',GetModemBrand)>0) OR (pos('China TeleCom',GetModemBrand)>0) then
    brand:=1
  else
    brand:=0;
  try
    comm.WriteStr('AT+CPMS?'#13);
    waktu := now;
    repeat
      if Stop=True then Exit;
      Sleep(100);
      Application.ProcessMessages;
      s := LBufferOut;
    until (pos(sOK, s) > 0) or (pos(sERROR, s) > 0) or (SecondsBetween(waktu,now) > 30);
    a:=pos('+CPMS:',s);
    b:=posex(',',s,a);
    c:=posex(',',s,b+1);
    d:=posex(',',s,c+1);
    max:=StrToInt(copy(s,c+1,d-c-1));
    for i:=0 to max do
    begin
      s:='';
      LBufferOut:='';
      if brand=1 then
        comm.WriteStr('AT^HCMGR='+ IntToStr(i) +#13)
      else
        comm.WriteStr('AT+CMGR='+ IntToStr(i) +#13);
      waktu := now;
      repeat
        if Stop=True then Exit;
        Sleep(100);
        Application.ProcessMessages;
        s := LBufferOut;
      until (pos(sOK, s) > 0) or (pos(sERROR, s) > 0) or (SecondsBetween(waktu,now) > 30);
      if (pos(sOK, s) > 0) then
      begin
        if brand=1 then
          a:=pos('^HCMGR:',s)
        else
          a:=pos('+CMGR:',s);
        b:=posex('"',s,a);
        c:=posex('"',s,b+1);
        if copy(s, b+1, c-b-1)='REC READ' then
          status:='1'
        else if copy(s, b+1, c-b-1)='REC UNREAD' then
          status:='0'
        else
          status:='0';

        ConvertMSGEx(s,pengirim,tanggal,isi);
        DoGetMessage(isi,pengirim,tanggal,i);
      end;
    end;
    //DeleteFile(ExtractFilePath(Application.ExeName)+'temp.fin');
  except
  end;
end;

function TSMSModule.Connect: boolean;
var waktu: tdatetime;
    buffer: string;
begin
  SetupModem;
  comm.Open;

  //Sleep(500);
  waktu := now;
  if ModemType=mtGSM then
  begin
    Connected := CekValidPort;
    Connect := Connected;
  end else
  begin
    Connected := CekValidPort;
    Connect := Connected;
  end;
  //if CekValidPort=False then
    //comm.Close;
end;

procedure TSMSModule.ConvertMSG(var datasms, smsc, tipe, pengirim, bentuk,
  skema, tanggal, batas, isi: string);
var pdu: string;
    p,i: integer;
begin
  pdu := datasms;
  smsc := '';
  p := StrToInt('$' + copy(pdu, 1, 2)) - 1;
  pdu := copy(pdu,5,length(pdu)-4);
  for i := 1 to p do begin
          smsc := smsc + pdu[i*2];
          smsc := smsc + pdu[i*2-1];
  end;
  if smsc[length(smsc)] = 'F' then
    smsc := copy(smsc, 1, length(smsc) - 1);
  pdu := copy(pdu, p*2+1,length(pdu)-p*2);

  tipe := copy(pdu, 1, 2);
  pdu := copy(pdu, 3, length(pdu)-2);

  pengirim := '';
  p := StrToInt('$'+copy(pdu,1,2));
  if p mod 2 = 1 then inc(p);
  pdu := copy(pdu,5,length(pdu)-4);
  for i := 1 to p div 2 do begin
          pengirim := pengirim + pdu[i*2];
          pengirim := pengirim + pdu[i*2-1];
  end;
  if pengirim[length(pengirim)] = 'F' then
          pengirim := copy(pengirim, 1, length(pengirim) - 1);

  pdu := copy(pdu,p+1,length(pdu)-p);

  bentuk := copy(pdu,1,2);
  pdu := copy(pdu, 3, length(pdu)-2);

  skema := copy(pdu,1,2);
  pdu := copy(pdu, 3, length(pdu)-2);

  tanggal := pdu[6]+pdu[5] + '-' + pdu[4]+pdu[3] + '-' +
             pdu[2]+pdu[1] + ' ' +
             pdu[8]+pdu[7] + ':' + pdu[10]+pdu[9] + ':' +
             pdu[12]+pdu[11];
  pdu := copy(pdu, 13, length(pdu)-12);
        
  batas := copy(pdu,1,2);
  pdu := copy(pdu, 3, length(pdu)-2);

  isi := PDU2Text(pdu);
end;

procedure TSMSModule.ConvertMSGEx(var datasms, pengirim, tanggal, isi: string);
var a,b,c,d,brand:integer;
    str,tgl,da,m,y,h,n,s:string;
    data:TStringList;
begin
  if (pos('HUAWEI',GetModemBrand)>0) then
    brand:=1
  else if (pos('China TeleCom',GetModemBrand)>0) then
    brand:=2
  else
    brand:=0;
  data:=TStringList.Create;
  if brand=1 then
  begin
    a:=pos('^HCMGR:',datasms)+7;
    b:=posex(#26,datasms,a+1);
    str:=copy(datasms, a, b-a-1);
  end else
  begin
    a:=pos('+CMGR:',datasms);
    b:=posex('"',datasms,a+1);
    c:=posex(#13,datasms,b+1); 
    str:=copy(datasms, b, c-b-1);
  end;
  split(',',str,data);
  if data.Count>0 then
  begin
    if brand=1 then
    begin
      pengirim:=data[0];
      y:=copy(data[1],3,2);
      m:=data[2];
      da:=data[3];
      h:=data[4];
      n:=data[5];
      s:=data[6];
    end else if brand=2 then
    begin
      pengirim:=copy(data[2],2,length(data[2])-2);
      tgl:=copy(data[7],2,length(data[7])-2);
      m:=copy(tgl,10,2);
      da:=copy(tgl,13,2);
      y:=copy(tgl,16,2);
      h:=copy(tgl,1,2);
      n:=copy(tgl,4,2);
      s:=copy(tgl,7,2);
    end else
    begin
      pengirim:=copy(data[1],2,length(data[1])-2);
      tgl:=copy(data[2],2,length(data[2])-2);
      da:=trim(copy(tgl,9,2));
      if copy(tgl,7,1)='/' then
        m:=copy(tgl,6,1)
      else
        m:=copy(tgl,6,2);
      y:=copy(tgl,3,2);
      if copy(tgl,13,1)=':' then
      begin
        h:='0'+copy(tgl,12,1);
        if copy(tgl,15,1)=':' then
        begin
          n:='0'+copy(tgl,14,1);
          if copy(tgl,17,1)=':' then
            s:='0'+copy(tgl,16,1)
          else
            s:=copy(tgl,16,2);
        end else
        begin
          n:=copy(tgl,14,2);
          if copy(tgl,18,1)=':' then
            s:=copy(tgl,17,1)
          else
            s:=copy(tgl,17,2);
        end;
      end else
      begin
        h:=copy(tgl,12,2);
        if copy(tgl,16,1)=':' then
        begin
          n:='0'+copy(tgl,15,1);
          if copy(tgl,18,1)=':' then
            s:='0'+copy(tgl,17,1)
          else
            s:=copy(tgl,17,2);
        end else
        begin
          n:=copy(tgl,15,2);
          if copy(tgl,19,1)=':' then
            s:='0'+copy(tgl,18,1)
          else
            s:=copy(tgl,18,2);
        end;
      end;
    end;
    tanggal:=da+'/'+m+'/'+y+' '+h+':'+n+':'+s;
    if brand=1 then
    begin
      a:=posex(#13#10,datasms,pos(data[6],datasms));
      b:=posex(#13#10,datasms,a+1);
      isi:=trim(copy(datasms,a+1,b-a-1));
    end else
    begin
      a:=pos('+CMGR:',datasms);
      if brand=2 then
      begin
        b:=posex(#13#10,datasms,a+1);
        c:=posex(#13#10,datasms,b+3);
      end else
      begin
        b:=posex(#13,datasms,a+1);
        c:=posex(#13,datasms,b+1);
      end;
      isi:=trim(copy(datasms, b, c-b));
    end;
  end;
end;

function TSMSModule.ConvertText(smsc, tipe, ref, tujuan, bentuk, skema,
  validitas, isi: string): string;
var
   PDU,tmp :string;
   p,
   i :byte;
begin
   PDU := '';
   If length(smsc)=0 then begin result :=''; exit; end;
   if length(tipe)=0 then tipe :='11';
   if length(ref)=0 then ref :='00';
   if length(bentuk)=0 then bentuk :='00';
   if length(skema)=0 then skema :='00';
   if length(validitas)=0 then validitas :='FF';
   If length(isi)=0 then begin result :=''; exit; end;

   if smsc[1]='0' then tmp :='81'+smsc else tmp :='91'+smsc;
   if(length(tmp)mod 2)<>0 then tmp :=tmp+'F';
   p := length(tmp);
   PDU :=PDU + inttohex(p div 2,2) + tmp[1] + tmp[2];
   for i:= 2 to length(tmp)div 2 do
   begin
        PDU :=PDU+tmp[i*2];
        PDU :=PDU+tmp[(i*2)-1];
   end;
   PDU :=PDU+tipe;
   PDU :=PDU+ref;
   if tujuan[1]='+' then tujuan:=copy(tujuan,2,length(tujuan)-1);
   PDU :=PDU+inttohex(length(tujuan),2);
   if(length(tujuan)mod 2)<>0 then tujuan:=tujuan+'F';
   if tujuan[1]='0' then PDU :=PDU+'81' else begin
     PDU :=PDU+'91';
   end;
   for i :=1 to length(tujuan)div 2 do
   begin
        PDU :=PDU+tujuan[i*2];
        PDU :=PDU+tujuan[(i*2)-1];
   end;
   PDU :=PDU+bentuk;
   PDU :=PDU+skema;
   PDU :=PDU+validitas;
   tmp := Text2PDU(isi);
   PDU :=PDU+tmp;
   i := length(tmp);
   lkirim := ((length(PDU) - p) div 2)-1;
   result :=PDU;
end;

constructor TSMSModule.Create(AOwner: TComponent);
begin
  inherited;

  comm := TComPort.Create(nil);
  comm.OnRxChar:=RxChar;
  Stop:=False;
  LBufferOut:='';
  LAuthor:='M. Nafi` Alfanthariq';
  LVersion:='1.0';
end;

destructor TSMSModule.Destroy;
begin
  comm.Free;
  
  inherited;
end;

function TSMSModule.Disconnect: boolean;
begin
  comm.Close;
  Connected:=False;
end;

procedure TSMSModule.DoNewMessage(Isi, Pengirim, Tanggal: string);
begin
  if Assigned(FOnNewMessage) then
    FOnNewMessage(Self, Isi, Pengirim, Tanggal);
end;

function TSMSModule.GetModemBrand: string;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('AT+CGMI'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos(#13#10,buffer);
      b:=pos(sOK,buffer);
      Result:=trim(copy(buffer,a+1,b-a-1));
    end else Result:='-';
  end else
  begin
    repeat
      if Stop=True then Exit;
      Sleep(100);
      Application.ProcessMessages;
      comm.WriteStr('ATI'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos('Manufacturer',buffer);
      b:=pos('Model',buffer);
      if (pos('+GMI',buffer)>0) then
        Result:=trim(copy(buffer,a+20,b-(a+20)))
      else
        Result:=trim(copy(buffer,a+14,b-(a+14)));
    end else Result:='-';
  end;
end;

function TSMSModule.GetModemModel: string;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('AT+CGMM'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos(#13#10,buffer);
      b:=pos(sOK,buffer);
      Result:=trim(copy(buffer,a+1,b-a-1));
    end else Result:='-';
  end else
  begin
    repeat
      if Stop=True then Exit;
      Sleep(100);
      Application.ProcessMessages;
      comm.WriteStr('ATI'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos('Model',buffer);
      b:=pos('Revision',buffer);
      Result:=trim(copy(buffer,a+7,b-(a+7)));
    end else Result:='-';
  end;
end;

function TSMSModule.GetModemOperator: string;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  comm.Open;
  waktu := now;
  repeat
    if Stop=True then Exit;
    LBufferOut:='';
    Sleep(500);
    buffer := '';
    Application.ProcessMessages;
    comm.WriteStr('AT+COPS?'#13);
    buffer := buffer + LBufferOut;
    {repeat
            if Stop=True then Exit;
            Sleep(100);
            Application.ProcessMessages;
            buffer := buffer + LBufferOut;
    until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
            or (secondsbetween(waktu, now) > 10)}
  until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
            or (secondsbetween(waktu, now) > 10);
  if trim(buffer)<>'' then
  begin
    if ModemType=mtGSM then
    begin
      a:=pos('+COPS',buffer);
      b:=posex('"',buffer,a)+1;
      c:=posex('"',buffer,b);
      if c-b=0 then
        Operator:=trim(copy(buffer,b,1))
      else
        Operator:=trim(copy(buffer,b,c-b));
    end else
    begin
      a:=pos('+COPS:',buffer)+6;
      //b:=posex(',',buffer,a);
      c:=StrToInt(trim(copy(buffer,a,1)));
      case c of
        0:Operator:='Automatic';
        1:Operator:='CDMA only';
        2:Operator:='CDMA or AMPS';
        3:Operator:='Analog only';
      end;
    end;
  end else Operator:='-';
  Result:=Operator;
end;

function TSMSModule.GetModemVersion: string;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('AT+CGMR'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos(#13#10,buffer);
      b:=pos(sOK,buffer);
      Result:=trim(copy(buffer,a+1,b-a-1));
    end else Result:='-';
  end else
  begin
    repeat
      if Stop=True then Exit;
      Sleep(100);
      Application.ProcessMessages;
      comm.WriteStr('ATI'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if (Pos(sOK, buffer) > 0) then
    begin
      a:=pos('Revision',buffer);
      b:=pos('ESN',buffer);
      Result:=trim(copy(buffer,a+16,b-(a+16)));
    end else Result:='-';
  end;
end;

function TSMSModule.GetSignal: integer;
var waktu:TDateTime;
    buffer, rssi:string;
    a,b:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  repeat
    if Stop=True then Exit;
    Sleep(500);
    Application.ProcessMessages;
    comm.WriteStr('AT+CSQ'#13);
    buffer := '';
    repeat
            if Stop=True then Exit;
            Sleep(100);
            Application.ProcessMessages;
            buffer := buffer + LBufferOut;
    until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
            or (secondsbetween(waktu, now) > 5)
  until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 10);
  if trim(buffer)<>'' then
  begin
    if pos('+CSQ:',buffer)>0 then
    begin
      a:=pos('+CSQ:',buffer)+5;
      b:=posex(',',buffer,a);
      rssi:=trim(copy(buffer,a,b-a));
      Result:=-133+(StrToInt(rssi)*2);
    end else Result:=0;
  end else Result:=0;
end;

function TSMSModule.GetSMSC: string;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  if ModemType=mtGSM then
  begin
    repeat
      if Stop=True then Exit;
      Sleep(500);
      Application.ProcessMessages;
      comm.WriteStr('AT+CSCA?'#13);
      buffer := '';
      repeat
              if Stop=True then Exit;
              Sleep(100);
              Application.ProcessMessages;
              buffer := buffer + LBufferOut;
      until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
              or (secondsbetween(waktu, now) > 10);
    until (Pos(sOK, buffer) > 0) or (secondsbetween(waktu, now) > 5);
    if trim(buffer)<>'' then
    begin
      a:=pos('+CSCA:',buffer);
      b:=posex('"',buffer,a)+1;
      c:=posex('"',buffer,b);
      if c-b=0 then
        Result:=trim(copy(buffer,b+1,1))
      else
        Result:=trim(copy(buffer,b+1,c-b-1));
    end else Result:='-';
  end else
  begin

  end;
end;

function TSMSModule.PDU2Text(pdudata: string): string;
var
  pdu,isi,hasilteks,huruf: string;
  i: integer;
  m,n,vgeser,sisa,
  c,d,e,f,panjang: byte;
  hasil,dbiner: array[1..9000] of byte;
begin
  if length(pdudata)=0 then begin
          Result := '';
          exit;
  end;
  pdu := copy(pdudata,3,length(pdudata));
  isi:= '';
  panjang := length(pdu) div 2;
  for i := 1 to panjang do begin
          huruf := copy(pdu, i*2 - 1, 2);
          dbiner[i] := StrToInt('$' + huruf);
  end;
  m := 1;
  vgeser := 0;
  sisa := 0;
  n := 1;
  while n <= panjang do
  begin
    c := dbiner[n];
    d := c shl vgeser;
    e := d or sisa;
    f := e and $7F;
    hasil[m] := f;
    Inc(vgeser);
    c := dbiner[n];
    d := c shr (8-vgeser);
    sisa := d;
    inc(m);
    inc(n);
    if vgeser >= 7 then begin
      hasil[m] := sisa and $7F;
      inc(m);
      sisa := 0;
      vgeser := 0;
    end;
  end;
  hasilteks := '';
  for i := 1 to m - 1 do
          hasilteks := hasilteks + chr(hasil[i]);
  Result := hasilteks;
end;

procedure TSMSModule.RxChar(Sender: TObject; Count: Integer);
var Str:string;
begin
  comm.ReadStr(Str, Count);
  LBufferOut:=LBufferOut + Str;
end;

function TSMSModule.SendGetData(teks, tOK: string; Msg: Boolean): string;
var waktu  : TDateTime;
    buffer : string;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  repeat
      if Stop=True then Exit;
      comm.WriteStr(teks);
      buffer := '';
      Sleep(1000);
      Application.ProcessMessages;
      waktu := now;
        repeat
             if Stop=True then Exit;
             Sleep(1000);
             Application.ProcessMessages;
             buffer := buffer + LBufferOut;
        until (pos(tOK, buffer) > 0) or (pos(sERROR, buffer) > 0)
             or (SecondsBetween(waktu,now) > 10);
  until (pos(tOK, buffer) > 0) or (pos(sERROR, buffer) > 0)
       or (SecondsBetween(waktu,now) > 20);
  result := buffer;
  if Msg=True then
  begin
    if (pos(sOK, buffer) > 0) then
      MsgSent:=True
    else
      MsgSent:=False;
  end;
end;

function TSMSModule.SendSMS(SMSC, Tujuan: string;
  Isi: WideString): boolean;
var PDU, PartIsi:string;
    Part, i, poss:integer;
    back:boolean;
begin
  if length(Isi)>150 then
  begin
    Part:=(length(isi) div 150) + 1;
    poss:=1;
    for i:=1 to Part do
    begin
      PartIsi:=copy(Isi,poss,150);
      PDU := ConvertText(SMSC,'','',Tujuan,'','','',PartIsi);
      back:=False;
      if (ModemType=mtCDMA) AND (Mode=smPDU) then
      begin
        Mode:=smText;
        back:=True;
      end;
      if Mode=smPDU then
      begin
        if ModemType=mtGSM then
          SendGetData('AT+CMGS=' + IntToStr(lkirim) + #13, '>', True)
        else
          SendGetData('AT+CMGS=' + IntToStr(lkirim) + #13, '>', True);
        SendGetData(PDU + #26, sOK, True);
      end;
      if back=True then Mode:=smPDU;
      poss:=poss+150;
    end;
  end else
  begin
    PDU := ConvertText(SMSC,'','',Tujuan,'','','',Isi);
    if Mode=smPDU then
    begin
      SendGetData('AT+CMGS=' + IntToStr(lkirim) + #13, '>', True);
      SendGetData(PDU + #26, sOK, True);
    end else
    begin
      SendGetData('AT+CMGS=' + Tujuan + #13, '>', True);
      SendGetData(Isi + #26, sOK, True);
    end;
  end;
  Result:=MsgSent;
end;

function TSMSModule.SendSMSText(Tujuan: string; Isi: WideString): boolean;
var PDU, PartIsi, buffer, par:string;
    Part, i, poss, brand:integer;
    back:boolean;
    waktu : TDateTime;
begin
  LBufferOut:='';
  if (pos('HUAWEI',GetModemBrand)>0) OR (pos('China TeleCom',GetModemBrand)>0) then
    brand:=1
  else
    brand:=0;
  if length(Isi)>150 then
  begin
    Part:=(length(isi) div 150) + 1;
    poss:=1;
    for i:=1 to Part do
    begin
      PartIsi:=copy(Isi,poss,150);
      if ModemType=mtGSM then
      begin
         comm.WriteStr('at+CMGF=1'+#13#10);
         comm.WriteStr('AT+CMGS="' + Tujuan +'",'+ #13#10);
         comm.WriteStr(PartIsi);
         comm.WriteStr(#26);
      end else
      begin
         if brand=1 then
           comm.WriteStr('at+CMGF=1'+#13#10);
         if brand=1 then
           comm.WriteStr('AT^HCMGS="' + Tujuan +'",'+ #13#10)
         else
           comm.WriteStr('AT+CMGS="' + Tujuan +'",'+ #13#10);
         comm.WriteStr(PartIsi);
         comm.WriteStr(#26);
      end;
      poss:=poss+150;
    end;
  end else
  begin
    if ModemType=mtGSM then
    begin
       comm.WriteStr('at+CMGF=1'+#13#10);
       comm.WriteStr('AT+CMGS="' + Tujuan +'",'+ #13#10);
       comm.WriteStr(Isi);
       comm.WriteStr(#26);
    end else
    begin
       if brand=1 then
         comm.WriteStr('at+CMGF=1'+#13#10);
       if brand=1 then
         comm.WriteStr('AT^HCMGS="' + Tujuan +'",'+ #13#10)
       else
         comm.WriteStr('AT+CMGS="' + Tujuan +'",'+ #13#10);
       comm.WriteStr(Isi);
       comm.WriteStr(#26);
    end;
  end;
  waktu:=now;
  repeat
     Sleep(100);
     Application.ProcessMessages;
     buffer:=buffer + LBufferOut;
    if brand=1 then
      par:='^HCMGSS:'
    else
      par:='+CMGS:';
  until (pos(par, buffer) > 0) or (pos(sERROR, buffer) > 0)
       or (SecondsBetween(waktu,now) > 60);
  Result:=(pos(par,buffer)>0);
end;

procedure TSMSModule.SetupModem;
begin
  comm.Port := LComPort;
  comm.BaudRate := StrToBaudRate(LBaudRate);
  comm.FlowControl.FlowControl := StrToFlowControl('Hardware');
end;

procedure TSMSModule.TerminateProcess;
begin
  if Stop=False then Stop:=True;
end;

function TSMSModule.text2PDU(text: string): string;
var   PDU : string;
      geser,panjang,tmp,tmp2,tmp3,n:byte;
begin
      PDU :='';
      panjang :=length(text);
      PDU :=PDU+IntToHex(panjang,2);

      geser :=0;
      for n :=1 to panjang-1 do
      begin
          tmp2 :=ord(text[n]);
          if geser<>0 then tmp2 :=tmp2 shr geser;
          tmp :=ord(text[n+1]);
          if geser=7 then
          begin
            geser :=0;
          end else
          begin
            tmp3 :=8-(geser+1);
            if tmp3<>0 then tmp:=tmp shl tmp3;
            PDU :=PDU+inttohex((tmp or tmp2),2);
            inc(geser);
          end;
      end;
      if geser<7 then
      begin
          tmp2:=ord(text[panjang]);
          if(geser<>0)then tmp2:=tmp2 shr geser;
          PDU:=PDU+inttohex(tmp2,2);
      end;
      result:=PDU;
end;

function TSMSModule.ReplaceStr(S: string) : String;
var I : integer;
    StrEx, Str : String;
begin
  for I := 1 to length (S) do
  begin
    Str:=copy(S,i,1);
    if (Str<>#0) then// AND (copy(S,i+1,1)<>'0') then
      StrEx:= StrEx + Str;
  end;
  Result:=StrEx;
end;

function TSMSModule.HexToString(H: String): WideString;
var I : Integer;
    S, Str: String;
begin
  Result:= '';
  for I := 1 to length (H) div 2 do
    S:= S+Char(StrToInt('$'+Copy(H,(I-1)*2+1,2)));
  Str:=ReplaceStr(S);
  Result:=Str;
end;

procedure TSMSModule.DoGetMessage(Isi, Pengirim, Tanggal: string; Index:integer);
begin
  if Assigned(FOnGetMessage) then
    FOnGetMessage(Self, Isi, Pengirim, Tanggal, Index);
end;

function TSMSModule.USSDCompatible: boolean;
var waktu: tdatetime;
    buffer: string;
    a,b,c:integer;
begin
  LBufferOut:='';
  comm.Open;
  waktu := now;
  if Stop=True then Exit;
  Sleep(100);
  Application.ProcessMessages;
  comm.WriteStr('AT+CUSD=1'#13);
  buffer := '';
  repeat
          if Stop=True then Exit;
          Sleep(100);
          Application.ProcessMessages;
          buffer := buffer + LBufferOut;
  until (Pos(sOK, buffer) > 0) or (Pos(sERROR, buffer) > 0)
          or (secondsbetween(waktu, now) > 10);
  if (Pos('ERROR: 3', buffer) > 0) OR (Pos('NOT SUPPORT', buffer) > 0) OR (Pos('ERROR', buffer) > 0) then
    Result:=False
  else
    Result:=True;
end;

procedure TSMSModule.SetUtils(Value : String);
begin
  if csDesigning in Componentstate then {do nothing}
  else
  begin
    LAuthor:=Value;
    LVersion:=Value;
  end;
end;

end.

