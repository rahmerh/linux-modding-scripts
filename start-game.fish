#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"
source "$script_dir/lib/games.fish"

if test (count $argv) -ne 1
    err "Usage: start-game.fish <game-name>"
    exit 1
end

set game $argv[1]
set game (resolve_game "$game"; or begin
    err "Unknown game: $game"
    exit 1
end)

set root "$PWD/$game"

set mods_dir "$root/mods"
set upper_dir "$root/merged"
set work_dir "$root/work"
set run_dir "$root/run"

# ---- GAME CONFIG ----
set install_dir
set compatdata_dir
set game_executable

switch $game
    case "Cyberpunk 2077"
        set install_dir "$HOME/.steam/steam/steamapps/common/Cyberpunk 2077"
        set compatdata_dir "$HOME/.steam/steam/steamapps/compatdata/1091500"
        set game_executable "$run_dir/bin/x64/Cyberpunk2077.exe"
    case '*'
        err "Unknown game: $game"
        exit 1
end
# ---------------------

for d in $mods_dir $install_dir
    if not test -d $d
        err "Missing directory: $d"
        exit 1
    end
end

function __cleanup --on-event fish_exit
    if not command -q mountpoint
        return
    end

    if not mountpoint -q "$run_dir"
        return
    end

    set max_retries 10
    set delay 1

    for attempt in (seq 1 $max_retries)
        if sudo umount "$run_dir" 2>/dev/null
            ok "Cleanup complete"
            return
        end

        step "Unmounting... (Attempt $attempt/$max_retries)"
        sleep $delay
    end

    warn "Failed to unmount after retries: $run_dir"
    echo "  You may need to close lingering processes or unmount manually:"
    echo "  sudo umount $run_dir"
end

if command -q mountpoint; and mountpoint -q "$run_dir"
    sudo umount "$run_dir"
end

hdr "Preparing $run_dir"
sudo rm -rf "$work_dir" "$run_dir"
mkdir -p "$work_dir" "$run_dir"

sudo mount -t overlay overlay \
    -o "lowerdir=$install_dir,upperdir=$upper_dir,workdir=$work_dir" \
    "$run_dir"

hdr "Starting $game, have fun!"

cd "$run_dir"
env \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam" \
    STEAM_COMPAT_DATA_PATH="$compatdata_dir" \
    WINEDLLOVERRIDES="winmm,version=n,b" \
    "$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton" \
    waitforexitandrun "$game_executable" >/dev/null 2>&1
