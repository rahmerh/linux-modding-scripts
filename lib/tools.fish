set lib_dir (path dirname (status --current-filename))
source "$lib_dir/log.fish"

function require_tool --description "Fail if a tool is not installed"
    set -l tool $argv[1]

    if test -z "$tool"
        err "require_tool: missing tool name"
        return 2
    end

    if not type -q $tool
        err "Required tool '$tool' is not installed or not in PATH"
        return 1
    end
end
