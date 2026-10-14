# Sourced from ~/.bashrc (chezmoi appends the line). Must work on bash 3.2.
. "$HOME/.config/shell/common.sh"

# cmux: sessions and projects, or sessions after -k. cdb: projects.
# shellcheck disable=SC2207  # session and project names never contain spaces
_cmux_complete() {
  local words
  if [ "$1" = cdb ]; then
    [ "$COMP_CWORD" -eq 1 ] || return
    words=$(pick-project --list)
  elif [ "$COMP_CWORD" -eq 2 ] && [ "${COMP_WORDS[1]}" = -k ]; then
    words=$(tmux ls -F '#S' 2>/dev/null)
  elif [ "$COMP_CWORD" -eq 1 ]; then
    words="$(tmux ls -F '#S' 2>/dev/null) $(pick-project --list)"
  else
    return
  fi
  COMPREPLY=($(compgen -W "$words" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _cmux_complete cmux cdb
