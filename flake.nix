{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

        packages = with pkgs.beam; packagesWith (interpreters.erlangR23.override { wxSupport = false; withSystemd = false; });

        me = self.packages.${system};
      in
      {
        packages = (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
          tsHelperImage = pkgs.dockerTools.streamLayeredImage {
            name = "quay.io/nobbz/${self.packages.x86_64-linux.tsHelper.pname}";
            tag = if self ? rev then "g${self.rev}" else "dontpush";
            contents = self.packages.x86_64-linux.tsHelper;
          };
          tsHelperImageStreamer = pkgs.writeShellScript "image-streamer" ''
            ${self.packages.${system}.tsHelperImage} | docker load
          '';
        }) // {
          elixir = packages.elixir_1_11.override rec {
            version = "1.11.3";
            src = pkgs.fetchFromGitHub rec {
              name = "elixir-${version}-source";
              owner = "elixir-lang";
              repo = "elixir";
              rev = "v${version}";
              sha256 = "sha256-DqmKpMLxrXn23fsX/hrjDsYCmhD5jbVtvOX8EwKBakc=";
            };
          };
          erlang = packages.erlang;
          tsHelper = let
            elixir = me.elixir;
            fetchMixDeps = packages.callPackage "${nix-beam}/lib/fetch-mix-deps.nix" { inherit elixir; };
            buildMix' = packages.callPackage "${nix-beam}/lib/build-mix.nix" { inherit elixir fetchMixDeps; };
          in buildMix' {
            inherit pname version;

            src = ./.;

            elixir = me.elixir;

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

          assetPipeline = (pkgs.callPackage ./assets { nodejs = pkgs.nodejs-12_x; }).package;
          assets = pkgs.stdenv.mkDerivation {
            pname = "${pname}-assets";
            inherit version;

            src = ./assets;

            NO_UPDATE_NOTIFIER = "true";

            buildInputs = [ pkgs.nodePackages.npm pkgs.python2 ];

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

        apps = (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
          streamImage = { type = "app"; program = "${self.packages.${system}.tsHelperImageStreamer}"; };
        });

        devShell = pkgs.mkShell {
          nativeBuildInputs = (with pkgs; [
            docker-compose
            git
            lefthook
            nodejs
            nixpkgs-fmt
          ]) ++ (with me; [ erlang elixir ])
          ++ (with pkgs.nodePackages; [ npm node2nix ])
          ++ pkgs.lib.optional (system != "x86_64-darwin") pkgs.inotify-tools;

          LOCAL_ARCHIVE = with pkgs;
            lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
          LANG = "en_US.UTF-8";

          ERL_INCLUDE_PATH = "${me.erlang}/lib/erlang/usr/include";
        };
      });
}
