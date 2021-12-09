unit uManifest;

interface

uses
  REST.Json,
  REST.Json.Types,
  System.Classes,
  SysUtils,
  JSON,
  System.TypInfo,
  StrUtils;

type
  TManifestRequest = class
  private
    FApplicationKey    : String;
    FApplicationSecret : String;
    FConsumerKey       : String;
  public
    property ApplicationKey : String read FApplicationKey write FApplicationKey;
    property ApplicationSecret : String read FApplicationSecret write FApplicationSecret;
    property ConsumerKey : String read FConsumerKey write FConsumerKey;
  end;

type
  TManifestRecord = class
  private
    FName  : String;
    FID    : String;
  published
    property Name : String read FName write FName;
    property ID   : String read FID write FID;
  end;

type
  TManifest = class(TObject)
  private
    FRecord        : TManifestRecord;
    FRequest       : TManifestRequest;

    [JSONMarshalled(False)] [JSonName('RecField')]
    Arquivo     : String;
  published
    property ZoneRecord  : TManifestRecord        read FRecord       write FRecord;
    property Request     : TManifestRequest         read FRequest    write FRequest;
  public
    procedure Carregar;
    procedure Salvar(Caminho : String = '');
    constructor Create(const Arquivo : String);
  end;

var
  Manifest : TManifest;

implementation

{ Configuracao }

procedure TManifest.Carregar;
var
  vConteudo : TStrings;

  j : TJsonObject;
label
  lInitialize;
begin
  vConteudo := TStringList.Create;
  try
    if not FileExists(Arquivo) then
      goto lInitialize;

    vConteudo.LoadFromFile(Arquivo);
    j := TJsonObject.ParseJSONValue(vConteudo.Text) as TJsonObject;
    TJson.JsonToObject(Self, j,  [joIndentCaseLower]);

    lInitialize:
    if not Assigned(FRecord) then
      Self.FRecord  := TManifestRecord.Create;
    if not Assigned(FRequest) then
      Self.FRequest := TManifestRequest.Create;
  finally
    if Assigned(vConteudo) then
      FreeAndNil(vConteudo);
  end;
end;

constructor TManifest.Create(const Arquivo : String);
begin
  Self.Arquivo          := Arquivo;
  Carregar;
end;

procedure TManifest.Salvar(Caminho : String = '');
var
  vConteudo : TStrings;
begin
  vConteudo := TStringList.Create;
  try
    vConteudo.Text := StringReplace(TJson.Format(TJson.ObjectToJsonObject(Self, [joIndentCaseLower])), '\/', '/', [rfReplaceAll]);
    vConteudo.SaveToFile(IfThen(Caminho <> '', Caminho, Arquivo));
  finally
    FreeAndNil(vConteudo);
  end;
end;

{ TManifestBalancaArquivos }

function StrDef(const AValue: string; const ADefault: string): string;
begin
  if AValue = '' then
    Result := ADefault
  else
    Result := AValue;
end;

{ TManifestDatabase }

initialization
  Manifest := TManifest.Create(ExtractFilePath(ParamStr(0)) + 'manifest.cfg')

finalization
  FreeAndNil(Manifest);

end.
