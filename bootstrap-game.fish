#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"
source "$script_dir/lib/tools.fish"
source "$script_dir/lib/games.fish"

if test (count $argv) -ne 1
    err "Usage: bootstrap.fish <game-name>"
    exit 1
end

set game $argv[1]
set game (resolve_game "$game"; or begin
    err "Unknown game: $game"
    exit 1
end)

require_tool protontricks; or exit 1
require_tool gum; or exit 1

switch $game
    case "Cyberpunk 2077"
        hdr "Bootstrapping $game..."

        gum spin --title "Installing Visual C++ runtime (vcrun2022)" -- protontricks 1091500 vcrun2022
    case '*'
        err "No bootstrap available for $game"
        exit 1
end

ok "Bootstrap complete"
