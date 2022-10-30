# (2022/07/20) Recreating this flake based on misterio's as it has many of the
# elements I'm looking for: https://github.com/Misterio77/nix-config
# TODO: he has a bunch of cool looking nix tools listed:
# https://github.com/Misterio77/nix-config/blob/main/home/misterio/cli/default.nix
#
# (2022/07/21) NOTE: we can have each home-manager config have its own dedicated
# folder in home too, if we want to specify individual machine stuff without
# trying to figure out how to do a ton of abstraction

# (2022/07/22) Is it possibly worth it to extract a lot of the vim config stuff 
# into development modules? It would be nice if cli-core were actually pretty small,
# and maybe there are quite a few systems where I don't really need any language 
# servers.
# TODO: also have a "minimal" hm that has almost nothing
# Note that the way you update packages (I think) for a home mangaer configuration
# is as they mention in their wiki, which is literally just "nix flake update":
# https://rycee.gitlab.io/home-manager/index.html#sec-flakes-standalone
# Also see the third-deep nested comment, discusses how you can explicitly set nix 
# to directly follow a specific url
# https://www.reddit.com/r/NixOS/comments/pmz2vi/how_do_i_update_nix_to_the_latest_unstable_version/

# (2022/07/24) Current problem with bootstrap: the first time you run it never
# works because I guess nix isn't found in path yet?

# (2022/09/14) I added a basic vscode install to arcane, but there's a lot of
# features that don't work since you can't edit the settings on the fly. There's
# a solution to this that modifies home activation for that package, seems
# fairly straightfoward: https://github.com/nix-community/home-manager/issues/1800

# (2022/10/23) I regularly get a "tput: unknown terminal 'xterm-kitty'" error the 
# time I'm trying to install things. This might be related to 
# https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-when-sshing-into-a-different-computer
# where the solution is to ssh with `kitty +kitten ssh myserver` It might be worth
# it to eventually include that terminfo directly in my config and copy over?


# (2022/10/26) Another valuable set of dotfiles to reference: https://man.sr.ht/~hutzdog/dotfiles/

# TODO's
# ===============================
# STRT: make the cli-core nvim more minimal, use dev modules to add more plugin stuff
# DONE: Add overlay for cmp-nvim-lsp-signature-help
# DONE: Add bootstrapping capability
# STRT: Start adding personal pkgs tools.
# DONE: setup terminfo_dirs because I feel like that's been a problem? See phantom sessionVariables
# TODO: package/cmd to grab the sha256 of a repo, see old flake
# TODO: way to automate firefox speedups? https://www.drivereasy.com/knowledge/speed-up-firefox/ (will need to add nur which has firefox and extensions)
# TODO: script to keep backup ref to home-manager gen and make it easy to switch to that one
# TODO: add pre-commit stuff to this
# TODO: make a exportshellcolors script that exports vars for colors, since it's easy to include that as a runtime dependency with  the writeshellapplication
# TODO: snippet for nix header block
# TODO: make a modified writeshellapplication that takes a version and a description and adds it to a special list that I can view with a separate package
# TODO: fix vim auto line break to be how I used to have it
# STRT: fix non writable settings.json for vscode
# DONE: add everforest vscode theme overlay
# TODO: submit everforest theme extension to nixpkgs, use https://github.com/NixOS/nixpkgs/pull/191145 as a model
# TODO: the nix lock file should be per machine, that way if I update on one I don't break it in the others 
# TODO: tool to build flake and grab configs and publish to separate repo for when nix unavailable
# TODO: it would be cool if features could be specified without ".nix" if it's
# just a file and not a folder
# TODO: investigate allowing serving a nix store via ssh https://nixos.org/manual/nix/stable/package-management/ssh-substituter.html
# TODO: make some nice plymouth boot stuff! 
# TODO: my lib should prob be called iris-lib to avoid ambiguity and confusion.

# MODULES NEEDED
#================================
# dev (-python -web -research) [unclear how much to break this up]
# research
# desktop/i3
# radio
# (hosting stuff)
# gaming

# Debugging tools:
#-------------------
# builtins.trace e1 e2 (prints e1, returns e2)
# nixpkgs.lib.traceVal e1 (prints and returns e1)

# QUESTIONS
# ===============================
#   - He has custom pkgs, but how does he reference them/pull them in?
#   A: ahhh, I believe he does it in overlay/default.nix at the end, the // ../pkgs
#
#   - Where does he pull in the features? lib.mkHome only puts them into
#   "extraSpecialArgs" along with some modules.
#   A: Inside home/misterio/default, he has an imports list that concats a map
#   with the features list (this "imports" is what makes it a "module", and it
#   is notably importing other modules)
#
#   - How do modules work, do they just automagically append everything when
#   multiple modules are all assigning to the same thing?
#   A: Yeah I think so, in https://nixos.wiki/wiki/Module in "under the hood",
#   they mention that for each option they collect all definitions from all
#   modules and merge them together according to options type.
#   NOTE: so this means we could probably have things like vim plugins/settings
#   modularized too? (e.g. I don't want javascript linters clogging up my system
#   if I have no intention of developing javascript on that system.)
#   NOTE: also, I can probably nest folders like misterio but also have default
#   in top level, so you can either auto import everything by specifying the top
#   level feature, or specify only select things.
#
#   - Wait, where's the "laptop" module? He mentions in /home/misterio/default
#   "import features _that have modules_, are there features that don't?
#
#   - How do we get those other elements put into extraSpecialArgs? 
#   A: They are passed as arguments to each module, so the beginning { ... }
#   function def line.
#
#   - How do I get access to my library functions deep within modules?
#   A: It's somehow still an argument being passed around.

{
  description = "My awesome-sauce and cool-beans nix configuration-y things.";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # unsure what this actually does. (It
      # makes it so that home-manager isn't downloading it's own set of nixpkgs,
      # we're "overriding" the nixpkgs input home-manager defines by default)
    };

    # TODO: add in nix-colors! 
  };

  outputs = inputs:
  let
    lib = import ./lib { inherit inputs; }; # This feels problematic, should probably be "mylib" instead
    inherit (lib) mkHome mkSystem mkStableSystem forAllSystems;
    inherit (builtins) attrValues;
  in
  rec {
    inherit lib; # TODO: ....why is this here? does this let you do outputs.lib? or self.lib?


    # =================== NIXOS CONFIGURATIONS ==================

    nixosConfigurations = {
      therock = mkStableSystem {
        configName = "therock";
        hostname = "therock";
        system = "x86_64-linux";
      };
    };

    # ===========================================================



    # =================== HOME CONFIGURATIONS ===================
      
    homeConfigurations = {
      # primary desktop
      phantom = mkHome {
        configName = "phantom";
        username = "dwl";
        hostname = "phantom";
        noNixos = true;
      };
	
      # primary laptop
      delta = mkHome {
        configName = "delta";
        username = "dwl";
        hostname = "delta";
        noNixos = true;
      };

      # homeserver
      therock = mkHome {
        configName = "therock";
        username = "dwl";
        hostname = "therock";
      };

      # work linux workstation 
      arcane = mkHome {
        configName = "arcane";
        username = "81n";
        hostname = "arcane";
        noNixos = true;
        gitEmail = "martindalena@ornl.gov";
        configLocation = "/home/81n/lab/nix-config";
      };

      # work laptop (wsl)
      wlap = mkHome {
        configName = "wlap";
        username = "dwl";
        hostname = "LAP124750";

        features = [ "dev" ];
        noNixos = true;
        gitEmail = "martindalena@ornl.gov";
      };
    };
    
    # ===========================================================
	
    overlays = {
      # https://nixos.wiki/wiki/Flakes (see section "Importing packages from multiple channels")
      # a single overlay that always includes both,
      # this would allow modules that get imported from both a stable and 
      # unstable context to work if they require a specific channel, and all the
      # rest of the packages will just default to whatever context called from.
      
      stable-unstable-combo = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
        stable = import inputs.nixpkgs-stable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      
      custom-pkgs = import ./overlay { inherit inputs; };
    };

    # overlay-unstable = final: prev: {
    #   unstable = import inputs.nixpkgs-unstable {
    #     system = prev.system;
    #     config.allowUnfree = true;
    #   };
    # };
    #
    # overlay-stable = final: prev: {
    #   stable = import inputs.nixpkgs-stable {
    #     system = prev.system;
    #     config.allowUnree = true;
    #   };
    # };

    legacyPackagesUnstable = forAllSystems (system:
      import inputs.nixpkgs-unstable {
        inherit system;
        overlays = attrValues overlays; # ++ [ overlay-stable ];
        config.allowUnfree = true;
      }
    );
    
    legacyPackagesStable = forAllSystems (system:
      import inputs.nixpkgs-stable {
        inherit system;
        overlays = attrValues overlays; # ++ [ overlay-unstable ];
        config.allowUnfree = true;
      }
    );
    
    # home-manager bootstrap script. If home-manager isn't yet installed, run
    # `nix shell .` and then `bootstrap [NAME OF HOME CONFIG]`
    # TODO: why isn't this just using the writeshellscript whatever?
    # checkout the bootstrap used in https://github.com/Misterio77/nix-starter-configs/blob/main/standard/shell.nix
    packages = forAllSystems (system: {
      default = with legacyPackagesUnstable.${system}; 
      stdenv.mkDerivation rec {
        name = "bootstrap-script";
        installPhase = /* bash */ ''
          mkdir -p $out/bin
          echo "#!${runtimeShell}" >> $out/bin/bootstrap
          echo "export TERMINFO_DIRS=/usr/share/terminfo" >> $out/bin/bootstrap
          echo "nix build --no-write-lock-file home-manager" >> $out/bin/bootstrap
          echo "./result/bin/home-manager --flake \".#\$1\" switch --impure" >> $out/bin/bootstrap
          chmod +x $out/bin/bootstrap
        '';
        dontUnpack = true;
      };
    });
  };
}
