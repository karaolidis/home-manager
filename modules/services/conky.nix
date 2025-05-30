{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.conky;

in
{
  meta.maintainers = [ lib.hm.maintainers.kaleo ];

  options = {
    services.conky = {
      enable = lib.mkEnableOption "Conky, a light-weight system monitor";

      package = lib.mkPackageOption pkgs "conky" { };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Configuration used by the Conky daemon. Check
          <https://github.com/brndnmtthws/conky/wiki/Configurations> for
          options. If not set, the default configuration, as described by
          {command}`conky --print-config`, will be used.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ (lib.hm.assertions.assertPlatform "services.conky" pkgs lib.platforms.linux) ];

    home.packages = [ cfg.package ];

    systemd.user.services.conky = {
      Unit = {
        Description = "Conky - Lightweight system monitor";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Restart = "always";
        RestartSec = "3";
        ExecStart = toString (
          [ "${cfg.package}/bin/conky" ]
          ++ lib.optional (cfg.extraConfig != "") "--config ${pkgs.writeText "conky.conf" cfg.extraConfig}"
        );
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
