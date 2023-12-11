# SPDX-FileCopyrightText: 2023 Technology Innovation Institute (TII)
#
# SPDX-License-Identifier: Apache-2.0
{
  self,
  inputs,
  lib,
  config,
  ...
}: {
  sops.defaultSopsFile = ./secrets.yaml;

  imports = lib.flatten [
    (with inputs; [
      nix-serve-ng.nixosModules.default
      sops-nix.nixosModules.sops
      disko.nixosModules.disko
    ])
    (with self.nixosModules; [
      common
      service-openssh
      user-tervis
    ])
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/58fa9dd4-a1ce-44d2-8f0c-eda12bacb119";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-ca3e4ffe-1ccb-4dcf-af93-cae49faed30c".device = "/dev/disk/by-uuid/ca3e4ffe-1ccb-4dcf-af93-cae49faed30c";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2697-2C6F";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/c3500cae-bf58-4ccb-9e5f-fd65751dc0cf";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-dbc498c0-2b86-4d78-9ff7-79543407d73a".device = "/dev/disk/by-uuid/dbc498c0-2b86-4d78-9ff7-79543407d73a";
  boot.initrd.luks.devices."luks-dbc498c0-2b86-4d78-9ff7-79543407d73a".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "tervis-servu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  nix.settings.min-free = lib.mkForce 10000000000;
  nix.settings.max-free = lib.mkForce 20000000000;
  nix.settings.min-free-check-interval = lib.mkForce 30;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;

  # Configure keymap in X11
  services.xserver = {
    layout = "fi";
    xkbVariant = "winkeys";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Set your time zone
  time.timeZone = lib.mkForce "Europe/Helsinki";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  environment.variables = {
    HISTCONTROL = "ignoreboth";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
