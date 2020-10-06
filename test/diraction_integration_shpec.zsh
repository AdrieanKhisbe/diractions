#!/usr/bin/env zsh

setopt aliases

plugin="$(dirname $0:A)/../diractions.plugin.zsh"

describe "Integration Diraction"

  it "basic script"
    output="$(zsh 2>&1 << BASIC_SCRIPT
      set -e
      DIRACTION_AUTO_CONFIG=false
      source $plugin

      diraction-batch-create << "DIR"
        dir-tmp /tmp
DIR
      echo \$_dir_tmp
      dir-tmp - pwd
      dir-tmp
      pwd

      zsh << SUB_SHELL
        echo dir-tmp:\\\$_dir_tmp:
SUB_SHELL
BASIC_SCRIPT
)"
    _status=$?
    assert equal $_status 0

    assert equal "$output" "/tmp\n/tmp\n/tmp\ndir-tmp::"
  end

  it "basic script with exports"
    output="$(zsh 2>&1 << BASIC_SCRIPT
      set -e
      DIRACTION_AUTO_CONFIG=false
      DIRACTION_EXPORT_VARIABLES=true
      source $plugin

      diraction-batch-create << "DIR"
        dir-tmp /tmp
DIR
      echo \$_dir_tmp
      dir-tmp - pwd
      dir-tmp
      pwd

      zsh << SUB_SHELL
        echo dir-tmp:\\\$_dir_tmp:
SUB_SHELL
BASIC_SCRIPT
)"
    _status=$?
    assert equal $_status 0

    assert equal "$output" "/tmp\n/tmp\n/tmp\ndir-tmp:/tmp:"
  end
end
