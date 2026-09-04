; ============================================================
; 海音アルラ Umine Alhura Ver.1.02
; Voicebank Installer
; Inno Setup 7.1.0
; ============================================================

[Setup]

AppId={{UmineAlhura-Voicebank-1.02}
AppName=海音アルラ Umine Alhura
AppVersion=1.02
AppVerName=海音アルラ Umine Alhura Ver.1.02

AppPublisher=Alhura Driftveil
AppPublisherURL=https://github.com/A-L-H-U-R-A
AppSupportURL=https://github.com/A-L-H-U-R-A/umine-alhura-releases
AppUpdatesURL=https://github.com/A-L-H-U-R-A/umine-alhura-releases

DefaultDirName={userdocs}\OpenUtau\Singers\海音アルラ Umine Alhura Ver.1.02
DisableDirPage=yes
DisableProgramGroupPage=yes

OutputDir=Output
OutputBaseFilename=UmineAlhura-1.02-Setup

Compression=lzma2
SolidCompression=yes

WizardStyle=classic
; IMPORTANTE: con WizardStyle=classic, Inno Setup SOLO admite BMP
; para estas dos imágenes (el soporte de PNG es exclusivo del
; estilo "modern"). Ya no se usa un archivo aparte "UmineAlhura_V2":
; la imagen principal del wizard (pantalla de bienvenida) ahora es
; directamente el boxart.
;
; NOTA: WizardImageFile / WizardImageBackColor / WizardImageStretch /
; WizardKeepAspectRatio se mantienen configurados (Inno los requiere
; para poder posicionar los controles WizardBitmapImage /
; WizardBitmapImage2), pero en tiempo de ejecución esos controles se
; ocultan explícitamente en CurPageChanged para wpWelcome y
; wpFinished, así que la imagen grande no llega a mostrarse.
WizardImageFile=assets\boxart.bmp
WizardSmallImageFile=assets\LOGO.bmp

WizardImageBackColor=white
WizardSmallImageBackColor=white

; Se deja que Inno escale manteniendo proporción (evita que el
; boxart/logo salgan recortados si el bitmap fuente es más grande
; que el área de imagen del wizard).
WizardImageStretch=yes
WizardKeepAspectRatio=yes

AlwaysShowDirOnReadyPage=yes

; Necesario para ZIP mediante ExtractArchive.
ArchiveExtraction=full

SetupIconFile=assets\icon.ico

Uninstallable=no

; Pide privilegios de administrador al ejecutar el instalador
; (antes: PrivilegesRequired=lowest).
PrivilegesRequired=admin

// WizardBackImageFile=assets\alhubox01.bmp
// WizardBackImageOpacity=255

[Files]

; ------------------------------------------------------------
; Archivos usados únicamente por el instalador.
; No se instalan en el voicebank.
; ------------------------------------------------------------

Source: "assets\_Hello_Planet__Alhutau.wav"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\alhubox01.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\icon.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\icon2.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\portrait.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\portrait2.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy

Source: "assets\boxart.bmp"; \
    DestDir: "{tmp}"; \
    Flags: dontcopy


[Code]

{ ============================================================
  CONSTANTES
  ============================================================ }

const
  SND_ASYNC = $0001;
  SND_NODEFAULT = $0002;
  SND_FILENAME = $00020000;
  SND_LOOP = $00000008;

  SM_CXSCREEN = 0;
  SM_CYSCREEN = 1;

  { Margen izquierdo/derecho usado en todas las páginas.
    Todo el layout se calcula a partir del ancho REAL de
    Page.Surface, nunca con números fijos, porque ese ancho
    cambia según el estilo del wizard y la imagen lateral. }
  PageMargin = 18;

  VoicebankFolderName = '海音アルラ Umine Alhura Ver.1.02';


{ ============================================================
  WINDOWS API
  ============================================================ }

procedure PlaySound(
  pszSound: String;
  hmod: Integer;
  fdwSound: Cardinal);
external 'PlaySoundW@winmm.dll stdcall';

function GetSystemMetrics(
  nIndex: Integer): Integer;
external 'GetSystemMetrics@user32.dll stdcall';


{ ============================================================
  VARIABLES GENERALES
  ============================================================ }

var
  IntroPage: TWizardPage;
  VoicebankPage: TWizardPage;
  InstallPage: TWizardPage;
  IconPage: TWizardPage;
  PortraitPage: TWizardPage;

  IntroTitle: TNewStaticText;
  IntroText: TNewStaticText;
  IntroInfo: TNewStaticText;

  VoicebankTitle: TNewStaticText;
  VoicebankInfo: TNewStaticText;

  InstallTitle: TNewStaticText;
  InstallInfo: TNewStaticText;

  OpenUtauRadio: TNewRadioButton;
  UtauRadio: TNewRadioButton;
  CustomRadio: TNewRadioButton;

  InstallPathEdit: TNewEdit;
  BrowseButton: TNewButton;

  IconTitle: TNewStaticText;
  IconInfo: TNewStaticText;

  Icon1Radio: TNewRadioButton;
  Icon2Radio: TNewRadioButton;

  Icon1Image: TBitmapImage;
  Icon2Image: TBitmapImage;

  PortraitTitle: TNewStaticText;
  PortraitInfo: TNewStaticText;

  Portrait1Radio: TNewRadioButton;
  Portrait2Radio: TNewRadioButton;

  Portrait1Image: TBitmapImage;
  Portrait2Image: TBitmapImage;

  SweetCheck: TNewCheckBox;

  SelectedInstallPath: String;

  CoreSelected: Boolean;
  SweetSelected: Boolean;
  DownloadsPrepared: Boolean;


{ ============================================================
  HELPER: CREAR LABEL
  ============================================================ }

function CreateLabel(
  Parent: TWinControl;
  CaptionText: String;
  LeftPos, TopPos, WidthPos, HeightPos: Integer;
  FontSize: Integer): TNewStaticText;
begin
  Result := TNewStaticText.Create(Parent);

  Result.Parent := Parent;
  Result.Left := ScaleX(LeftPos);
  Result.Top := ScaleY(TopPos);
  Result.Width := ScaleX(WidthPos);
  Result.Height := ScaleY(HeightPos);

  Result.Caption := CaptionText;

  Result.Font.Size := FontSize;

  { Sin esto, un texto más largo que WidthPos no se envuelve
    y termina saliéndose del control o de la página. }
  Result.WordWrap := True;
  Result.AutoSize := False;
end;


{ ============================================================
  HELPER: CREAR IMAGEN (estira a un tamaño fijo)
  ============================================================
  Se usa para imágenes que YA vienen preparadas con la
  proporción exacta del recuadro que van a ocupar (por
  ejemplo icon.bmp / icon2.bmp / portrait.bmp / portrait2.bmp,
  que son cuadradas o con una relación de aspecto conocida
  y fija). No se debe usar para imágenes cuya proporción no
  coincide con el recuadro, porque las deforma.
  ============================================================ }

function CreatePreviewImage(
  Parent: TWinControl;
  FileName: String;
  LeftPos, TopPos, WidthPos, HeightPos: Integer): TBitmapImage;
begin
  Result := TBitmapImage.Create(Parent);

  Result.Parent := Parent;

  Result.Left := ScaleX(LeftPos);
  Result.Top := ScaleY(TopPos);

  Result.Width := ScaleX(WidthPos);
  Result.Height := ScaleY(HeightPos);

  Result.Stretch := True;

  Result.Bitmap.LoadFromFile(FileName);
end;


{ ============================================================
  MUSIC
  ============================================================ }

procedure StartBackgroundMusic;
begin
  PlaySound(
    ExpandConstant('{tmp}\_Hello_Planet__Alhutau.wav'),
    0,
    SND_ASYNC or
    SND_NODEFAULT or
    SND_FILENAME or
    SND_LOOP
  );
end;


procedure StopBackgroundMusic;
begin
  PlaySound('', 0, 0);
end;


{ ============================================================
  INTRO PAGE
  ============================================================ }

procedure CreateIntroPage;
var
  AvailWidth: Integer;
  ContentLeft: Integer;
begin
  IntroPage := CreateCustomPage(
    wpWelcome,
    'Welcome to the Umine Alhura Voicebank Installer',
    'Install and configure the 海音アルラ Umine Alhura voicebank.'
  );

  { Sin boxart: el contenido ocupa todo el ancho disponible
    de la página, sin reservar espacio a la izquierda para
    ninguna imagen. }
  ContentLeft := PageMargin;
  AvailWidth := IntroPage.Surface.ClientWidth - (PageMargin * 2);

  IntroTitle := CreateLabel(
    IntroPage.Surface,
    '海音アルラ Umine Alhura',
    ContentLeft,
    8,
    AvailWidth,
    30,
    16
  );

  IntroTitle.Alignment := taCenter;

  IntroText := CreateLabel(
    IntroPage.Surface,
    'This installer will guide you through the installation of the Umine Alhura voicebank.',
    ContentLeft,
    48,
    AvailWidth,
    55,
    9
  );

  IntroText.Alignment := taCenter;

  IntroInfo := CreateLabel(
    IntroPage.Surface,
    'Voicebank: 海音アルラ Umine Alhura Ver.1.02' + #13#10 +
    'Language: Japanese' + #13#10 +
    'Type: UTAU' + #13#10 +
    'Recommended range: C4-C6' + #13#10 +
    'Best performance: G4-G5',
    ContentLeft,
    112,
    AvailWidth,
    110,
    9
  );

  IntroInfo.Alignment := taLeftJustify;
end;


{ ============================================================
  VOICEBANK PAGE
  ============================================================ }

procedure CreateVoicebankPage;
var
  AvailWidth: Integer;
  ContentLeft: Integer;
begin
  VoicebankPage := CreateCustomPage(
    IntroPage.ID,
    'Voicebank Configuration',
    'Choose which voice colors you want to install.'
  );

  { Sin boxart: el contenido ocupa todo el ancho disponible
    de la página, sin reservar espacio a la izquierda para
    ninguna imagen. }
  ContentLeft := PageMargin;
  AvailWidth := VoicebankPage.Surface.ClientWidth - (PageMargin * 2);

  VoicebankTitle := CreateLabel(
    VoicebankPage.Surface,
    'Voice Colors',
    ContentLeft,
    8,
    AvailWidth,
    30,
    14
  );

  VoicebankTitle.Alignment := taCenter;

  VoicebankInfo := CreateLabel(
    VoicebankPage.Surface,
    'Core is required. Sweet is an optional append.',
    ContentLeft,
    46,
    AvailWidth,
    35,
    9
  );

  VoicebankInfo.Alignment := taCenter;

  SweetCheck := TNewCheckBox.Create(VoicebankPage);

  SweetCheck.Parent := VoicebankPage.Surface;

  SweetCheck.Left := ScaleX(ContentLeft);
  SweetCheck.Top := ScaleY(92);

  SweetCheck.Width := ScaleX(AvailWidth);
  SweetCheck.Height := ScaleY(20);

  SweetCheck.Caption := 'Install Sweet append (_S)';

  SweetCheck.Checked := True;
end;


{ ============================================================
  INSTALL LOCATION PAGE
  ============================================================ }

procedure BrowseInstallFolder(Sender: TObject);
var
  Directory: String;
begin
  Directory := InstallPathEdit.Text;

  if BrowseForFolder(
    'Select the folder where the voicebank will be installed:',
    Directory,
    True
  ) then
  begin
    InstallPathEdit.Text := Directory;

    CustomRadio.Checked := True;
  end;
end;


procedure CreateInstallPage;
var
  AvailWidth: Integer;
  EditWidth: Integer;
  BrowseWidth: Integer;
begin
  InstallPage := CreateCustomPage(
    VoicebankPage.ID,
    'Installation Location',
    'Choose where the voicebank should be installed.'
  );

  AvailWidth := InstallPage.Surface.ClientWidth - (PageMargin * 2);
  BrowseWidth := 75;

  InstallTitle := CreateLabel(
    InstallPage.Surface,
    'Where should Umine Alhura be installed?',
    PageMargin,
    8,
    AvailWidth,
    30,
    14
  );

  InstallTitle.Alignment := taCenter;

  InstallInfo := CreateLabel(
    InstallPage.Surface,
    'Choose one of the standard locations or select a custom folder.',
    PageMargin,
    42,
    AvailWidth,
    35,
    9
  );

  InstallInfo.Alignment := taCenter;


  OpenUtauRadio := TNewRadioButton.Create(InstallPage);

  OpenUtauRadio.Parent := InstallPage.Surface;

  OpenUtauRadio.Left := ScaleX(PageMargin);
  OpenUtauRadio.Top := ScaleY(90);

  OpenUtauRadio.Width := ScaleX(AvailWidth);
  OpenUtauRadio.Height := ScaleY(20);

  OpenUtauRadio.Caption :=
    'OpenUtau — Documents\OpenUtau\Singers';

  OpenUtauRadio.Checked := True;


  UtauRadio := TNewRadioButton.Create(InstallPage);

  UtauRadio.Parent := InstallPage.Surface;

  UtauRadio.Left := ScaleX(PageMargin);
  UtauRadio.Top := ScaleY(118);

  UtauRadio.Width := ScaleX(AvailWidth);
  UtauRadio.Height := ScaleY(20);

  UtauRadio.Caption :=
    'UTAU — AppData\Roaming\UTAU\voice';


  CustomRadio := TNewRadioButton.Create(InstallPage);

  CustomRadio.Parent := InstallPage.Surface;

  CustomRadio.Left := ScaleX(PageMargin);
  CustomRadio.Top := ScaleY(146);

  CustomRadio.Width := ScaleX(AvailWidth);
  CustomRadio.Height := ScaleY(20);

  CustomRadio.Caption :=
    'Custom location';

  { El campo de texto ocupa todo el ancho disponible MENOS
    el botón Browse y el hueco entre ambos, así el botón
    nunca se sale de la página. }
  EditWidth := AvailWidth - BrowseWidth - 10;

  InstallPathEdit := TNewEdit.Create(InstallPage);

  InstallPathEdit.Parent := InstallPage.Surface;

  InstallPathEdit.Left := ScaleX(PageMargin);
  InstallPathEdit.Top := ScaleY(182);

  InstallPathEdit.Width := ScaleX(EditWidth);
  InstallPathEdit.Height := ScaleY(23);

  InstallPathEdit.Text :=
    ExpandConstant(
      '{userdocs}\OpenUtau\Singers'
    );


  BrowseButton := TNewButton.Create(InstallPage);

  BrowseButton.Parent := InstallPage.Surface;

  BrowseButton.Left := ScaleX(PageMargin + EditWidth + 10);
  BrowseButton.Top := ScaleY(181);

  BrowseButton.Width := ScaleX(BrowseWidth);
  BrowseButton.Height := ScaleY(25);

  BrowseButton.Caption := 'Browse...';

  BrowseButton.OnClick := @BrowseInstallFolder;
end;


{ ============================================================
  ICON PAGE
  ============================================================ }

procedure CreateIconPage;
var
  AvailWidth: Integer;
  ImgSize: Integer;
  Gap: Integer;
  BlockLeft: Integer;
begin
  IconPage := CreateCustomPage(
    InstallPage.ID,
    'Choose an Icon',
    'Select the icon that will be used by OpenUtau.'
  );

  AvailWidth := IconPage.Surface.ClientWidth - (PageMargin * 2);

  IconTitle := CreateLabel(
    IconPage.Surface,
    'Voicebank Icon',
    PageMargin,
    8,
    AvailWidth,
    30,
    14
  );

  IconTitle.Alignment := taCenter;


  IconInfo := CreateLabel(
    IconPage.Surface,
    'Choose the artwork you want to use as the singer icon.',
    PageMargin,
    42,
    AvailWidth,
    35,
    9
  );

  IconInfo.Alignment := taCenter;

  { Las dos imágenes se tratan como un solo bloque de
    (ImgSize * 2 + Gap) de ancho, y ese bloque se centra
    respecto al ancho real de la página. }
  ImgSize := 96;
  Gap := 26;

  BlockLeft := (IconPage.Surface.ClientWidth - (ImgSize * 2 + Gap)) div 2;

  Icon1Image := CreatePreviewImage(
    IconPage.Surface,
    ExpandConstant('{tmp}\icon.bmp'),
    BlockLeft,
    90,
    ImgSize,
    ImgSize
  );


  Icon2Image := CreatePreviewImage(
    IconPage.Surface,
    ExpandConstant('{tmp}\icon2.bmp'),
    BlockLeft + ImgSize + Gap,
    90,
    ImgSize,
    ImgSize
  );


  Icon1Radio := TNewRadioButton.Create(IconPage);

  Icon1Radio.Parent := IconPage.Surface;

  Icon1Radio.Left := ScaleX(BlockLeft);
  Icon1Radio.Top := ScaleY(90 + ImgSize + 12);

  Icon1Radio.Width := ScaleX(ImgSize);
  Icon1Radio.Height := ScaleY(20);

  Icon1Radio.Caption := 'Icon 1';

  Icon1Radio.Checked := True;


  Icon2Radio := TNewRadioButton.Create(IconPage);

  Icon2Radio.Parent := IconPage.Surface;

  Icon2Radio.Left := ScaleX(BlockLeft + ImgSize + Gap);
  Icon2Radio.Top := ScaleY(90 + ImgSize + 12);

  Icon2Radio.Width := ScaleX(ImgSize);
  Icon2Radio.Height := ScaleY(20);

  Icon2Radio.Caption := 'Icon 2';
end;


{ ============================================================
  PORTRAIT PAGE
  ============================================================ }

procedure CreatePortraitPage;
var
  AvailWidth: Integer;
  ImgWidth: Integer;
  ImgHeight: Integer;
  Gap: Integer;
  BlockLeft: Integer;
begin
  PortraitPage := CreateCustomPage(
    IconPage.ID,
    'Choose a Portrait',
    'Select the portrait that will be displayed by OpenUtau.'
  );

  AvailWidth := PortraitPage.Surface.ClientWidth - (PageMargin * 2);

  PortraitTitle := CreateLabel(
    PortraitPage.Surface,
    'Voicebank Portrait',
    PageMargin,
    8,
    AvailWidth,
    30,
    14
  );

  PortraitTitle.Alignment := taCenter;


  PortraitInfo := CreateLabel(
    PortraitPage.Surface,
    'Choose the artwork you want to use as the singer portrait.',
    PageMargin,
    42,
    AvailWidth,
    35,
    9
  );

  PortraitInfo.Alignment := taCenter;

  ImgWidth := 92;
  ImgHeight := 120;
  Gap := 26;

  BlockLeft := (PortraitPage.Surface.ClientWidth - (ImgWidth * 2 + Gap)) div 2;

  Portrait1Image := CreatePreviewImage(
    PortraitPage.Surface,
    ExpandConstant('{tmp}\portrait.bmp'),
    BlockLeft,
    86,
    ImgWidth,
    ImgHeight
  );


  Portrait2Image := CreatePreviewImage(
    PortraitPage.Surface,
    ExpandConstant('{tmp}\portrait2.bmp'),
    BlockLeft + ImgWidth + Gap,
    86,
    ImgWidth,
    ImgHeight
  );


  Portrait1Radio := TNewRadioButton.Create(PortraitPage);

  Portrait1Radio.Parent := PortraitPage.Surface;

  Portrait1Radio.Left := ScaleX(BlockLeft);
  Portrait1Radio.Top := ScaleY(86 + ImgHeight + 12);

  Portrait1Radio.Width := ScaleX(ImgWidth);
  Portrait1Radio.Height := ScaleY(20);

  Portrait1Radio.Caption := 'Portrait 1';

  Portrait1Radio.Checked := True;


  Portrait2Radio := TNewRadioButton.Create(PortraitPage);

  Portrait2Radio.Parent := PortraitPage.Surface;

  Portrait2Radio.Left := ScaleX(BlockLeft + ImgWidth + Gap);
  Portrait2Radio.Top := ScaleY(86 + ImgHeight + 12);

  Portrait2Radio.Width := ScaleX(ImgWidth);
  Portrait2Radio.Height := ScaleY(20);

  Portrait2Radio.Caption := 'Portrait 2';
end;


{ ============================================================
  INSTALL LOCATION
  ============================================================ }

function GetSelectedInstallPath: String;
var
  BasePath: String;
  SuffixLen: Integer;
begin

  if OpenUtauRadio.Checked then
  begin
    BasePath :=
      ExpandConstant(
        '{userdocs}\OpenUtau\Singers'
      );
  end

  else if UtauRadio.Checked then
  begin
    BasePath :=
      ExpandConstant(
        '{userappdata}\UTAU\voice'
      );
  end

  else
  begin
    BasePath := InstallPathEdit.Text;
  end;

  BasePath := RemoveBackslashUnlessRoot(BasePath);

  SuffixLen := Length(VoicebankFolderName);

  { Si el usuario ya navegó/escribió directamente hasta la
    carpeta del voicebank (por ejemplo porque reinstaló sobre
    la misma carpeta), no la volvemos a añadir. Antes esto
    producía rutas duplicadas como
    "...\Ver.1.02\海音アルラ Umine Alhura Ver.1.02". }
  if (Length(BasePath) >= SuffixLen) and
     (Lowercase(Copy(BasePath, Length(BasePath) - SuffixLen + 1, SuffixLen)) =
      Lowercase(VoicebankFolderName)) then
  begin
    Result := BasePath;
  end
  else
  begin
    Result := AddBackslash(BasePath) + VoicebankFolderName;
  end;
end;


{ ============================================================
  FIND CHARACTER CONFIG
  ============================================================ }

function FindCharacterConfig: String;
begin
  Result :=
    ExpandConstant('{app}\character.yaml');

  if FileExists(Result) then
    Exit;

  Result :=
    ExpandConstant('{app}\character.yml');

  if FileExists(Result) then
    Exit;

  Result := '';
end;


{ ============================================================
  CONFIGURE CHARACTER.YAML
  ============================================================ }

function ConfigureSelectedCharacter: Boolean;
var
  ConfigFile: String;
  Lines: TArrayOfString;

  I: Integer;

  SelectedImage: String;
  SelectedPortrait: String;

  FoundImage: Boolean;
  FoundPortrait: Boolean;

  LineText: String;
begin

  Result := False;

  ConfigFile := FindCharacterConfig;

  if ConfigFile = '' then
  begin
    MsgBox(
      'The voicebank was installed, but character.yaml / character.yml could not be found.' +      #13#10#13#10 +
      'The selected artwork could not be applied automatically.',
      mbError,
      MB_OK
    );

    Exit;
  end;


  if Icon2Radio.Checked then
    SelectedImage := 'icon2.bmp'
  else
    SelectedImage := 'icon.bmp';


  if Portrait2Radio.Checked then
    SelectedPortrait := 'portrait2.png'
  else
    SelectedPortrait := 'portrait.png';


  if not LoadStringsFromFile(
    ConfigFile,
    Lines
  ) then
  begin

    MsgBox(
      'Could not read:' +      #13#10 +
      ConfigFile,
      mbError,
      MB_OK
    );

    Exit;
  end;


  FoundImage := False;
  FoundPortrait := False;


  for I := 0 to GetArrayLength(Lines) - 1 do
  begin

    LineText := Trim(Lines[I]);


    if Pos('image:', LineText) = 1 then
    begin
      Lines[I] :=
        'image: ' +
        SelectedImage;

      FoundImage := True;
    end

    else if Pos('portrait:', LineText) = 1 then
    begin
      Lines[I] :=
        'portrait: ' +
        SelectedPortrait;

      FoundPortrait := True;
    end;

  end;


  if not FoundImage then
  begin

    SetArrayLength(
      Lines,
      GetArrayLength(Lines) + 1
    );

    Lines[
      GetArrayLength(Lines) - 1
    ] :=
      'image: ' +
      SelectedImage;

  end;


  if not FoundPortrait then
  begin

    SetArrayLength(
      Lines,
      GetArrayLength(Lines) + 1
    );

    Lines[
      GetArrayLength(Lines) - 1
    ] :=
      'portrait: ' +
      SelectedPortrait;

  end;


  if not SaveStringsToUTF8FileWithoutBOM(
    ConfigFile,
    Lines,
    False
  ) then
  begin

    MsgBox(
      'Could not update:' +      #13#10 +
      ConfigFile,
      mbError,
      MB_OK
    );

    Exit;
  end;


  Result := True;
end;


{ ============================================================
  DOWNLOADS
  ============================================================ }

procedure PrepareDownloads;
var
  DownloadPage: TDownloadWizardPage;

  CoreZip: String;
  SweetZip: String;
  AssetsZip: String;

begin

  if DownloadsPrepared then
    Exit;


  DownloadPage :=
    CreateDownloadPage(
      'Downloading Voicebank',
      'Please wait while the required files are downloaded.',
      nil
    );


  CoreZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-core-1.02.zip'
    );


  SweetZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-sweet-1.02.zip'
    );


  AssetsZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-assets-1.02.zip'
    );


  DownloadPage.Clear;


  DownloadPage.Add(
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-core-1.02.zip',
    'umine-alhura-core-1.02.zip',
    'bebcd4d7fae1c201114c079d46279c9df8e26fe2891b923597dce0287b167048'
  );


  if SweetSelected then
  begin

    DownloadPage.Add(
      'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-sweet-1.02.zip',
      'umine-alhura-sweet-1.02.zip',
      'ef43b059d9fca6b9dd770e158832c8e5279df4ae7c11f58af3ddbcc6d005f5af'
    );

  end;


  DownloadPage.Add(
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-assets-1.02.zip',
    'umine-alhura-assets-1.02.zip',
    '26ca39697318fa78f3925ef35a4bf57dcd2b6ad10591464eec1ea5b635992f84'
  );


  DownloadPage.Show;

  try

    DownloadPage.Download;

  except

    MsgBox(
      'An error occurred while downloading the voicebank files.' +      #13#10#13#10 +
      GetExceptionMessage,
      mbError,
      MB_OK
    );

    Abort;

  finally

    DownloadPage.Hide;

  end;


  DownloadsPrepared := True;
end;


{ ============================================================
  EXTRACT DOWNLOADS
  ============================================================ }

procedure ExtractDownloadedFiles;
var
  CoreZip: String;
  SweetZip: String;
  AssetsZip: String;

begin

  CoreZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-core-1.02.zip'
    );


  SweetZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-sweet-1.02.zip'
    );


  AssetsZip :=
    ExpandConstant(
      '{tmp}\umine-alhura-assets-1.02.zip'
    );


  ForceDirectories(
    ExpandConstant('{app}')
  );


  try

    ExtractArchive(
      CoreZip,
      ExpandConstant('{app}'),
      '',
      True,
      nil
    );


    if SweetSelected then
    begin

      ExtractArchive(
        SweetZip,
        ExpandConstant('{app}'),
        '',
        True,
        nil
      );

    end;


    ExtractArchive(
      AssetsZip,
      ExpandConstant('{app}'),
      '',
      True,
      nil
    );


  except

    MsgBox(
      'The voicebank archives could not be extracted.' +      #13#10#13#10 +
      GetExceptionMessage,
      mbError,
      MB_OK
    );

    Abort;

  end;

end;


{ ============================================================
  READY PAGE
  ============================================================ }

function UpdateReadyMemo(
  Space,
  NewLine,
  MemoUserInfoInfo,
  MemoDirInfo,
  MemoTypeInfo,
  MemoComponentsInfo,
  MemoGroupInfo,
  MemoTasksInfo: String): String;
var
  SelectedDir: String;
begin

  { Reutiliza la misma función que ya evita duplicar el
    nombre de la carpeta del voicebank. }
  SelectedDir :=
    GetSelectedInstallPath;


  Result :=
    MemoUserInfoInfo +
    Space +
    'Installation folder:' +
    NewLine +
    Space +
    Space +
    SelectedDir +
    NewLine +
    NewLine +

    Space +
    'Voice colors:' +
    NewLine +
    Space +
    Space +
    'Core';

  if SweetCheck.Checked then
  begin

    Result :=
      Result +
      NewLine +
      Space +
      Space +
      'Sweet';

  end;


  Result :=
    Result +
    NewLine +
    NewLine +

    Space +
    'Artwork:' +
    NewLine +
    Space +
    Space +
    'Icon: ';

  if Icon2Radio.Checked then
    Result := Result + 'Icon 2'
  else
    Result := Result + 'Icon 1';


  Result :=
    Result +
    NewLine +
    Space +
    Space +
    'Portrait: ';


  if Portrait2Radio.Checked then
    Result := Result + 'Portrait 2'
  else
    Result := Result + 'Portrait 1';


  Result :=
    Result +
    NewLine +
    NewLine +
    MemoTypeInfo +
    MemoComponentsInfo +
    MemoGroupInfo +
    MemoTasksInfo;
end;


{ ============================================================
  NEXT BUTTON
  ============================================================ }

function NextButtonClick(
  CurPageID: Integer): Boolean;
begin

  Result := True;


  if CurPageID = VoicebankPage.ID then
  begin

    SweetSelected :=
      SweetCheck.Checked;

    CoreSelected :=
      True;

  end;


  if CurPageID = InstallPage.ID then
  begin

    SelectedInstallPath :=
      GetSelectedInstallPath;

    { Ya no se bloquean rutas dentro de "Program Files": el
      instalador corre con permisos de administrador
      (PrivilegesRequired=admin), así que puede escribir en
      cualquier ubicación que el usuario elija, incluyendo
      "Custom location" apuntando a Program Files. }
    WizardForm.DirEdit.Text :=
      SelectedInstallPath;

  end;


  if CurPageID = PortraitPage.ID then
  begin

    PrepareDownloads;

  end;

end;


{ ============================================================
  PREPARE TO INSTALL
  ============================================================ }

function PrepareToInstall(
  var NeedsRestart: Boolean): String;
begin

  Result := '';

  SweetSelected :=
    SweetCheck.Checked;

  CoreSelected :=
    True;

  SelectedInstallPath :=
    GetSelectedInstallPath;

  { Sin restricción de "Program Files": ya corre como admin. }
  WizardForm.DirEdit.Text :=
    SelectedInstallPath;


  try

    PrepareDownloads;

  except

    Result :=
      'The required voicebank files could not be downloaded.';

  end;

end;


{ ============================================================
  INSTALLATION STEPS
  ============================================================ }

procedure CurStepChanged(
  CurStep: TSetupStep);
begin

  if CurStep = ssInstall then
  begin

    ExtractDownloadedFiles;
  end;


  if CurStep = ssPostInstall then
  begin

    ConfigureSelectedCharacter;
  end;

end;


{ ============================================================
  PAGE CHANGED
  ============================================================ }

procedure CurPageChanged(
  CurPageID: Integer);
begin

  { La página de bienvenida (wpWelcome) es la única página
    que Inno muestra ANTES de que exista una oportunidad de
    reafirmar el z-order (el BringToFront hecho dentro de
    InitializeWizard ocurre antes de que el asistente sea
    realmente visible en pantalla, así que no es fiable para
    la primera página). }
  if CurPageID = wpWelcome then
  begin
    WizardForm.BringToFront;

    { Se oculta la imagen grande por defecto de la página de
      bienvenida: ya no se muestra ninguna imagen aquí. }
    WizardForm.WizardBitmapImage.Visible := False;
  end;


  if CurPageID = IntroPage.ID then
  begin
    WizardForm.BringToFront;
  end;


  if CurPageID = VoicebankPage.ID then
  begin
    WizardForm.BringToFront;
  end;


  if CurPageID = InstallPage.ID then
  begin
    WizardForm.BringToFront;
  end;


  if CurPageID = IconPage.ID then
  begin
    WizardForm.BringToFront;
  end;


  if CurPageID = PortraitPage.ID then
  begin
    WizardForm.BringToFront;
  end;


  if CurPageID = wpFinished then
  begin
    WizardForm.BringToFront;

    { Se oculta la imagen grande de la página final: ya no
      se muestra ningún retrato al terminar la instalación. }
    WizardForm.WizardBitmapImage2.Visible := False;
  end;

end;

{ ============================================================
  INITIALIZE
  ============================================================ }

procedure InitializeWizard;
begin

  { ----------------------------------------------------------
   Extraer los archivos visuales/audio del instalador.
   ---------------------------------------------------------- }

  ExtractTemporaryFile(
    '_Hello_Planet__Alhutau.wav'
  );

  ExtractTemporaryFile(
    'icon.bmp'
  );

  ExtractTemporaryFile(
    'icon2.bmp'
  );

  ExtractTemporaryFile(
    'portrait.bmp'
  );

  ExtractTemporaryFile(
    'portrait2.bmp'
  );

  ExtractTemporaryFile(
    'boxart.bmp'
  );
  
  { ----------------------------------------------------------
   Music
   ----------------------------------------------------------}

  StartBackgroundMusic;


  { ----------------------------------------------------------
   Custom pages
   ----------------------------------------------------------}

  CreateIntroPage;

  CreateVoicebankPage;

  CreateInstallPage;

  CreateIconPage;

  CreatePortraitPage;


  { ----------------------------------------------------------
   Default values
   ----------------------------------------------------------}

  CoreSelected := True;
  SweetSelected := True;
  DownloadsPrepared := False;

  SelectedInstallPath :=
    ExpandConstant(
      '{userdocs}\OpenUtau\Singers\海音アルラ Umine Alhura Ver.1.02'
    );

end;


{ ============================================================
  DEINITIALIZE
  ============================================================ }

procedure DeinitializeSetup;
begin

  StopBackgroundMusic;

end;
