#!/usr/bin/env bash
# Shared helpers for Search Dat Term.

sdt_application_dirs() {
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local data_dirs="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    local base

    printf '%s\n' "$data_home/applications"

    while IFS= read -r base; do
        [[ -n "$base" ]] && printf '%s\n' "$base/applications"
    done < <(printf '%s' "$data_dirs" | tr ':' '\n')

    # Flatpak exports are not always included in XDG_DATA_DIRS.
    printf '%s\n' \
        "$HOME/.local/share/flatpak/exports/share/applications" \
        "/var/lib/flatpak/exports/share/applications"
}

sdt_find_desktop_files() {
    local dirs=()
    local dir

    while IFS= read -r dir; do
        [[ -d "$dir" ]] && dirs+=("$dir")
    done < <(sdt_application_dirs)

    (("${#dirs[@]}" > 0)) || return 0
    find "${dirs[@]}" -type f -name '*.desktop' -print0 2>/dev/null
}

sdt_find_desktop_id() {
    local wanted="$1"
    local file

    while IFS= read -r -d '' file; do
        if [[ "${file##*/}" == "$wanted.desktop" ]]; then
            printf '%s\n' "$file"
            return 0
        fi
    done < <(sdt_find_desktop_files)

    return 1
}

sdt_launch_desktop_id() {
    local id="$1"
    local desktop_file

    if ! desktop_file=$(sdt_find_desktop_id "$id"); then
        printf 'Search Dat Term: desktop entry not found: %s\n' "$id" >&2
        return 1
    fi

    # Prefer the original launcher where available; gio can launch a desktop
    # file by path and also handles entries outside gtk-launch's search path.
    if command -v gtk-launch >/dev/null 2>&1 && gtk-launch "$id"; then
        return 0
    fi

    if command -v gio >/dev/null 2>&1; then
        gio launch "$desktop_file"
        return
    fi

    if command -v dex >/dev/null 2>&1; then
        dex "$desktop_file"
        return
    fi

    printf '%s\n' 'Search Dat Term: install gtk-launch, gio (GLib), or dex to launch desktop applications.' >&2
    return 1
}

sdt_nicknames_file() {
    local legacy="$HOME/.config/niri/command/nicknames.sh"
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

    if [[ -n "${SDT_NICKNAMES_FILE:-}" ]]; then
        printf '%s\n' "$SDT_NICKNAMES_FILE"
    elif [[ -f "$legacy" ]]; then
        # Preserve the author's existing setup without requiring Niri.
        printf '%s\n' "$legacy"
    else
        printf '%s\n' "$config_home/search-dat-term/nicknames.sh"
    fi
}
