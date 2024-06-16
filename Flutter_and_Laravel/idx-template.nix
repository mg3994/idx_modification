{pkgs, ...}: 
let 
  flutter = pkgs.fetchzip {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.2-stable.tar.xz";
    hash = "sha256-1MNsakGh9idMUR8bSDu7tVpZB6FPn6nmtvc+Gi10+SA=";
  };
  
in {
     packages = [
        pkgs.curl
        pkgs.gnutar
        pkgs.xz
        pkgs.git
        pkgs.busybox
    ];

    bootstrap = ''
      cp -rf ${flutter} flutter
      chmod -R u+w flutter
      # PUB_CACHE=/tmp/pub-cache ./flutter/bin/flutter create "$out"
      # mkdir -p "$out"/.{flutter-sdk,idx}
      # mv flutter "$out/.flutter-sdk/flutter"
      # echo ".flutter-sdk/flutter" >> "$out/.gitignore"
      mkdir -p "$out/.idx"
      curl -L -o "$out/.idx/run.sh" "https://raw.githubusercontent.com/mg3994/Flutter-Laravel/main/run.sh"
      chmod +x "$out/.idx/run.sh"
      # Execute run.sh script
      cd "$out/.idx"
      chmod +x run.sh
      ./run.sh
      # Optionally delete run.sh after execution
      rm run.sh
      # Make dev.nix executable
      chmod +x dev.nix
      # Return to $out directory
      cd "$out"
      
      
    '';
}
