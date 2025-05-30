{pkgs, settings, ...}:

{
  home.file = {
    ".config/zsh/plugins/zsh-autosuggestions".source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
    ".config/zsh/plugins/fast-syntax-highlighting".source = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
    ".config/zsh/plugins/nix-zsh-completions".source = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix";
    ".config/zsh/plugins/pure".source = "${pkgs.pure-prompt}/share/zsh/site-functions";
    ".config/zsh/functions".source = ../../dotfiles/.config/zsh/functions;
    ".config/zsh/keybinds.zsh".source = ../../dotfiles/.config/zsh/keybinds.zsh;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    envExtra = ''
      export EDITOR="vim"
      export TERMINAL="konsole"
      export TERM="konsole"
      export BROWSER="firefox"
      export VIDEO="mpv"
      export OPENER="xdg-open"
    '';
    initContent = ''
      # Set emacs key binding.
      bindkey -e

      # Import functions.
      source "$ZDOTDIR/functions"

      # Set custom key bindings.
      zsh_add_config keybinds.zsh

      # Configure pure-prompt.
      export PURE_PROMPT_SYMBOL="$"
      if [ "$USER" = "root" ]; then
        export PURE_PROMPT_SYMBOL="#"
      fi
      export PROMPT_PURE_SSH_CONNECTION=YES
      zsh_fpath_plugin sindresorhus/pure
      autoload -U promptinit; promptinit
      zstyle :prompt:pure:user color cyan
      zstyle :prompt:pure:host color white
      zstyle ':prompt:pure:prompt:*' color white
      prompt pure

      # Add extra plugins.
      zsh_add_plugin zdharma-continuum/fast-syntax-highlighting

      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      zsh_add_plugin zsh-users/zsh-autosuggestions

      # Show off the system.
      ${pkgs.fastfetch}/bin/fastfetch
    '';
  };
}
