# - coqide compilation can be disabled by setting buildIde to false
# - The csdp program used for the Micromega tactic is statically referenced.
#   However, coq can build without csdp by setting it to null.
#   In this case some Micromega tactics will search the user's path for the csdp program and will fail if it is not found.
# - The exact version can be specified through the `version` argument to
#   the derivation; it defaults to the latest stable version.

{
  lib,
  stdenv,
  fetchzip,
  fetchurl,
  writeText,
  pkg-config,
  gnumake42,
  customOCamlPackages ? null,
  ocamlPackages_4_09,
  ocamlPackages_4_10,
  ocamlPackages_4_12,
  ocamlPackages_4_14,
  rocqPackages, # for versions >= 9.0 that are transition shims on top of Rocq
  ncurses,
  buildIde ? null, # default is true for Coq < 8.14 and false for Coq >= 8.14
  glib,
  adwaita-icon-theme,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  csdp ? null,
  version,
  coq-version ? null,
}@args:
let
  lib = import ../../../../build-support/coq/extra-lib.nix { inherit (args) lib; };

  release = {
    "8.7.0".sha256 = "1h18b7xpnx3ix9vsi5fx4zdcbxy7bhra7gd5c5yzxmk53cgf1p9m";
    "8.7.1".sha256 = "0gjn59jkbxwrihk8fx9d823wjyjh5m9gvj9l31nv6z6bcqhgdqi8";
    "8.7.2".sha256 = "0a0657xby8wdq4aqb2xsxp3n7pmc2w4yxjmrb2l4kccs1aqvaj4w";
    "8.8.0".sha256 = "13a4fka22hdxsjk11mgjb9ffzplfxyxp1sg5v1c8nk1grxlscgw8";
    "8.8.1".sha256 = "1hlf58gwazywbmfa48219amid38vqdl94yz21i11b4map6jfwhbk";
    "8.8.2".sha256 = "1lip3xja924dm6qblisk1bk0x8ai24s5xxqxphbdxj6djglj68fd";
    "8.9.0".sha256 = "1dkgdjc4n1m15m1p724hhi5cyxpqbjw6rxc5na6fl3v4qjjfnizh";
    "8.9.1".sha256 = "1xrq6mkhpq994bncmnijf8jwmwn961kkpl4mwwlv7j3dgnysrcv2";
    "8.10.0".sha256 = "138jw94wp4mg5dgjc2asn8ng09ayz1mxdznq342n0m469j803gzg";
    "8.10.1".sha256 = "072v2zkjzf7gj48137wpr3c9j0hg9pdhlr5l8jrgrwynld8fp7i4";
    "8.10.2".sha256 = "0znxmpy71bfw0p6x47i82jf5k7v41zbz9bdpn901ysn3ir8l3wrz";
    "8.11.0".sha256 = "1rfdic6mp7acx2zfwz7ziqk12g95bl9nyj68z4n20a5bcjv2pxpn";
    "8.11.1".sha256 = "0qriy9dy36dajsv5qmli8gd6v55mah02ya334nw49ky19v7518m0";
    "8.11.2".sha256 = "0f77ccyxdgbf1nrj5fa8qvrk1cyfy06fv8gj9kzfvlcgn0cf48sa";
    "8.12.0".sha256 = "18dc7k0piv6v064zgdadpw6mkkxk7j663hb3svgj5236fihjr0cz";
    "8.12.1".sha256 = "1rkcyjjrzcqw9xk93hsq0vvji4f8r5iq0f739mghk60bghkpnb7q";
    "8.12.2".sha256 = "18gscfm039pqhq4msq01nraig5dm9ab98bjca94zldf8jvdv0x2n";
    "8.13.0".sha256 = "1l2c63vskp8kiyxiyi5rpgbmnv67ysn3y4lybd6nj0li5llibifi";
    "8.13.1".sha256 = "15drjcqhsgwqnv02bbidyhk316ypyhz1pxfz2gwsalci9svhkz0v";
    "8.13.2".sha256 = "14d4alp35hngvga9m7cfp5d1nl62xdj0nm4811f2jjblk86gxxk4";
    "8.14.0".sha256 = "0yxjx9kq9bfpk31dc1c6a0pz0827fz7jmrcwwd4n7dc07yi0arq8";
    "8.14.1".sha256 = "0xdqiabgm4lrm6d7lw544zd8xwb1cdcavsxvwwlqq6yid2rl2yli";
    "8.15.0".sha256 = "sha256:0q7jl3bn0d1v9cwdkxykw4frccww6wbh1p8hdrfqw489mkxmh5jh";
    "8.15.1".sha256 = "sha256:1janvmnk3czimp0j5qmnfwx6509vhpjc2q7lcza1bc6dm6kn8n42";
    "8.15.2".sha256 = "sha256:0qibbvzrhsvs6w3zpkhyclndp29jnr6bs9i5skjlpp431jdjjfqd";
    "8.16.0".sha256 = "sha256-3V6kL9j2rn5FHBxq1mtmWWTZS9X5cAyvtUsS6DaM+is=";
    "8.16.1".sha256 = "sha256-n7830+zfZeyYHEOGdUo57bH6bb2/SZs8zv8xJhV+iAc=";
    "8.17.0".sha256 = "sha256-TGwm7S6+vkeZ8cidvp8pkiAd9tk008jvvPvYgfEOXhM=";
    "8.17.1".sha256 = "sha256-x+RwkbxMg9aR0L3WSCtpIz8jwA5cJA4tXAtHMZb20y4=";
    "8.18.0".sha256 = "sha256-WhiBs4nzPHQ0R24xAdM49kmxSCPOxiOVMA1iiMYunz4=";
    "8.19.0".sha256 = "sha256-ixsYCvCXpBHqJ71hLQklphlwoOO3i/6w2PJjllKqf9k=";
    "8.19.1".sha256 = "sha256-kmZ8Uk8jpzjOd67aAPp3C+vU2oNaBw9pr7+Uixcgg94=";
    "8.19.2".sha256 = "sha256-q+i07JsMZp83Gqav6v1jxsgPLN7sPvp5/oszVnavmz0=";
    "8.20.0".sha256 = "sha256-WFpZlA6CzFVAruPhWcHQI7VOBVhrGLdFzWrHW0DTSl0=";
    "8.20.1".sha256 = "sha256-nRaLODPG4E3gUDzGrCK40vhl4+VhPyd+/fXFK/HC3Ig=";
    "9.0.0".sha256 = "sha256-GRwYSvrJGiPD+I82gLOgotb+8Ra5xHZUJGcNwxWqZkU=";
    "9.1+rc1".sha256 = "sha256-GShKHQ9EdvyNe9WlkzF6KLYybc5dPeVrh4bpkVy6pY4=";
  };
  releaseRev = v: "V${v}";
  fetched =
    import ../../../../build-support/coq/meta-fetch/default.nix
      {
        inherit
          lib
          stdenv
          fetchzip
          fetchurl
          ;
      }
      {
        inherit release releaseRev;
        location = {
          owner = "coq";
          repo = "coq";
        };
      }
      args.version;
  version = fetched.version;
  coq-version =
    args.coq-version or (if version != "dev" then lib.versions.majorMinor version else "dev");
  coqAtLeast = v: coq-version == "dev" || lib.versionAtLeast coq-version v;
  buildIde = args.buildIde or (!coqAtLeast "8.14");
  ideFlags = lib.optionalString (
    buildIde && !coqAtLeast "8.10"
  ) "-lablgtkdir ${ocamlPackages.lablgtk}/lib/ocaml/*/site-lib/lablgtk2 -coqide opt";
  csdpPatch = lib.optionalString (csdp != null) ''
    substituteInPlace plugins/micromega/sos.ml --replace "; csdp" "; ${csdp}/bin/csdp"
    substituteInPlace plugins/micromega/coq_micromega.ml --replace "System.is_in_system_path \"csdp\"" "true"
  '';
  ocamlPackages =
    if customOCamlPackages != null then
      customOCamlPackages
    else
      lib.switch coq-version [
        {
          case = lib.versions.range "8.16" "8.18";
          out = ocamlPackages_4_14;
        }
        {
          case = lib.versions.range "8.14" "8.15";
          out = ocamlPackages_4_12;
        }
        {
          case = lib.versions.range "8.11" "8.13";
          out = ocamlPackages_4_10;
        }
        {
          case = lib.versions.range "8.7" "8.10";
          out = ocamlPackages_4_09;
        }
      ] ocamlPackages_4_14;
  ocamlNativeBuildInputs = [
    ocamlPackages.ocaml
    ocamlPackages.findlib
  ]
  ++ lib.optional (coqAtLeast "8.14") ocamlPackages.dune_3;
  ocamlPropagatedBuildInputs =
    [ ]
    ++ lib.optional (!coqAtLeast "8.10") ocamlPackages.camlp5
    ++ lib.optional (!coqAtLeast "8.13") ocamlPackages.num
    ++ lib.optional (coqAtLeast "8.13") ocamlPackages.zarith;
  self = stdenv.mkDerivation {
    pname = "coq";
    inherit (fetched) version src;

    passthru = {
      inherit coq-version;
      inherit ocamlPackages ocamlNativeBuildInputs;
      inherit ocamlPropagatedBuildInputs;
      # For compatibility
      inherit (ocamlPackages)
        ocaml
        camlp5
        findlib
        num
        ;
      rocqPackages = lib.optionalAttrs (coqAtLeast "8.21") rocqPackages;
      emacsBufferSetup = pkgs: ''
        ; Propagate coq paths to children
        (inherit-local-permanent coq-prog-name "${self}/bin/coqtop")
        (inherit-local-permanent coq-dependency-analyzer "${self}/bin/coqdep")
        (inherit-local-permanent coq-compiler "${self}/bin/coqc")
        ; If the coq-library path was already set, re-set it based on our current coq
        (when (fboundp 'get-coq-library-directory)
          (inherit-local-permanent coq-library-directory (get-coq-library-directory))
          (coq-prog-args))
        (mapc (lambda (arg)
          (when (file-directory-p (concat arg "/lib/coq/${coq-version}/user-contrib"))
            (setenv "COQPATH" (concat (getenv "COQPATH") ":" arg "/lib/coq/${coq-version}/user-contrib")))) '(${
              lib.concatStringsSep " " (map (pkg: "\"${pkg}\"") pkgs)
            }))
        ; TODO Abstract this pattern from here and nixBufferBuilders.withPackages!
        (defvar nixpkgs--coq-buffer-count 0)
        (when (eq nixpkgs--coq-buffer-count 0)
          (make-variable-buffer-local 'nixpkgs--is-nixpkgs-coq-buffer)
          (defun nixpkgs--coq-inherit (buf)
            (inherit-local-inherit-child buf)
            (with-current-buffer buf
              (setq nixpkgs--coq-buffer-count (1+ nixpkgs--coq-buffer-count))
              (add-hook 'kill-buffer-hook 'nixpkgs--decrement-coq-buffer-count nil t))
            buf)
          ; When generating a scomint buffer, do inherit-local inheritance and make it a nixpkgs-coq buffer
          (defun nixpkgs--around-scomint-make (orig &rest r)
            (if nixpkgs--is-nixpkgs-coq-buffer
                (progn
                  (advice-add 'get-buffer-create :filter-return #'nixpkgs--coq-inherit)
                  (apply orig r)
                  (advice-remove 'get-buffer-create #'nixpkgs--coq-inherit))
              (apply orig r)))
          (advice-add 'scomint-make :around #'nixpkgs--around-scomint-make)
          ; When we have no more coq buffers, tear down the buffer handling
          (defun nixpkgs--decrement-coq-buffer-count ()
            (setq nixpkgs--coq-buffer-count (1- nixpkgs--coq-buffer-count))
            (when (eq nixpkgs--coq-buffer-count 0)
              (advice-remove 'scomint-make #'nixpkgs--around-scomint-make)
              (fmakunbound 'nixpkgs--around-scomint-make)
              (fmakunbound 'nixpkgs--coq-inherit)
              (fmakunbound 'nixpkgs--decrement-coq-buffer-count))))
        (setq nixpkgs--coq-buffer-count (1+ nixpkgs--coq-buffer-count))
        (add-hook 'kill-buffer-hook 'nixpkgs--decrement-coq-buffer-count nil t)
        (setq nixpkgs--is-nixpkgs-coq-buffer t)
        (inherit-local 'nixpkgs--is-nixpkgs-coq-buffer)
      '';
    };

    nativeBuildInputs = [
      pkg-config
    ]
    ++ ocamlNativeBuildInputs
    ++ lib.optional buildIde copyDesktopItems
    ++ lib.optional (buildIde && coqAtLeast "8.10") wrapGAppsHook3
    ++ lib.optional (!coqAtLeast "8.6") gnumake42;
    buildInputs = [
      ncurses
    ]
    ++ lib.optionals buildIde (
      if coqAtLeast "8.10" then
        [
          ocamlPackages.lablgtk3-sourceview3
          glib
          adwaita-icon-theme
        ]
      else
        [ ocamlPackages.lablgtk ]
    );

    propagatedBuildInputs = ocamlPropagatedBuildInputs;

    postPatch = ''
      UNAME=$(type -tp uname)
      RM=$(type -tp rm)
      substituteInPlace tools/beautify-archive --replace "/bin/rm" "$RM"
      ${lib.optionalString (
        !coqAtLeast "8.7"
      ) "substituteInPlace configure.ml --replace \"md5 -q\" \"md5sum\""}
      ${csdpPatch}
    '';

    setupHook = writeText "setupHook.sh" ''
      addCoqPath () {
        if test -d "''$1/lib/coq/${coq-version}/user-contrib"; then
          export COQPATH="''${COQPATH-}''${COQPATH:+:}''$1/lib/coq/${coq-version}/user-contrib/"
        fi
      }

      addEnvHooks "$targetOffset" addCoqPath
    '';

    preConfigure =
      if coqAtLeast "8.10" then
        ''
          patchShebangs dev/tools/
        ''
      else
        ''
          configureFlagsArray=(
            ${ideFlags}
          )
        '';

    prefixKey = "-prefix ";

    buildFlags = [
      "revision"
      "coq"
    ]
    ++ lib.optional buildIde "coqide"
    ++ lib.optional (!coqAtLeast "8.14") "bin/votour";
    enableParallelBuilding = true;

    createFindlibDestdir = true;

    desktopItems = lib.optional buildIde (makeDesktopItem {
      name = "coqide";
      exec = "coqide";
      icon = "coq";
      desktopName = "CoqIDE";
      comment = "Graphical interface for the Coq proof assistant";
      categories = [
        "Development"
        "Science"
        "Math"
        "IDE"
        "GTK"
      ];
    });

    postInstall =
      let
        suffix = lib.optionalString (coqAtLeast "8.14") "-core";
      in
      lib.optionalString (!coqAtLeast "8.17") ''
        cp bin/votour $out/bin/
      ''
      + ''
        ln -s $out/lib/coq${suffix} $OCAMLFIND_DESTDIR/coq${suffix}
      ''
      + lib.optionalString (coqAtLeast "8.14") ''
        ln -s $out/lib/coqide-server $OCAMLFIND_DESTDIR/coqide-server
      ''
      + lib.optionalString buildIde ''
        mkdir -p "$out/share/pixmaps"
        ln -s "$out/share/coq/coq.png" "$out/share/pixmaps/"
      '';

    meta = with lib; {
      description = "Coq proof assistant";
      longDescription = ''
        Coq is a formal proof management system.  It provides a formal language
        to write mathematical definitions, executable algorithms and theorems
        together with an environment for semi-interactive development of
        machine-checked proofs.
      '';
      homepage = "https://coq.inria.fr";
      license = licenses.lgpl21;
      branch = coq-version;
      maintainers = with maintainers; [
        roconnor
        thoughtpolice
        vbgl
        Zimmi48
      ];
      platforms = platforms.unix;
      mainProgram = "coqide";
    };
  };
in
if coqAtLeast "8.21" then
  self.overrideAttrs (o: {
    # coq-core is now a shim for rocq
    propagatedBuildInputs = o.propagatedBuildInputs ++ [
      rocqPackages.rocq-core
    ];
    buildPhase = ''
      runHook preBuild
      dune build -p coq-core,coqide-server${lib.optionalString buildIde ",rocqide"} -j $NIX_BUILD_CORES
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      dune install --prefix $out coq-core coqide-server${lib.optionalString buildIde " rocqide"}
      # coq and rocq are now in different directories, which sometimes confuses coq_makefile
      # which expects both in the same /nix/store/.../bin/ directory
      # adding symlinks to content it
      ROCQBIN=$(dirname ''$(command -v rocq))
      for b in csdpcert ocamllibdep rocq rocq.byte rocqchk votour ; do
        ln -s ''${ROCQBIN}/''${b} $out/bin/
      done
      runHook postInstall
    '';
  })
else if coqAtLeast "8.17" then
  self.overrideAttrs (_: {
    buildPhase = ''
      runHook preBuild
      make dunestrap
      dune build -p coq-core,coq-stdlib,coqide-server${lib.optionalString buildIde ",coqide"} -j $NIX_BUILD_CORES
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      dune install --prefix $out coq-core coq-stdlib coqide-server${lib.optionalString buildIde " coqide"}
      runHook postInstall
    '';
  })
else
  self
