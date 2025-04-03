# flake.nix
{
  description = "Python development environment with Poetry, linters, and DB tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Or nixos-unstable
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonVersion = "310";
        pythonInterpreter = pkgs."python${pythonVersion}";

        # System dependencies needed by Python packages or tools
        systemDeps = [
          pkgs.git
          pkgs.gnumake
          pkgs.postgresql # For psycopg build/runtime libs and psql client
          pkgs.libffi     # Often needed by C extensions
          # Add pkgs.redis if you want the redis-cli in the nix shell
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonInterpreter
            pkgs.poetry
          ] ++ systemDeps;

          shellHook = ''
            export VIRTUAL_ENV=$PWD/.venv
            export PATH=$VIRTUAL_ENV/bin:$PATH
            export POETRY_VIRTUALENVS_IN_PROJECT=true

            # Add system library paths if needed (psycopg binary usually handles its own)
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath systemDeps}:$LD_LIBRARY_PATH

            # Activate venv if it exists, otherwise prompt user
            if [ -f "$VIRTUAL_ENV/bin/activate" ]; then
              source "$VIRTUAL_ENV/bin/activate"
            else
              echo ""
              echo "#################################################################"
              echo "#                                                               #"
              echo "# NOTICE: Python virtual environment not found or not active. #"
              echo "# Run 'poetry install' to create it.                           #"
              echo "#                                                               #"
              echo "#################################################################"
              echo ""
            fi

            alias python=python3

            # Display versions for verification
            echo "--- Environment Info ---"
            echo "Nix Python: $(nix eval --raw nixpkgs#python${pythonVersion})/bin/python ($(nix eval --raw nixpkgs#python${pythonVersion}.version))"
            echo "Poetry Version: $(poetry --version)"
            if [ -f "$VIRTUAL_ENV/bin/activate" ]; then
                echo "Active Venv: $VIRTUAL_ENV"
                echo "Venv Python: $(python --version)"
            fi
            echo "-------------------------"
            echo "Development environment ready! Run 'poetry install' if needed."
          '';
        };
      }
    );
}