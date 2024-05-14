{ config, lib, pkgs, ... }:

{
  networking.extraHosts =
    ''
      10.0.100.5 kiki kiki.gec.im
      10.0.100.6 tama tama.gec.im
      10.0.100.7 kate kate.gec.im
      10.0.100.8 mika mika.gec.im
      10.0.100.13 gaming-pc gaming-pc.gec.im
    '';

  networking.localCommands =
    ''
      /run/current-system/sw/bin/iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
    '';

  boot.kernel.sysctl."net.bridge.bridge-nf-call-ip6tables" = 0;
  boot.kernel.sysctl."net.bridge.bridge-nf-call-iptables" = 0;
  boot.kernel.sysctl."net.bridge.bridge-nf-call-arptables" = 0;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (python311.withPackages(ps: with ps; [ pip pandas requests libvirt lxml packaging ]))
    qemu_full
    libvirt
    swtpm
    edk2
  ];

  # Compatibility with libvirt internals.
  system.activationScripts.binqemu = {
    text =
    ''
      ln -sfn /run/current-system/sw/bin/qemu-system-x86_64 /usr/bin/qemu-system-x86_64
    '';
  };
}
