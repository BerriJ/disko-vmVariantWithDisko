_: {
  # This creates users based on the userSpec options
  # See flake.nix for an example and modules/userSpec.nix for all options
  users.users."alice" = {
    description = "Alice Henderson";
    group = "alice";
    hashedPassword = "$6$qtPoLl68R53aFek9$bKycesrO8nM27wB98Qdcv3ffX2LlWU1v.dV8XJLIndyueV0lOcXaZGhK.TZAnqHN4tBW6yhZKcYdB5G1NT5nP1";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  users.groups = {
    alice = { };
  };
}
