{ sources, compiler }:
[
  (final: prev: {
    inherit (import sources.gitignore { inherit (prev) lib; }) gitignoreFilter;
  })
  (final: prev: {
    stan = import ./packages.nix { pkgs = prev; inherit compiler; };
  })
]
