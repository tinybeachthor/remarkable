{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    mach-nix = {
      url = github:DavHau/mach-nix/master;
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, mach-nix }:
    let
      supportedSystems = [ "x86_64-linux" ];

      # Function to generate a set based on supported systems
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ ];
      });

    in rec {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          rmapi = pkgs.rmapi;
          paper2remarkable = (import ./paper2remarkable {
            inherit pkgs;
            mach-nix = (mach-nix.lib.${system});
          });
        });

      devShell = forAllSystems (system: import ./shell.nix {
        pkgs = nixpkgsFor.${system};
      });
    };
}
