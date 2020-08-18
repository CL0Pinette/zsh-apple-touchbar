source ${0:A:h}/functions.zsh

set_state 'command_history'

# Main menu that leads to the other views
function menu_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'menu_view'

    create_key 1 '📖 history' 'history_view'
    create_key 2 '⚙️ configs' 'configs_view'
    create_key 3 '🖍 commands' 'commands_view'
    create_key 4 '🖥 stats' 'computer_view'
}

# Shows command history on touchbar
function history_view() {
	remove_and_unbind_keys
    stop_async_if_running

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

    # Back to menu
    create_key 1 '👈' 'menu_view'

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
    stop_async_if_running

    set_state 'configs'

    create_key 1 '👈' 'menu_view'

    # Commands
    create_key 2 '~/.vimrc' 'vi ~/.vimrc' '-s'
    create_key 3 '~/.zshrc' 'vi ~/.zshrc' '-s'
    create_key 4 'vi 🎨' 'vi ~/.vim/colors/' '-s'
    create_key 5 'coc-config' 'vi ~/.vim/coc-config.vim' '-s'
    create_key 6 'touchbar' 'vi ~/.zsh/zsh-apple-touchbar/zsh-apple-touchbar.zsh' '-s'
    create_key 7 'vim statusline' 'vi ~/.vim/statusline.vim' '-s'
}

function commands_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'commands'

    create_key 1 '👈' 'menu_view'

    # Commands
    create_key 2 'emacs' 'emacs &' '-s'
    create_key 3 'vim' 'vi' '-s'
}

function computer_view() {
    remove_and_unbind_keys

    set_state 'computer'

    # Setup keys with press functionality
    create_key 1 '👈' 'menu_view'
    create_key 4 'coc-config' 'vi ~/.vim/coc-config.vim' '-s'

    # Setup async updates to touchbar
    if [ -z $tempfile ]; then
        path_to_update_script="$HOME/.zsh/zsh-apple-touchbar/compStats/update_async.zsh"
        start_async $path_to_update_script
        echo "(Started updating touchbar with PID: $!)"
    fi
}

zle -N menu_view
zle -N history_view
zle -N configs_view
zle -N commands_view
zle -N computer_view

precmd_apple_touchbar() {
	case $state in
        menu)               menu_view ;;
        command_history)    history_view ;;
		configs)            configs_view ;;
        commands)           commands_view ;;
        computer)           computer_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
