{
  lib,
  fetchFromGitHub,
  python3Packages,

  # tests
  gitMinimal,
  ripgrep,
  writableTmpDirAsHomeHook,

  versionCheckHook,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "seagoat";
  version = "1.0.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kantord";
    repo = "SeaGOAT";
    tag = "v${version}";
    hash = "sha256-5fg9qv9rTEOxMWiYIp2sBABqrOUuB7K/VkUgwhM27n0=";
  };

  build-system = [ python3Packages.poetry-core ];

  pythonRelaxDeps = [
    "chromadb"
    "psutil"
    "setuptools"
  ];

  dependencies = with python3Packages; [
    appdirs
    blessed
    chardet
    chromadb
    deepmerge
    flask
    gitpython
    halo
    jsonschema
    nest-asyncio
    ollama
    psutil
    pygments
    requests
    stop-words
    waitress
  ];

  nativeCheckInputs =
    with python3Packages;
    [
      pytestCheckHook
      freezegun
      pytest-asyncio
      pytest-mock
      pytest-snapshot
    ]
    ++ [
      gitMinimal
      ripgrep
      versionCheckHook
      writableTmpDirAsHomeHook
    ];
  versionCheckProgramArg = "--version";

  disabledTests = import ./failing_tests.nix;

  # require network access
  disabledTestPaths = [
    "tests/test_chroma.py"
  ];

  preCheck = ''
    git init
  '';

  __darwinAllowLocalNetworking = true;

  postInstall = ''
    wrapProgram $out/bin/seagoat-server \
      --prefix PATH : "${ripgrep}/bin"
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Local-first semantic code search engine";
    homepage = "https://kantord.github.io/SeaGOAT/";
    changelog = "https://github.com/kantord/SeaGOAT/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lavafroth ];
    mainProgram = "seagoat";
  };
}
