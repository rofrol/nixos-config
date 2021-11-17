# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Added by rofrol
  boot.loader.grub.useOSProber = true;

  networking.hostName = "msi-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #
  # should probably be in hardware-configuration.nix
  # https://github.com/NixOS/nixpkgs/issues/146226
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  # disable wayland for now, as screensharing required pipewire
  # and pipewire is probably too old in 21.05
  #services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;

  # no login manager when enabled below any combination of drivers
  # https://github.com/AleksanderGondek/nixos-config/blob/c0899f10642d6b481467e89237ba2a43aa3b0224/desktops/nvidia-desktop.nix#L8
  #services.xserver.videoDrivers = [
  #  "intel"
  #  "nvidia"
  #];

  # https://nixos.wiki/wiki/Nvidia
  #services.xserver.displayManager.gdm.wayland = true;
  #services.xserver.displayManager.gdm.nvidiaWayland = false;
  #services.xserver.displayManager.gdm.nvidiaWayland = true;
  #hardware.nvidia.modesetting.enable = true;
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.prime = {
  #  offload.enable = true;

  #  # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #  intelBusId = "PCI:0:2:0";

  #  # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #  nvidiaBusId = "PCI:1:0:0";
  #};
  
  # https://nixos.wiki/wiki/GNOME
  programs.dconf.enable = true;
  # Many applications rely heavily on having an icon theme available, GNOME’s Adwaita is a good choice but most recent icon themes should work as well.
  #environment.systemPackages = [ gnome3.adwaita-icon-theme ];
  #Systray Icons
  #To get systray icons, install the related gnome shell extension
  #environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
  #And ensure gnome-settings-daemon udev rules are enabled :
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # https://unix.stackexchange.com/questions/437248/how-can-i-install-gnome-shell-extensions-from-extensions-gnome-org-through-firef
  nixpkgs.config.firefox.enableGnomeExtensions = true;
  #nixpkgs.config.chrome.enableGnomeExtensions = true;
  services.gnome.chrome-gnome-shell.enable = true;

  # https://github.com/nix-community/home-manager/issues/284#issuecomment-771119855
  #dconf.settings."org/gnome/shell".disable-user-extensions = false;

  #xdg.dataFile = listToAttrs (map ({ id, package }: {
  #  name = "gnome-shell/extensions/${id}";
  #  value = { source = package; };
  #}) cfg.extensions);


  # Configure keymap in X11
  services.xserver.layout = "pl";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.roman = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "networkmanager"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      #nvidia-offload
      # tcl and tk needed for gitk
      # https://github.com/NixOS/nixpkgs/blob/nixos-21.05/pkgs/applications/version-management/git-and-tools/git/default.nix#L75
      # https://github.com/NixOS/nixpkgs/issues/7726#issuecomment-100351564
      tcl
      tk
      gitFull
      # other
      htop
      calibre
      docker
      file
      google-chrome
      transmission
      transmission-gtk
      neovim
      vscode
      efibootmgr
      gnome.gnome-tweaks # nix-env -q shows as gnome-tweaks
      gnomeExtensions.appindicator
      #gnomeExtensions.dash-to-dock
      mesa-demos
      glmark2
      powertop
      gimp
      inkscape
      desktop-file-utils # has update-desktop-database https://github.com/tubleronchik/kuka-airapkgs/blob/d3bea431b0a092c67256f0c92e362f641182af8b/pkgs/tools/misc/mimeo/default.nix#L18
      tig
      tilix
      firefox
      xorg.xeyes
      ripgrep
      gparted
      dmidecode
      mc
      ncdu
      nixpkgs-fmt
      jq
      # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/14
      # https://discourse.nixos.org/t/import-list-in-configuration-nix-vs-import-function/11372/4
      nvd
      manix
      # development
      nodejs
      python
      robo3t
      # nodejs development
      pkg-config # nix-env -q shows as pkg-config-wrapper
      glew
      libGLU # nix-env -q shows as glu
      xorg.libXi # nix-env -q shows as libXi
      zlib
      xorg.libX11 # nix-env -q shows libX11
      imagemagick
      optipng
  ];

  # /etc/nix/nix.conf is read-only
  # https://unix.stackexchange.com/questions/544340/nixos-unable-to-modify-or-chmod-nix-config-etc-nix-nix-conf
  # https://github.com/NixOS/nixpkgs/issues/80332#issuecomment-587540348
  # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
  #nix = {
  #  #gc.automatic = false;
  #  #optimise.automatic = true;
  #  #readOnlyStore = true;
  #  #useSandbox = true;
  #  #package = pkgs.nixUnstable;
  #  extraOptions = ''
  #    experimental-features = nix-command
  #  '';
  #};

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
    ubuntu_font_family # nix-env -q shows as ubuntu-font-family
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # https://github.com/jordanisaacs/daysquare/blob/be8df7a44d79ed47da3730768b851cfd2a1c514f/flake.nix#L270
  services.mongodb = {
    package = pkgs.mongodb-4_2;
    #bind_ip = "0.0.0.0";
    enable = true;
  };
  services.redis.enable = true;
}

