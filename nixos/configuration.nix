# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos-unstable/nixos/modules/programs/wayland/dms-shell.nix>
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot = {

    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];

    loader.timeout = 0;

  };

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  time.timeZone = "America/Manaus";

  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2"; 

  services.xserver.xkb.layout = "br";
  services.xserver.xkb.variant = "abnt2";


  zramSwap.enable = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      dgop = unstable.dgop;
    })
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true; 
  virtualisation.docker.enable = true;
  services.upower.enable = true;
  services.thermald.enable = true;
  services.fstrim.enable = true;
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  users.users.admilson = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  programs.firefox.enable = true;
  programs.thunderbird.enable = true;
  programs.localsend.enable = true;
  programs.niri.enable = true;
  programs.niri.useNautilus = true;

  programs.dms-shell = {
    enable = true;
    package = unstable.dms-shell;
    quickshell.package = unstable.quickshell;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    github-desktop
    alacritty
    nautilus
    adwaita-icon-theme
    graphite-cursors
    loupe
    evince
    discord
    unstable.vscode
    xwayland-satellite
    gnome-connections
    file-roller
    (python3.withPackages(ps: with ps; [ tkinter requests pandas ]))
    beekeeper-studio
    onlyoffice-desktopeditors
    deskflow
  ];

  xdg.mime.defaultApplications = {
    "application/pdf" = [ "org.gnome.Evince.desktop" ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_DATA_DIRS = lib.mkDefault "/run/current-system/sw/share";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.auto-optimise-store = true;

  services.displayManager.ly.enable = true;

  system.stateVersion = "25.11";

}

