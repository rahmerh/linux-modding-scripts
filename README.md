# Linux modding scripts

A small set of scripts to make modding games on Linux easier while keeping the base game installation clean.

The core idea is:
- Mods are installed into separate folders
- All mods are merged into a single `merged/` directory
- The game is launched through an **overlayfs mount** that overlays `merged/` on top of the original game directory
- The base game install is never modified

These scripts are intentionally **folder-based** and avoid hidden state. This does result in some some manual setup in certain situations.

## How it works

Before launch:
1. All mod folders in `<game>/mods/` are merged into `<game>/merged/`
2. An overlayfs mount is created combining:
   - `lowerdir` → the game install directory
   - `upperdir` → the merged mods directory
3. The overlay is mounted at `<game>/run/`

The game is then launched from the overlay mount and, once the game exits, the mount is cleaned up.

Merging the mods is done in alphabetical order of the mods folders. The install script automatically prefixes a 3 digit number to the folder name. You're free to reorder this load order by changing this manually.

## Folder layout

Each game lives in its own folder:

```
./Cyberpunk 2077/
  mods/
    001_FirstMod/
    002_SecondMod/
  merged/
  work/
  run/
```
This folder structure will be created automatically when running the scripts. The `<game-name>` argument passed to scripts must match the folder name exactly. (Ex: `./start-game.fish "Cyberpunk 2077"`)

## Prerequisites

- [Fish](https://fishshell.com/)
- [Gum](https://github.com/charmbracelet/gum)
- [Steam](https://store.steampowered.com/)

## Usage

`install-mod.fish <game-name> <archive-path>`

Install mod from the downloaded archive into the game's mods folder. Add `--keep-archive` to prevent the archive from being deleted on completion.

`start-game.fish <game-name>`

Starts the game from the `run` dir with all mods overlayed. Will start an overlayfs mount before starting and will unmount after the game exits.

## Supported games

- Cyberpunk 2077

## Roadmap

- [ ] Validate extracted archive folder structure
- [ ] Configurable proton version
- [ ] General configuration (game or install paths)
- [ ] Nexus mods integration (Downloading games using their API)
