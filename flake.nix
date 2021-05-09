{
  description = "Chromatin Test Plugin";

  inputs.hix.url = github:tek/hix;
  inputs.ribosome.url = github:tek/ribosome;

  outputs = { hix, ribosome, ... }:
  let
    inherit (ribosome.inputs) chiasma;
    overrides = { hackage, source, minimal, configure, pkgs, ... }: {
      cornea = hackage "0.4.0.0" "1w9rkf6f861kknkskywb8fczlk7az8m56i3hvmg6a5inpvqf6p7i";
      chiasma = source.package chiasma "chiasma";
      ribosome = configure "--extra-prog-path=${pkgs.neovim}/bin" (
        minimal (source.package ribosome "ribosome"));
      ribosome-test = minimal (source.package ribosome "ribosome-test");
    };

  in hix.flake {
    base = ./.;
    inherit overrides;
    compat = false;
    packages.crm-test = ./packages/crm-test;
    versionFile = "ops/hpack/packages/crm-test.yaml";
    runConfig = p: {
      extraShellInputs = [p.pkgs.neovim];
    };
  };
}
