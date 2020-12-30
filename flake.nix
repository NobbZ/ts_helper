{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-beam.url = "github:hauleth/nix-elixir";
  inputs.nix-beam.flake = false;

  outputs = { self, nixpkgs, flake-utils, nix-beam }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import nix-beam) ];
        };

        callErl = (pkgs.callPackage "${nixpkgs}/pkgs/development/beam-modules/lib.nix" { }).callErlang;
        erl22 = (callErl "${nixpkgs}/pkgs/development/interpreters/erlang/R22.nix" {
          withSystemd = false;
        }).override { wxSupport = false; };

        packages = with pkgs.beam; packagesWith erl22;

        me = self.packages.${system};
      in
      {
        packages.elixir = packages.elixir_1_10;
        packages.erlang = packages.erlang;
        packages.nobbzDev = packages.buildMix' rec {
          pname = "nobbz.dev";
          version = "0.0.1+${self.lastModifiedDate}.${if self ? "rev" then self.rev else "dirty"}";

          src = self;

          mixSha256 = "sha256-3P/x3trwfgaPapWm5+XqdphyK+EEyiojGP0t02SLLPY=";

          postPatch = ''
            substituteInPlace mix.exs \
              --replace 'version: "0.1.0"' 'version: "${version}"'
          '';

          postFixup = ''
            find $out -name 'bcrypt_nif.so' -exec strip -s {} \;
            find $out -name 'epmd' -exec strip -s {} \;
            for f in $(${pkgs.findutils}/bin/find $out -name start); do
              substituteInPlace $f \
                --replace 'ROOTDIR=${packages.erlang}/lib/erlang' 'ROOTDIR=""'
            done
          '';
        };
        packages.nobbzDevImage = pkgs.dockerTools.buildLayeredImage {
          name = "quay.io/nobbz/${me.nobbzDev.pname}";
          tag = if self ? rev then "g${self.rev}" else "dontpush";
          contents = me.nobbzDev;
        };

        defaultPackage = me.nobbzDev;

        devShell = pkgs.mkShell {
          nativeBuildInputs = (with pkgs; [
            docker-compose
            git
            lefthook
            nodePackages.npm
            nodePackages.node2nix
            nodejs
            nixpkgs-fmt
            inotify-tools
          ]) ++ (with me; [ elixir erlang ]);

          LOCAL_ARCHIVE = with pkgs;
            lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
          LANG = "en_US.UTF-8";

          ERL_INCLUDE_PATH = "${me.erlang}/lib/erlang/usr/include";
        };
      });
}
