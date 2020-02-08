source ${0:A:h}/functions.zsh

set_state 'main'

function main_view() {
	remove_and_unbind_keys

	set_state 'main'

    # History File
    ZHIST=~/.zhistory
    # Number of function keys to use for history (Ex: 12 -> F1 - F12)
    HISTORY_KEYS=12
    # How deep to search zhistory for unique commands
    DEPTH=15

    latest=$(tail -n $DEPTH $ZHIST | sed "s/: [0-9]*:[0-9];//g" | cut -c 1- | tail -r)
    cmds=("${(f)latest}")
    # Strip whitespace at end of cmds
    for (( i = 1 ; i < ${#cmds[@]} ; i++ ))
    do
        cmds[$i]=$(echo ${cmds[$i]} | awk '{$1=$1};1')
    done
    # Remove Duplicates
    cmds=("${(u)cmds[@]}")
    # Create keys
    hist_keys=($HISTORY_KEYS - 1)
    num_keys=$(($HISTORY_KEYS>${#cmds[@]} ? ${#cmds[@]} : $HISTORY_KEYS))
    for (( i = 0 ; i < $num_keys ; i++ ))
    do
        create_key $i "${cmds[$i]}" "${cmds[$i]}" '-s' 2> /dev/null
        # echo "[made key at $i with command \"${cmds[$i]}\"]"
    done

    # TODO:  See TODO.md
}

zle -N main_view

precmd_apple_touchbar() {
	case $state in
		main) main_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
