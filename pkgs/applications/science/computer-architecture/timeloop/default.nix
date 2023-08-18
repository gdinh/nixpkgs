{ lib
, stdenv
, fetchFromGitHub
, scons
, libconfig
, boost
, libyaml
, yaml-cpp
, ncurses
, gpm
, enableAccelergy ? true
, enableISL ? false
, accelergy
}:

stdenv.mkDerivation rec {
  pname = "timeloop";
  version = "unstable-2023-07-18";

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = "timeloop";
    rev = "be27768a6466aeae18c52d0221ce778b8b58870c";
    hash = "sha256-Fp3nmsT+JEE3KIojNXwNLt12FOmNZsjHVMZwMJg58iQ=";
  };

  nativeBuildInputs = [ scons ];

  propagatedBuildInputs = [
    libconfig
    boost
    libyaml
    yaml-cpp
    ncurses
    accelergy
   ] ++ lib.optionals stdenv.isLinux [ gpm ];

  preConfigure = ''
    cp -r ./pat-public/src/pat ./src/pat
    rm include/pat
    cp -r ./pat-public/src/pat ./include/pat
  '';

  enableParallelBuilding = true;

  postPatch = lib.optionalString stdenv.isDarwin ''
    # disable LTO on macos as link-time optimization fails within nix
    # see https://github.com/NixOS/nixpkgs/issues/19098
    substituteInPlace ./src/SConscript --replace ", '-flto'" ""

    #remove hardcoding of c compiler
    sed -i '40i env.Replace(CC = "${stdenv.cc.targetPrefix}cc")' ./SConstruct
    sed -i '40i env.Replace(CXX = "${stdenv.cc.targetPrefix}c++")' ./SConstruct
  '';

  sconsFlags = lib.optional enableAccelergy "--accelergy"
    ++ lib.optional enableISL "--with-isl";
    #FIXME isl may require additional deps

  installPhase = ''
    cp -r ./bin ./lib $out
    mkdir -p $out/share
    cp -r ./doc $out/share
    mkdir -p $out/data
    cp -r ./problem-shapes ./configs $out/data
    cp -r ./include $out/include
   '';

  meta = with lib; {
    description = "Chip modeling/mapping benchmarking framework";
    homepage = "https://timeloop.csail.mit.edu";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gdinh ];
  };
}
