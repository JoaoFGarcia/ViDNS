unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, REST.Client, Rest.Types, DateUtils, IdHash, IdHashSHA, JSON, Data.Bind.Components, Data.Bind.ObjectScope,
  IdHttp, Vcl.AppEvnts, JvComponentBase, JvTrayIcon;

type
  TIPNotify = procedure(AIP : String) of Object;
  TViDNS = class(TThread)
  protected
    procedure Execute; override;
  private
    FRestClient        : TRESTClient;
    FRestRequest       : TRESTRequest;
    FRestResponse      : TRESTResponse;
    FTerminated        : Boolean;
    FNotifyEvent       : TIPNotify;
    function GetIP: String;
  public
    constructor Create();
    procedure Terminate;
  published
    property Terminated  : Boolean   read FTerminated  write FTerminated;
    property NotifyEvent : TIPNotify read FNotifyEvent write FNotifyEvent;
  end;

type
  TfrmMain = class(TForm)
    edtAK: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtCK: TEdit;
    edtAS: TEdit;
    Label3: TLabel;
    spt: TPanel;
    edtZone: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtRecordID: TEdit;
    lblRID: TLabel;
    btnSave: TButton;
    lblIP: TLabel;
    tray: TJvTrayIcon;
    appEvents: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure appEventsMinimize(Sender: TObject);
  private
    procedure Restore;
    { Private declarations }
  public
    { Public declarations }
    procedure Notify(AIP : String);
  end;

var
  frmMain : TfrmMain;
  viDNS   : TViDns;

implementation

uses
  uManifest,
  System.Net.HttpClient;

{$R *.dfm}

procedure TfrmMain.appEventsMinimize(Sender: TObject);
begin
  //Hide();
  //WindowState := wsMinimized;

  //tray.IconVisible := True;
  //tray.BalloonHint('ViDNS', 'Hey! Estou operante por aqui', TBalloonType.btNone);
end;

procedure TfrmMain.Restore();
begin
  Show();
  WindowState := wsNormal;
  Application.Restore();
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  Manifest.Request.ApplicationKey    := edtAK.Text;
  Manifest.Request.ApplicationSecret := edtAS.Text;
  Manifest.Request.ConsumerKey       := edtCK.Text;
  Manifest.ZoneRecord.Name           := edtZone.Text;
  Manifest.ZoneRecord.ID             := (edtRecordID.Text);
  Manifest.Salvar();
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  edtAK.Text       := Manifest.Request.ApplicationKey;
  edtAS.Text       := Manifest.Request.ApplicationSecret;
  edtCK.Text       := Manifest.Request.ConsumerKey;
  edtZone.Text     := Manifest.ZoneRecord.Name;
  edtRecordID.Text := (Manifest.ZoneRecord.ID);

  viDNS            := TViDns.Create();
  viDNS.Start();
end;

procedure TfrmMain.Notify(AIP: String);
begin
  Self.lblIP.Caption := AIP;
end;

{ TViDNS }

constructor TViDNS.Create;
begin
  inherited Create(True);
  FRestClient           := TRestClient.Create('https://api.ovh.com/1.0/');
  FRestClient.UserAgent := 'ViDNS 1.0';
  FRestClient.Accept    := '*/*';
  FRestClient.SecureProtocols := [THTTPSecureProtocol.SSL2, THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS1, THTTPSecureProtocol.TLS11, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
  // Instância - objeto de requisição
  FRestRequest          := TRESTRequest.Create(nil);
  FRestRequest.Method   := rmPUT;
  FRestRequest.Client   := FRestClient;
  FRestRequest.AcceptEncoding := 'gzip, deflate, br';
  FRestRequest.Accept := '*/*';
  // Instância - objeto de resposta
  FRestResponse         := TRESTResponse.Create(nil);
  FRestRequest.Response := FRestResponse;
  FRestResponse.ContentType := 'application/json';

  FNotifyEvent := frmMain.Notify;
end;

procedure TViDNS.Execute;
var
  SHA1  : TIdHashSHA1;
  jObj  : TJsonObject;
  iTime : Integer;
  sHash : String;
  sIP   : String;
begin
  inherited;
  SHA1  := TIdHashSHA1.Create;

  repeat
    jObj  := TJsonObject.Create;
    if Manifest.ZoneRecord.ID = '0' then
    begin
      Sleep(1000);
      Continue;
    end;
    try
      sIP := GetIP;
      jObj.AddPair('target', sIP);
      FNotifyEvent(sIP);

      iTime := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now));

      FRestRequest.ClearBody;
      FRestRequest.AddBody(jObj);
      FRestRequest.Method   := rmPUT;
      //FRestRequest.AddBody(jObj.ToString);
      FRestRequest.Resource := '/domain/zone/' + Manifest.ZoneRecord.Name + '/record';
      FRestRequest.ResourceSuffix := Manifest.ZoneRecord.ID;
      FRestRequest.Params.AddHeader('X-Ovh-Application', Manifest.Request.ApplicationKey).Options := [poDoNotEncode, poAutoCreated];
      FRestRequest.Params.AddHeader('X-Ovh-Consumer'   , Manifest.Request.ConsumerKey).Options := [poDoNotEncode, poAutoCreated];
      FRestRequest.Params.AddHeader('X-Ovh-Timestamp'  , IntToStr(iTime)).Options := [poDoNotEncode, poAutoCreated];

      sHash :=
               Manifest.Request.ApplicationSecret   + '+' +
               Manifest.Request.ConsumerKey         + '+' +
               'PUT'                                + '+' +
               FRestRequest.GetFullRequestURL()     + '+' +
               FRestRequest.GetFullRequestBody      + '+' +
               IntToStr(iTime);

      sHash := '$1$' + LowerCase(SHA1.HashStringAsHex(sHash));
      FRestRequest.Params.AddHeader('X-Ovh-Signature'  , sHash).Options := [poDoNotEncode, poAutoCreated];
      FRestRequest.Execute;

      FRestRequest.ClearBody;
      FRestRequest.Method   := rmPost;
      FRestRequest.ResourceSuffix := '';
      FRestRequest.Resource := '/domain/zone/vieo.cc/refresh';
      sHash :=
               Manifest.Request.ApplicationSecret   + '+' +
               Manifest.Request.ConsumerKey         + '+' +
               'POST'                                + '+' +
               FRestRequest.GetFullRequestURL()     + '+' +
               FRestRequest.GetFullRequestBody      + '+' +
               IntToStr(iTime);

      sHash := '$1$' + LowerCase(SHA1.HashStringAsHex(sHash));
      FRestRequest.Params.AddHeader('X-Ovh-Signature'  , sHash).Options := [poDoNotEncode, poAutoCreated];
      FRestRequest.Execute;

      Sleep(120000);
      FreeAndNil(jObj);
    except
    end;
  until(Terminated);
end;

function TViDNS.GetIP() : String;
var
  jObj   : TJSONObject;
  str    : string;
  http   : TIdHttp;
begin
  str  := '';
  http := TIdHTTP.Create(nil);
  try
      str  := http.Get('http://ipinfo.io/json?token=097ed02e80cf7e');
      jObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(str),0)           as TJSONObject;
      str  := jObj.Get('ip').JsonValue.Value;
      jObj.Free;
      http.Free;
  except
  end;
  result := str;
end;

procedure TViDNS.Terminate;
begin
  Self.FTerminated := True;
end;

end.
