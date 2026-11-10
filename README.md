# Search Dat Term

A terminal-based application launcher and app-nickname tool for Linux.

Search Dat Term lets you find installed desktop applications from a terminal using [fzf](https://github.com/junegunn/fzf), launch them, and create short shell commands (nicknames) for applications you use often.

## Features

- **Terminal app search** — interactively search desktop applications with fzf.
- **Launch applications** — launch the selected desktop entry using an available desktop launcher.
- **Create app nicknames** — use `addnick` to create a short Bash function for an installed application.
- **Automatic nickname loading** — `addnick` adds the nickname file to your Bash startup file automatically.
- **XDG application discovery** — checks user and system application directories.
- **Flatpak and Snap discovery** — checks common export directories.
- **Custom discovery paths** — add directories containing desktop-entry files with `SDT_EXTRA_APPLICATION_DIRS`.

## Requirements

- Linux with a graphical desktop session.
- Bash 4 or newer.
- [fzf](https://github.com/junegunn/fzf).
- Standard command-line utilities: `find`, `awk`, `grep`, `sort`, `sed`, and `tr`.
- At least one desktop-entry launcher:
  - `gtk-launch`
  - `gio` with its `launch` subcommand
  - `dex` (optional alternative)

Package names vary by distribution. Install `fzf` and at least one supported launcher using your distribution's package manager.

## Install

Clone the repository and run:

```bash
git clone https://github.com/RendCoding/Search-Dat-Term.git
cd Search-Dat-Term
bash install.sh
```

The installer places commands in `~/.local/bin` and the shared helper library under `$XDG_DATA_HOME/search-dat-term` (or `~/.local/share/search-dat-term` when `XDG_DATA_HOME` is unset).

Make sure `~/.local/bin` is in your `PATH`. You can override the command installation directory by setting `SDT_BIN_DIR` before running the installer.

| Command | Purpose |
| --- | --- |
| `terminal-app-search` | Opens an fzf list of discovered desktop applications and launches the selected app. |
| `addnick` | Prompts for an application nickname, saves it, and enables automatic Bash loading. |
| `sdt-launch` | Launches a desktop entry by its desktop-file ID. |

## Nicknames

Run:

```bash
addnick
```

Choose an application and enter a nickname containing letters, numbers, underscores, or hyphens (starting with a letter). SDT saves the function to:

```text
${XDG_CONFIG_HOME:-~/.config}/search-dat-term/nicknames.sh
```

If the historical `~/.config/niri/command/nicknames.sh` file already exists, SDT reuses it to avoid breaking an existing setup. Override the nickname file with `SDT_NICKNAMES_FILE`.

**Automatic startup setup:** after saving a nickname, `addnick` adds a source line to your Bash startup file. By default it uses the historical `~/.config/niri/command/bashrc` if that file exists; otherwise it uses `~/.bashrc`. The line is added only once. If your terminal starts Bash with a different custom rcfile, set `SDT_BASH_STARTUP_FILE` to that file before running `addnick`.

For example:

```bash
export SDT_BASH_STARTUP_FILE="$HOME/.config/my-shell/bashrc"
addnick
```

Open a new Bash session after creating the nickname. You can then run the nickname directly, for example `fox`. Generated functions use `sdt-launch`, which must be available on your `PATH`.

## Application discovery

Search Dat Term checks:

- `$XDG_DATA_HOME/applications` (defaults to `~/.local/share/applications`)
- Each `applications` directory under `$XDG_DATA_DIRS` (defaults to `/usr/local/share:/usr/share`)
- `~/.local/share/flatpak/exports/share/applications`
- `/var/lib/flatpak/exports/share/applications`
- `/var/lib/snapd/desktop/applications`
- Any additional directories listed in `SDT_EXTRA_APPLICATION_DIRS`

Desktop entries marked `NoDisplay=true` or `Hidden=true`, and entries whose type is not `Application`, are skipped.

### If an application does not appear

Not every application installs its desktop-entry file in the same place. Some applications are installed as portable AppImages, unpacked manually, installed by a third-party package manager, or configured to store launcher files in a custom directory. **If an application's `.desktop` file is outside the directories above, SDT will not find it automatically.** SDT searches for desktop-entry files; it does not scan every executable on the computer.

1. **Find the application's desktop file.** Search likely locations:

   ```bash
   find "$HOME" /opt /usr/local/share -type f -name '*.desktop' 2>/dev/null
   ```

   Narrow the search by application name if needed:

   ```bash
   find "$HOME" /opt /usr/local/share -type f -iname '*firefox*.desktop' 2>/dev/null
   ```

2. **Check SDT's search paths.** Run:

   ```bash
   source "${XDG_DATA_HOME:-$HOME/.local/share}/search-dat-term/search-dat-term.sh"
   sdt_application_dirs
   ```

   To count the desktop files discovered:

   ```bash
   sdt_find_desktop_files | tr -cd '\\0' | wc -c
   ```

3. **Add the directory containing the desktop file.** Use a colon-separated list:

   ```bash
   export SDT_EXTRA_APPLICATION_DIRS="$HOME/Applications/share/applications:/opt/my-apps/share/applications"
   ```

   These must be the directories containing the `.desktop` files, not merely the directories containing application binaries. The setting is read when SDT runs.

4. **Make the setting persistent.** Add the export line to your Bash startup file (commonly `~/.bashrc`), open a new terminal, and check `sdt_application_dirs` again.

5. **Check the desktop entry.** It should be a valid `.desktop` file with `Type=Application` and a working `Exec=` command. SDT intentionally skips entries with `Hidden=true` or `NoDisplay=true`. Inspect the relevant fields:

   ```bash
   grep -E '^(Type|Name|Exec|Hidden|NoDisplay)=' /path/to/app.desktop
   ```

6. **Try the search again.** Run `terminal-app-search`. If the app appears but will not launch, check that `gtk-launch`, `gio`, or `dex` is installed and that the `Exec=` command is valid.

If the application has no `.desktop` file, SDT has no desktop entry to discover. Create a valid launcher file in a searched directory or in a directory listed in `SDT_EXTRA_APPLICATION_DIRS`.

## Desktop environment

The tools are terminal-based and do not require Hyprland, Niri, Kitty, or a particular terminal emulator. They must be run inside a graphical desktop session so launched applications can open.

The historical `~/.config/niri/command/` paths are retained when existing files are detected. They are legacy file locations, not a requirement to use Niri. The original Arch workflow remains supported through the GTK launcher and legacy nickname/config paths.

## Testing status

Application discovery and launching have been tested on Void Linux. Nickname creation and manual nickname loading have also been tested there; the automatic startup integration is newly added and should be verified after updating. This does not mean every distribution, package format, or desktop environment has been tested.

Please include your distribution, desktop environment, available launcher command, and any error output when reporting a problem.

## Contributing

Bug reports and suggestions are welcome. Include your distribution, desktop environment, and relevant error messages.
