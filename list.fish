#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"

if test (count $argv) -ne 1
    err "Usage: list.fish <game-name>"
    exit 1
end

set game $argv[1]
set root "$PWD/$game"
set mods_dir "$root/mods"

if not test -d "$root"
    err "Game directory not found: $root"
    exit 1
end

if not test -d "$mods_dir"
    err "Mods directory not found: $mods_dir"
    exit 1
end

hdr "Installed mods for $game"

set found 0

for d in (ls -d $mods_dir/* 2>/dev/null)
    if test -d "$d"
        set found 1
        set base (basename "$d")

        if string match -rq '^([0-9]{3})_' "$base"
            set idx (string sub -s 1 -l 3 "$base")
            set name (string sub -s 5 "$base")
            step "[$idx] $name"
        else
            step "[???] $base"
        end
    end
end

if test $found -eq 0
    warn "No mods installed"
end
