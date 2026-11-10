# Bash rcfile used only by the Search Dat Term Kitty popup.
export PATH="$HOME/.local/bin:$PATH"

# Load existing SDT nicknames when available.
_nick_file="${SDT_NICKNAMES_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/search-dat-term/nicknames.sh}"
if [[ -f "$HOME/.config/niri/command/nicknames.sh" && -z "${SDT_NICKNAMES_FILE:-}" ]]; then
    _nick_file="$HOME/.config/niri/command/nicknames.sh"
fi
[[ -f "$_nick_file" ]] && source "$_nick_file"
unset _nick_file

clear
if command -v fastfetch >/dev/null 2>&1; then
    # Fastfetch detects the current distro and chooses its compact logo.
    fastfetch --config none --logo-type small --structure os:kernel:uptime:shell
else
    printf '%s\n' 'Tip: install fastfetch to show your distro logo and system summary.'
fi

printf '\nType search to find and launch an application.\n'
search() {
    terminal-app-search
}
PS1='\[\e[1;36m\]sdt\[\e[0m\] > '
