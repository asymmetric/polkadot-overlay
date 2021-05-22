{
  description = "Polkadot overlay";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    polkadot = {
      url = github:paritytech/polkadot/release;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, polkadot }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      version =
        let
          v = pkgs.lib.strings.fileContents ./latest-version;
        in
        with builtins; substring 1 (stringLength v) v;
      hash = pkgs.lib.strings.fileContents ./hash;
      name = "polkadot-latest";
      src = polkadot;
    in
    {
      overlay = final: prev: {
        "${name}" = self.packages.${system}.${name};
      };

      packages.${system}.${name} = pkgs.polkadot.overrideAttrs (old: {
        inherit src name version;

        cargoDeps = old.cargoDeps.overrideAttrs (_: {
          inherit src;

          name = "${name}-vendor.tar.gz";
          outputHash = hash;
        });
      });

      defaultPackage.${system} = self.packages.${system}.${name};
    };
}
