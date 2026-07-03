{
  lib,
  cmake,
  fftw,
  kdePackages,
  libmpdclient,
  libpulseaudio,
  pipewire,
  pkg-config,
  buildPackages,
  fetchgit,
  pkgsBuildTarget,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quester";
  version = "0.2.0-unstable-2026-07-01";

  src = fetchgit {
    url = "https://codeberg.org/anoraktrend/quester";
    rev = "8fc4997fe9f0f285e3d35786043f8b3655b424c3";
    hash = "sha256-/RDzbUKtKB+SZhSuUJCt7c3uhlmC+w6UQeQ1m8KtH1Q=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    fftw
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
    kdePackages.kirigami
    libmpdclient
    libpulseaudio
    pipewire
    pkg-config
  ];

  postPatch = ''
    sed -i '334,336d' CMakeLists.txt
  '';

  enableParallelBuilding = true;

  meta = {
    homepage = "https://codeberg.org/anoraktrend/quester";
    description = "A QML-based MPD Client.";
    longDescription = ''
      A modern, visually rich MPD and Mopidy client built with Qt 6 and QML

      Quester is a desktop client for the Music Player Daemon (MPD) and Mopidy. It provides a fluid user interface focused on album art and visual feedback. Built using C++ and Qt Quick (QML), it aims to offer a lightweight yet visually appealing way to browse and play your music library.
    '';
    license = lib.licenses.mit;
    mainProgram = "quester";
    maintainers = with lib.maintainers; [
      sed4906
    ];
    platforms = lib.platforms.unix;
  };
})
