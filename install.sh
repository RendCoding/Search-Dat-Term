#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SDT_BIN_DIR:-$HOME/.local/bin}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$DATA_HOME/search-dat-term"
APPLICATIONS_DIR="$DATA_HOME/applications"
POPUP_DESKTOP_FILE="$APPLICATIONS_DIR/search-dat-term-popup.desktop"

for file in terminal-app-search addnick sdt-launch sdt-popup; do
    if [[ ! -f "$SCRIPT_DIR/bin/$file" ]]; then
        echo "Missing file: $SCRIPT_DIR/bin/$file" >&2
        exit 1
    fi
done

if [[ ! -f "$SCRIPT_DIR/lib/search-dat-term.sh" ]]; then
    echo "Missing shared library: $SCRIPT_DIR/lib/search-dat-term.sh" >&2
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/share/sdt-popup.bashrc" ]]; then
    echo "Missing popup shell config: $SCRIPT_DIR/share/sdt-popup.bashrc" >&2
    exit 1
fi

mkdir -p "$BIN_DIR" "$DATA_DIR" "$APPLICATIONS_DIR"
cp "$SCRIPT_DIR/bin/terminal-app-search" "$BIN_DIR/"
cp "$SCRIPT_DIR/bin/addnick" "$BIN_DIR/"
cp "$SCRIPT_DIR/bin/sdt-launch" "$BIN_DIR/"
cp "$SCRIPT_DIR/bin/sdt-popup" "$BIN_DIR/"
cp "$SCRIPT_DIR/lib/search-dat-term.sh" "$DATA_DIR/search-dat-term.sh"
cp "$SCRIPT_DIR/share/sdt-popup.bashrc" "$DATA_DIR/sdt-popup.bashrc"
chmod 755 "$BIN_DIR/terminal-app-search" "$BIN_DIR/addnick" "$BIN_DIR/sdt-launch" "$BIN_DIR/sdt-popup"

# Generate a desktop entry with the actual installed path. This lets desktop
# environments launch the popup even when their shortcut PATH omits ~/.local/bin.
desktop_exec="$BIN_DIR/sdt-popup"
desktop_exec="${desktop_exec//\\/\\\\}"
desktop_exec="${desktop_exec// /\\ }"
cat > "$POPUP_DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Search Dat Term Popup
Comment=Open the compact Search Dat Term terminal
Exec=$desktop_exec
Terminal=false
Categories=Utility;
EOF

printf 'Installed Search Dat Term commands to: %s\n' "$BIN_DIR"
printf 'Installed shared library to: %s\n' "$DATA_DIR/search-dat-term.sh"
printf 'Installed popup shell config to: %s\n' "$DATA_DIR/sdt-popup.bashrc"
printf 'Installed popup desktop launcher to: %s\n' "$POPUP_DESKTOP_FILE"
printf '%s\n' 'For KDE shortcuts, use: gtk-launch search-dat-term-popup'

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        printf 'Note: add %s to your PATH to run the commands by name.\n' "$BIN_DIR"
        ;;
esac
