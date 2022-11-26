# amethyst, system configuration for BEAST HOME PC!

{ config, pkgs, hostname, lib, ... }:
let
  capsLockKBLayout = pkgs.writeText "xkb-layout" ''
    clear lock
    clear mod4
    clear mod5
    keycode 66 = Hyper_L
    !add lock = Hyper_L
    add mod4 = Super_L Super_R
    add mod5 = Hyper_L
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    timeout = 2;

    grub = {
      enable = true;
      version = 2;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };
  
  # Enable networking
  networking = {
    useDHCP = false; # networkmanager does this?
    networkmanager.enable = true;
    
    hostName = hostname;
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 22 ];
    };
  };

  # debug with `fc-list | grep 'fontname'`
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    powerline-fonts
    nerdfonts
  ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
      owner = "WildfireXIII";
      repo = "sddm-chili";
      rev = "caa55a0ed9996bcd3ddec2dd48a2c7975fa49f4c";
      sha256 = "09qd4fhbvj3afm9bmviilc7bk9yx7ij6mnl49ps4w5jm5fgmzxlx";
    })}";
    desktopManager.session = [
      {
        name = "xsession";
        start = ''
          ${pkgs.runtimeShell} $HOME/.xsession &
          waitPID=$!
        '';
      }
    ];
  };
  
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true; # recommended from https://linuxhint.com/how-to-instal-steam-on-nixos/
  services.xserver.videoDrivers = [ "nvidia" ];

  # https://discourse.nixos.org/t/xmodmap-keyboard-layout-customization-question/11522
  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  # enable using the caps lock key has Mod5
  services.xserver.displayManager.sessionCommands = /* bash */''
    # set up the monitors
    LEFT="DP-3"
    CENTER="DP-0"
    RIGHT="DP-5"
    HDMI="HDMI"
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output $LEFT --mode 1920x1080 --pos 0x10 --rotate normal \
      --output $RIGHT --mode 1920x1080 --pos 4480x10 --rotate normal \
      --output $CENTER --mode 2560x1440 --pos 1920x0 --rotate normal \
      --output $HDMI --off
      
    
    # set up my caps lock keyboard configuration
    ${pkgs.xorg.xmodmap}/bin/xmodmap ${capsLockKBLayout}

    # allow keyring authentication, apparently fails without this
    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
  '';
  

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

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
    jack.enable = true;
  };

  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
    shell = pkgs.zsh;
  };

  #programs.zsh.enable = true;

  # https://linuxhint.com/how-to-instal-steam-on-nixos/
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  
  services.openssh = {
    enable = true;
    passwordAuthentication = true; # TODO: set this to false
    permitRootLogin = "no";
  };


  environment.systemPackages = with pkgs; [
    openrgb

    # necessary for sddm theme
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtgraphicaleffects

    # steam stuff
    steamcmd
    steam-run
    #steam-run-native # ???
    #(steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ]; nativeOnly = true; }).run
    #(steam.override { withPrimus = true; extraPkgs = pkgs: [ bumblebee glxinfo ]; nativeOnly = true; }).run
    #(steam.override { withJava = true; })

    # experimental audio control
    #qpwgraph
    #pavucontrol
    # easyeffects # can't seem to get this to work, crashes when adding any
    # effect
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
  system.stateVersion = "22.05"; # Did you read the comment?

}