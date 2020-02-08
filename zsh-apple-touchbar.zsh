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

    # Get latest and remove duplicates/whitespace
    latest=$(tail -n $DEPTH $ZHIST | sed "s/: [0-9]*:[0-9];//g" | awk '{$1=$1};1' | cut -c 1- | tail -r)
    cmds=("${(fu)latest}")
    # Create keys
    hist_keys=($HISTORY_KEYS - 1)
    num_keys=$(($HISTORY_KEYS>${#cmds[@]} ? ${#cmds[@]} : $HISTORY_KEYS))
    for (( i = 0 ; i < $num_keys ; i++ ))
    do
        create_key $i "${cmds[$i]}" "${cmds[$i]}" '-s' 2> /dev/null
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
