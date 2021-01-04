{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-beam.url = "github:hauleth/nix-elixir";
  inputs.nix-beam.flake = false;

  outputs = { self, nixpkgs, flake-utils, nix-beam }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import nix-beam) ];
        };

        pname = "ts-helper";
        versionNumber = "0.0.1";
        versionSuffix = "${self.lastModifiedDate}.${self.rev or "dirty"}";
        version = "${versionNumber}+${versionSuffix}";

        callErl = (pkgs.callPackage "${nixpkgs}/pkgs/development/beam-modules/lib.nix" { }).callErlang;
        erl22 = (callErl "${nixpkgs}/pkgs/development/interpreters/erlang/R22.nix" {
          withSystemd = false;
        }).override { wxSupport = false; };

        erl22systemd = pkgs.beam.interpreters.erlangR22;

        packages = with pkgs.beam; packagesWith erl22;
        packagesSystemd = with pkgs.beam; packagesWith erl22systemd;

        ex = "elixir_1_10";

        me = self.packages.${system};
      in
      {
        packages = (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
          tsHelperImage = pkgs.dockerTools.buildLayeredImage {
            name = "quay.io/nobbz/${self.packages.x86_64-linux.tsHelper.pname}";
            tag = if self ? rev then "g${self.rev}" else "dontpush";
            contents = self.packages.x86_64-linux.tsHelper;
          };
        }) // {
          elixir = packages.${ex};
          erlang = packages.erlang;
          tsHelper = packages.buildMix' {
            inherit pname version;

            src = ./.;

            mixSha256 = "sha256-uOrYb78s2B5rjS5LScx//TOO203xA130tWi3zPGWPAc=";

            LANG = "en_US.UTF-8";
            LOCAL_ARCHIVE = with pkgs;
              lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";

            configurePhase = ''
              cp -rv ${me.assets} priv/static
              chmod -Rv a+w priv/static
            '';

            postPatch = ''
              substituteInPlace mix.exs \
                --replace 'version: "0.1.0"' 'version: "${version}"'
            '';

            preBuild = ''
              mix phx.digest
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

          assetPipeline = (pkgs.callPackage ./assets { }).package;
          assets = pkgs.stdenv.mkDerivation {
            pname = "${pname}-assets";
            inherit version;

            src = ./assets;

            NO_UPDATE_NOTIFIER = "true";

            buildInputs = [ pkgs.nodePackages.npm ];

            patchPhase = ''
              substituteInPlace webpack.config.js \
                --replace ../priv/static/js dist/js
            '';

            configurePhase = ''
              cp -rv ${me.assetPipeline}/lib/node_modules/ts_helper_js/node_modules node_modules
            '';

            buildPhase = ''
              mkdir -p dist/js
              ./node_modules/.bin/webpack --mode production
            '';

            installPhase = ''
              mkdir -p $out
              cp -rv dist/* $out
            '';
          };
        };

        defaultPackage = me.tsHelper;

        devShell = pkgs.mkShell {
          nativeBuildInputs = (with pkgs; [
            docker-compose
            git
            lefthook
            nodejs
            nixpkgs-fmt
          ]) ++ ([ packagesSystemd.erlang packagesSystemd.${ex} ])
          ++ (with pkgs.nodePackages; [ npm node2nix ])
          ++ pkgs.lib.optional (system != "x86_64-darwin") pkgs.inotify-tools;

          LOCAL_ARCHIVE = with pkgs;
            lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
          LANG = "en_US.UTF-8";

          ERL_INCLUDE_PATH = "${me.erlang}/lib/erlang/usr/include";
        };
      });
}
