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

; Carpeta BASE: dentro se crean una subcarpeta por cada versión
; que se elija instalar (CVVC y/o CV), así que el directorio que
; se muestra/elige ya no es el de un voicebank concreto.
DefaultDirName={userdocs}\OpenUtau\Singers
DisableDirPage=yes
DisableProgramGroupPage=yes

OutputDir=Output
OutputBaseFilename=UmineAlhura-1.02-Setup

Compression=lzma2
SolidCompression=yes

WizardStyle=classic
; IMPORTANTE: con WizardStyle=classic, Inno Setup SOLO admite BMP
; para estas imágenes (el soporte de PNG es exclusivo del estilo
; "modern").
;
; El panel grande que Inno reserva de forma nativa para
; WizardImageFile (Welcome/Finished) tiene un tamaño FIJO, y si
; boxart.bmp es más grande que ese panel lo recorta. Por eso esa
; imagen nativa se oculta desde [Code] (InitializeWizard) y, en
; su lugar, el mismo boxart.bmp se agrega a mano —ya escalado a
; un tamaño máximo controlado (ver BoxartMaxWidth/BoxartMaxHeight
; en [Code])— en todas las páginas, EXCEPTO Ready, Installing y
; la de descargas, tal como se pidió.
WizardImageFile=assets\boxart.bmp
WizardSmallImageFile=assets\LOGO.bmp

WizardImageBackColor=white
WizardSmallImageBackColor=white

WizardImageStretch=no

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

  { Separación horizontal entre el boxart y la columna de
    contenido que queda a su derecha. }
  BoxartGap = 20;

  { Top que usa el boxart en todas las páginas; coincide con el
    Top que ya usaban los títulos, para que la imagen y la
    primera fila de contenido queden alineadas ("misma fila"). }
  BoxartTop = 8;

  { Tamaño MÁXIMO que puede ocupar el boxart (ancho y alto). Se
    achica manteniendo su proporción hasta entrar en este
    recuadro; si ya es más chico que esto, no se agranda. La
    imagen fuente es 347x500 (proporción ~0.69); estos valores
    respetan esa proporción. Subir/bajar estos dos números para
    hacer la imagen más grande o más chica. }
  BoxartMaxWidth = 200;
  BoxartMaxHeight = 353;

  { ----------------------------------------------------------
    Voicebanks: cada versión se instala en su propia carpeta
    dentro de la carpeta base elegida.
    ---------------------------------------------------------- }

  { CVVC (Ver.1.00): la versión nueva, es la que viene por
    defecto y su zip ya trae los assets (character.yaml, icon,
    portrait) junto con los audios. }
  CvvcFolderName = 'CVVC 海音アルラ Umine Alhura Ver.1.00';

  { CV (Ver.1.02): la versión clásica, opcional. Sus audios
    vienen en el release 1.02 (Core + Sweet) y sus assets en un
    zip aparte, igual que siempre. }
  CvFolderName = '海音アルラ Umine Alhura Ver.1.02';

  { Carpeta temporal (creada dentro de la carpeta base, para que
    el rename final sea del mismo volumen e instantáneo) donde
    se extrae el zip del CVVC antes de moverlo a su carpeta
    definitiva. Sirve para ignorar/igualar el nombre de la
    carpeta raíz que trae el zip. }
  CvvcStagingName = '_umine_cvvc_tmp';

  { ----------------------------------------------------------
    Archivos a descargar
    ---------------------------------------------------------- }

  CVVC_ZIP_URL =
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/CVVC-V1.00/umine-alhura-cvvc-1.00.zip';

  CVVC_ZIP_FILE = 'umine-alhura-cvvc-1.00.zip';

  CVVC_ZIP_SHA256 =
    '199e21f33545cdfdd438ceb0f8b4d8fe676ce9d57a9747d61d51d11b1e435a28';

  CORE_ZIP_URL =
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-core-1.02.zip';

  CORE_ZIP_FILE = 'umine-alhura-core-1.02.zip';

  CORE_ZIP_SHA256 =
    'bebcd4d7fae1c201114c079d46279c9df8e26fe2891b923597dce0287b167048';

  SWEET_ZIP_URL =
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-sweet-1.02.zip';

  SWEET_ZIP_FILE = 'umine-alhura-sweet-1.02.zip';

  SWEET_ZIP_SHA256 =
    'ef43b059d9fca6b9dd770e158832c8e5279df4ae7c11f58af3ddbcc6d005f5af';

  ASSETS_ZIP_URL =
    'https://github.com/A-L-H-U-R-A/umine-alhura-releases/releases/download/1.02/umine-alhura-assets-1.02.zip';

  ASSETS_ZIP_FILE = 'umine-alhura-assets-1.02.zip';

  ASSETS_ZIP_SHA256 =
    '26ca39697318fa78f3925ef35a4bf57dcd2b6ad10591464eec1ea5b635992f84';


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

  CvvcCheck: TNewCheckBox;
  CvCheck: TNewCheckBox;
  SweetCheck: TNewCheckBox;

  SelectedInstallPath: String;

  { Selección hecha en la página de versiones. }
  CvvcSelected: Boolean;
  CvSelected: Boolean;
  SweetSelected: Boolean;

  { Página de descargas creada UNA sola vez y reutilizada entre
    llamadas a PrepareDownloads (por si el usuario vuelve atrás
    y cambia la selección, solo se descarga lo que falte). }
  DownloadPage: TDownloadWizardPage;

  { Boxart cargado UNA sola vez en memoria (en vez de leer
    boxart.bmp de disco en cada página) y tamaño de la columna
    de contenido que queda a la derecha de la imagen, calculado
    también una sola vez y reutilizado por todas las páginas
    (personalizadas y nativas). }
  BoxartBitmap: TBitmap;
  BoxartWidth: Integer;
  BoxartHeight: Integer;
  ContentLeft: Integer;


{ ============================================================
  HELPER: DESESCALAR (Actual px -> unidades de diseño)
  ============================================================
  ScaleX/ScaleY convierten unidades de diseño (96 DPI) a
  píxeles reales según el escalado de Windows. Pero
  Surface.ClientWidth/ClientHeight YA vienen en píxeles reales
  (post-escalado). Si se resta directamente contra ContentLeft/
  PageMargin/etc. (que son unidades de diseño sin escalar) y el
  resultado se vuelve a pasar por ScaleX/ScaleY más adelante
  (como hace CreateLabel), el cálculo queda
  en unidades mezcladas: al 100% de escala no se nota (ScaleX(x)
  = x), pero con escalado de Windows a 125%/150%/etc. las
  imágenes terminan corridas a la derecha y/o abajo, cada vez
  más lejos cuanto mayor es la escala.

  Estas dos funciones hacen la conversión inversa a ScaleX/
  ScaleY, para poder trabajar SIEMPRE en unidades de diseño y
  evitar esa mezcla. Se usa 10000 como base (en vez de un número
  chico) para minimizar el error de redondeo interno de
  ScaleX/ScaleY. }

function UnscaleX(Actual: Integer): Integer;
var
  Factor: Extended;
begin
  Factor := ScaleX(10000) / 10000.0;

  if Factor = 0 then
    Factor := 1;

  Result := Round(Actual / Factor);
end;


function UnscaleY(Actual: Integer): Integer;
var
  Factor: Extended;
begin
  Factor := ScaleY(10000) / 10000.0;

  if Factor = 0 then
    Factor := 1;

  Result := Round(Actual / Factor);
end;


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
  HELPER: CREAR IMAGEN DEL BOXART (tamaño natural, sin deformar)
  ============================================================
  El ancho/alto NO se fuerzan a un recuadro arbitrario: se usan
  BoxartWidth/BoxartHeight (el tamaño real del bitmap, calculado
  una sola vez en InitializeWizard) escalados por ScaleX/ScaleY
  solo para DPI. Como se escalan ambos lados por igual, la
  proporción original se conserva siempre.

  Se coloca siempre pegada al margen izquierdo (PageMargin) y al
  mismo Top (BoxartTop) en todas las páginas, para que quede
  alineada con la primera fila de contenido en cada una.
  ============================================================ }

function CreateBoxartImage(Parent: TWinControl): TBitmapImage;
begin
  Result := TBitmapImage.Create(Parent);

  Result.Parent := Parent;

  { Reutiliza el bitmap ya cargado en memoria en vez de leer
    boxart.bmp de disco otra vez por cada página. }
  Result.Bitmap.Assign(BoxartBitmap);

  Result.Stretch := True;

  Result.Left := ScaleX(PageMargin);
  Result.Top := ScaleY(BoxartTop);

  Result.Width := ScaleX(BoxartWidth);
  Result.Height := ScaleY(BoxartHeight);
end;


{ ============================================================
  HELPER: DESPLAZAR UN CONTROL NATIVO A LA COLUMNA DE CONTENIDO
  ============================================================
  Usado sobre controles nativos de Inno que YA existen en
  páginas que no se crean con CreateCustomPage (Ready,
  Installing): recorta el control desde la izquierda para que
  arranque en ContentLeft (a la derecha del boxart) conservando
  su borde derecho original, en vez de reposicionar todo el
  layout de esas páginas a mano.
  ============================================================ }

procedure ShiftControlRightOfContent(Ctrl: TControl);
var
  OriginalRight: Integer;
begin
  if Ctrl = nil then
    Exit;

  OriginalRight := Ctrl.Left + Ctrl.Width;

  Ctrl.Left := ScaleX(ContentLeft);
  Ctrl.Width := OriginalRight - Ctrl.Left;
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
begin
  IntroPage := CreateCustomPage(
    wpWelcome,
    'Welcome to the Umine Alhura Voicebank Installer',
    'Install and configure the 海音アルラ Umine Alhura voicebank.'
  );

  CreateBoxartImage(IntroPage.Surface);

  { El contenido ya no ocupa todo el ancho de la página: arranca
    en ContentLeft, a la derecha del boxart. }
  AvailWidth := UnscaleX(IntroPage.Surface.ClientWidth) - ContentLeft - PageMargin;

  IntroTitle := CreateLabel(
    IntroPage.Surface,
    '海音アルラ Umine Alhura',
    ContentLeft,
    BoxartTop,
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
    'Voicebanks: CVVC Ver.1.00 (default) + CV Ver.1.02 (optional)' + #13#10 +
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
  HELPER: CREAR CHECKBOX
  ============================================================ }

function CreateOptionCheck(
  Parent: TWinControl;
  CaptionText: String;
  TopPos: Integer;
  WidthPos: Integer;
  IsChecked: Boolean): TNewCheckBox;
begin
  Result := TNewCheckBox.Create(Parent);

  Result.Parent := Parent;

  Result.Left := ScaleX(ContentLeft);
  Result.Top := ScaleY(TopPos);

  Result.Width := ScaleX(WidthPos);
  Result.Height := ScaleY(20);

  Result.Caption := CaptionText;

  Result.Checked := IsChecked;
end;


{ ============================================================
  VOICEBANK PAGE
  ============================================================
  Ya no se elige "qué voicecolor": ahora se elige QUÉ VERSIONES
  instalar (CVVC y/o CV). El CVVC es la nueva por defecto y ya
  trae sus assets; el Sweet es un voicecolor del CV, así que su
  checkbox solo se habilita cuando se marca el CV.
  ============================================================ }

procedure CvCheckClick(Sender: TObject);
begin
  { El Sweet es un voicecolor del CV: solo se puede elegir si se
    va a instalar el CV. Si se desmarca el CV, su estado queda
    guardado por si se vuelve a marcar. }
  SweetCheck.Enabled := CvCheck.Checked;
end;


procedure CreateVoicebankPage;
var
  AvailWidth: Integer;
begin
  VoicebankPage := CreateCustomPage(
    IntroPage.ID,
    'Voicebank Versions',
    'Choose which voicebank versions you want to install.'
  );

  CreateBoxartImage(VoicebankPage.Surface);

  AvailWidth := UnscaleX(VoicebankPage.Surface.ClientWidth) - ContentLeft - PageMargin;

  VoicebankTitle := CreateLabel(
    VoicebankPage.Surface,
    'Voicebank Versions',
    ContentLeft,
    BoxartTop,
    AvailWidth,
    30,
    14
  );

  VoicebankTitle.Alignment := taCenter;

  VoicebankInfo := CreateLabel(
    VoicebankPage.Surface,
    'CVVC (Ver.1.00) is the new default and already includes its artwork.' + #13#10 +
    'The classic CV (Ver.1.02) is optional and can be installed alongside it.',
    ContentLeft,
    46,
    AvailWidth,
    35,
    9
  );

  VoicebankInfo.Alignment := taCenter;

  CvvcCheck := CreateOptionCheck(
    VoicebankPage.Surface,
    'Install CVVC — Ver.1.00 (default)',
    92,
    AvailWidth,
    True
  );

  CvCheck := CreateOptionCheck(
    VoicebankPage.Surface,
    'Install CV — Ver.1.02 (classic)',
    120,
    AvailWidth,
    False
  );

  CvCheck.OnClick := @CvCheckClick;

  SweetCheck := CreateOptionCheck(
    VoicebankPage.Surface,
    'Install Sweet append (_S) — CV voicecolor',
    148,
    AvailWidth,
    True
  );

  SweetCheck.Enabled := CvCheck.Checked;
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
    'Choose the base folder for the voicebanks.'
  );

  CreateBoxartImage(InstallPage.Surface);

  AvailWidth := UnscaleX(InstallPage.Surface.ClientWidth) - ContentLeft - PageMargin;
  BrowseWidth := 75;

  InstallTitle := CreateLabel(
    InstallPage.Surface,
    'Where should the voicebank folders be installed?',
    ContentLeft,
    BoxartTop,
    AvailWidth,
    30,
    14
  );

  InstallTitle.Alignment := taCenter;

  InstallInfo := CreateLabel(
    InstallPage.Surface,
    'One folder per selected version is created inside the base folder.' + #13#10 +
    'Choose one of the standard locations or select a custom folder.',
    ContentLeft,
    42,
    AvailWidth,
    35,
    9
  );

  InstallInfo.Alignment := taCenter;


  OpenUtauRadio := TNewRadioButton.Create(InstallPage);

  OpenUtauRadio.Parent := InstallPage.Surface;

  OpenUtauRadio.Left := ScaleX(ContentLeft);
  OpenUtauRadio.Top := ScaleY(90);

  OpenUtauRadio.Width := ScaleX(AvailWidth);
  OpenUtauRadio.Height := ScaleY(20);

  OpenUtauRadio.Caption :=
    'OpenUtau — Documents\OpenUtau\Singers';

  OpenUtauRadio.Checked := True;


  UtauRadio := TNewRadioButton.Create(InstallPage);

  UtauRadio.Parent := InstallPage.Surface;

  UtauRadio.Left := ScaleX(ContentLeft);
  UtauRadio.Top := ScaleY(118);

  UtauRadio.Width := ScaleX(AvailWidth);
  UtauRadio.Height := ScaleY(20);

  UtauRadio.Caption :=
    'UTAU — AppData\Roaming\UTAU\voice';


  CustomRadio := TNewRadioButton.Create(InstallPage);

  CustomRadio.Parent := InstallPage.Surface;

  CustomRadio.Left := ScaleX(ContentLeft);
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

  InstallPathEdit.Left := ScaleX(ContentLeft);
  InstallPathEdit.Top := ScaleY(182);

  InstallPathEdit.Width := ScaleX(EditWidth);
  InstallPathEdit.Height := ScaleY(23);

  { Se toma el valor inicial del directorio del wizard (respeta
    DefaultDirName o el /DIR que se pase al ejecutar el
    instalador). No se puede usar la constante app aquí porque
    todavía no está inicializada al crear las páginas. }
  InstallPathEdit.Text :=
    WizardForm.DirEdit.Text;

  if InstallPathEdit.Text = '' then
    InstallPathEdit.Text :=
      ExpandConstant('{userdocs}\OpenUtau\Singers');


  BrowseButton := TNewButton.Create(InstallPage);

  BrowseButton.Parent := InstallPage.Surface;

  BrowseButton.Left := ScaleX(ContentLeft + EditWidth + 10);
  BrowseButton.Top := ScaleY(181);

  BrowseButton.Width := ScaleX(BrowseWidth);
  BrowseButton.Height := ScaleY(25);

  BrowseButton.Caption := 'Browse...';

  BrowseButton.OnClick := @BrowseInstallFolder;
end;


{ ============================================================
  INSTALL LOCATION (carpeta BASE)
  ============================================================
  El usuario elige la carpeta base (por ejemplo
  Documents\OpenUtau\Singers). Dentro de ella el instalador crea
  UNA SUBCARPETA POR CADA VERSIÓN elegida:

    <base>\CVVC 海音アルラ Umine Alhura Ver.1.00   (si CVVC)
    <base>\海音アルラ Umine Alhura Ver.1.02         (si CV)

  Si la ruta ya termina con el nombre de alguna de esas carpetas
  (por ejemplo al reinstalar sobre una instalación anterior), se
  quita el sufijo para trabajar siempre con la base. Antes esto
  producía rutas duplicadas como
  "...\Ver.1.02\海音アルラ Umine Alhura Ver.1.02".
  ============================================================ }

function StripVoicebankFolderName(const BasePath: String): String;
var
  SuffixLen: Integer;
begin
  Result := BasePath;

  SuffixLen := Length(CvvcFolderName);

  if (Length(Result) >= SuffixLen) and
     (Lowercase(Copy(Result, Length(Result) - SuffixLen + 1, SuffixLen)) =
      Lowercase(CvvcFolderName)) then
  begin
    Result := RemoveBackslashUnlessRoot(ExtractFileDir(Result));
    Exit;
  end;

  SuffixLen := Length(CvFolderName);

  if (Length(Result) >= SuffixLen) and
     (Lowercase(Copy(Result, Length(Result) - SuffixLen + 1, SuffixLen)) =
      Lowercase(CvFolderName)) then
    Result := RemoveBackslashUnlessRoot(ExtractFileDir(Result));
end;


function GetSelectedBasePath: String;
var
  BasePath: String;
begin

  { En modo silencioso (SILENT/VERYSILENT) no hay interacción con
    el wizard: se respeta la carpeta que llega por /DIR en vez de
    imponer la ubicación por defecto del radio button. }
  if WizardSilent then
  begin
    BasePath := WizardForm.DirEdit.Text;

    if BasePath = '' then
      BasePath :=
        ExpandConstant('{userdocs}\OpenUtau\Singers');
  end

  else if OpenUtauRadio.Checked then
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

  Result := StripVoicebankFolderName(BasePath);
end;



{ ============================================================
  DOWNLOADS
  ============================================================
  Se descarga SOLO lo que falta: si el usuario vuelve atrás y
  cambia la selección, los zips que ya están en el directorio
  temporal del instalador no se vuelven a bajar. Por eso la lista
  se limpia y se agregan únicamente los archivos que no existen
  todavía.

  Qué se descarga según la página de versiones:

    CVVC  → umine-alhura-cvvc-1.00.zip   (audio + assets juntos)
    CV    → umine-alhura-core-1.02.zip   (siempre)
            + umine-alhura-assets-1.02.zip (character.yaml + arte por defecto)
            + umine-alhura-sweet-1.02.zip  (si se eligió Sweet)
  ============================================================ }

procedure PrepareDownloads;
var
  NeedDownload: Boolean;

  CvvcZip: String;
  CoreZip: String;
  SweetZip: String;
  AssetsZip: String;

begin

  if DownloadPage = nil then
    DownloadPage :=
      CreateDownloadPage(
        'Downloading Voicebank',
        'Please wait while the required files are downloaded.',
        nil
      );


  CvvcZip :=
    ExpandConstant('{tmp}\' + CVVC_ZIP_FILE);

  CoreZip :=
    ExpandConstant('{tmp}\' + CORE_ZIP_FILE);

  SweetZip :=
    ExpandConstant('{tmp}\' + SWEET_ZIP_FILE);

  AssetsZip :=
    ExpandConstant('{tmp}\' + ASSETS_ZIP_FILE);


  DownloadPage.Clear;

  NeedDownload := False;


  if CvvcSelected and (not FileExists(CvvcZip)) then
  begin

    DownloadPage.Add(
      CVVC_ZIP_URL,
      CVVC_ZIP_FILE,
      CVVC_ZIP_SHA256
    );

    NeedDownload := True;

  end;


  if CvSelected and (not FileExists(CoreZip)) then
  begin

    DownloadPage.Add(
      CORE_ZIP_URL,
      CORE_ZIP_FILE,
      CORE_ZIP_SHA256
    );

    NeedDownload := True;

  end;


  if CvSelected and SweetSelected and (not FileExists(SweetZip)) then
  begin

    DownloadPage.Add(
      SWEET_ZIP_URL,
      SWEET_ZIP_FILE,
      SWEET_ZIP_SHA256
    );

    NeedDownload := True;

  end;


  if CvSelected and (not FileExists(AssetsZip)) then
  begin

    DownloadPage.Add(
      ASSETS_ZIP_URL,
      ASSETS_ZIP_FILE,
      ASSETS_ZIP_SHA256
    );

    NeedDownload := True;

  end;


  { Nada nuevo que bajar: no se muestra la página de descargas. }
  if not NeedDownload then
    Exit;


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

end;


{ ============================================================
  CALLBACK DE PROGRESO DE EXTRACCIÓN
  ============================================================
  Sin este callback (pasando nil a ExtractArchive, como antes),
  Inno no tiene forma de saber qué está haciendo la extracción
  en segundo plano: la barra de progreso y el texto de estado
  de la página "Installing" se quedan congelados durante todo
  el proceso. Esta función se conecta como OnExtractionProgress
  y va actualizando StatusLabel (con el archivo actual) y
  ProgressGauge (con el porcentaje) en cada paso.
  ============================================================ }

function ExtractionProgress(
  const ArchiveName, FileName: String;
  const Progress, ProgressMax: Int64): Boolean;
var
  PercentDone: Integer;
begin
  if ProgressMax > 0 then
    PercentDone := (Progress * 100) div ProgressMax
  else
    PercentDone := 0;

  WizardForm.ProgressGauge.Max := 100;
  WizardForm.ProgressGauge.Position := PercentDone;

  WizardForm.StatusLabel.Caption :=
    'Extracting ' +
    ExtractFileName(ArchiveName) +
    ': ' +
    ExtractFileName(FileName);

  WizardForm.StatusLabel.Update;
  WizardForm.ProgressGauge.Update;

  { Devolver True permite que la extracción continúe. }
  Result := True;
end;


{ ============================================================
  EXTRACT DOWNLOADS
  ============================================================ }

{ ============================================================
  HELPER: ÚNICA SUBCARPETA DE UN DIRECTORIO
  ============================================================ }

function FindSingleSubDir(const ParentDir: String): String;
var
  FindRec: TFindRec;
  DirCount: Integer;
begin

  Result := '';
  DirCount := 0;


  if FindFirst(AddBackslash(ParentDir) + '*', FindRec) then
  try

    repeat

      if (FindRec.Name <> '.') and (FindRec.Name <> '..') and
         ((FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
      begin
        Inc(DirCount);

        Result := FindRec.Name;
      end;

    until not FindNext(FindRec);

  finally

    FindClose(FindRec);

  end;


  if DirCount <> 1 then
    Result := '';

end;


{ ============================================================
  EXTRACCIÓN DEL CVVC (aplanando la carpeta raíz del zip)
  ============================================================
  El zip del CVVC trae UNA sola carpeta raíz con todos sus
  archivos (audios + assets). Como el CVVC se instala en su
  propia carpeta dentro de la base:

  1. se extrae en una carpeta temporal dentro de la base
     (mismo volumen → los renombres no copian nada),
  2. se localiza esa carpeta raíz (sea cual sea el nombre con
     el que venga escrita en el zip),
  3. se renombra a la carpeta final, reemplazando si ya existía.

  Así no queda ninguna carpeta anidada de más y el nombre final
  es exactamente CvvcFolderName, sin importar la codificación
  con la que el zip almacene sus nombres.
  ============================================================ }

function ExtractCvvcVoicebank(const BaseDir: String): String;
var
  StagingDir: String;
  TargetDir: String;
  BackupDir: String;
  RootName: String;
  RootPath: String;
begin

  { Devuelve '' si salió bien, o el mensaje de error si falló.
    (El script no admite "raise", así que el error se devuelve.) }
  Result := '';

  TargetDir :=
    AddBackslash(BaseDir) + CvvcFolderName;

  StagingDir :=
    AddBackslash(BaseDir) + CvvcStagingName;


  { Limpia restos de una extracción anterior a medias. }
  DelTree(StagingDir, True, True, True);

  ForceDirectories(StagingDir);


  { Si esto falla, la excepción la captura el llamador. }
  ExtractArchive(
    ExpandConstant('{tmp}\' + CVVC_ZIP_FILE),
    StagingDir,
    '',
    True,
    @ExtractionProgress
  );


  RootName := FindSingleSubDir(StagingDir);

  if RootName = '' then
  begin
    DelTree(StagingDir, True, True, True);

    Result :=
      'The CVVC archive does not contain its expected root folder.';

    Exit;
  end;

  RootPath :=
    AddBackslash(StagingDir) + RootName;


  if DirExists(TargetDir) then
  begin

    { Se aparta la instalación anterior, se pone la nueva en su
      lugar y recién entonces se borra la vieja: si el rename
      fallara, la instalación anterior sigue intacta. }
    BackupDir := TargetDir + '.old';

    DelTree(BackupDir, True, True, True);

    if not RenameFile(TargetDir, BackupDir) then
    begin
      DelTree(StagingDir, True, True, True);

      Result :=
        'The previous CVVC folder could not be replaced:' + #13#10 +
        TargetDir;

      Exit;
    end;

    if not RenameFile(RootPath, TargetDir) then
    begin
      RenameFile(BackupDir, TargetDir);
      DelTree(StagingDir, True, True, True);

      Result :=
        'The CVVC folder could not be created:' + #13#10 +
        TargetDir;

      Exit;
    end;

    DelTree(BackupDir, True, True, True);

  end

  else if not RenameFile(RootPath, TargetDir) then
  begin
    DelTree(StagingDir, True, True, True);

    Result :=
      'The CVVC folder could not be created:' + #13#10 +
      TargetDir;

    Exit;
  end;


  DelTree(StagingDir, True, True, True);


  { Verificación rápida: si en algún momento cambia la
    estructura del release, se avisa en vez de instalar una
    carpeta vacía o incompleta. }
  if not FileExists(AddBackslash(TargetDir) + 'character.yaml') then
    MsgBox(
      'The CVVC voicebank was extracted, but character.yaml was not found in:' +      #13#10 +
      TargetDir,
      mbInformation,
      MB_OK
    );

end;


procedure ExtractDownloadedFiles;
var
  BaseDir: String;
  CvDir: String;
  ErrMsg: String;

begin

  { SelectedInstallPath es la carpeta BASE (no la de un
    voicebank concreto): dentro se crean las carpetas de cada
    versión que se instaló. }
  BaseDir := SelectedInstallPath;

  ErrMsg := '';


  if CvvcSelected then
  begin

    try

      ErrMsg := ExtractCvvcVoicebank(BaseDir);

    except

      { Si la extracción falló a medias, no se deja la carpeta
        temporal dentro de la base. }
      DelTree(
        AddBackslash(BaseDir) + CvvcStagingName,
        True,
        True,
        True
      );

      ErrMsg := GetExceptionMessage;

    end;

  end;


  if (ErrMsg = '') and CvSelected then
  begin

    CvDir :=
      AddBackslash(BaseDir) + CvFolderName;

    try

      ForceDirectories(CvDir);


      ExtractArchive(
        ExpandConstant('{tmp}\' + CORE_ZIP_FILE),
        CvDir,
        '',
        True,
        @ExtractionProgress
      );


      if SweetSelected then
      begin

        ExtractArchive(
          ExpandConstant('{tmp}\' + SWEET_ZIP_FILE),
          CvDir,
          '',
          True,
          @ExtractionProgress
        );

      end;


      { Los assets (character.yaml + arte por defecto) van
        al final, así sobrescriben lo que traigan los otros zips. }
      ExtractArchive(
        ExpandConstant('{tmp}\' + ASSETS_ZIP_FILE),
        CvDir,
        '',
        True,
        @ExtractionProgress
      );

    except

      ErrMsg := GetExceptionMessage;

    end;

  end;


  if ErrMsg <> '' then
  begin

    MsgBox(
      'The voicebank archives could not be extracted.' +      #13#10#13#10 +
      ErrMsg,
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

  { Carpeta BASE: dentro se crean las carpetas de cada versión. }
  SelectedDir :=
    GetSelectedBasePath;


  Result :=
    MemoUserInfoInfo +
    Space +
    'Base folder:' +
    NewLine +
    Space +
    Space +
    SelectedDir +
    NewLine +
    NewLine +

    Space +
    'Voicebanks to install:' +
    NewLine;


  if CvvcSelected then
  begin

    Result :=
      Result +
      Space +
      Space +
      CvvcFolderName +
      NewLine;

  end;


  if CvSelected then
  begin

    Result :=
      Result +
      Space +
      Space +
      CvFolderName +
      NewLine +
      Space +
      Space +
      Space +
      'Core';

    if SweetSelected then
    begin

      Result :=
        Result +
        NewLine +
        Space +
        Space +
        Space +
        'Sweet';

    end;

    Result := Result + NewLine;

  end;


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

    { Al menos una versión: sin nada seleccionado no hay nada
      que instalar. }
    if (not CvvcCheck.Checked) and (not CvCheck.Checked) then
    begin

      MsgBox(
        'Select at least one voicebank version to install.' +      #13#10#13#10 +
        'CVVC (Ver.1.00) is the default one; you can also add the classic CV (Ver.1.02).',
        mbError,
        MB_OK
      );

      Result := False;

      Exit;

    end;

    CvvcSelected := CvvcCheck.Checked;
    CvSelected := CvCheck.Checked;

    SweetSelected :=
      CvSelected and SweetCheck.Checked;

  end;


  if CurPageID = InstallPage.ID then
  begin

    SelectedInstallPath :=
      GetSelectedBasePath;

    { Ya no se bloquean rutas dentro de "Program Files": el
      instalador corre con permisos de administrador
      (PrivilegesRequired=admin), así que puede escribir en
      cualquier ubicación que el usuario elija, incluyendo
      "Custom location" apuntando a Program Files. }
    WizardForm.DirEdit.Text :=
      SelectedInstallPath;

    { Esta es la última página personalizada: aquí arrancan las
      descargas para que estén listas al llegar a Ready. }
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

  { Se releen los checkboxes por si el usuario volvió atrás y
    cambió la selección después de la última página de versiones. }
  CvvcSelected := CvvcCheck.Checked;
  CvSelected := CvCheck.Checked;

  SweetSelected :=
    CvSelected and SweetCheck.Checked;

  SelectedInstallPath :=
    GetSelectedBasePath;

  { Sin restricción de "Program Files": ya corre como admin. }
  WizardForm.DirEdit.Text :=
    SelectedInstallPath;


  if (not CvvcSelected) and (not CvSelected) then
  begin

    Result :=
      'Select at least one voicebank version to install.';

    Exit;

  end;


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

end;


{ ============================================================
  PAGE CHANGED
  ============================================================
  Ya no hace falta ocultar/expandir nada aquí: el boxart se
  muestra de forma nativa en wpWelcome/wpFinished (vía
  WizardImageFile) y se añadió a mano en el resto de páginas
  desde InitializeWizard/CreateBoxartImage. Solo queda
  reafirmar el z-order al cambiar de página.
  ============================================================ }

procedure CurPageChanged(
  CurPageID: Integer);
begin

  if CurPageID = wpWelcome then
    WizardForm.BringToFront;

  if CurPageID = IntroPage.ID then
    WizardForm.BringToFront;

  if CurPageID = VoicebankPage.ID then
    WizardForm.BringToFront;

  if CurPageID = InstallPage.ID then
    WizardForm.BringToFront;

  if CurPageID = wpFinished then
    WizardForm.BringToFront;

end;

{ ============================================================
  INITIALIZE
  ============================================================ }

procedure InitializeWizard;
var
  NaturalWidth: Integer;
  NaturalHeight: Integer;
  WidthRatio: Double;
  HeightRatio: Double;
  ScaleRatio: Double;
  FinishedBoxartImg: TBitmapImage;
begin

  { ----------------------------------------------------------
   Extraer los archivos visuales/audio del instalador.
   ---------------------------------------------------------- }

  ExtractTemporaryFile(
    '_Hello_Planet__Alhutau.wav'
  );

  ExtractTemporaryFile(
    'boxart.bmp'
  );

  { ----------------------------------------------------------
   Boxart: se carga UNA sola vez en memoria y se calcula,
   también una sola vez, el ancho de la columna de contenido
   que queda a la derecha de la imagen. Todas las páginas
   (personalizadas y nativas) reutilizan ContentLeft/
   BoxartWidth/BoxartHeight para su layout.
   ---------------------------------------------------------- }

  BoxartBitmap := TBitmap.Create;
  BoxartBitmap.LoadFromFile(ExpandConstant('{tmp}\boxart.bmp'));

  NaturalWidth := BoxartBitmap.Width;
  NaturalHeight := BoxartBitmap.Height;

  { Se achica el boxart, manteniendo su proporción, hasta que
    entre en el recuadro BoxartMaxWidth x BoxartMaxHeight. Si ya
    es más chico que ese recuadro, no se agranda (ScaleRatio no
    pasa de 1).

    El "* 1.0" en el numerador fuerza división REAL: sin él, si
    el motor de script llegara a evaluar esto como división
    entera, BoxartMaxWidth/NaturalWidth (100/1748, por ejemplo)
    daría 0 en vez de 0.057, y la imagen terminaría con tamaño
    0x0 -- invisible en TODAS las páginas a la vez, que es
    justo lo que pasó. }
  WidthRatio := (BoxartMaxWidth * 1.0) / NaturalWidth;
  HeightRatio := (BoxartMaxHeight * 1.0) / NaturalHeight;

  if WidthRatio < HeightRatio then
    ScaleRatio := WidthRatio
  else
    ScaleRatio := HeightRatio;

  if ScaleRatio > 1 then
    ScaleRatio := 1;

  BoxartWidth := Round(NaturalWidth * ScaleRatio);
  BoxartHeight := Round(NaturalHeight * ScaleRatio);

  { Piso de seguridad: nunca dejar la imagen en 0 (o casi 0) por
    algún caso raro de redondeo, para que jamás vuelva a quedar
    invisible. }
  if BoxartWidth < 20 then
    BoxartWidth := 20;

  if BoxartHeight < 20 then
    BoxartHeight := 20;

  ContentLeft := PageMargin + BoxartWidth + BoxartGap;


   { ----------------------------------------------------------
    Music
    ----------------------------------------------------------}

  if not WizardSilent then
    StartBackgroundMusic;


  { ----------------------------------------------------------
   Custom pages
   ----------------------------------------------------------}

  CreateIntroPage;

  CreateVoicebankPage;

  CreateInstallPage;

  { Si el directorio inicial no es el de OpenUtau (por ejemplo
    porque se pasó /DIR al ejecutar el instalador), se marca la
    ubicación personalizada para que esa sea la carpeta base que
    se use en vez del valor por defecto del radio button. }
  if (WizardForm.DirEdit.Text <> '') and
     (Lowercase(WizardForm.DirEdit.Text) <>
      Lowercase(ExpandConstant('{userdocs}\OpenUtau\Singers'))) then
  begin
    InstallPathEdit.Text := WizardForm.DirEdit.Text;

    CustomRadio.Checked := True;
  end;


  { ----------------------------------------------------------
   Ready / Installing / Descargas: a pedido, estas páginas se
   quedan SIN boxart, tal cual se ven por defecto.
   ----------------------------------------------------------}


  { ----------------------------------------------------------
   Welcome / Finished: el panel que Inno reserva de forma
   nativa para WizardImageFile tiene un tamaño FIJO; si el
   boxart es más grande que ese panel, lo recorta (por eso se
   veía "cortado a la mitad"). Se oculta esa imagen nativa y se
   agrega el boxart ya escalado a mano (BoxartWidth/
   BoxartHeight), con el mismo tamaño que usa el resto de
   páginas.
   ----------------------------------------------------------}

  WizardForm.WizardBitmapImage.Visible := False;
  CreateBoxartImage(WizardForm.WelcomeLabel1.Parent);
  ShiftControlRightOfContent(WizardForm.WelcomeLabel1);
  ShiftControlRightOfContent(WizardForm.WelcomeLabel2);

  WizardForm.WizardBitmapImage2.Visible := False;

  FinishedBoxartImg := CreateBoxartImage(WizardForm.FinishedLabel.Parent);

  { Centrado vertical: Top/Height de FinishedBoxartImg ya están en
    píxeles reales (CreateBoxartImage ya les aplicó ScaleY), así que
    el cálculo se hace directo contra el ClientHeight del contenedor,
    sin volver a escalar. Esto hace que la imagen se recentre sola
    cada vez que cambia BoxartMaxWidth/BoxartMaxHeight, en vez de
    quedar pegada al Top fijo (BoxartTop) que usan el resto de
    páginas. }
  FinishedBoxartImg.Top :=
    (WizardForm.FinishedLabel.Parent.ClientHeight - FinishedBoxartImg.Height) div 2;

  if FinishedBoxartImg.Top < 0 then
    FinishedBoxartImg.Top := 0;

  ShiftControlRightOfContent(WizardForm.FinishedHeadingLabel);
  ShiftControlRightOfContent(WizardForm.FinishedLabel);
  ShiftControlRightOfContent(WizardForm.RunList);


  { ----------------------------------------------------------
   Default values
   ----------------------------------------------------------}

  { Por defecto se instala el CVVC (la versión nueva); el CV es
    opcional y su Sweet solo se habilita si se marca el CV
    (que además arranca marcado, como hasta ahora). }
  CvvcSelected := True;
  CvSelected := False;
  SweetSelected := True;

  SelectedInstallPath :=
    ExpandConstant(
      '{userdocs}\OpenUtau\Singers'
    );

  DownloadPage := nil;

end;


{ ============================================================
  DEINITIALIZE
  ============================================================ }

procedure DeinitializeSetup;
begin

  StopBackgroundMusic;

  if BoxartBitmap <> nil then
    BoxartBitmap.Free;

end;
