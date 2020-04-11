#!/usr/bin/env zsh
# to be sourced from travis.
# adpated from https://github.com/mafredri/zsh-async/blob/master/.travis.yml
setup_zsh() {
    dest="$ZSH_DIST/$1"
    tar_type=.tar.xz
    tar_args=xJ
    case $1 in
        5.0.8|5.0.2) tar_type=.tar.gz; tar_args=xz;;
    esac
    if [[ ! -d $dest/bin ]]; then
    tmp="$(mktemp --directory --tmpdir="${TMPDIR:/tmp}" zshbuild.XXXXXX)"
    (
        cd "$tmp" &&
        curl -L http://downloads.sourceforge.net/zsh/zsh-${1}${tar_type} | tar ${tar_args} &&
        cd zsh-$1 &&
        ./configure --prefix="$dest" &&
        make &&
        mkdir -p "$dest" &&
        make install ||
        echo "Failed to build zsh-${1}!"
    )
    fi
    export PATH="$dest/bin:$PATH"
}

setup_zsh $@