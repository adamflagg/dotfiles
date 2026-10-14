# dotfiles

Shell and tmux config shared across my Linux boxes and Macs, managed with
[chezmoi](https://chezmoi.io).

## New machine

```sh
# Linux (installs chezmoi to ~/.local/bin)
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply adamflagg/dotfiles

# macOS
brew install chezmoi && chezmoi init --apply adamflagg/dotfiles
```

Open a new shell afterwards.

`init` asks two questions about this machine (see [Claude launchers](#claude-launchers)):

- **Projects root**: the folder whose git repos the picker lists (default
  `~/Projects` on macOS, `~` elsewhere).
- **Default project**: where `cmux` and `cdb` start. Leave it blank to pick
  each time (e.g. on a laptop with many repos); set it on a machine where
  you work in one repo (e.g. `~/work/app`).

It also installs tmux and fzf if they're missing (not on Unraid; see
[Unraid](#unraid)).

## Day to day

| To | Run |
|----|-----|
| Pull changes onto this machine | `chezmoi update` |
| Edit a managed file | `chezmoi edit ~/.tmux.conf` (then `chezmoi apply`) |
| Start tracking a file | `chezmoi add ~/.something` |
| See what apply would change | `chezmoi diff` |
| Change this machine's projects root or default project | `chezmoi init --prompt --apply` (asks everything again; without `--apply` the answers are saved but not used until the next apply) |
| Commit and push | `chezmoi cd`, then plain git (pushing needs GitHub credentials) |

After `chezmoi update`, if `chezmoi apply` says the config template has changed,
run `chezmoi init`: it asks only the questions that are new.

## What's here

| Source | Lands at | What |
|--------|----------|------|
| `dot_local/bin/executable_cmux` | `~/.local/bin/cmux` | Claude in tmux, one session per workstream. `cmux -h` |
| `dot_local/bin/executable_pick-project` | `~/.local/bin/pick-project` | Project picker used by `cmux` and `cdb`. `pick-project -h` |
| `dot_local/bin/executable_claude-bypass` | `~/.local/bin/claude-bypass` | `claude` with permission checks off, or auto mode as root |
| `dot_config/shell/common.sh.tmpl` | `~/.config/shell/common.sh` | PATH, `PROJECTS_ROOT`/`DEFAULT_PROJECT`, `cdb` (Claude without tmux) for bash and zsh |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | Per-machine answers asked at `chezmoi init` (`projectsRoot`, `defaultProject`) |
| `dot_config/shell/init.{bash,zsh}` | `~/.config/shell/` | Loads common.sh, adds tab completion |
| `dot_tmux.conf` | `~/.tmux.conf` | `tmux-256color` where the machine's terminfo has it, else `xterm-256color` (Unraid) |
| `.chezmoidata/packages.yaml` | — | Tools every machine needs (tmux, fzf) |
| `run_onchange_before_install-packages.sh.tmpl` | — | Installs missing packages with brew or apt; re-runs when the list changes |
| `run_onchange_after_hook-shell-rc.sh` | — | Appends one `source` line to `~/.bashrc` / `~/.zshrc` |
| `.chezmoiremove` | — | Files to delete from every machine whose source was removed here |
| `.chezmoiignore` | — | Skips the rc hook and package install on Unraid |

## Claude launchers

| Command | Does |
|---------|------|
| `cmux` | Claude in tmux, one session per workstream (details: `cmux -h`) |
| `cmux <word>` | Resume session `<word>`; else start one in project `<word>`; else start a new session called `<word>` |
| `cmux -p` | Force the menu: running sessions, then projects |
| `cmux -k <name>` | Kill a session |
| `cdb` | Claude in this terminal, no tmux |
| `cdb <project>` | Start in that project (a partial name opens the picker, filtered) |
| `cdb -p` | Force the project picker |

- **Where they start:** this machine's default project, or the picker when it's
  blank. With no default project, a bare `cmux` always shows the menu, so `-p`
  only matters on a machine that has one.
- **The picker** lists the git repos directly under the projects root.
  Worktrees (whose `.git` is a file) are left out. To hide a repo on one
  machine, add its name to `~/.config/pick-project/exclude` (local, not
  managed here). Details: `pick-project -h`.
- **Exiting:** `/exit` or Ctrl-C twice closes the `cmux` session too, and you're
  back in your terminal. `prefix d` leaves it running for later.
- **Permissions:** both run Claude through `claude-bypass`, so permission
  checks are off. As root, where Claude Code refuses that unless
  `IS_SANDBOX=1`, it starts in auto mode instead.

## Unraid

`/root` is a RAM disk on Unraid, so everything chezmoi writes is gone after a
reboot. There, a script that runs at array start does the setup instead:

- chezmoi itself, its source and its config live on persistent storage (the
  array or a pool), symlinked to the usual places.
- Every boot runs `chezmoi apply --force` to rebuild `~/.local/bin`,
  `~/.config/shell` and `~/.tmux.conf` from that source (offline).
- `init.bash` is loaded from `~/.bashrc.d`, not by the rc hook, and packages
  come from un-get; `.chezmoiignore` skips both scripts.

## Rules

- **`~/.bashrc` and `~/.zshrc` are not tracked.** They hold secrets, nvm,
  per-machine PATH. Anything portable goes in `~/.config/shell/` instead.
- **No secrets or personal details in this repo**: it's public. That means no
  hostnames, IPs, private repo names, employer or project names, or
  machine-specific paths. Those go in the local rc file or the per-machine
  answers.
- **Removing a managed file:** delete its source *and* list its target in
  `.chezmoiremove`, or it stays behind on every machine.
- **Scripts must run on macOS's `/bin/bash` 3.2**: no `mapfile`,
  `EPOCHSECONDS`, `declare -A` or `${var,,}`. Test with
  `docker run --rm -it bash:3.2`.
- **Per-machine settings** are prompts in `.chezmoi.toml.tmpl`, answered once at
  `chezmoi init` and kept in the untracked `~/.config/chezmoi/chezmoi.toml`. Change
  them with `chezmoi init --prompt --apply`, or `chezmoi edit-config` then `chezmoi apply`. Templates must still render
  when a key is missing (`hasKey`), because `chezmoi update` doesn't re-ask.
