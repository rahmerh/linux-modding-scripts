function resolve_game --argument-names input
    switch (string lower -- "$input")
        case "cyberpunk 2077" cyberpunk cyberpunk2077 cbp
            echo "Cyberpunk 2077"
        case '*'
            return 1
    end
end
