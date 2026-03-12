{ stdenv, lib, gzip }:

let
  version = "0.9.1";

  # Build versioning — pre-computed in build-meta/*.json before each build
  buildMeta = builtins.fromJSON (builtins.readFile ../../build-meta/model-quantizer.json);
  buildVersion = buildMeta.build_version;
in
stdenv.mkDerivation {
  pname = "model-quantizer";
  inherit version;
  src = ../../.;

  nativeBuildInputs = [ gzip ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1 $out/share/doc/model-quantizer \
             $out/share/model-quantizer

    for script in scripts/*.sh; do
      name=$(basename "$script" .sh)
      cp "$script" "$out/bin/$name"
      chmod +x "$out/bin/$name"
    done

    cp scripts/setup-venv "$out/bin/setup-venv"
    chmod +x "$out/bin/setup-venv"

    for page in man/*.1; do
      gzip -c "$page" > "$out/share/man/man1/$(basename "$page").gz"
    done

    cp README.md $out/share/doc/model-quantizer/

    cat > $out/share/model-quantizer/flox-build-version-${toString buildVersion} <<'MARKER'
build-version: ${toString buildVersion}
version: ${version}
git-rev: ${buildMeta.git_rev}
git-rev-short: ${buildMeta.git_rev_short}
force-increment: ${toString buildMeta.force_increment}
changelog: ${buildMeta.changelog}
MARKER
  '';

  meta = with lib; {
    description = "HuggingFace model quantization tools (AWQ, FP8, LLM Compressor)";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
