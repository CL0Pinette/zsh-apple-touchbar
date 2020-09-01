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

# $1: script to run async
function start_async() {
    if [ ! -z $async_PID ]; then
        echo "!! Tried to start async job when async_PID is not empty ($async_PID)"
        exit 1
    fi

    add-zsh-hook zshexit stop_async_if_running

    # Create temp pip for exchange of PID
    tmpdir=$(mktemp -d touchbar.XXXXXXXXX)
    PID_pipe="$tmpdir/PID_pipe"
    mkfifo "$PID_pipe"

    ( "$1" $PID_pipe & )
    export async_PID=$(cat $PID_pipe)

    rm -rf $tmpdir
}

function stop_async_if_running() {
    if [ ! -z $async_PID ]; then
        stop_async
    fi
}

function stop_async() {
    if [ -z $async_PID ]; then
        echo "!! Tried to stop async job when async_PID empty"
        exit 1
    fi

    kill $async_PID
    unset async_PID
}

keys=('^[OP' '^[OQ' '^[OR' '^[OS' '^[[15~' '^[[17~' '^[[18~' '^[[19~' '^[[20~' '^[[21~' '^[[23~' '^[[24~' '^[[1;2P'  '^[[1;2Q'  '^[[1;2R' '^[[1;2S'  '^[[15;2~'  '^[[17;2~'  '^[[18;2~'  '^[[19;2~' '^[[20;2~' '^[[21;2~' '^[[23;2~' '^[[24;2~')
