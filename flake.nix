{
  description = "🟪";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system; 
          config = { 
            allowBroken = true;
            allowUnfree = true;
          };
        };
        
        # System-specific dependencies
        linuxDeps = with pkgs; [
          # Linux-specific system dependencies for Tauri
          webkitgtk_4_1
          gtk3
          libsoup_3
          cairo
          glib
          gdk-pixbuf
          libayatana-appindicator
          at-spi2-atk
          pango
          harfbuzz
          librsvg
          dbus
          openssl_3
          xorg.libXtst
          xorg.libXrandr
          xorg.libxcb
          xorg.libxkbcommon
          libGL
        ];
        
        macosDeps = with pkgs; [
          # macOS-specific system dependencies for Tauri
          rustc
          rustfmt
          libiconv
          darwin.apple_sdk.frameworks.WebKit
          darwin.apple_sdk.frameworks.AppKit
          darwin.apple_sdk.frameworks.CoreFoundation
          darwin.apple_sdk.frameworks.CoreServices
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.CoreGraphics
          darwin.apple_sdk.frameworks.Foundation
          darwin.apple_sdk.frameworks.IOKit
          darwin.libobjc
        ];
        
        # Common dependencies for all platforms
        commonDeps = with pkgs; [
          openssl
          rustc
          rustfmt
          clippy
          rust-analyzer
          libiconv
        ];
        
        # Determine system-specific dependencies based on platform
        platformDeps = if pkgs.stdenv.isDarwin then macosDeps else linuxDeps;
        
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkg-config
            rustc
            cargo
            cargo-tauri
            rustfmt
            rust-analyzer
            gobject-introspection
            nodejs_22
            git
            bun
          ];
          
          buildInputs = commonDeps ++ platformDeps;
          
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          
          shellHook = ''
            export PATH="$PATH:$HOME/.cargo/bin"
            echo "🟪 bingbong 🟪"
            echo "Tauri development environment loaded for ${if pkgs.stdenv.isDarwin then "macOS" else "Linux"}!"
          '';
        };
      });
}
