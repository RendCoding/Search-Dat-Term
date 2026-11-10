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

## Original commands

| Command | Purpose |
| --- | --- |
| `terminal-app-search` | Opens an fzf list of discovered desktop applications and launches the selected app. |
| `addnick` | Prompts for an application nickname and adds a Bash function that launches its desktop entry. |
| `search` | The application-search function in the author's custom Bash configuration. |

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

The original scripts and personal shell/terminal configuration are being added to this repository in a separate step. There is not yet a generic installer or a cross-distribution setup procedure. Until those files and instructions are published, do not assume that cloning this repository alone installs the commands.

## Portability roadmap

The work is intentionally staged:

1. Record and publish the original working files without changing their behaviour.
2. Verify that the repository accurately represents the author's existing setup.
3. Only then, make the minimum changes needed for other Linux distributions, keeping the original Arch/Hyprland workflow working.

## Contributing

Bug reports and suggestions are welcome. Please distinguish issues with the original setup from requests for additional distribution support; portability is a later stage of the project.
