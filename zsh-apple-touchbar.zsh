source ${0:A:h}/functions.zsh

set_state 'command_history'

function history_view() {
	remove_and_unbind_keys

	set_state 'command_history'

    # Number of function keys to use for history (Ex: 12 -> F1 - F12)
    history_keys=12

    # How deep to search zhistory for unique commands
    depth=15

    # How many keys are reserved for other purposes than history
    reserved_keys=1

    # Get latest and remove duplicates/whitespace
    latest_commands=$(history -$depth | sed 's/^ [0-9][0-9]*\**  *//g' | tail -r)
    command_list=("${(fu)latest_commands}")

    # To common commands
    create_key 1 '> ⚙️' 'configs_view'

    # Create keys
    num_keys_to_display=$(( $history_keys > ${#command_list[@]} ? ${#command_list[@]} : $history_keys))
    num_keys_to_display=$(( $num_keys_to_display + $reserved_keys ))

    for (( i = $reserved_keys + 1 ; i < $num_keys_to_display ; i++ )); do
        list_index=$(($i - $reserved_keys))
        create_key "$i" "${command_list[$list_index]}" "${command_list[$list_index]}" '-s' 2> /dev/null
    done

}

function configs_view() {
    remove_and_unbind_keys

    set_state 'configs'


    create_key 1 '> 📚' 'commands_view'

    # Commands
    create_key 2 '~/.vimrc' 'vi ~/.vimrc' '-s'
    create_key 3 '~/.zshrc' 'vi ~/.zshrc' '-s'
    create_key 4 'vi 🎨' 'vi ~/.vim/colors/' '-s'
    create_key 5 'touchbar' 'vi ~/.zsh/zsh-apple-touchbar/zsh-apple-touchbar.zsh' '-s'
}

function commands_view() {
    remove_and_unbind_keys

    set_state 'commands'

    create_key 1 '> 📖' 'history_view'

    # Commands
    create_key 2 'emacs' 'emacs &' '-s'
    create_key 3 'vim' 'vi' '-s'
}

zle -N history_view
zle -N configs_view
zle -N commands_view

precmd_apple_touchbar() {
	case $state in
        command_history)    history_view ;;
		configs)            configs_view ;;
        commands)           commands_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
