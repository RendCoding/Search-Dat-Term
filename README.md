# Search Dat Term

A terminal-based application launcher and app-nickname tool for Linux.

Search Dat Term lets you find installed desktop applications from a terminal using [fzf](https://github.com/junegunn/fzf), launch them, and create short shell commands (nicknames) for applications you use often.

## Portability work

The original Arch-based setup is preserved on the `main` branch. Portability work is being developed separately on `portability-v1` so changes can be reviewed before they replace the original version.

The portability branch adds:

- XDG-based application discovery (`XDG_DATA_HOME` and `XDG_DATA_DIRS`).
- Additional standard application directories and Flatpak/Snap export directories.
- Optional custom application directories through `SDT_EXTRA_APPLICATION_DIRS`.
- A launcher that prefers `gtk-launch`, then tries `gio launch`, then `dex`.
- A configurable nickname file location, while continuing to use the historical Niri-era file if it already exists.
- A user-local installer that does not depend on a particular distribution's package manager.

This is an initial compatibility pass, not a claim that every Linux distribution or desktop environment has been tested. The launcher requires one of `gtk-launch`, `gio`, or `dex`.

## Features

- **Terminal app search** — interactively search desktop applications with fzf.
- **Launch applications** — launch the selected desktop entry through an available desktop launcher.
- **Create app nicknames** — use `addnick` to create a short Bash function for an installed application.
- **Flatpak and Snap discovery** — checks common export directories for these package formats.
- **Custom discovery paths** — add directories containing desktop-entry files when an application is installed somewhere non-standard.

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

After creating a nickname, `addnick` now automatically adds a `source` line for the nickname file to your Bash startup file. By default it uses the historical `~/.config/niri/command/bashrc` if that file exists; otherwise it uses `~/.bashrc`. It adds the line only once. Set `SDT_BASH_STARTUP_FILE` before running `addnick` if your Bash session uses a different startup file. Open a new Bash session after creating a nickname. The generated functions use `sdt-launch`, which must be available on your `PATH`.

## Application discovery

Search Dat Term checks these locations:

- `$XDG_DATA_HOME/applications` (defaults to `~/.local/share/applications`)
- Each `applications` directory under `$XDG_DATA_DIRS` (defaults to `/usr/local/share:/usr/share`)
- `~/.local/share/flatpak/exports/share/applications`
- `/var/lib/flatpak/exports/share/applications`
- `/var/lib/snapd/desktop/applications`
- Any additional directories listed in `SDT_EXTRA_APPLICATION_DIRS`

Desktop entries marked `NoDisplay=true` or `Hidden=true`, and entries whose type is not `Application`, are skipped.

### If an application does not appear

Not every application installs its desktop-entry file in the same place. Some applications are installed as portable AppImages, unpacked manually, installed by a third-party package manager, or configured to store their launcher files in a custom directory. **If an application's `.desktop` file is outside the directories above, SDT will not find it automatically.** SDT searches for desktop-entry files; it does not scan every executable on the computer.

Use these steps to check and fix discovery:

1. **Check whether the application has a desktop-entry file.** Search likely locations for its `.desktop` file. For example:

   ```bash
   find "$HOME" /opt /usr/local/share -type f -name '*.desktop' 2>/dev/null
   ```

   If you know the application's name, narrow the search, for example:

   ```bash
   find "$HOME" /opt /usr/local/share -type f -iname '*firefox*.desktop' 2>/dev/null
   ```

2. **Check SDT's standard search paths.** Run:

   ```bash
   source "${XDG_DATA_HOME:-$HOME/.local/share}/search-dat-term/search-dat-term.sh"
   sdt_application_dirs
   ```

   Confirm that the directory containing the missing `.desktop` file is listed. To see how many desktop files SDT discovers:

   ```bash
   sdt_find_desktop_files | tr -cd '\\0' | wc -c
   ```

3. **Add the directory that actually contains the `.desktop` file.** Set `SDT_EXTRA_APPLICATION_DIRS` to one or more directories, separated by colons. For example, if your custom launchers are in `~/Applications/share/applications` and `/opt/my-apps/share/applications`:

   ```bash
   export SDT_EXTRA_APPLICATION_DIRS="$HOME/Applications/share/applications:/opt/my-apps/share/applications"
   ```

   These must be the directories containing the `.desktop` files, not merely the folders containing application binaries. The setting is read when SDT runs.

4. **Make the setting persistent.** Add your own `export SDT_EXTRA_APPLICATION_DIRS=...` line to your Bash startup file (commonly `~/.bashrc`). Open a new terminal or source that file, then run `sdt_application_dirs` again to confirm the custom paths appear.

5. **Check the desktop entry itself.** The file should be a valid `.desktop` entry with `Type=Application` and a working `Exec=` command. Check that it does not contain `Hidden=true` or `NoDisplay=true`, because SDT intentionally skips those entries. You can inspect it with:

   ```bash
   grep -E '^(Type|Name|Exec|Hidden|NoDisplay)=' /path/to/app.desktop
   ```

6. **Run the search again.** Start `terminal-app-search` after setting the extra path. If the entry is discovered but does not launch, check that an available launcher (`gtk-launch`, `gio`, or `dex`) is installed and that the desktop entry's `Exec=` command is valid.

If the application has no `.desktop` file at all, SDT has no desktop entry to discover. Create a valid launcher file for that application in one of the searched directories (or in a directory listed in `SDT_EXTRA_APPLICATION_DIRS`), then search again.

## Desktop environment

The application search and nickname tools are terminal-based and do not require Hyprland, Niri, Kitty, or a particular terminal emulator. They need to be run inside a graphical desktop session so that launched applications can open.

## Testing status

The portability branch has been tested for application discovery and launching on Void Linux. This does not mean every distribution, package format, or desktop environment has been tested. Please report your distribution, desktop environment, launcher command available on your system, and any error output when reporting a problem.

## Original version

The original Arch-based scripts and README are preserved on the `main` branch. The portability branch is intentionally separate until the changes have been reviewed and tested.

## Contributing

Bug reports and suggestions are welcome. Please include your distribution, desktop environment, and the output of any relevant error messages.
