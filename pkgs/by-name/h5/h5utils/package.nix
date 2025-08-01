{
  stdenv,
  fetchurl,
  lib,
  hdf5,
  libpng,
  libjpeg,
  hdf4 ? null,
  libmatheval ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "1.13.2";
  pname = "h5utils";

  # fetchurl is used instead of fetchFromGitHub because the git repo version requires
  # additional tools to build compared to the tarball release; see the README for details.
  src = fetchurl {
    url = "https://github.com/stevengj/h5utils/releases/download/${finalAttrs.version}/h5utils-${finalAttrs.version}.tar.gz";
    hash = "sha256-7qeFWoI1+st8RU5hEDCY5VZY2g3fS23luCqZLl8CQ1E=";
  };

  # libdf is an alternative name for libhdf (hdf4)
  preConfigure = lib.optionalString (hdf4 != null) ''
    substituteInPlace configure \
    --replace "-ldf" "-lhdf" \
  '';

  preBuild = lib.optionalString hdf5.mpiSupport "export CC=${lib.getBin hdf5.mpi}/mpicc";

  buildInputs = [
    hdf5
    libjpeg
    libpng
  ]
  ++ lib.optional hdf5.mpiSupport hdf5.mpi
  ++ lib.optional (hdf4 != null) hdf4
  ++ lib.optional (libmatheval != null) libmatheval;

  meta = {
    description = "Set of utilities for visualization and conversion of scientific data in the free, portable HDF5 format";
    homepage = "https://github.com/stevengj/h5utils";
    changelog = "https://github.com/NanoComp/h5utils/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      gpl2Plus
    ];
    maintainers = [ lib.maintainers.sfrijters ];
  };
})
