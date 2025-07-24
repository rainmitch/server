{ config, lib, pkgs, ... }:

{
  users.users.rain = {
    isNormalUser = true;
    description = "Rain";
    extraGroups = [ "wheel" ]; # for sudo access
    shell = pkgs.zsh;
    home = "/home/rain";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    histSize = 10000;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.gnupg.agent.enable = true;
  programs.git = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    nano
    gnupg
  ];
}
