# hc admin reference

Detail the core `hc` skill doesn't need: terminal sizing, remote machines,
launch environment, recovery, updates, installs, platform quirks. Trimmed
from `hc --skill`; diff against upstream before updating.

## Terminal sizing and display

API clients that already know a terminal's pane size can pass `size: {cols, rows}`
to `terminal.run` (both positive). It applies before the program starts. Omit it
for the unchanged configured headless size (default 200×120); later viewers
still resize the terminal normally. `display: {fg, bg, cursor, cell}` (as in
`terminal.attach`) likewise answers the program's color and cell-size queries
from its start, before any viewer attaches.

## Other machines and files

Your harness's own file tools touch only the machine you run on. Use hc for
remote files and commands. `hc machine ls` lists configured machines; see
`hc machine --help` to configure SSH or `--via <cmd>` connections.
Without `--name`, SSH machines use the first host label (IPs stay whole),
shortened to 32 characters with `-2`, `-3`, etc. added if the name is taken.

On Windows, `hc server status` never starts a core. If elevated SSH startup
would block the same user's desktop session, open Herdr on that Windows
machine or run `hc server start` in a normal desktop terminal, then reconnect.
Headless Windows machines can still start their core over SSH.
New Windows terminals refresh user/system environment settings, including PATH.

```sh
hc run --on vps --cwd /srv/app cargo test    # returns vps/t3; use that full address
hc run --bg --on vps --cwd /srv/app cargo build
hc exec --on vps --cwd /srv/app git diff    # short command, exact output, no terminal
hc file read --on vps /srv/app/src/x.rs --offset 200 --limit 100
hc file edit --on vps /srv/app/src/x.rs --old 'exact text' --new 'replacement'
hc file write --on vps /srv/app/src/y.rs < content.txt
```

`exec -i` feeds piped input to the command. File writes replace the whole
file and create parent folders. Edits require the old text exactly once;
`edit_failed` means add enough context to make it unique. Repeat `--old` and
`--new` pairs for multiple changes; all succeed or none do. No remote shell
text rewriting needed: only the edit travels.
Remote paths start at that machine's home unless you set `--cwd`; local
paths start at your current folder. Prefer explicit paths for remote work.

## Launch environment and recovery

- `hc run` without a command starts this machine's own shell. On macOS,
  this is a login shell so it loads the login environment; explicit commands
  are unchanged. Recovery shells use the same rule.
- `shell = ["nu"]` in `~/.config/herdr-core/config.toml` (Windows:
  `%APPDATA%\herdr-core\config.toml`) overrides the shell for new terminals
  and recovery. Each list item is one argument. Changes apply on the next
  launch; running programs stay running. A missing executable reports
  `spawn_failed`; recovery retries and logs launch errors in `holder.log`.
- Programs get the login session's environment. A local `DISPLAY` or
  `WAYLAND_DISPLAY` is left out only when its socket is missing or refuses
  connections. Host displays (including SSH forwarding) stay as they are.
  A missing `XAUTHORITY` file does not remove a display.
- `hc keep <t>` (or `run --keep`) replaces a lost program with a shell,
  never reruns a task. `hc keep <t> --off` disables recovery. Signal death
  without an exit code is loss too. After a grace delay, recovery runs on
  every OS, including after a host shutdown. On macOS, shutdown warnings
  preserve kept programs even if they catch a signal and exit with a code;
  on Linux, systemd stops the core before its holders. Ordinary exits and
  explicit kills remain final. Streams end on loss; reattach after the
  restarted event. Pending input/attach may be unavailable: retry after recovery.

## Updates and installs (macOS)

- `hc update` also restarts an older running core when the installed binary
  is already current. JSON reports `restarted: true`; terminals keep running.
  Managed installs must be updated with their package manager instead, and
  one in a folder you can't write (Unix) the way it was installed.
- On macOS, privacy requests from terminal programs belong to Herdr Core,
  not Herdr.app. Existing Herdr.app grants do not transfer to the core.
- macOS installs keep the newest bundle at the fixed physical path
  `~/.local/share/herdr-core/active/Herdr Core.app`, selected by a `current`
  symlink, with `hc` and `herdr-core` links in
  `~/.local/bin` (`HC_INSTALL_DIR` overrides the links'
  folder). Updates keep running terminals. A bundled install's `update --from`
  needs a complete signed `.app` (or its `Contents/MacOS/herdr-core`), not a bare
  executable. Terminals created before this bundle
  upgrade may still have broken macOS privacy access: recreate those terminals;
  restarting only the core cannot repair their old holders. After an old updater
  copies only the binary, run `hc update` to finish installing the bundle, even
  if the version is already current. The app completes this during its update.
  Startup never downloads updates. Previous bundles stay on disk while their
  cores or holders run; later installs reclaim unused previous bundles.
  Per-user installs use the bundle. Root/system destinations keep the
  independently signed standalone executable and their existing macOS privacy
  behavior. Machine installs also preserve bundles. A standalone sender cannot
  replace a bundled remote core: run `hc update` there instead. Root remotes
  receive the standalone release.
- On macOS, desktop starts use a one-shot launchd job so quitting the launching
  app doesn't end terminals. SSH starts stay direct. If launchd fails, startup
  falls back to a direct child and logs the reason in `core.log`; that core may
  end with its launching app.

## Misc

- Codex must run with `--no-daemon` (including templates), or its commands
  execute outside hc.
