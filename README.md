# Getax 2025 - Nix Flake

Nix flake for the Getax 2025 tax software (Geneva). 
Done for fun and experimenting with how to package software and make it run on NixOs :) 


## Usage

```bash
# Run directly
nix run .

# Or build and run
nix build .
./result/bin/getax-pp-2025
```

## Requirements

- Nix with flakes enabled
- Linux system

## Updating

To update to a newer version:

```nix
src = pkgs.fetchurl {
  url = "http://www.getax.ch/getaxpp/2026/getax2026.tar.gz";
  sha256 = ""; # Run nix build to get correct --> nix-prefetch-url http://www.getax.ch/getaxpp/2026/getax2026.tar.gz  
};
```

- May need to update jdk, webkitgtk and gtk as I had to tweak and play until I found a set of parameters that worked

## Links

- [Getax Official Website](http://www.getax.ch)