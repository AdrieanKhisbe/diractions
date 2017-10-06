# -*- coding: utf-8 -*-
# Spec for the dispatcher commands

setopt aliases
ORIGINAL_DIR="$PWD"
_DISPATCHER=$(dirname $0:A)/../__diraction-dispatch
function __diraction-dispatch() {
    . $_DISPATCHER
}

# set up dispatcher command
DIR_DIR=/tmp/diraction-test
mkdir $DIR_DIR
touch ${DIR_DIR}/{a,b,c}
diraction create dir $DIR_DIR

completion_commands=(compadd _message _command_names _path_files _directories _ls _describe)
for cmd in $completion_commands; do
    stub_command $cmd "echo $cmd "'$@ '
done

describe "Dispacher Completion"
  it "Call diraction_dispatch with no args"
    export CURRENT=3 words=(__diraction-dispatch $DIR_DIR)
    output="$(__diraction-dispatch)"
    assert grep "$output" "compadd -x Whitelisted commands"
    assert grep "$output" "_describe -t commands Dispatcher subcommand _DIRACTION_HELP_SUBCOMMAND"
    assert grep "$output" "make.*git.*du"
  end
end
rm -rf $DIR_DIR
