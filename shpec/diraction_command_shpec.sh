# Spec for the diraction command

# PB: rely on funcion, only existing in zsh, but zsh has end...

describe "Diraction Commands"

  before
     load $__/../diractions.plugin.zsh
  end

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

end
