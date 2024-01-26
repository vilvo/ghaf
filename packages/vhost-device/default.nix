{
  pkgs,
  lib,
  fetchFromGitHub,
  callPackage,
  rustPlatform,
  stdenv,
}: let
  fenix =
    callPackage
    (fetchFromGitHub {
      owner = "nix-community";
      repo = "fenix";
      rev = "77d5a2d";
      hash = "sha256-kd8Mlh+4NIG/NIkXeEwSIlwQuvysKJM4BeLrt2nvcc8=";
    })
    {};
in
  rustPlatform.buildRustPackage rec {
    pname = "vhost-device";
    version = "0.1.0";

    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

    # acknowledgements https://hoverbear.org/blog/rust-bindgen-in-nix/
    preBuild = ''
      # From: https://github.com/NixOS/nixpkgs/blob/1fab95f5190d087e66a3502481e34e15d62090aa/pkgs/applications/networking/browsers/firefox/common.nix#L247-L253
      # Set C flags for Rust's bindgen program. Unlike ordinary C
      # compilation, bindgen does not invoke $CC directly. Instead it
      # uses LLVM's libclang. To make sure all necessary flags are
      # included we need to look in a few places.
      export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
        $(< ${stdenv.cc}/nix-support/libc-cflags) \
        $(< ${stdenv.cc}/nix-support/cc-cflags) \
        $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
        ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
        ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"} \
      "
    '';

    nativeBuildInputs = with pkgs; [fenix.default.toolchain pkg-config];
    buildInputs = with pkgs; [libgpiod alsa-lib pipewire];

    src = fetchFromGitHub {
      owner = "rust-vmm";
      repo = pname;
      rev = "6ca911e";
      hash = "sha256-4beXurubtl67XTSNPrtbFEAK/ZZ6SrAVLu4sfHexZBU=";
    };

    # disable individual specific requirements tests that are failing
    checkFlags = [
      "--skip=i2c::tests::test_phys_device_failure"
      "--skip=tests::test_fail_listener"
      "--skip=audio_backends::pipewire::tests::test_pipewire_backend_invalid_stream"
      "--skip=audio_backends::pipewire::tests::test_pipewire_backend_success"
      "--skip=audio_backends::tests::test_alloc_audio_backend"
    ];

    # mitigate issue with missing hash in the Cargo log-file
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "libspa-0.7.2" = "sha256-ugRmj0eYEkV1+ekp+WQAFRcyook9NsJ6loj+dLcBLY8=";
      };
    };

    meta = with lib; {
      description = "vhost-user device backends workspace";
      homepage = "https://github.com/rust-vmm/vhost-device";
      license = licenses.asl20;
      maintainers = ["tiiuae/ghaf"];
    };
  }
