# Search Dat Term

A terminal-based application launcher and app-nickname tool for Linux.

Search Dat Term lets you find installed desktop applications from a terminal using [fzf](https://github.com/junegunn/fzf), launch them, and create short shell commands (nicknames) for applications you use often.

## Portability work

The original Arch-based setup is preserved on the `main` branch. Portability work is being developed separately on `portability-v1` so changes can be reviewed before they replace the original version.

The portability branch adds:

- XDG-based application discovery (`XDG_DATA_HOME` and `XDG_DATA_DIRS`).
- Additional standard application directories and Flatpak export directories.
- A launcher that prefers `gtk-launch`, then tries `gio launch`, then `dex`.
- A configurable nickname file location, while continuing to use the historical Niri-era file if it already exists.
- A user-local installer that does not depend on a particular distribution's package manager.

This is an initial compatibility pass, not a claim that every Linux distribution or desktop environment has been tested. The launcher requires one of `gtk-launch`, `gio`, or `dex`.

## Features

- **Terminal app search** — interactively search desktop applications with fzf.
- **Launch applications** — launch the selected desktop entry through an available desktop launcher.
- **Create app nicknames** — use `addnick` to create a short Bash function for an installed application.
- **Flatpak discovery** — checks common system and per-user Flatpak export directories.

## Requirements

- Linux with a graphical desktop session.
- Bash 4 or newer.
- [fzf](https://github.com/junegunn/fzf).
- Standard command-line utilities: `find`, `awk`, `grep`, `sort`, `sed`, and `tr`.
- At least one desktop-entry launcher:
  - `gtk-launch` (GTK 3)
  - `gio` with its `launch` subcommand (GLib)
  - `dex` (optional alternative)

Package names vary by distribution. Install `fzf` and at least one supported launcher using your distribution's package manager.

## Install

From a cloned copy of this repository, run:

```bash
bash install.sh
```

The installer places the commands in `~/.local/bin` and the shared helper library under `$XDG_DATA_HOME/search-dat-term` (or `~/.local/share/search-dat-term` when `XDG_DATA_HOME` is unset).

Make sure `~/.local/bin` is in your `PATH`. You can override the command installation directory by setting `SDT_BIN_DIR` before running the installer.

The installed commands are:

| Command | Purpose |
| --- | --- |
| `terminal-app-search` | Opens an fzf list of discovered desktop applications and launches the selected app. |
| `addnick` | Prompts for an application nickname and adds a Bash function. |
| `sdt-launch` | Launches a desktop entry by its desktop-file ID. |

## Nicknames

The first time `addnick` creates a nickname file, its default location is:

```text
${XDG_CONFIG_HOME:-~/.config}/search-dat-term/nicknames.sh
```

If the historical `~/.config/niri/command/nicknames.sh` file already exists, it is reused to avoid breaking an existing setup. You can override the location with `SDT_NICKNAMES_FILE`.

After creating a nickname, add the `source` line printed by `addnick` to your Bash startup file (commonly `~/.bashrc`), then open a new Bash session. The generated functions use `sdt-launch`, which must be available on your `PATH`.

## Application discovery

Search Dat Term checks:

- `$XDG_DATA_HOME/applications` (defaults to `~/.local/share/applications`)
- Each `applications` directory under `$XDG_DATA_DIRS` (defaults to `/usr/local/share:/usr/share`)
- `~/.local/share/flatpak/exports/share/applications`
- `/var/lib/flatpak/exports/share/applications`

Desktop entries marked `NoDisplay=true` or `Hidden=true`, and entries whose type is not `Application`, are skipped.

## Desktop environment

The application search and nickname tools are terminal-based and do not require Hyprland, Niri, Kitty, or a particular terminal emulator. They need to be run inside a graphical desktop session so that launched applications can open.

## Testing status

The portability branch has not yet been tested across a representative set of distributions or desktop environments. Please report your distribution, desktop environment, launcher command available on your system, and any error output when reporting a problem.

## Original version

The original Arch-based scripts and README are preserved on the `main` branch. The portability branch is intentionally separate until the changes have been reviewed and tested.

## Contributing

Bug reports and suggestions are welcome. Please include your distribution, desktop environment, and the output of any relevant error messages.
