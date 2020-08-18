function print_key() {
  echo -ne $*
}

function remove_keys() {
  print_key "\033]1337;PopKeyLabels\a"
}

function unbind_keys() {
  for key in "$keys[@]"; do
    bindkey -s "$key" ''
  done
}

function remove_and_unbind_keys() {
  remove_keys
  unbind_keys
}

function set_state() {
  state=$1
}

function create_key() {
    print_key "\033]1337;SetKeyLabel=F${1}=${2}\a"

  if [ "$4" = "-s" ]; then
      bindkey -s $keys[$1] "$3\n"
  else
    bindkey $keys[$1] "$3"
  fi
}

# Creates a temp file and passes it to the async script
# Async script runs as long temp file exists.
function start_async() {
    if [ ! -z $tempfile ]; then
        echo "!! Tried to start async job when tempfile is not empty ($tempfile)"
        exit 1
    fi

    add-zsh-hook zshexit stop_async_if_running

    tempfile=$(mktemp -t touchbar)
    echo "(tempfile: $tempfile)"
    . "$1" "$tempfile" &
    echo "Ran script async..."
}

function stop_async_if_running() {
    if [ ! -z $tempfile ]; then
        stop_async
    fi
}

# Removes the temp file, stopping the async script
function stop_async() {
    if [ -z $tempfile ]; then
        echo "!! Tried to stop async job when tempfile empty ($tempfile)"
        exit 1
    fi

    rm $tempfile
    unset tempfile
}

keys=('^[OP' '^[OQ' '^[OR' '^[OS' '^[[15~' '^[[17~' '^[[18~' '^[[19~' '^[[20~' '^[[21~' '^[[23~' '^[[24~')
