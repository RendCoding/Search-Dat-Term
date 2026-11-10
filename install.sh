#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SDT_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/search-dat-term"

for file in terminal-app-search addnick sdt-launch; do
    if [[ ! -f "$SCRIPT_DIR/bin/$file" ]]; then
        echo "Missing file: $SCRIPT_DIR/bin/$file" >&2
        exit 1
    fi
done

if [[ ! -f "$SCRIPT_DIR/lib/search-dat-term.sh" ]]; then
    echo "Missing shared library: $SCRIPT_DIR/lib/search-dat-term.sh" >&2
    exit 1
fi

mkdir -p "$BIN_DIR" "$DATA_DIR"
cp "$SCRIPT_DIR/bin/terminal-app-search" "$BIN_DIR/"
cp "$SCRIPT_DIR/bin/addnick" "$BIN_DIR/"
cp "$SCRIPT_DIR/bin/sdt-launch" "$BIN_DIR/"
cp "$SCRIPT_DIR/lib/search-dat-term.sh" "$DATA_DIR/search-dat-term.sh"
chmod 755 "$BIN_DIR/terminal-app-search" "$BIN_DIR/addnick" "$BIN_DIR/sdt-launch"

printf 'Installed Search Dat Term commands to: %s\n' "$BIN_DIR"
printf 'Installed shared library to: %s\n' "$DATA_DIR/search-dat-term.sh"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        printf 'Note: add %s to your PATH to run the commands by name.\n' "$BIN_DIR"
        ;;
esac
