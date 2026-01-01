{ lib, ... }:
{
  # Import everything in this directory except this file
  imports =
    let
      # 1. Read all files in the current directory
      folder = builtins.readDir ./.;

      # 2. Filter the list
      filterFunc =
        name: type:
        # Ignore this file itself to avoid infinite recursion
        name != "default.nix"
        && (
          # Include regular .nix files
          (type == "regular" && lib.hasSuffix ".nix" name)
          # Include directories (like your ./xserver folder)
          || (type == "directory")
        );

      # 3. Apply the filter
      files = lib.filterAttrs filterFunc folder;

      # 4. Convert file names to absolute paths
      paths = map (name: ./. + "/${name}") (builtins.attrNames files);
    in
    paths;
}
