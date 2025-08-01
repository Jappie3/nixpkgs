{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pydantic,
  pytest-vcr,
  pytestCheckHook,
  pythonOlder,
  requests,
  requests-oauthlib,
}:

buildPythonPackage rec {
  pname = "garth";
  version = "0.5.17";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SO3pOMOLL9cHd+VccCVTh3XZPBBH9DzHxEgfKgSxCcs=";
  };

  pythonRelaxDeps = [ "requests-oauthlib" ];

  build-system = [ hatchling ];

  dependencies = [
    pydantic
    requests
    requests-oauthlib
  ];

  nativeCheckInputs = [
    pytest-vcr
    pytestCheckHook
  ];

  pythonImportsCheck = [ "garth" ];

  disabledTests = [
    # Tests require network access
    "test_client_request"
    "test_connectapi"
    "test_daily"
    "test_download"
    "test_exchange"
    "test_hrv_data_get"
    "test_login"
    "test_refresh_oauth2_token"
    "test_sleep_data"
    "test_username"
    "test_weekly"
  ];

  meta = with lib; {
    description = "Garmin SSO auth and connect client";
    homepage = "https://github.com/matin/garth";
    changelog = "https://github.com/matin/garth/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
