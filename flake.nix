{
  description = "Getax 2025 application";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system ;
        };

        getax-pp-2025 = pkgs.stdenv.mkDerivation rec {
          pname = "getax-pp-2025";
          version = "2025";
          
          src = pkgs.fetchurl {
            url = "http://www.getax.ch/getaxpp/2025/getax2025.tar.gz";
            sha256 = "0rlbssaxia5mgx4b2r0rxc58ll75n5i45pn7nl11481cq3lf4rfw";
          };
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          
          buildInputs = [
            pkgs.jdk17
            pkgs.webkitgtk_4_1
            pkgs.gtk3
            pkgs.gobject-introspection
          ];
          
          unpackPhase = ''
            mkdir -p source
            ${pkgs.gnutar}/bin/tar -xzvf $src -C source
          '';
          
          installPhase = ''
            mkdir -p $out/libexec/getax-pp-2025 $out/bin
            cp -r source/getax-pp-2025/* $out/libexec/getax-pp-2025/
            
            # Fix the launcher script
            # TL;DR : https://nix.dev/permalink/stub-ld 
            # Maybe there is a different and better way ? 
            sed 's/jre\/bin\///' $out/libexec/getax-pp-2025/getax-pp-2025 > $out/libexec/getax-pp-2025/getax-pp-2025.fixed
            chmod +x $out/libexec/getax-pp-2025/getax-pp-2025.fixed
            
            # Create wrapper script with proper library paths
            # Ensures that the jre can find the lib especially SWT related
            makeWrapper $out/libexec/getax-pp-2025/getax-pp-2025.fixed $out/bin/getax-pp-2025 \
              --chdir $out/libexec/getax-pp-2025 \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jdk17 ]} \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ 
                pkgs.webkitgtk_4_1 
                pkgs.gtk3 
                pkgs.gobject-introspection
                pkgs.glib
              ]}
          '';
          
          meta = with pkgs.lib; {
            description = "Getax 2025 tax software";
            homepage = "http://www.getax.ch";
            license = licenses.free;
            platforms = platforms.linux;
          };
        };
      in
      with pkgs;
      {
        packages.default = getax-pp-2025;
        apps.default = flake-utils.lib.mkApp { drv = getax-pp-2025; };
        
      }
    );
}