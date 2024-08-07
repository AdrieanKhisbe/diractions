#!/usr/bin/env zsh
# Spec for the diraction command
# §todo: steps definitions.

setopt aliases
CURRENT_DIR="$PWD"
source $(dirname $0:A)/../diractions.plugin.zsh
source $(dirname $0:A)/diraction_test_utils.zsh

diraction-destroy-all -f

describe "Diraction Commands"

  describe "Dispatcher"

    it "Transfer existing commands"
        ok=false
        stub_command diraction-save "ok=true"
        diraction save
        unstub_command diraction-save
        assert equal $ok true
     end
     it "Error for non existing commands"
        diraction whatthefuck 2> /dev/null
        assert equal $? 1
      end
     it "Error if no subcommand"
        diraction 2> /dev/null
        assert equal $? 1
     end
  end

  describe "Diraction Creation"
    it "create working diraction"
      dir="/tmp/some-name"
      mkdir -p "$dir"
      diraction create testitest "$dir"
      assert glob "$(type testitest)" "*alias*"
      testitest
      assert equal "$PWD" "$dir"
      diraction destroy testitest
    end

    it "support diraction name in kebab case"
      dir="/tmp/some-name-dash"
      mkdir -p "$dir"
      diraction create dash-in-it "$dir"
      assert glob "$(type dash-in-it)" "*alias*"
      assert equal "$_dash_in_it" "$dir"
      dash-in-it
      assert equal "$PWD" "$dir"
      diraction destroy dash-in-it
    end

    it "create working diractions using batch"
      mkdir -p "/tmp/some-dir1" "/tmp/some-dir2"
      diraction batch-create << "DIRS"
        test1 /tmp/some-dir1
        test2 /tmp/some-dir2
DIRS
      assert glob "$(type test1)" "*alias*"
      assert glob "$(type test2)" "*alias*"
      test1
      assert equal "$PWD" "/tmp/some-dir1"
      test2
      assert equal "$PWD" "/tmp/some-dir2"
      diraction destroy-all -f
    end

    it "create working diractions using batch with space and comments"
      mkdir -p "/tmp/some-dir" "/tmp/  some  space  dir" "/tmp/some-dir-with-#hastag"
      diraction batch-create << "DIRS"
        test1-com /tmp/some-dir # comment
        test2-space   /tmp/  some  space  dir
        test2-space-protected /tmp/\ \ some\ \ space\ \ dir
        test3-hash /tmp/some-dir-with-#hastag
        # just a comment
DIRS

      assert glob "$(type test1-com)" "*alias*"
      test1-com
      assert equal "$PWD" "/tmp/some-dir"

      assert glob "$(type test2-space)" "*alias*"
      test2-space
      assert equal "$PWD" "/tmp/  some  space  dir"

      assert glob "$(type test2-space-protected)" "*alias*"
      test2-space-protected
      assert equal "$PWD" "/tmp/  some  space  dir"

      assert glob "$(type test3-hash)" "*alias*"
      test3-hash
      assert equal "$PWD" "/tmp/some-dir-with-#hastag"
      diraction destroy-all -f
    end

    it "create working diractions using batch with tildes and quotes"
      diraction batch-create --ignore-missing-dir option << "DIRS"
        test1-home ~/.test/d1
        test2-home-quote '~/.test/d2'
        test3-home-double-quote "~/.test/d3"
        test4-home-double-quote-comment "~/.test/with space" # comment
DIRS

      assert glob "$(type test1-home)" "*alias*"
      assert equal "$(whence -f test1-home)" '_diraction-dispatch "~/.test/d1"'

      assert glob "$(type test2-home-quote)" "*alias*"
      assert equal "$(whence -f test2-home-quote)" '_diraction-dispatch "'"'"'~/.test/d2'"'"'"' # "'path'" in quotes

      assert glob "$(type test3-home-double-quote)" "*alias*"
      assert equal "$(whence -f test3-home-double-quote)" '_diraction-dispatch ""~/.test/d3""'

      assert glob "$(type test4-home-double-quote-comment)" "*alias*"
      assert equal "$(whence -f test4-home-double-quote-comment)" '_diraction-dispatch ""~/.test/with space""'

      diraction destroy-all -f
    end

    it "create working diractions using batch and option"
      mkdir -p "/tmp/some-dir1" "/tmp/some-dir2"
      diraction batch-create --create-missing-dir << "DIRS"
        test1 /tmp/some/dir1
        test2 /tmp/some/dir2
DIRS
      assert glob "$(type test1)" "*alias*"
      assert glob "$(type test2)" "*alias*"
      test1
      assert equal "$PWD" "/tmp/some/dir1"
      assert file_present  "/tmp/some/dir1"
      test2
      assert equal "$PWD" "/tmp/some/dir2"
      assert file_present  "/tmp/some/dir2"
      rm -rf /tmp/some
      diraction destroy-all -f
    end

    it "create working diraction with name in it"
      dir="/tmp/some name with space"
      mkdir -p "$dir"
      diraction create testitest "$dir"
      assert glob "$(type testitest)" "*alias*"
      testitest
      assert equal "$PWD" "$dir"
      diraction destroy testitest
      # todo: extract cleanup function. or make in sandbox
    end

    it "Deny creation if non existing"
      output="$(diraction create ghost /tmp/oh-no/I/don/t/exists  2>&1)"
      assert equal $? 2
      assert equal "$output" "diraction: /tmp/oh-no/I/don/t/exists is not a real directory (ghost)\nyou can force creation adding --ignore-missing-dir flag or use --create-missing-dir"
    end

    it "Allow creation of diraction if missing folder but force"
      diraction create ghost /tmp/oh-no/I/don/t/exists --ignore-missing-dir
      assert equal $? 0
      assert grep "$(which ghost)" "aliased to _diraction-dispatch"
    end

    it "Allow creation if non existing but force"
      diraction create alive_ghost /tmp/oh-no/I/don/t/exists --create-missing-dir
      assert equal $? 0
      assert file_present "/tmp/oh-no/I/don/t/exists"
      assert grep "$(which alive_ghost)" "aliased to _diraction-dispatch"
    end

    rm -rf /tmp/oh-no/I/don/t/exists
    diraction-destroy-all -f
  end
  describe "Diraction listing"
    dir1="/tmp/dir1"; dir2="/tmp/dir2"
    diraction-fake test1 "$dir1"
    diraction-fake test2 "$dir2"

    it "ls all the dirs"
        output="$(diraction ls)"
        assert grep "$output" "List of diractions"
        assert grep "$output" "test1.* -  /tmp/dir1"
        assert grep "$output" "test2.* -  /tmp/dir2"
    end

    it "ls some dirs"
        output="$(diraction ls 2)"
        assert grep "$output" "List of diractions"
        assert no_grep "$output" "test1.* -  /tmp/dir1"
        assert grep "$output" "test2.* -  /tmp/dir2"
    end
    it "ls-alias"
        output="$(diraction list-alias)"
        assert equal "$output" "test1 test2"
    end

    it "ls-alias with pattern"
        output="$(diraction list-alias t1)"
        assert equal "$output" "test1"
    end

    it "ls-dir"
        output="$(diraction list-dir)"
        assert equal "$output" "/tmp/dir1 /tmp/dir2"
    end

    it "ls-dir with alias"
        output="$(diraction list-dir r2)"
        assert equal "$output" "/tmp/dir2"
    end
  end
end

cd "$CURRENT_DIR"
