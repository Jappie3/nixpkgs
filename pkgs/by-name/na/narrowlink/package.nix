{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "narrowlink";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "narrowlink";
    repo = "narrowlink";
    rev = version;
    hash = "sha256-O66eihqSxwvrUfJj+VMrs7Vfndz2LPKQEnH7BDljvUg=";
  };

  cargoHash = "sha256-NjL5A+HEz7WDsTcwAGj1g+Brs4JYsU1kl0OZfTfoBN0=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  meta = {
    description = "Self-hosted solution to enable secure connectivity between devices across restricted networks like NAT or firewalls";
    homepage = "https://github.com/narrowlink/narrowlink";
    license = with lib.licenses; [
      agpl3Only
      mpl20
    ]; # the gateway component is AGPLv3, the rest is MPLv2
    maintainers = with lib.maintainers; [ dit7ya ];
    mainProgram = "narrowlink";
  };
}
