
{config, pkgs, ...}:

{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      #KbdInteractiveAuthentication = false;
      AllowUsers = [ "rain" ];
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };
  security.pam = {
    services.sshd.googleAuthenticator.enable = true;
  };
}
