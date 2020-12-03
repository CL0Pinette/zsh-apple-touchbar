script_path=${0:A:h}
source ${0:A:h}/functions.zsh

autoload -Uz add-zsh-hook

if [ -z $async_PID ]; then
    set_state 'weather' # TODO this doesn't work when an async script is running?
else
    set_state 'command_history'
fi

# If async command is running on startup, pause it while this shell instance is running
resume_old_async_cmd() {
    kill -CONT $other_shell_async_PID
}
if [ ! -z $async_PID ]; then
    other_shell_async_PID=$async_PID
    unset async_PID
    kill -STOP $other_shell_async_PID
    add-zsh-hook zshexit resume_old_async_cmd
fi

# Main menu that leads to the other views
menu_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'menu_view'

    create_key 1 '📖 history' 'history_view'
    create_key 2 '⚙️ configs' 'configs_view'
    create_key 3 '🖍 commands' 'commands_view'
    create_key 4 '🖥  stats' 'computer_view'
    create_key 5 '⛅  weather' 'weather_view'
}

# Shows command history on touchbar
history_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'command_history'

    # Number of function keys to use for history (Ex: 12 -> F1 - F12)
    history_keys=24

    # How deep to search history for unique commands
    depth=40

    # How many keys are reserved for other purposes than history
    reserved_keys=1

    # Get latest and remove duplicates/whitespace
    latest_commands=$(history -$depth | sed 's/ *[0-9][0-9]*\**  *//g' | tail -r)
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

configs_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'configs'

    create_key 1 '👈' 'menu_view'

    # Commands
    create_key 2  '~/.vimrc' 'vi ~/.vimrc' '-s'
    create_key 3  '~/.zshrc' 'vi ~/.zshrc' '-s'
    create_key 4  'p10k' 'vi ~/.p10k.zsh' '-s'
    create_key 5  'vi 🎨' 'vi ~/.vim/colors/' '-s'
    create_key 6  'bin_scripts' 'vi ~/bin_scripts' '-s'
    create_key 7  'coc-config' 'vi ~/.vim/coc-config.vim' '-s'
    create_key 8  'coc-json' 'vi ~/.vim/coc-settings.json' '-s'
    create_key 9  'touchbar' 'vi ~/.zsh/zsh-apple-touchbar/zsh-apple-touchbar.zsh' '-s'
    create_key 10 'ideavim' 'vi ~/.ideavimrc' '-s'
    create_key 11 'vim statusline' 'vi ~/.vim/statusline.vim' '-s'
}

function commands_view() {
    remove_and_unbind_keys
    stop_async_if_running

    set_state 'commands'

    create_key 1 '👈' 'menu_view'

    # Commands
    create_key 2 'pwd | pbcopy' 'pwd | pbcopy' '-s'
    create_key 3 'vim git revision' 'vi $(git diff --name-only master)' '-s'
    create_key 4 'emacs notetaking' 'j Classes && emacs & ' '-s'
    create_key 5 'readme preview' 'vmd README.md' '-s'
    create_key 6 'gridwar' 'j GridWars && java -jar Gridwars.jar' '-s'
}

function computer_view() {
    set_state 'computer'

    if [ -z $async_PID ]; then # If not already running
        remove_and_unbind_keys
        create_key 1 '👈' 'menu_view'
        create_key 2 '' 'htop' '-s'

        update_async="$script_path/update_async.zsh"
        computer_script="$script_path/compStats/comp.py"

        start_async "$update_async" "$computer_script" 5 5 2
    fi
}

function weather_view() {
    set_state 'weather'

    if [ -z $async_PID ]; then # If not already running
        remove_and_unbind_keys
        create_key 1 '👈' 'menu_view'
        create_key 2 '' 'curl v2.wttr.in/' '-s'

        update_async="$script_path/update_async.zsh"
        weather_script="$script_path/weather/wttr.py"

        start_async "$update_async" "$weather_script" 1200 30 2
    fi
}

zle -N menu_view
zle -N history_view
zle -N configs_view
zle -N commands_view
zle -N computer_view
zle -N weather_view

precmd_apple_touchbar() {
    case $state in
        menu)               menu_view ;;
        command_history)    history_view ;;
        configs)            configs_view ;;
        commands)           commands_view ;;
        computer)           computer_view ;;
        weather)            weather_view ;;
    esac
}


add-zsh-hook precmd precmd_apple_touchbar
