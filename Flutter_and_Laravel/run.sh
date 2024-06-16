#!/bin/bash

# Get the current directory
current_dir=$(dirname "$(pwd)")

# Create the content of the dev.nix file
cat <<EOF > dev.nix

  # To learn more about how to use Nix to configure your environment
  # see: https://developers.google.com/idx/guides/customize-idx-env
  {pkgs}:
  let
    flutterProjectDir = "${current_dir}_flutter"; # Define your Flutter project directory here
    laravelProjectDir = "${current_dir}_laravel"; # Define your Laravel project directory here
  in 
  {
    # Which nixpkgs channel to use.
    channel = "stable-23.11"; # or "unstable"
    # Use https://search.nixos.org/packages to find packages
    packages = [
      pkgs.nodePackages.firebase-tools
      pkgs.jdk17
      pkgs.unzip
      pkgs.php82
      pkgs.php82Packages.composer
      pkgs.nodejs_20
    ];
    # Sets environment variables in the workspace
    env = {};
    idx = {
      # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
      extensions = [
        "usernamehw.errorlens"
        "Dart-Code.flutter"
        "Dart-Code.dart-code"
        # "vscodevim.vim"
      ];

      workspace = {
        # Runs when a workspace is first created with this \`dev.nix\` file
       
        onCreate = {
          build-flutter = ''
            #  cd \${flutterProjectDir}/android # you can't echo but just in case
             echo "Changing directory to \${flutterProjectDir}/android"

             cd \${flutterProjectDir}/android || { echo "Failed to change directory"; exit 1; }

            echo "Switching to Flutter master channel"
            flutter channel master || { echo "Failed to switch Flutter channel"; exit 1; }
            flutter upgrade || { echo "Failed to upgrade Flutter"; exit 1; }

            echo "Running gradlew assembleDebug"
            ./gradlew \\
              --parallel \\
              -Pverbose=true \\
              -Ptarget-platform=android-x86 \\
              -Ptarget=\${flutterProjectDir}/lib/main.dart \\
              -Pbase-application-name=android.app.Application \\
              -Pdart-defines=RkxVVFRFUl9XRUJfQ0FOVkFTS0lUX1VSTD1odHRwczovL3d3dy5nc3RhdGljLmNvbS9mbHV0dGVyLWNhbnZhc2tpdC85NzU1MDkwN2I3MGY0ZjNiMzI4YjZjMTYwMGRmMjFmYWMxYTE4ODlhLw== \\
              -Pdart-obfuscation=false \\
              -Ptrack-widget-creation=true \\
              -Ptree-shake-icons=false \\
              -Pfilesystem-scheme=org-dartlang-root \\
              assembleDebug

            # TODO: Execute web build in debug mode.
            # flutter run does this transparently either way
            # https://github.com/flutter/flutter/issues/96283#issuecomment-1144750411
            # flutter build web --profile --dart-define=Dart2jsOptimization=O0 

            adb -s emulator-5554 wait-for-device
          '';
        };
        
        # To run something each time the workspace is (re)started, use the \`onStart\` hook
      # Runs when the workspace is (re)started
        onStart = {
         
     
          
        };
     
      };
      # Enable previews and customize configuration
      previews = {
        enable = true;
        previews = {
          web = {
            cwd = "\${laravelProjectDir}";
            command = ["php" "artisan" "serve" "--port" "\$PORT" "--host" "0.0.0.0"];
            manager = "web";
          };
          android = {
            cwd = "\${flutterProjectDir}";
            command = ["flutter" "run" "--enable-experiment=macros"  "--machine" "-d" "android" "-d" "emulator-5554" "--target=\${flutterProjectDir}/lib/main.dart"];
            manager = "flutter";
          };
        };
      };
    };
  }

EOF

# Set the permissions for the file


echo "dev.nix file created and permissions set."
