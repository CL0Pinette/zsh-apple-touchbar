source ${0:A:h}/functions.zsh

set_state 'main'

function main_view() {
	remove_and_unbind_keys

	set_state 'main'

    # Get last 5
    zhist=~/.zhistory
    # echo "--boutta set cmds"

    # 12 Function Keys
    latest=$(tail -n 13 $zhist | sed "s/: [0-9]*:[0-9];/;/g" | cut -c 2- | tail -r)
    #
    # All 25 on the touchbar
    # Currently keys past F12 are broken ):
    # latest=$(tail -n 25 $zhist | sed "s/: [0-9]*:[0-9];/;/g" | cut -c 2- | tail -r)

    #  echo "---commands are..."
    #  for i in "${latest[@]}"
    #  do
    #      echo $i
    #  done
    # echo "--doin the splitting"

    # Split tail on newline
    cmds=("${(f)latest}")
    # echo "--enter loop"

    for (( i = 0 ; i < ${#cmds[@]} ; i++ ))
    do
        # Add keys; remove 2> /dev/null to show error messages
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
