#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"

if test (count $argv) -ne 1
    err "Usage: bootstrap.fish <game-name>"
    exit 1
end

set game $argv[1]

if not command -q protontricks
    err "protontricks is not installed"
    exit 1
end

if not command -q gum
    err "gum is not installed"
    exit 1
end

switch $game
    case "Cyberpunk 2077"
        hdr "Bootstrapping $game..."

        gum spin --title "Installing Visual C++ runtime (vcrun2022)" -- protontricks 1091500 vcrun2022
    case '*'
        err "No bootstrap available for $game"
        exit 1
end

ok "Bootstrap complete"
