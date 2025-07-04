{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {

    devShells.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      pkgs.mkShell {
        name = "gimme tht";
        buildInputs =
          with pkgs; [
            just
            wrangler
            gleam
            erlang
            rebar3
            libnotify
            inotify-tools
            gnumake
            gcc
            readline
            openssl
            zlib
            libxml2
            curl
            libiconv
            elmPackages.elm
            elmPackages.nodejs
            elmPackages.elm-xref
            elmPackages.elm-test
            elmPackages.elm-live
            elmPackages.elm-json
            elmPackages.elm-review
            elmPackages.elm-format
            elmPackages.elm-upgrade
            elmPackages.elm-analyse
            elmPackages.elm-language-server
            uglify-js
          ];
      };
  };
}
