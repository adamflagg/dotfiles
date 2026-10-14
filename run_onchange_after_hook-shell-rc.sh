#!/bin/sh
# Point ~/.bashrc and ~/.zshrc at the shared config. The rc files themselves
# stay machine-local (secrets, nvm, PATH tweaks), so this only appends one
# line to each, once. zsh's line goes last so compinit has already run.
# shellcheck disable=SC2088  # the ~ is written to the rc file literally, on purpose
hook() {  # $1 = rc file, $2 = init file
  grep -qsF "$2" "$1" && return
  printf '\n# Shared shell config, managed by chezmoi (see ~/.local/share/chezmoi)\n[ -f %s ] && . %s\n' "$2" "$2" >> "$1"
  echo "chezmoi: hooked $2 into $1"
}
hook "$HOME/.bashrc" '~/.config/shell/init.bash'
command -v zsh >/dev/null && hook "$HOME/.zshrc" '~/.config/shell/init.zsh'
exit 0
