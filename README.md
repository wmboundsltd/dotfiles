<img width="300" alt="dotfiles_preview" src="https://github.com/user-attachments/assets/98976abb-a5e6-41b5-a00d-8b20d7ac766b">
<img width="300" alt="dotfiles_preview" src="https://github.com/user-attachments/assets/a1a88e51-18b9-4c0f-b17b-795849d5a847">
<img width="300" alt="dotfiles_preview" src="https://github.com/user-attachments/assets/53ac77f8-bf5b-4b53-8b6f-b01fc5ee95a0">

## u0398's dotfiles


A collection of dotfiles for a number of programs:

- Zsh Shell
- Bash Shell
- tmux Terminal Multiplexer
- nvim Text Editor

Both Bash and Zsh shell configurations include some degree of completion and git support.

## tmux

The tmux theme is a [fork](https://github.com/u0398/tmux-catppuccin) of the [Catpputtin tmux plugin](https://github.com/catppuccin/tmux). Combined with a [fork](https://github.com/u0398/tmux-continuum) of the [Continuum plugin](https://github.com/tmux-plugins/tmux-continuum), it's possible to display the interval and duration of automatic saves of the tmux environment.

![continuum](https://github.com/user-attachments/assets/95dc0c3e-63de-4a89-85ae-1a2b945d6e41)


## Installation

The dotfiles are intended to be used in a detached worktree:
```
git clone --bare https://github.com/u0398/.dotfiles $HOME/.dotfiles
cd ~/.dotfiles
git config core.bare false
git config core.worktree "$HOME"
git config --local status.showUntrackedFiles no
cd ~
rm -r ~/.bash* ~/.profile
git --git-dir=$HOME/.dotfiles/ checkout
git --git-dir=$HOME/.dotfiles/ submodule update --init --recursive --remote
git --git-dir=$HOME/.dotfiles/ remote set-url origin git@github.com:u0398/.dotfiles.git
```
fzf requires installation. The config files need no modification, so use `--bin` to only install the binary.
```
cd ~/.config/fzf
./install --bin
```
Build batcat's binary cache for custom catppuccin themes.
```
bat cache --build
```
Finally, switch to zsh shell, and reconnect.
```
chsh -s /bin/zsh
```

#
Then use the`dotgit`and`dotlazy`(lazygit) to work with the repository.

## Recommended Packages

- zsh
- lazygit
- neovim (unstable)
- fzf
- batcat
- ripgrep
- fd
