{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  python312,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "maigret";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "soxoj";
    repo = "maigret";
    tag = "v${version}";
    hash = "sha256-Z8SnA7Z5+oKW0AOaNf+c/zR30lrPFmXaxxKkbnDXNNs=";
  };

  patches = [
    # https://github.com/soxoj/maigret/pull/1117
    (fetchpatch {
      name = "pytest-7.3-compatibility.patch";
      url = "https://github.com/soxoj/maigret/commit/ecb33de9e6eec12b6b45a1152199177f32c85be2.patch";
      hash = "sha256-nFx3j1Q37YLtYhb0QS34UgZFgAc5Z/RVgbO9o1n1ONE=";
    })
  ];

  build-system = with python312.pkgs; [ setuptools ];

  dependencies = with python312.pkgs; [
    aiodns
    aiohttp
    aiohttp-socks
    arabic-reshaper
    async-timeout
    attrs
    beautifulsoup4
    certifi
    chardet
    cloudscraper
    colorama
    future
    html5lib
    idna
    jinja2
    lxml
    markupsafe
    mock
    multidict
    networkx
    pycountry
    pypdf2
    pysocks
    python-bidi
    pyvis
    requests
    requests-futures
    six
    socid-extractor
    soupsieve
    stem
    torrequest
    tqdm
    typing-extensions
    webencodings
    xhtml2pdf
    xmind
    yarl
  ];

  nativeCheckInputs = with python312.pkgs; [
    pytest-httpserver
    pytest-asyncio
    pytestCheckHook
  ];

  pythonRelaxDeps = true;

  pythonRemoveDeps = [ "future-annotations" ];

  pytestFlags = [
    # DeprecationWarning: There is no current event loop
    "-Wignore::DeprecationWarning"
  ];

  disabledTests = [
    # Tests require network access
    "test_extract_ids_from_page"
    "test_import_aiohttp_cookies"
    "test_maigret_results"
    "test_pdf_report"
    "test_self_check_db_negative_enabled"
    "test_self_check_db_positive_enable"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # AsyncioProgressbarExecutor is slower on darwin than it should be,
    # Upstream issue: https://github.com/soxoj/maigret/issues/679
    "test_asyncio_progressbar_executor"
  ];

  pythonImportsCheck = [ "maigret" ];

  meta = {
    description = "Tool to collect details about an username";
    homepage = "https://maigret.readthedocs.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      fab
      thtrf
    ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
