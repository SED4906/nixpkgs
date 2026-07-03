{
  lib,
  bison,
  buildPackages,
  fetchFromGitHub,
  pkgsBuildTarget,
  stdenv,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jam-haiku";
  version = "2.5-unstable-2026-05-19";

  src = fetchFromGitHub {
    owner = "haiku";
    repo = "buildtools";
    rev = "bfa561e3708c0e2d0155fb403b988ba515c9b16d";
    hash = "sha256-LmsSCDGSIARVPlRoK4D+7LJv3C3V7n9P9K+hNdYII7I=";
  };

  sourceRoot = "${finalAttrs.src.name}/jam";

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    bison
  ];

  enableParallelBuilding = true;

  strictDeps = true;

  postPatch = ''
    substituteInPlace jam.h --replace-fail 'ifdef linux' 'ifdef __linux__'
  ''
  +
    # When cross-compiling, we need to set the preprocessor macros
    # OSMAJOR/OSMINOR/OSPLAT to the values from the target platform, not the host
    # platform. This looks a little ridiculous because the vast majority of build
    # tools don't embed target-specific information into their binary, but in this
    # case we behave more like a compiler than a make(1)-alike.
    lib.optionalString (stdenv.hostPlatform != stdenv.targetPlatform) ''
       cat >>jam.h <<EOF
       #undef OSMAJOR
       #undef OSMINOR
       #undef OSPLAT
       $(
         gcc -E -dM jam.h | grep -E '^#define (OSMAJOR|OSMINOR|OSPLAT) '
        )
      EOF
    '';

  installPhase = ''
    runHook preInstall

    ./jam0 -sBINDIR=$out/bin install
    install -Dm644 -t ''${!outputDoc}/share/doc/jam-${finalAttrs.version}/ *.html

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "jam -v";
    };
    tests.os = testers.runCommand {
      name = "${finalAttrs.finalPackage.name}-os";
      nativeBuildInputs = [ finalAttrs.finalPackage ];
      script = ''
        echo 'echo $(OS) ;' > Jamfile
        os=$(jam -d0)
        [[ $os != UNKNOWN* ]] && touch $out
      '';
    };
  };

  meta = {
    homepage = "https://www.haiku-os.org/guides/building/jam";
    description = "Just Another Make (Haiku buildtools)";
    longDescription = ''
      Jam is a program construction tool, like make(1).

      Jam recursively builds target files from source files, using dependency
      information and updating actions expressed in the Jambase file, which is
      written in jam's own interpreted language. The default Jambase is compiled
      into jam and provides a boilerplate for common use, relying on a
      user-provide file "Jamfile" to enumerate actual targets and sources.

      This is Haiku's custom fork.
    '';
    license = lib.licenses.free;
    mainProgram = "jam";
    maintainers = with lib.maintainers; [
      sed4906
    ];
    platforms = lib.platforms.unix;
  };
})
