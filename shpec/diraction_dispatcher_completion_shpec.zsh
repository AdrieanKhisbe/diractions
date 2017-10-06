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

describe "Dispacher Command"
it "Call diraction_dispatch"
export CURRENT=3 words=(__diraction-dispatch $DIR_DIR)
stub_command compadd 'echo $@'
__diraction-dispatch


end
end
rm -rf $DIR_DIR
