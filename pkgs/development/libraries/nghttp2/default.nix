{ lib, stdenv, fetchurl, pkg-config

# Optional Dependencies
, openssl ? null, zlib ? null
, enableLibEv ? !stdenv.hostPlatform.isWindows, libev ? null
, enableCAres ? !stdenv.hostPlatform.isWindows, c-ares ? null
, enableHpack ? false, jansson ? null
, enableAsioLib ? false, boost ? null
, enableGetAssets ? false, libxml2 ? null
, enableJemalloc ? false, jemalloc ? null
, enableApp ? with stdenv.hostPlatform; !isWindows && !isStatic
, enablePython ? false, python ? null, cython ? null, ncurses ? null, setuptools ? null
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

assert enableHpack -> jansson != null;
assert enableAsioLib -> boost != null;
assert enableGetAssets -> libxml2 != null;
assert enableJemalloc -> jemalloc != null;
assert enablePython -> python != null && cython != null && ncurses != null && setuptools != null;

let inherit (lib) optional optionals optionalString; in

stdenv.mkDerivation rec {
  pname = "nghttp2";
  version = "1.41.0";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-${version}.tar.bz2";
    sha256 = "0h12wz72paxnj8l9vv2qfgfbmj20c6pz6xbilb7ns9zcwxwa0p34";
  };

  outputs = [ "bin" "out" "dev" "lib" ]
    ++ optional enablePython "python";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ]
    ++ optional enableLibEv libev
    ++ [ zlib ]
    ++ optional enableCAres c-ares
    ++ optional enableHpack jansson
    ++ optional enableAsioLib boost
    ++ optional enableGetAssets libxml2
    ++ optional enableJemalloc jemalloc
    ++ optionals enablePython [ python ncurses setuptools ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-spdylay=no"
    "--disable-examples"
    (lib.enableFeature enableApp "app")
  ] ++ optional enableAsioLib "--enable-asio-lib --with-boost-libdir=${boost}/lib"
    ++ (if enablePython then [
    "--with-cython=${cython}/bin/cython"
  ] else [
    "--disable-python-bindings"
  ]);

  preInstall = optionalString enablePython ''
    mkdir -p $out/${python.sitePackages}
    # convince installer it's ok to install here
    export PYTHONPATH="$PYTHONPATH:$out/${python.sitePackages}"
  '';
  postInstall = optionalString enablePython ''
    mkdir -p $python/${python.sitePackages}
    mv $out/${python.sitePackages}/* $python/${python.sitePackages}
  '';

  #doCheck = true;  # requires CUnit ; currently failing at test_util_localtime_date in util_test.cc

  meta = with lib; {
    homepage = "https://nghttp2.org/";
    description = "A C implementation of HTTP/2";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
