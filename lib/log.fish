set -g C_HDR (set_color 00ffff)
set -g C_STEP (set_color 008b8b)
set -g C_OK (set_color 00ff00)
set -g C_WARN (set_color ffff00)
set -g C_ERR (set_color ff5555)
set -g C_RST (set_color normal)

function hdr
    echo -e "$C_HDR$argv$C_RST"
end

function step
    echo -e "  → $C_STEP$argv$C_RST"
end

function ok
    echo -e "✔ $C_OK$argv$C_RST"
end

function warn
    echo -e "⚠ $C_WARN$argv$C_RST"
end

function err
    echo -e "$C_ERR$argv$C_RST"
end
