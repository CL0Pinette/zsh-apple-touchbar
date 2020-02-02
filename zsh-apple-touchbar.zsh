source ${0:A:h}/functions.zsh

set_state 'main'

function main_view() {
	remove_and_unbind_keys

	set_state 'main'

	create_key 1 'pwd-copy' 'pwd |tr -d "\\n" |pbcopy' '-s'
	create_key 2 'vi ~/.vimrc' 'vi ~/.vimrc' '-s'
	create_key 3 'open .' 'open .' '-s'
	create_key 4 'git status' 'git status' '-s'
	create_key 5 'source ~/.zshrc' 'source ~/.zshrc' '-s'
	create_key 6 'ls -A' 'ls -A' '-s'
	create_key 7 '✨ extra' 'extra_util_view'
	create_key 8 '📖 git' 'git_view'
	create_key 9 '💻 programs' 'programs_view'
	create_key 10 '❔ other' 'other_view'
}

function extra_util_view() {
	remove_and_unbind_keys

	set_state 'extra_util'

	create_key 1 '👈 back' 'main_view'
	create_key 2 'source ~/.zshrc' 'source ~/.zshrc' '-s'

	set_state 'main'
}

function git_view() {
	remove_and_unbind_keys

	set_state 'git'

	create_key 1 '👈 back' 'main_view'
	create_key 2 'status' 'git status' '-s'
	create_key 3 'add .' 'git add .' '-s'
	create_key 4 'remove all' 'git rm --cached -r *' '-s'
	create_key 5 'push' 'git push' '-s'
	create_key 6 'pull' 'git pull' '-s'
	create_key 7 'branch' 'git branch' '-s'
	create_key 8 'stash' 'git stash' '-s'
	create_key 9 'stash pop' 'git stash pop' '-s'
	create_key 10 'fetch' 'git fetch' '-s'
	create_key 11 'More 👉' 'git-extra_view'
}

function git-extra_view() {
	remove_and_unbind_keys

	set_state 'git-extra'

	create_key 1 '👈 back' 'git_view'
	create_key 2 'vim .gitignore' 'vi .gitignore' '-s'
	create_key 3 'push -u origin master' 'git push -u origin master' '-s'
	create_key 4 'force push' 'git push -f' '-s'
	create_key 5 'stash list' 'git stash list' '-s'
	create_key 6 'stash clear' 'git stash clear' '-s'
	create_key 7 'amend commit' 'git commit --amend' '-s'
	create_key 8 'hard reset' 'git reset --hard HEAD' '-s'
	create_key 9 'soft reset' 'git reset --soft' '-s'
	create_key 10 'checkout master' 'git checkout master' '-s'
}

function programs_view() {
	remove_and_unbind_keys

	set_state 'programs'

	create_key 1 '👈 back' 'main_view'
	create_key 2 '🌍' 'safari' '-s'
	create_key 3 '🕵️‍♂️' 'incognito' '-s'
	create_key 4 '📧' 'gmail_cornell' '-s'
	create_key 5 '💌' 'gmail_personal' '-s'
}

function other_view() {
	remove_and_unbind_keys

	set_state 'other'

	create_key 1 '👈 back' 'main_view'
	create_key 2 '🐘 gradle' 'gradle_view'
	create_key 3 '🐍 python' 'python_view'
}

function gradle_view() {
	remove_and_unbind_keys

	set_state 'gradle'

	create_key 1 '👈 back' 'other_view'
	create_key 2 'gradle run' 'gradle run' '-s'
	create_key 3 'gradle run plain' 'gradle run --console=plain' '-s'
	create_key 4 'gradle test' 'gradle test' '-s'
	create_key 5 'rerun tests' 'gradle test --rerun-tasks' '-s'
	create_key 6 'stop daemon' 'gradle --stop' '-s'
	create_key 7 'init java' 'gradle init --type -java-application' '-s'
}

function python_view() {
	remove_and_unbind_keys

	set_state 'python'

	create_key 1 '👈 back' 'other_view'
	create_key 2 'interactive shell' 'python' '-s'
	create_key 3 'venv' 'venv' '-s'
	create_key 4 'deactivate' 'deactivate' '-s'
	create_key 5 'init venv' 'initvenv' '-s'
}

zle -N main_view
zle -N extra_util_view
zle -N git_view
zle -N git-extra_view
zle -N programs_view
zle -N other_view
zle -N gradle_view
zle -N python_view

precmd_apple_touchbar() {
	case $state in
		main) main_view ;;
		extra_util) extra_util_view ;;
		git) git_view ;;
		git-extra) git-extra_view ;;
		programs) programs_view ;;
		other) other_view ;;
		gradle) gradle_view ;;
		python) python_view ;;
	esac
}

autoload -Uz add-zsh-hook

add-zsh-hook precmd precmd_apple_touchbar
