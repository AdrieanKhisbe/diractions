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
mkdir -p ${DIR_DIR}/dir{1,2,3}
diraction create dir $DIR_DIR

completion_commands=(compadd _message _command_names _path_files _directories _ls _describe _options_set)
for cmd in $completion_commands; do
    stub_command $cmd "echo $cmd "'$@ '
done

describe "Dispatcher Completion"
  it "Completion with no args"
    export CURRENT=3 words
    words=(__diraction-dispatch $DIR_DIR)
    output="$(__diraction-dispatch)"
    assert grep "$output" "compadd -x Whitelisted commands"
    assert grep "$output" "_describe -t commands Dispatcher subcommand _DIRACTION_HELP_SUBCOMMAND"
    assert grep "$output" "make.*git.*du"
  end

  it "Completion with word arg"
    export CURRENT=3 words=(__diraction-dispatch $DIR_DIR ls)
    output="$(__diraction-dispatch)"
    assert grep "$output" "compadd -x Whitelisted commands"
    assert grep "$output" "_describe -t commands Dispatcher subcommand _DIRACTION_HELP_SUBCOMMAND"
    assert grep "$output" "make.*git.*du"
  end

  it "Completion with some dir prefix that do not exist"
    export CURRENT=3 words=(__diraction-dispatch $DIR_DIR /xyz)
    output="$(__diraction-dispatch)"
    assert grep "$output" "_message .\?No matching subdir.\?"
  end

  it "Completion with some dir prefix that do exist"
    export CURRENT=3 words=(__diraction-dispatch $DIR_DIR /dir)
    output="$(__diraction-dispatch)"
    assert grep "$output" "compadd -S .\?.\? \?-X .\?Matching Subdirs.\? -U -a paths"
  end

  it "Completion with some whitelisted command"
    export CURRENT=4 words=(__diraction-dispatch $DIR_DIR ls -)
    output="$(__diraction-dispatch)"
    assert grep "$output" "_ls"
  end

  it "Completion with some subdir after slash"
    export CURRENT=4 words=(__diraction-dispatch $DIR_DIR / dir)
    output="$(__diraction-dispatch)"
    assert grep "$output" "_directories -W $DIR_DIR"
  end

  it "Completion after interactive"
    export CURRENT=4 words=(__diraction-dispatch $DIR_DIR interactive)
    output="$(__diraction-dispatch)"
    assert grep "$output" "_message Just hit enter, and enter the interactive mode :)"
  end

  describe "Completion of exec/forward command"
    it "command of forward"
      export CURRENT=4 words=(__diraction-dispatch $DIR_DIR - l)
      output="$(__diraction-dispatch)"
      assert grep "$output" "_command_names"
    end

    it "argument of command with completion command available"
      export CURRENT=5 words=(__diraction-dispatch $DIR_DIR - ls alo)
      output="$(__diraction-dispatch)"
      assert grep "$output" "_ls"
    end

    it "argument of command with no completion command available"
      export CURRENT=5 words=(__diraction-dispatch $DIR_DIR - toto)
      output="$(__diraction-dispatch)"
      assert grep "$output" "_path_files -W $DIR_DIR"
      assert grep "$output" "_options_set"
    end
  end
end
rm -rf $DIR_DIR
