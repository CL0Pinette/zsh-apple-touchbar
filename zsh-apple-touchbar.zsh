source ${0:A:h}/functions.zsh

set_state 'main'

function main_view() {
	remove_and_unbind_keys

	set_state 'main'

    # Number of function keys to use for history (Ex: 12 -> F1 - F12)
    history_keys=12

    # How deep to search zhistory for unique commands
    depth=15

    # Get latest and remove duplicates/whitespace
    latest_commands=$(history -$depth | sed 's/^ [0-9][0-9]*\**  *//g' | tail -r)
    command_list=("${(fu)latest_commands}")

    # Create keys
    hist_keys=($history_keys - 1)
    num_keys=$(($history_keys>${#command_list[@]} ? ${#command_list[@]} : $history_keys))

    for (( i = 0 ; i < $num_keys ; i++ )); do
        create_key $i "${command_list[$i]}" "${command_list[$i]}" '-s' 2> /dev/null
    done
}

zle -N main_view

precmd_apple_touchbar() {
	case $state in
		main) main_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
