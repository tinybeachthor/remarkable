{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    mach-nix = {
      url = github:DavHau/mach-nix/master;
      inputs = {
        nixpkgs.follows     = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    tinybeachthor = {
      url = github:tinybeachthor/nur-packages/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, mach-nix, tinybeachthor }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          overlays = [ tinybeachthor.overlay ];
        });
      in rec {
        devShell = import ./shell.nix { inherit pkgs; };
        packages = {
          rmapi = pkgs.rmapi;
          paper2remarkable = (import ./paper2remarkable {
            inherit pkgs;
            mach-nix = (mach-nix.lib.${system});
          });
        };
        overlay = final: prev: packages;
      });
}
