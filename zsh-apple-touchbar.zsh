source ${0:A:h}/functions.zsh

set_state 'main'

function main_view() {
	remove_and_unbind_keys

	set_state 'main'

    # Get last 5
    zhist=~/.zhistory
    echo "--boutta set cmds"
    latest=$(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];/;/g" | cut -c 2-)
    echo "---commands are..."
    for i in "${latest[@]}"
    do
        echo $i
    done
    echo "--doin the splitting"
    cmds=("${(f)latest}")
    echo "--enter loop"
    for (( i = 0 ; i < ${#cmds[@]} ; i++ ))
    do
        create_key $i "${cmds[$i]}" "${cmds[$i]}" '-s'
        echo "made key at $i with command \"${cmds[$i]}\""
    done

	# create_key 1 'pwd-copy' 'pwd |tr -d "\\n" |pbcopy' '-s'
	# create_key 2 'vi ~/.vimrc' 'vi ~/.vimrc' '-s'
	# create_key 3 'open .' 'open .' '-s'
	# create_key 4 'git status' 'git status' '-s'
	# create_key 5 'source ~/.zshrc' 'source ~/.zshrc' '-s'
	# create_key 6 'ls -A' 'ls -A' '-s'
	# create_key 7 '✨ extra' 'extra_util_view'
	# create_key 8 '📖 git' 'git_view'
	# create_key 9 '💻 programs' 'programs_view'
	# create_key 10 '❔ other' 'other_view'
}

zle -N main_view

precmd_apple_touchbar() {
	case $state in
		main) main_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
