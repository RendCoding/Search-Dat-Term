# Search Dat Term

A terminal-based application launcher and app-nickname tool for Linux.

Search Dat Term lets you find installed desktop applications from a terminal using [fzf](https://github.com/junegunn/fzf), launch them, and create short shell commands (nicknames) for applications you use often.

## Features

- **Terminal app search** — interactively search installed desktop applications with fzf.
- **Launch applications** — launch the selected desktop entry using an available desktop launcher.
- **Create app nicknames** — use `addnick` to create a short shell command for an installed application.
- **Automatic nickname loading** — `addnick` adds the nickname file to your Bash startup file automatically.
- **Compact Kitty popup** — optional small terminal with a distro-aware compact Fastfetch summary and logo.
- **Desktop integration** — supplied Hyprland rules and an installed desktop launcher for KDE Plasma shortcuts.
- **XDG application discovery** — checks user and system application directories, including common Flatpak and Snap exports.

## Requirements

- Linux with a graphical desktop session.
- Bash 4 or newer.
- [fzf](https://github.com/junegunn/fzf).
- Standard command-line utilities: `find`, `awk`, `grep`, `sort`, `sed`, and `tr`.
- At least one desktop-entry launcher: `gtk-launch`, `gio launch`, or optionally `dex`.
- For the optional popup: Kitty. Fastfetch is optional.

Package names vary by distribution. Install `fzf`, a supported desktop launcher, and (if using the popup) Kitty with your distribution's package manager.

## Install

```bash
git clone https://github.com/RendCoding/Search-Dat-Term.git
cd Search-Dat-Term
bash install.sh
```

The installer places commands in `~/.local/bin`, the shared helper library and popup shell config under `$XDG_DATA_HOME/search-dat-term` (or `~/.local/share/search-dat-term`), and a desktop launcher at `$XDG_DATA_HOME/applications/search-dat-term-popup.desktop`. The desktop launcher contains the actual installed path to `sdt-popup`, so KDE and other desktop shortcut tools do not have to find it through their own PATH.

Make sure `~/.local/bin` is in your shell's PATH. You can override the command installation directory by setting `SDT_BIN_DIR` before running the installer.

| Command | Purpose |
| --- | --- |
| `terminal-app-search` | Opens an fzf list of discovered desktop applications and launches the selected app. |
| `addnick` | Prompts for an application nickname, saves it, and enables automatic Bash loading. |
| `sdt-launch` | Launches a desktop entry by its desktop-file ID. |
| `sdt-popup` | Opens the compact Kitty search terminal. |

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

Open a new Bash session after creating the nickname. You can then run the nickname directly, for example `fox`. Generated functions use `sdt-launch`, which must be available on your PATH.

## Compact Kitty popup

The optional popup opens a dedicated Kitty window with a compact Fastfetch summary, the small logo Fastfetch detects for the current distribution, and a `search` shell function that starts the SDT application picker.

- Default popup size: **760 × 420 pixels**.
- Kitty window class: **`sdt-popup`** (use this to target only the popup in window rules).
- Fastfetch uses `--logo-type small`; it does not hard-code the Arch logo.
- Fastfetch is optional. The popup still opens without it.

Launch it directly with:

```bash
sdt-popup
```

### Hyprland

A ready-made Hyprland snippet is included at `config/hyprland/sdt-popup.conf`. Copy and source it:

```bash
mkdir -p ~/.config/hypr
cp config/hyprland/sdt-popup.conf ~/.config/hypr/sdt-popup.conf
```

Add this line to your main Hyprland config:

```ini
source = ~/.config/hypr/sdt-popup.conf
```

The snippet binds `SUPER + R`, floats and centers only the `sdt-popup` window, and sets it to 760 × 420. Reload Hyprland after adding it. If that key is already in use, change the `bind` line to another key.

### KDE Plasma 6 (KWin)

The installer creates a desktop launcher named **Search Dat Term Popup**. This is useful because KDE shortcut commands may not inherit the interactive shell's PATH.

1. Open **System Settings → Keyboard → Shortcuts**.
2. Add a **Command or Script** shortcut.
3. Set its command to:

   ```bash
   gtk-launch search-dat-term-popup
   ```

4. Assign the desired key combination (for example, **Meta + R**) and apply it.

To make the popup small and centered:

1. Open **System Settings → Window Management → Window Rules** and add a rule.
2. Use **Detect Window Properties** and select the popup. Confirm its window class is `sdt-popup`.
3. In the rule editor, use **Add Property** to add **Size** and **Initial placement**.
4. Set Size to **Apply Initially**, width **760**, height **420**. Set Initial placement to **Centered**.
5. Save the rule and apply the changes.

The rule should match the `sdt-popup` class so it does not resize ordinary Kitty windows. KDE labels and layout can vary slightly between Plasma releases.

### Other desktop environments and window managers

The popup command itself is desktop-environment independent. The keybinding and window placement rules are not: GNOME, Xfce, Cinnamon, i3, Sway, Niri, and other compositors/window managers each expose different shortcut and per-window-rule settings.

For another environment:

- Bind its custom keyboard shortcut to the installed `sdt-popup` command. If the desktop cannot find it by name, use the full path (normally `$HOME/.local/bin/sdt-popup`) or launch the installed desktop entry using that environment's application launcher.
- Match the Kitty window by class **`sdt-popup`**.
- If supported, configure it as floating, centered, and initially **760 × 420**.
- Change the key combination in that environment's shortcut settings; the Hyprland snippet only applies to Hyprland.

Not every desktop environment supports per-window size and placement rules. In those cases, the popup will still launch, but its size and position may need to be adjusted through that environment's own tools or Kitty settings.

### Changing the popup size

- **Hyprland:** edit the `size 760 420` rule in `config/hyprland/sdt-popup.conf`.
- **KDE Plasma:** edit the Size property in the KWin rule for `sdt-popup`.
- **Other environments:** edit the matching per-window rule, if that environment supports one.

The default values are a starting point; adjust them to suit your display.

### Future desktop integration

Automatic detection and configuration of the active desktop environment/window manager — including choosing a suitable default popup size and keybinding — is a planned future improvement. For now, SDT deliberately provides manual, environment-specific setup instructions rather than guessing at or overwriting a user's desktop shortcuts and window rules.

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

The core tools are terminal-based and do not require Hyprland, Niri, Kitty, or a particular terminal emulator. They must be run inside a graphical desktop session so launched applications can open. The optional popup uses Kitty; window sizing and keyboard shortcuts are configured separately for each desktop environment/window manager, as described above.

The historical `~/.config/niri/command/` paths are retained when existing files are detected. They are legacy file locations, not a requirement to use Niri. The original Arch workflow remains supported through the GTK launcher and legacy nickname/config paths.

## Testing status

Application discovery and launching have been tested on Void Linux. Nickname creation and manual nickname loading have also been tested there. The compact Kitty popup, distro-specific Fastfetch display, and automatic nickname startup have been added; popup behavior and desktop integration should be verified on each supported desktop environment. KDE Plasma 6.7.5 setup has been user-tested for the popup launcher, keybinding, size, and centered placement. This does not mean every distribution, package format, or desktop environment has been tested.

Please include your distribution, desktop environment, available launcher command, and any error output when reporting a problem.

## Contributing

Bug reports and suggestions are welcome. Include your distribution, desktop environment, and relevant error messages.
