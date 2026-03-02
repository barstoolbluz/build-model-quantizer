{ stdenv, lib, gzip }:

let
  version = "0.1.0";
  buildRevision = "2";
  buildNotes = ''
    Add setup-venv script to package.
    Fix usage output for all quantize scripts (print comment header, not raw source).
  '';
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

    printf '%s\n' "${buildNotes}" > "$out/share/model-quantizer/BUILD-${version}-r${buildRevision}"
  '';

  meta = with lib; {
    description = "HuggingFace model quantization tools (AWQ, FP8, LLM Compressor)";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
