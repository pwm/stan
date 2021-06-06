{ system ? builtins.currentSystem, compiler ? null }:
let
  pkgs = import ./nix { inherit system compiler; };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.stan.shell
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stan.shell}/lib:$LD_LIBRARY_PATH
  '';
}
