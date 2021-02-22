{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, mednafen
, gtk2 ? null
, gtk3 ? null
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "mednaffe";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "AmatCoder";
    repo = "mednaffe";
    rev = version;
    sha256 = "sha256-BS/GNnRYj9klc4RRj7LwNikgApNttv4IyWPL694j+gM=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config wrapGAppsHook ];
  buildInputs = [ gtk2 gtk3 mednafen ];

  configureFlags = [ (lib.enableFeature (gtk3 != null) "gtk3") ];

  dontWrapGApps = true;

  postInstall = ''
    wrapProgram $out/bin/mednaffe \
      --prefix PATH ':' "${mednafen}/bin" \
      "''${gappsWrapperArgs[@]}"
   '';

  meta = with lib; {
    description = "GTK-based frontend for mednafen emulator";
    homepage = "https://github.com/AmatCoder/mednaffe";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ sheenobu yegortimoshenko AndersonTorres ];
    platforms = platforms.linux;
  };
}
