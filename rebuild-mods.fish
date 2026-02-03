#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"
source "$script_dir/lib/tools.fish"
source "$script_dir/lib/games.fish"

if test (count $argv) -ne 1
    err "Usage: rebuild-mods.fish <game-name>"
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

if not test -d "$root"
    err "Game directory not found: $root"
    exit 1
end

if not test -d "$mods_dir"
    err "Mods directory not found: $mods_dir"
    exit 1
end

if not test -d "$upper_dir"
    err "Merged directory not found: $upper_dir"
    exit 1
end

# ---- GAME CONFIG ----
switch $game
    case "Cyberpunk 2077"
        # nothing yet
    case '*'
        err "Unknown game: $game"
        exit 1
end
# ---------------------

hdr "Rebuilding mods"

if test -z "$upper_dir" -o "$upper_dir" = / -o "$upper_dir" = "$HOME"
    err "Refusing to wipe unsafe merged dir: '$upper_dir'"
    exit 1
end

rm -rf -- "$upper_dir"/*

set merged 0
for mod in (ls -1 "$mods_dir" | sort)
    set src "$mods_dir/$mod"
    if not test -d "$src"
        continue
    end

    step "Merging $mod"

    for file in (find "$src" -type f)
        set rel (string replace -r "^"(string escape --style=regex "$src")"/" "" -- "$file")
        set dst "$upper_dir/$rel"
        set dst_dir (path dirname "$dst")

        mkdir -p "$dst_dir"
        cp -f "$file" "$dst"
        set merged (math $merged + 1)
    end
end

set seen_files
set owners

set overwrite_pairs
set files

for mod in (ls -1 "$mods_dir" | sort)
    set src "$mods_dir/$mod"

    for file in (find "$src" -type f 2>/dev/null)
        set rel (string replace -r "^"(string escape --style=regex "$src")"/" "" -- "$file")

        set idx (contains --index -- "$rel" $seen_files)
        set -q idx[1]; or set idx 0

        if test $idx -gt 0
            set victim $owners[$idx]
            set overwrite_pairs $overwrite_pairs "$mod|$victim"
            set files $files "$rel"
        else
            set seen_files $seen_files "$rel"
            set owners $owners "$mod"
        end
    end
end

if test (count $overwrite_pairs) -gt 0
    warn "Overwrite conflicts:"

    set unique_pairs
    for e in $overwrite_pairs
        if not contains -- "$e" $unique_pairs
            set unique_pairs $unique_pairs "$e"
        end
    end

    for pair in $unique_pairs
        set over (string split -m1 '|' -- $pair)[1]
        set victim (string split -m1 '|' -- $pair)[2]

        warn "$over -> $victim"

        for i in (seq (count $overwrite_pairs))
            if test "$overwrite_pairs[$i]" = "$pair"
                warn "  - $files[$i]"
            end
        end
    end
end

ok "Rebuild complete — $merged files merged"
