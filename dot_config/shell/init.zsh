# Sourced from ~/.zshrc (chezmoi appends the line, after compinit has run).
. "$HOME/.config/shell/common.sh"

# cmux: sessions and projects, or sessions after -k. cdb: projects.
_cmux() {
  if [[ $service == cdb ]]; then
    (( CURRENT == 2 )) && compadd -- ${(f)"$(pick-project --list)"}
  elif (( CURRENT == 3 )) && [[ $words[2] == -k ]]; then
    compadd -- ${(f)"$(tmux ls -F '#S' 2>/dev/null)"}
  elif (( CURRENT == 2 )); then
    compadd -- ${(f)"$(tmux ls -F '#S' 2>/dev/null)"} ${(f)"$(pick-project --list)"}
  fi
}
if (( $+functions[compdef] )); then compdef _cmux cmux cdb; fi
