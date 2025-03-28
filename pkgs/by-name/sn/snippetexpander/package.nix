{
  lib,
  buildGoModule,
  makeWrapper,
  scdoc,
  installShellFiles,
  snippetexpanderd,
  snippetexpanderx,
}:

buildGoModule rec {
  inherit (snippetexpanderd) src version;

  pname = "snippetexpander";

  vendorHash = "sha256-2nLO/b6XQC88VXE+SewhgKpkRtIHsva+fDudgKpvZiY=";

  proxyVendor = true;

  modRoot = "cmd/snippetexpander";

  nativeBuildInputs = [
    makeWrapper
    scdoc
    installShellFiles
  ];

  buildInputs = [
    snippetexpanderd
    snippetexpanderx
  ];

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${src.rev}'"
  ];

  postInstall = ''
    make man
    installManPage snippetexpander.1
  '';

  postFixup = ''
    # Ensure snippetexpanderd and snippetexpanderx are available to start/stop.
    wrapProgram $out/bin/snippetexpander \
      --prefix PATH : ${
        lib.makeBinPath [
          snippetexpanderd
          snippetexpanderx
        ]
      }
  '';

  meta = {
    description = "Your little expandable text snippet helper CLI";
    homepage = "https://snippetexpander.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snippetexpander";
  };
}
