#!/usr/bin/env zsh

setopt aliases
source $(dirname $0:A)/../diractions.plugin.zsh

describe "Diraction config checking"
  config_fixture_dir=$(mktemp -d /tmp/diractions-config-check.XXXXXX)
  config_fixture="$config_fixture_dir/definitions with spaces"
  mkdir -p "$config_fixture_dir/path with spaces" "$config_fixture_dir/path#hash"

  it "returns success when zero directories are missing"
    valid_config_fixture="$config_fixture_dir/valid-config"
    print -r -- 'existing /tmp' > "$valid_config_fixture"
    -diraction-check-file-dir "$valid_config_fixture" >/dev/null
    assert equal $? 0
  end

  it "accepts an existing directory through the public file command"
    print -r -- "existing /tmp" > "$config_fixture"
    diraction check file "$config_fixture" >/dev/null
    assert equal $? 0
  end

  it "resolves quoted, escaped, home, and commented paths like the loader"
    cat > "$config_fixture" <<EOF
# comment

plain /tmp
double "$config_fixture_dir/path with spaces" # comment
single '$config_fixture_dir/path with spaces'
escaped $config_fixture_dir/path\ with\ spaces
home \$HOME
tilde ~
quoted-tilde '~'
hash $config_fixture_dir/path#hash
EOF
    diraction check file "$config_fixture" >/dev/null
    assert equal $? 0
    output=$(
      diraction destroy-all -f
      -diraction-parse-file "$config_fixture" >/dev/null || exit $?
      print -rl -- "$_double" "$_home" "$_quoted_tilde"
    )
    assert equal $? 0
    assert equal "$output" "$config_fixture_dir/path with spaces\n$HOME\n$HOME"
  end

  it "counts missing directories and returns failure"
    print -rl -- "existing /tmp" "missing $config_fixture_dir/missing" "other $config_fixture_dir/other" > "$config_fixture"
    output=$(-diraction-check-file-dir "$config_fixture")
    assert equal $? 1
    assert grep "$output" "There is 2 missing directories"
  end

  it "rejects unmatched quotes"
    print -r -- 'broken "/tmp' > "$config_fixture"
    diraction check file "$config_fixture" >/dev/null 2>&1
    assert equal $? 1
  end

  it "retains syntax failure when directory checking succeeds"
    print -r -- 'broken' > "$config_fixture"
    saved_directory_checker=$functions[-diraction-check-file-dir]
    stub_command -diraction-check-file-dir 'return 0'
    diraction check file "$config_fixture" >/dev/null 2>&1
    assert equal $? 1
    functions[-diraction-check-file-dir]=$saved_directory_checker
  end

  it "checks the configured file with the same behavior"
    print -r -- 'existing /tmp' > "$config_fixture"
    saved_definition_file=$DIRACTION_DEF_FILE
    DIRACTION_DEF_FILE=$config_fixture
    diraction check config >/dev/null
    assert equal $? 0
    DIRACTION_DEF_FILE=$saved_definition_file
  end

  it "returns failure for a missing definition file"
    diraction check file "$config_fixture_dir/not-a-file" >/dev/null 2>&1
    assert equal $? 2
  end

  it "checks syntax without executing command substitutions"
    print -r -- "example \$(touch $config_fixture_dir/syntax-executed)" > "$config_fixture"
    -diraction-check-file-syntax "$config_fixture" >/dev/null
    assert equal $? 0
    assert file_absent "$config_fixture_dir/syntax-executed"
  end

  rm -rf "$config_fixture_dir"
end
