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
            echo "---------------------------------------------------------"
            echo "If using sqlalchemy run 'make db-init' to initialize the database."
            echo "alembic.ini: The main configuration file."
            echo "   change script_location = src/alembic"
            echo "   delete the sqlalchemy.url line, we will get this from the environment"
            echo "   change file_template = %%(year)d_%%(month).2d_%%(day).2d_%%(hour).2d%%(minute).2d-%%(rev)s_%%(slug)s if you want to use timezone aware timestamps"
            echo "   copy .env.py.example to .env.py and fill in the values"
            echp ""
            echo "---------------------------------------------------------"
            echo "src/alembic/: A directory containing:"
            echo "  env.py: The script Alembic runs to configure the migration environment."
            echo "  script.py.mako: A template for generating new migration scripts."
            echo "  versions/: A directory where your migration scripts will live (initially empty)."
            echo ""
            echo "---------------------------------------------------------"
            echo "Replace <your-repo-url> and <your-repo-name> placeholders."
            echo "Update author details in pyproject.toml and potentially the README."
            echo "Add actual build status/coverage badges if you set up CI/CD."
            echo "If you didn't include a LICENSE file, either create one (e.g., with the MIT license text) or simply state 'This project is licensed under the MIT License.' at the end of the README."
          '';
        };
      }
    );
}