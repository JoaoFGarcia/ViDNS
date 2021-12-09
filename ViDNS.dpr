program ViDNS;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uManifest in 'uManifest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'ViDNS';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
