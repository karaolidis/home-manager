{ config, lib, pkgs, ... }:
let cfg = config.programs.abook;
in {
  options.programs.abook = {
    enable = lib.mkEnableOption "Abook";

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        field pager = Pager
        view CONTACT = name, email
        set autosave=true
      '';
      description = ''
        Extra lines added to {file}`$HOME/.config/abook/abookrc`.
        Available configuration options are described in the abook repository:
        <https://sourceforge.net/p/abook/git/ci/master/tree/sample.abookrc>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.abook ];

    xdg.configFile."abook/abookrc" = lib.mkIf (cfg.extraConfig != "") {
      text = ''
        # Generated by Home Manager.
        # See http://abook.sourceforge.net/

        ${cfg.extraConfig}
      '';
    };
  };
}
