# Search Dat Term

A terminal-based application launcher and app-nickname tool for Linux.

Search Dat Term lets you find installed desktop applications from a terminal using [fzf](https://github.com/junegunn/fzf), launch them, and create short shell commands (nicknames) for applications you use often.

> **Project status:** This repository is documenting the original working setup first. The current implementation was built on Arch Linux and is now used with Hyprland and Kitty. Cross-distribution compatibility work has **not started yet**. The goal is to preserve the existing behaviour before making the project portable.

## Features

- **Terminal app search** — interactively search desktop applications with fzf.
- **Launch applications** — launch the selected desktop entry using `gtk-launch`.
- **Create app nicknames** — use `addnick` to create a short Bash function for an installed application.
- **Flatpak discovery** — the standalone app-search and nickname scripts also check the common per-user and system Flatpak export directories.

## Current requirements

The original setup uses:

- Linux
- Bash
- [fzf](https://github.com/junegunn/fzf)
- `gtk-launch` (provided by GTK)
- `setsid` (used by generated nickname functions; commonly provided by util-linux)

The current terminal workflow uses Kitty. The author's desktop environment is Hyprland. These are part of the current setup, not requirements of the application-search scripts themselves.

## Files and commands

The original standalone scripts are in `bin/`:

| File / command | Purpose |
| --- | --- |
| `bin/terminal-app-search` | Opens an fzf list of discovered desktop applications and launches the selected app. |
| `bin/addnick` | Prompts for an application nickname and adds a Bash function that launches its desktop entry. |

To put the scripts on your personal command path:

```bash
mkdir -p "$HOME/.local/bin"
cp bin/terminal-app-search bin/addnick "$HOME/.local/bin/"
```

Make sure `$HOME/.local/bin` is in your `PATH`. The scripts are stored in Git with executable permissions.

The author's custom Bash configuration also contains a `search` function. That personal shell configuration has not yet been added to the repository.

## Application discovery

The standalone scripts look for desktop entries in these locations:

- `~/.local/share/applications`
- `/usr/share/applications`
- `/var/lib/flatpak/exports/share/applications`
- `~/.local/share/flatpak/exports/share/applications`

The original `addnick` workflow writes generated functions to:

```text
~/.config/niri/command/nicknames.sh
```

That directory name is historical: the project began while the author was using Niri and was later carried over to a Hyprland setup. The existing path is being documented as-is; it is not a requirement to use Niri.

## Configuration and installation

The two standalone scripts are published, but the author's personal Bash/Kitty/Hyprland integration is still being documented. There is not yet a generic installer or a cross-distribution setup procedure. The scripts currently retain the original paths and assumptions of the working setup.

## Portability roadmap

The work is intentionally staged:

1. Record and publish the original working files without changing their behaviour.
2. Verify that the repository accurately represents the author's existing setup.
3. Only then, make the minimum changes needed for other Linux distributions, keeping the original Arch/Hyprland workflow working.

## Contributing

Bug reports and suggestions are welcome. Please distinguish issues with the original setup from requests for additional distribution support; portability is a later stage of the project.
