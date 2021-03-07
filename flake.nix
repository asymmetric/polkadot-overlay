{
  description = "Polkadot overlay";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    polkadot = {
      url = github:paritytech/polkadot/release;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, polkadot }: {

    overlay = final: prev:
      let
        pkgs = nixpkgs.legacyPackages.${final.system};
        vers = pkgs.lib.strings.fileContents ./latest-version;
        # remove v
        version = with builtins; substring 1 (stringLength vers) vers;
        hash = pkgs.lib.strings.fileContents ./hash;
        name = "polkadot-latest";
        src = polkadot;
      in
        {
          polkadot-latest = pkgs.polkadot.overrideAttrs (old: {
            inherit src name version;

            cargoDeps = old.cargoDeps.overrideAttrs(_: {
              inherit src;

              name = "${name}-vendor.tar.gz";
              outputHash = hash;
            });
          });
        };

    defaultPackage.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlay ]; };
      in
        pkgs.polkadot-latest;

  };
}
