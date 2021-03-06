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
  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598
  #unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };

  # https://nixos.wiki/wiki/Python
  inherit (pkgs) python3;
  my-python-packages = python-packages: with python-packages; [
    pip # is it needed?
    pandas
    requests
    beautifulsoup4
    #sqlite3 # looks like python3 in nixos has sqlite support already
    autopep8
  ];
  python-with-my-packages = python3.withPackages my-python-packages;
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
  # https://sourcegraph.com/github.com/NixOS/nixpkgs/-/blob/nixos/modules/config/i18n.nix?L40:21
  # https://sourcegraph.com/github.com/M-Gregoire/infrastructure/-/blob/nixos/common.nix?L87:29
  # https://sourcegraph.com/github.com/magnetophon/nixosConfig/-/blob/common.nix?L889
  i18n = {
    defaultLocale = "pl_PL.UTF-8";
    extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; LC_TIME = "pl_PL.UTF-8"; };
    supportedLocales = [ "en_US.UTF-8/UTF-8" "pl_PL.UTF-8/UTF-8" ];
  };
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
  services.xserver.displayManager.gdm.wayland = false;
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
  # https://unix.stackexchange.com/questions/377600/in-nixos-how-to-remap-caps-lock-to-control/639163#639163
  # TODO: Make it working in wayland also?
  #services.xserver.xkbOptions = "caps:escape";
  #console.useXkbConfig = true;

  # # needed when using xkbOptions or interception-tools
  # https://gitlab.com/interception/linux/plugins/dual-function-keys#my-key-combination-isnt-working
  #
  # $ gsettings get org.gnome.desktop.input-sources xkb-options
  # ['terminate:ctrl_alt_bksp', 'lv3:ralt_switch']
  # $ gsettings get org.gnome.desktop.input-sources sources
  # [('xkb', 'pl')]

  # regular GNOME uses gnome-settings-daemon to manage keyboard configuration. And its keyboard manager uses GSettings to store the keyboard configuration, only using the xkb config for initial set up:
  # You can clean up the settings using
  # $ gsettings reset org.gnome.desktop.input-sources xkb-options
  # $ gsettings reset org.gnome.desktop.input-sources sources
  # and the system defaults should be picked up after re-login.
  # https://discourse.nixos.org/t/problem-with-xkboptions-it-doesnt-seem-to-take-effect/5269/2
  # https://discourse.nixos.org/t/configuring-caps-lock-as-control-on-console/9356
  # I do this with services.udev.extraHwdb
  # interception-tools.enable = true;
  # In my NixOS configuration to get Capslock as Control + Escape verywhere.
 
  # https://www.reddit.com/r/NixOS/comments/r4swzy/comment/hmj4gxq/
  environment.etc."dual-function-keys.yaml".text = ''
    MAPPINGS:
      - KEY: KEY_CAPSLOCK
        TAP: KEY_ESC
        HOLD: KEY_LEFTCTRL
  '';
  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK]
    '';
  };



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
      "wireshark"
    ];
  };
  # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-21.11
  users.groups.users = {};

  nixpkgs.config.allowUnfree = true;

  # https://discourse.nixos.org/t/neovim-checkhealth-problems/16233/4
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    "L+ /lib64/ld-linux-x86-64.so.2 - - - - ${pkgs.stdenv.glibc}/lib64/ld-linux-x86-64.so.2"
  ];

  # https://nixos.wiki/wiki/NixOS:extend_NixOS
  #
  # https://www.reddit.com/r/NixOS/comments/cg102t/comment/eudvtz1/
  # https://discourse.nixos.org/t/direct-firmware-load-for-regulatory-db-failed/16317
  systemd.services.iw-reg-set = {
    serviceConfig = {
      ExecStart = "${pkgs.iw}/bin/iw reg set PL";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.geoclue2.enable = true;

  # /etc/nix/nix.conf is read-only
  # https://unix.stackexchange.com/questions/544340/nixos-unable-to-modify-or-chmod-nix-config-etc-nix-nix-conf
  # https://github.com/NixOS/nixpkgs/issues/80332#issuecomment-587540348
  # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
  nix = {
    package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    #gc.automatic = false;
    #optimise.automatic = true;
    #readOnlyStore = true;
    #useSandbox = true;
  };

  # https://www.reddit.com/r/NixOS/comments/r0o829/comment/hlv6hoj/
  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/19
  # https://sourcegraph.com/github.com/vic/mk-darwin-system/-/blob/default.nix?L60
  #${nix}/bin/nix profile diff-closures --profile /run/current-system "$systemConfig"
  system.activationScripts.diff = ''
    ${pkgs.nixUnstable}/bin/nix store \
        --experimental-features 'nix-command' \
        diff-closures /run/current-system "$systemConfig"
  '';
  
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
      tig
      git-trim
      htop
      calibre
      docker
      file
      #google-chrome
      unstable.google-chrome
      transmission
      transmission-gtk
      unstable.neovim
      # clipboard on linux needs xclip on xorg or wl-paste on wayland
      # https://discourse.nixos.org/t/how-to-support-clipboard-for-neovim/9534/3
      # or xsel https://github.com/neovim/neovim/issues/7945#issuecomment-361970165
      xclip
      vscode
      efibootmgr
      gnome.gnome-tweaks # nix-env -q shows as gnome-tweaks
      mesa-demos
      glmark2
      powertop
      gimp
      inkscape
      desktop-file-utils # has update-desktop-database https://github.com/tubleronchik/kuka-airapkgs/blob/d3bea431b0a092c67256f0c92e362f641182af8b/pkgs/tools/misc/mimeo/default.nix#L18
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
      sqlite-interactive # readline works in this variant
      # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/14
      # https://discourse.nixos.org/t/import-list-in-configuration-nix-vs-import-function/11372/4
      nvd
      manix
      pavucontrol
      mpv
      ffmpeg
      audacity
      nix-index
      exiftool
      python-with-my-packages
      obs-studio
      fd
      iw
      (geoclue2.override { withDemoAgent = true; })
      lsb-release
      yt-dlp
      tokei
      # speedtest -L
      # speedtest -s 4166
      ookla-speedtest
      libreoffice-fresh
      tree
      csvkit
      #bintools
      #bintools-unwrapped
      p7zip
      workrave
      mono
      #
      # hardware information
      #
      inxi
      hwinfo
      # sudo lshw -short
      # sudo lshw -C storage
      lshw
      #
      # development
      #
      nodejs-16_x
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
      gnumake
      libuuid # libuuid is in util-linux, required for node-canvas or sth
  ];

  xdg.mime.defaultApplications = {
    "application/pdf" = "evince.desktop";
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

  # https://nixos.wiki/wiki/Steam
  programs.steam.enable = true;

  # https://www.reddit.com/r/NixOS/comments/n4b3tl/i_cant_initiate_capture_session_on_wlp3s0_says_i/
  # https://github.com/search?q=%22programs.wireshark.enable%22&type=code
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

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
    extraConfig = ''
      operationProfiling.mode: all
      #systemLog.quiet: false
    '';
  };
  services.redis.enable = true;

  services.fstrim.enable = true;
}

