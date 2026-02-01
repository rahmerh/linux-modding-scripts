#!/usr/bin/env fish

set script_dir (path dirname (status --current-filename))
source "$script_dir/lib/log.fish"

# ---- flags ----
set keep_archive 0
if contains -- --keep-archive $argv
    set keep_archive 1
    set argv (string match -v -- '--keep-archive' $argv)
end
# --------------

if test (count $argv) -ne 2
    err "Usage: install-mod.fish <game-name> <archive-path>"
    exit 1
end

set game $argv[1]
set archive (realpath $argv[2])

if not test -f "$archive"
    err "Archive not found: $archive"
    exit 1
end

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

# ---- GAME CONFIG ----
switch $game
    case "Cyberpunk 2077"
        # Empty until required later
    case '*'
        err "Unknown game: $game"
        exit 1
end
# ---------------------

function derive_default_mod_name --argument-names archive_path
    set base (basename "$archive_path")
    set name (string replace -r '\.(zip|7z|rar)$' '' -- "$base")

    set name (string replace -a '–' '-' -- "$name")
    set name (string replace -a '—' '-' -- "$name")

    set left (string split -m1 ' - ' -- "$name")[1]
    if test -n "$left"
        set name "$left"
    end

    set m (string match -rg '^(.*?)-[0-9].*$' -- "$name")
    if test (count $m) -gt 0
        set name "$m[1]"
    end

    set name (string replace -r '\s*[0-9]+(\.[0-9]+)+\s*' ' ' -- "$name")

    set name (string trim -- "$name")
    set name (string replace -ar '\s+' ' ' -- "$name")

    set name (string replace -ar '[^A-Za-z0-9]+' '' -- "$name")

    echo "$name"
end

hdr "Installing mod: $archive"

set default_name (derive_default_mod_name "$archive")

set mod_name (gum input \
    --prompt "Install folder name: " \
    --value "$default_name")

if test -z "$mod_name"
    warn "Aborted: no folder name provided"
    exit 1
end

set mod_name (string replace -r '[\\/]' '_' "$mod_name")

if not string match -rq '^[0-9]{3}_' "$mod_name"
    set existing_dir ""
    for d in $mods_dir/*
        if test -d $d
            set base (basename $d)
            if string match -rq '^[0-9]{3}_' $base
                set suffix (string sub -s 5 $base)
                if test "$suffix" = "$mod_name"
                    set existing_dir $d
                    break
                end
            end
        end
    end

    if test -n "$existing_dir"
        set mod_name (basename "$existing_dir")
    else
        set max_index 0
        for d in $mods_dir/*
            if test -d $d
                set base (basename $d)
                if string match -rq '^[0-9]{3}_' $base
                    set num (string sub -s 1 -l 3 $base)
                    if test $num -gt $max_index
                        set max_index $num
                    end
                end
            end
        end

        set next_index (math $max_index + 1)
        set prefix (printf "%03d" $next_index)
        set mod_name "$prefix"_"$mod_name"
    end
end

set target_dir "$mods_dir/$mod_name"

if test -e "$target_dir"
    if gum confirm "Overwrite?"
        step "Removing existing folder"
        rm -rf "$target_dir"
    else
        err "Target mod directory already exists: $target_dir"
        exit 1
    end
end

mkdir -p "$target_dir"

step "Extracting: $archive"
step "Destination: $target_dir"

switch (string lower "$archive")
    case '*.zip'
        unzip -q "$archive" -d "$target_dir"
    case '*.7z'
        7z x "$archive" -o"$target_dir" >/dev/null
    case '*.rar'
        unrar x "$archive" "$target_dir" >/dev/null
    case '*'
        err "Unsupported archive format: $archive"
        rm -rf "$target_dir"
        exit 1
end

ok "Installation complete"

if test $keep_archive -eq 0
    step "Removing archive"
    rm -f "$archive"
    ok "Archive deleted"
end
