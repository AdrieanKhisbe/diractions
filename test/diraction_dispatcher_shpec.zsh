# -*- coding: utf-8 -*-
# Spec for the dispatcher commands
# -*- mode: ruby  -*-

setopt aliases
ORIGINAL_DIR="$PWD"
source $(dirname $0:A)/../diractions.plugin.zsh

# set up dispatcher command
DIR_DIR=/tmp/diraction-test
mkdir $DIR_DIR
touch ${DIR_DIR}/{a,b,c}
diraction create dir $DIR_DIR

describe "Dispacher Command"
   it "Is defined as an alias"
     alias dir 2>/dev/null >/dev/null
     assert equal $? 0
   end
   it "Simple cd works"
     dir
     assert equal "$(pwd)" $DIR_DIR
     cd -
   end
   # §TODO: jump to subdirectory
   it 'can tell me where it points'
     output=$(dir where)
     assert equal "$output" "$DIR_DIR"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end
   it 'can ls files in it'
     output=$(dir ls)
     assert equal "$output" "a\nb\nc"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end
   it 'can tree files in it'
     output=$(dir tree | sed 's/`/i/')
     assert grep "$output" "/tmp/diraction-test"
     assert grep "$output" "0 directories, 3 files"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end

   it "Can execute commands"
     output=$(dir - ls)
     assert equal "$output" "a\nb\nc"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end

   it "Can execute whitelisted command"
     output=$(dir make 2>&1)
     assert equal "$output" "make: *** No targets specified and no makefile found.  Stop."
     assert equal "$(pwd)" $ORIGINAL_DIR
   end

   it "Can report invalid argument"
     output=$(dir yolo 2>&1)
     assert equal "$output" "Invalid argument! <yolo>"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end

   it "Can perform command in context (eval)"
     for exec_aliases in - , _ e exec; do
       output=$(dir $exec_aliases echo '$PWD')
       assert equal "$output" "/tmp/diraction-test"
       assert equal "$(pwd)" $ORIGINAL_DIR
     done
   end

   it "Can perform command in context (eval quoted)"
     for quoted_exec_aliases in quoted-exec '--' ',,'; do
       output=$(dir $quoted_exec_aliases echo '$PWD')
       assert equal "$output" '$PWD'
       assert equal "$(pwd)" $ORIGINAL_DIR
     done
   end

   it "Can try perform command in context, fail, and still be in correct directory "
     output=$(dir , oooohh-nooooo 2>&1)
     assert equal "$output" "(eval):1: command not found: oooohh-nooooo"
     assert equal "$(pwd)" $ORIGINAL_DIR
   end

end

rm -rf $DIR_DIR
