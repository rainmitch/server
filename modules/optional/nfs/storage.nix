
{config, pkgs, ...}:

{
  fileSystems."/export/storage" = {
    device = "/mnt/storage/storage";
    options = ["bind" "nfsvers=4.2"];
  };
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = '''';
    exports = ''
      /export          192.168.0.90(rw,fsid=0,all_squash,anonuid=1000) 192.168.0.9(rw,fsid=0,all_squash,anonuid=1000,insecure)
      /export/storage  192.168.0.90(rw,nohide) 192.168.0.9(rw,nohide)
      /export/storage/torrents 192.168.0.90(rw,nohide) 192.168.0.22(rw,nohide)
    '';
  };
}
