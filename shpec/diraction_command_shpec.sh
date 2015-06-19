# Spec for the diraction command

# PB: rely on funcion, only existing in zsh, but zsh has end...
# §todo: steps definitions.

describe "Diraction Commands"

  source ./diractions.plugin.zsh
  CURRENT_DIR=$PWD

  describe "Dispatcher"

    it "Transfer existing commands"
        ok=false
        stub_command diraction-list "ok=true"
        diraction list
        unstub_command diraction-list
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
      directory_names=('/tmp/some-name' '/tmp/some name with space' )
      for dir in "${(@)directory_names}"
      do
        mkdir -p "$dir"
        diraction create testitest "$dir"
        assert match "$(type testitest)" "*alias*"
        testitest # how to test alias??
        assert equal $PWD "$dir"
        diraction destroy testitest
      done
    end

    it "Deny creation if non existing"
    end

    it "Allow creation if non existing but force"
    end
  end
end
