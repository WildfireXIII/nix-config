# THE ALL IMPORTANT AND MIGHTY NEOVIM CONFIGURATION STUFFS.
# TODO: at some point possibly move the lsp stuff out to dev?
# unclear if I want to break up nvim configuration into two separate sections,
# but it might make it cleaner here.
# NOTE: that this is what misterio does, though it's just broken up into diff
# files in the same folder, not completely separate directories. 

# TODO: keep vim config separate, and minimal, (and don't set vimAlias) so if
# you want simple/raw editing capability can just use vim instead of neovim.

# TODO: do more space bindings in normal, e.g. recommended for format is
# <space>f, and misterio mapped <space>m to make for example.

# TODO: use relativenumber line numbers ("set number relativenumber")

# TODO: possible plugins:
# vim-illuminate - https://github.com/RRethy/vim-illuminate (highlight other instances of that var/word)
# which-key - https://github.com/folke/which-key.nvim (popup with possible keybindings from what you started typing, useful for remembering posible commands)
# nvim-tree - https://github.com/kyazdani42/nvim-tree.lua (better nerdtree)
# telescope - https://github.com/nvim-telescope/telescope.nvim (consider over vista?)
# trouble - https://github.com/folke/trouble.nvim (nice list of diagnostics errors, better than default)
# medieval - https://github.com/gpanders/vim-medieval (execute code blocks in markdown files)

{ pkgs, ... }:
let
  inherit (builtins) readFile;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = readFile ./vim-conf.vim;

    plugins = with pkgs.vimPlugins; [

      # -- Langs --
      vim-nix

      # -- Utils --
      fzfWrapper # TODO: unclear on differences between this one and fzf-vim
      fzf-vim
      nvim-comment # shortcut to comment lines
      vim-tmux-navigator # vim-side of navigating between tmux/vim panes

      # -- Visual improvements --
      everforest # beautiful colorscheme
      lualine-nvim # better statusline written in lua
      nvim-web-devicons # TODO: unclear if this works w/o font-awesome?
      indent-blankline-nvim # show indent line and current block highlight
      vista-vim # shows a "map" of all the symbols from lsp

      # -- Autocompletion --
      nvim-cmp
      cmp-buffer
      cmp-spell
      cmp-path

      # -- Treesitter --
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)) # TODO: ??
      cmp-treesitter
      
      # -- LSP --
      nvim-lspconfig # easy configuration setups for a bunch of lsp's
      null-ls-nvim # an lsp server wrapper for any cli utils that don't have dedicated server
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help # continues to display signature info as you type

      # -- Snippets --
      luasnip
      cmp_luasnip
    ];

    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nodePackages.vim-language-server

      # -- Python language server stuff --
      python39Packages.python-lsp-server
      python39Packages.pylsp-mypy # TODO: unclear if working
      python39Packages.pyls-isort
      python39Packages.python-lsp-black
      python39Packages.flake8

      universal-ctags # important for vista-vim to work 
      fzf
    ];

    extraPython3Packages = (ps: with ps; [
        jedi
        pynvim
    ]);
  };
}
