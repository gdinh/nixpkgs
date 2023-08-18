{ buildPythonPackage
, fetchFromGitHub
, lib
, cmake
, pkg-config
, timeloop
, boost
, libyaml
, yaml-cpp
, ncurses
, accelergy
, stdenv
, pybind11
}:

buildPythonPackage rec {
  pname = "pytimeloop";
  version = "unstable-2023-03-02";

  src = fetchFromGitHub {
    owner = "Accelergy-Project";
    repo = "timeloop-python";
    rev = "97c99da25e0007e0dc15c275935e979c7106928f";
    hash = "sha256-4LdDEZ1K+DC5uRBpeGSTFw0ReZ+BNqohn5/+LM5sADQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];

  # Simulate the git submodules but with nixpkgs dependencies
  postUnpack = ''
    rm -rf $sourceRoot/lib/*
    ln -s ${pybind11.src} $sourceRoot/lib/pybind11
  '';

  propagatedBuildInputs = [
    timeloop
    boost
    libyaml
    yaml-cpp
    ncurses
    accelergy
  ];

  preConfigure = ''
    export TIMELOOP_INCLUDE_PATH=${timeloop}/include
    export TIMELOOP_LIB_PATH=${timeloop}/lib
  '';

  # postPatch = lib.optionalString stdenv.isDarwin ''
  #   substituteInPlace ./CMakeLists.txt \
  #     --replace "set(CMAKE_CXX_FLAGS \"-Wall -Wextra\")" "set(CMAKE_CXX_FLAGS \"-Wall -dynamiclib -Wextra\")"
  # '';

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-fno-lto";

  dontUseCmakeConfigure = true;

  docheck = false;
  
  meta = with lib; {
    description = "Python wrapper for the Timeloop project";
    homepage = "https://github.com/Accelergy-Project/timeloop-python";
    license = licenses.mit;
    maintainers = with maintainers; [ gdinh ];
  };
}
