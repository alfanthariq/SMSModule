program Demo;

uses
  Forms,
  U_demo in 'U_demo.pas' {frm_demo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_demo, frm_demo);
  Application.Run;
end.
