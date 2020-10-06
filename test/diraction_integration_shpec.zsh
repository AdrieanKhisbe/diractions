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
        tmp /tmp
DIR
      tmp - pwd
      tmp
      pwd
BASIC_SCRIPT
)"
    _status=$?
    assert equal $_status 0

    assert equal $output "/tmp\n/tmp"
  end
end
