################################################################################
##                 ____  _                 __  _                              ##
##                / __ \(_)________ ______/ /_(_)___  ____  _____             ##
##               / / / / / ___/ __ `/ ___/ __/ / __ \/ __ \/ ___/             ##
##              / /_/ / / /  / /_/ / /__/ /_/ / /_/ / / / (__  )              ##
##             /_____/_/_/   \__,_/\___/\__/_/\____/_/ /_/____/               ##
##                                                                            ##
##                Doing Anything,                                             ##
##                                  Anywhere,                                 ##
##                                               From There                   ##
##                                                                            ##
################################################################################

# Diractions: Doing Anything, Anywhere, from here
# Author: Adrien Becchis (@AdrieanKhisbe on github&twitter)
# Homepage: http://github.com/AdrieanKhisbe/diractions
# License: MIT License<Adriean.Khisbe@live.fr>
# Version: v0.17.1
# Released on: 2020-08-24

# §bonux: mini stupid logo. :) (paaaneaux)

################################################################################
# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.


################################################################################
# ¤> Config
# ¤>> Commands variables
#------------------------------------------------------------------------------#
# ¤>> Vars

##' variable accumulating the defuns
declare -gA DIRACTION_REGISTER
declare -gA _DIRACTION_HELP
# -g flag so it persist outside the script
# §NOTE: Arrays are not exported in child process :/
# §maybe: keep the disabled defuns

##' Util function pour définir valeur par default si celles-ci non définies
-set-default () {
    # ¤note: from antigen
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
    # §see: make it not exportable?
}
#' function to easily declare help associated to the provided command
-diraction-help(){
    if [[ $# != 2 ]]; then
        echo "Wrong usage of help. Pb with the source" >&2
        exit 1
    fi
    _DIRACTION_HELP[$1]="$fg_bold[blue]diraction $1$reset_color $2"
}

# oh yes, yell like a zsh var!! :D
-set-default DIRACTION_INTERACTIVE_PROMPT "$fg_bold[red]>> $fg_bold[blue]"  # §todo: make it bold
-set-default DIRACTION_EDITOR ${EDITOR:-vi}
-set-default DIRACTION_DEF_FILE "$HOME/.diractions" # §maybe rename to config file
-set-default DIRACTION_BROWSER # §todo: update
-set-default DIRACTION_AUTO_CONFIG true

# --
if [[ -z $DIRACTION_DISPATCH_WHITELIST ]]; then
    # for  build tools + files utils
    DIRACTION_DISPATCH_WHITELIST=(make rake sbt gradle git cask bundler ncdu du nemo nautilus open xdg-open ls)
    # §maybe: later, add function to register to whitelist command
fi
# --

# §bonux: more config
# §bonux: provide documentation too! : store in an array? (name var and doc)
unset -f -- -set-default

# ¤>> constants
DIRACTION_USAGE="usage: new/create <aliasname> <dir>
disable / enable / destroy <aliasname>
list|ls / list-alias|la / list-dir|ld / grep <aliaspattern>"
# ¤note: function -set-constant wasn't working
# §later? maybe restore notion of constant?

################################################################################
# ¤> "Alvar" diractions functions
# ¤>> Notes:

#------------------------------------------------------------------------------#
# ¤>> Functions

##' Command dispatcher
#' ¤note: inspired from Antigen Shrikant Sharat Kandula
function diraction(){

    if [[ $# == 0 ]]; then
        echo "Please provide a command\n${DIRACTION_USAGE}" >&2
        return 1
    fi

    # §maybe: handle help of diraction itself
    local cmd=$1
    shift


    if { (( ${@[(I)--help]} )) ||  (( ${@[(I)-h]} ))} ; then
        if [[ -z "$_DIRACTION_HELP[$cmd]" ]] ; then
            echo "Command $cmd does not exist."
            echo "$DIRACTION_USAGE"
        else
            # §maybe: cut diraction- in all doc
            echo;echo "$_DIRACTION_HELP[$cmd]"
        fi

    elif functions "diraction-$cmd" > /dev/null; then
        # ¤note: functions print all function or specified one
        "diraction-$cmd" "$@"
    else
         echo "No such subcommand\n${DIRACTION_USAGE}" >&2;
         return 1
    fi
}


##' ¤>> Alias&Variable Combo function:
## §TODO: HERE would need to refactor to handle option if want to place if in the end
-diraction-help create '<name> <dir> [--ignore-missing-dir/--create-missing-dir]
Create a new diraction.
Link a directory to create both a variable "_$1", and a "dispatch" alias "$1"

If variable already exist, it will not be updated!
Add --ignore-missing-dir option if you want to bypass existence checking test'
function diraction-create() {
    if [[ $# -lt 2 ]]; then
        echo "Wrong Number of arguments\ndiraction-create <alias> <dir>" >&2
        return 1
    fi

    local alias=$1
    local var="_$(echo $alias | tr '-' '_')"
    local dir="$2"

    if [[ ! -d "$dir" ]]; then
        if [[ "--create-missing-dir" = "$3" ]]; then
            mkdir -p $dir
        elif [[ "--ignore-missing-dir" != "$3" ]]; then
            echo "diraction: $dir is not a real directory ($alias)\nyou can force creation adding --ignore-missing-dir flag or use --create-missing-dir" >&2
            return 2
            # §maybe: log "dir is missing". count numb of miss
        fi
    fi

    # create variable if not already bound
    if [ -z "${(P)var}" ] ; then
        # ¤note: déréférencement de variable: ${(P)var}
        export $var="$(eval echo "$dir")"
        # §see: keep export?
        # §maybe: readonly probably better?? (maybe not: could not unset then)
    fi
    # create an alias: call to the _diraction-dispach function with directory as argument
    alias "$alias"="_diraction-dispatch \"$dir\""

    # §see: keep var or not? if yes use $var prefixed by \$ (to enable to change target,but var consulted each time)

    DIRACTION_REGISTER[$alias]="$dir"
}

-diraction-help save "<name>
Save current directory as diraction"
function diraction-save() {
    if [[ $# -lt 1 ]]; then
        echo "Wrong Number of arguments\ndiraction-alias <alias>" >&2
        return 1
    fi
    diraction-create $1 $PWD
}

# ¤>> Other utils functions
-diraction-help exist "
check if alias attached to diraction"
function diraction-exist() {
    [[ -n "$DIRACTION_REGISTER[$1]" ]]
}

-diraction-help list "
List existing diractions (eventually filtered by given arg)"
function diraction-list() {
    echo "List of diractions:"
    for a in ${(ko)DIRACTION_REGISTER}; do
        if [ -n "$1" ] && [[ ! "$a" =~ $1 ]] ; then continue; fi
        echo "$a\t -  $DIRACTION_REGISTER[$a]"
        # §TODO: indent [retrieve zsh link]
    done | sed "s;$HOME;~;" # waiting for regexp
    # beware separation while evaluating
}
diraction-ls() { diraction-list $@; }

-diraction-help list-alias "
List existing diraction aliases (eventually filtered by given arg)"
function diraction-list-alias() {
    if [ ! -n "$1" ]; then
        echo ${(ko)DIRACTION_REGISTER}
    else
        echo ${(ko)DIRACTION_REGISTER} | tr ' ' '\n' | egrep $1 | xargs echo -n
    fi
}
diraction-la () { diraction-list-alias $@; }

-diraction-help list-dir "
List existing diraction directories (eventually filtered by given arg)"
function diraction-list-dir() {
    if [ ! -n "$1" ]; then
        echo ${(ov)DIRACTION_REGISTER}
    else
        echo ${(ov)DIRACTION_REGISTER} | tr ' ' '\n' | egrep $1 | xargs echo -n
    fi
}
diraction-ld() { diraction-list-dir $@; }

-diraction-help grep "<pattern>
Grep existing diraction to find matching aliases"
function diraction-grep() {
    if [[ $# == 0 ]]; then
        echo "Please provide something to grep it with" >&2
        return 1
    else
        echo "List of diractions: matching '$@'"
        for a in ${(ko)DIRACTION_REGISTER}; do
            echo "$a\t -  $DIRACTION_REGISTER[$a]"
            # §TODO: indent: see padding: http://zsh.sourceforge.net/Doc/Release/Expansion.html
        done | grep $@
    fi
}

-diraction-help disable "<name>
Disable attached alias"
function diraction-disable() {
    if diraction-exist $1 ;then
        disable -a $1
    else
        echo "Provided argument is not a registered diraction" >&2
        return 1
    fi
}

-diraction-help enable "<name>
Re-enable attached alias"
function diraction-enable() {
    if diraction-exist $1 ;then
        enable -a $1
        # §maybe: disable variable or not?
    else
        echo "Provided argument is not a registered diraction" >&2
        return 1
    fi
}

-diraction-help destroy "<name>
Destroy alias and variable attached to diraction name"
function diraction-destroy() {
    if diraction-exist $1 ;then
        unalias $1
        unset "_$(echo $alias | tr '-' '_')"
        unset "DIRACTION_REGISTER[$1]"
    else
        echo "Provided argument is not a registered diraction" >&2
        return 1
    fi
}

-diraction-help destroy-all "[--force|-f]
destroy all diraction variables
Need -f/--force flag to perform"
function diraction-destroy-all() {
    if [[ "-f" == $1  ]] || [[ "--force" == $1  ]]
    then
        for a in ${(k)DIRACTION_REGISTER}; do
            diraction-destroy $a
        done
    else
        echo "If you wanna really destroy all diraction add the -f/--force flag" >&2
        return 1
    fi
}

-diraction-help reset "
Reset direction environment by first destroying everython then reloading config"
function diraction-reset() {
    echo "Reseting diraction environment"
    diraction-destroy-all -f
    diraction-load-config # load config
    # §maybe: for security issue. add some env flag this has been done?
}

# §TODO: diraction-dump: flux ou dir
# §maybe: reuse serialisation function that was once develop
# ¤note: keep insertion order in this case.

-diraction-help whitelist "<cmd*>
Add provided commands to the whitelist"
function diraction-whitelist() {
    DIRACTION_DISPATCH_WHITELIST+=($@)
}

-diraction-help blacklist "<cmd*>
Remove provided commands from the whitelist"
function diraction-blacklist() {
    for cmd in $@ ; do
        DIRACTION_DISPATCH_WHITELIST=("${(@)DIRACTION_DISPATCH_WHITELIST:#$cmd}")
    done
# cf http://stackoverflow.com/questions/3435355/remove-entry-from-array
}

-diraction-help help "
Yo Dawg, I herd you like help, so I put an help in your help
so you can get helped while you search help"
function diraction-help() {
    if [[ $# != 1 ]] ; then
        echo -n $fg_bold[blue]
        cat <<"BANNER"
      ____  _                 __  _
     / __ \(_)________ ______/ /_(_)___  ____  _____
    / / / / / ___/ __ `/ ___/ __/ / __ \/ __ \/ ___/
   / /_/ / / /  / /_/ / /__/ /_/ / /_/ / / / (__  )
  /_____/_/_/   \__,_/\___/\__/_/\____/_/ /_/____/

BANNER
        # ¤note: figlet -f slant Diractions
        # ¤note: "BANNER" quotes protect from () eval
        echo "$reset_color$DIRACTION_USAGE"
    else
        if diraction-exist $1 ;then
            "$1 diraction is bound to ${DIRACTION_REGISTER[$1]} the directory"
        else
            cat <<EOF
There is no diraction named $1
For more help about diraction please run 'diraction help'.
EOF
        fi
        # §MAYBE: rather make a doc about existing commands?
        #
    fi
}


################################################################################
# ¤> Config functions
# ¤>> Charging of personnal config

##' Load personal config of user
##' first load predefined function if exist. then load config file
function diraction-load-config() {
    ## two options, function or file. load both, function taking precedence

    # Load personal function if existing
    # §todo: doc
    if functions "diraction-personal-config" > /dev/null; then
        # §later: add security about function content?
        # §maybe: set the name of the function as a custom variable
        #  "$(functions diraction-personal-config | grep "^[[:space:]]*diraction-")"
        diraction-personal-config
    fi

    if [[ -f "$DIRACTION_DEF_FILE" ]] && ! -diraction-parse-file "$DIRACTION_DEF_FILE" --ignore-missing-dir ; then
        echo "Error while parsing $DIRACTION_DEF_FILE, please it has check correct syntax" >&2
        return 1
    fi
}

##' parse file as diraction definition
function -diraction-parse-file() {
    if [[ ! -f "$1" ]]
    then
        echo 'diraction parse file need to be given a file!' >&2
        return 2;
    else
        cat $1 | sed 's/~/$HOME/' | diraction-batch-create $2
        return $?
    fi
}

##' function to create a set of batch definition from sdin
function diraction-batch-create() {
    local SED_OPT
    if [[ "$(uname -s)" -eq "Darwin" ]] ; then SED_OPT="-E" ; else SED_OPT="-R" ; fi

    cat -n |  sed 's:#.*$::' | sed $SED_OPT 's/[[:space:]]+/ /g' |
    # kill comment for the eval
    # §maybe: extract to function when fill do check-syntax, check file exist.
    # should rafine to have a read keeping memory in count?. (maybe cat -n)
    # Must take a function. # should be private ?. or defined
    while read line ; do
        # Using `eval` so that we can use the shell-style quoting in each line
        # piped to `antigen-bundles`.   ¤note: inspired form antigen

        local ko=false

        local -a aline
        set -A aline ${(@s: :)line}

        local option="$1"

        if [[  "${#aline}" -le 1 ]]; then
            # next: ignore empty line
            :
        elif [[  "${#aline}" != 3 ]] ; then
            echo "At line ${aline[1]}, invalid number of argument: ${aline[2,-1]}" >&2
            ko=true
        elif [[ $option =~ "-missing-dir" ]]; then
            diraction-create "$aline[2]" "$aline[3]" $option
        else
            local dir=$(eval echo "$aline[3]")
            if [[ -d "$dir" ]]; then
                diraction-create "$aline[2]" "$dir"
            else
                echo "At line ${aline[1]}, directory '$dir' does not exists" >&2
                ko=true
            fi
        fi
        if $ko ; then
            echo "Error occured during batch create, so stopping the process:\n$line" >&2
            # §todo: more specific error, check arg line
            return 1
        fi
    done
}

## §TODO: save test file to run test.
function diraction-check() {
    # §todo: alias doctor

    #§maybe refactor which command as a variable?
    if [[ "$1" == "config" ]]; then
        echo ">> Checkying config [${DIRACTION_DEF_FILE}] syntax:"
        diraction-check-config-syntax && echo "Syntax seems fine :)"
        echo ">> Checkying config [${DIRACTION_DEF_FILE}] directory existance:"
        diraction-check-config-dir && echo "All dir seems to exist"

    elif [[ "$1" == "file" ]]; then
        if [[ -f "$2" ]]; then
            echo "Checkying file [$2] syntax: "
            -diraction-check-file-syntax $2 && echo "Syntax seems fine :)"
            echo "Checkying file [$2] diractories: "
            -diraction-check-file-dir  $2 && echo "All dir seems to exist"
        else
            echo "Please provide some file to check" >&2
        fi
    else
        echo "Please say what you want to check :) config/file syntax/alias" >&2
        return 1
        # §maybe: add a help command
    fi
}

##' check if syntax of provided file is correct
## §maybe: can acces it from outside §here
function -diraction-check-file-syntax() {
    if [[ ! -f "$1" ]];then
        echo "File-check-dir: need a file as argument : ${1:-no argument}" >&2
        return 2
    fi

    local ok=0
    cat -n $1 |  sed 's:#.*$::' | while read line; do
        local -a aline;
        set -A aline $line
        # §TODO: security, check injection pattern? : rm? \Wrm\W and issue warning (not running eval)
        # §todo: add checksum to file
        if [[  ! ("${#aline}" == 3 ||  "${#aline}" == 1 ) ]] ; then
            echo "At line ${aline[1]}, invalid number of argument: ${aline[2,-1]}"
            ok=1
        elif ! eval "echo ${aline[2,-1]} >/dev/null" 2>/dev/null  ; then
        # §todo: cekc eval?
            echo "At line ${aline[1]}, some syntax error occured ${aline[2,-1]}"
            ok=1
        fi
    done
    return $ok
}

##' check if directoryes of provided file exists
function -diraction-check-file-dir() {

    if [[ ! -f "$1" ]];then
        echo "File-check-dir: need a file as argument : ${1:-no argument}" >&2
        return 2
    fi

    local nbMiss=0

     cat -n $1 | grep '^[[:space:]]\+[[:digit:]]\+[[:space:]]\+[^#[:space:]]\+[[:space:]]\+[^#[:space:]]\+' |
    # §maybe: extract function, or just constant pattern!
    # §maybe: use a real regexp
    # will let skip quote with # inside..
    # if add a trailing $ will refuse path with space inside.
    sed 's:#.*$::' | while read line; do
        local -a aline; set -A aline $line #§check

        local var="_$aline[2]"
        local "$var"="$(eval echo ${aline[3]/\~/\$HOME})" # eval for expansion of dir
        local dir=${(P)$(echo $var)}
        if [[  ! -d "$dir" ]] ; then
            # ¤note: double quote prevent tilde from being expanded
            echo "At line ${aline[1]}, directory ${aline[3]/\$HOME/~} does not exist"
            ((++nbMiss))
            # §todo: use incr to have number of failing directory?
        fi
        # ¤note: cut sans field c'est TAB
    done
    if [[ $nbMiss -ge 0 ]];then
        echo "There is $nbMiss missing directories"
        return 1;
    else
        return 0
    fi
}

##' check syntax of config file
# §maybe swap name: config/syntax
function diraction-check-config-syntax() {
    if [[ -f ${DIRACTION_DEF_FILE} ]] ; then
        -diraction-check-file-syntax ${DIRACTION_DEF_FILE}
        return $?
    else
        echo "Config file does not exist" >&2
    fi
}
##' check directory existance of config file
function diraction-check-config-dir() {
    if [[ -f ${DIRACTION_DEF_FILE} ]] ; then
        -diraction-check-file-dir ${DIRACTION_DEF_FILE}
        return $?
    else
        echo "Config file does not exist" >&2
    fi
}

################################################################################
# ¤> Dispatch function
# ¤note: maybe add wrapping command to write the directoring going into it.
# §note: ¤doc: add how should be invocated. [maybe rather in a readme once extracted
# ¤note: as may expect, no local function (was a stupid idea)
# check dont come polute: otherwise use _diraction_functions

# §todo: refactor: file edit, and else and EVAL DIR!!!
# ¤later: check function exist: otherwise :(eval):1: command not found: nautilus
# §maybe: sed the errorto remove the eval
function _diraction-dispatch() {
    # §see: send var name or directory?
    local dir="$1" cdir="${cdir:-$PWD}"  # capture first arguments
    # cdir already defined for recursive call
    shift                                # get ride of initial args

    # ¤note: disabled checking for performance issue.
    #        assume that function that was correctly created with diraction-create

    if [[ -n "$1" ]]; then
        # capture command and shift
        local cmd="$1"
        shift # ¤note: shift take no argument
    else
        # just jump to the dir
        cd "$dir" ; return $?
    fi

    ## §todo: local eval §maybe. §see

    case "$cmd" in
        l|ls) (cd "$dir" && ls "${@[@]}") ;;
        _l|_ls) ls "$dir" $@ ;;
        t|tree) (tree "$dir" && ls "${@[@]}") ;; # §beware: command not necessary installed
        _t|_tree) tree "$dir" $@;;
        c|cd|/) # §maybe: extract diraction-jump subdir
            local sdir="$dir/$1"
            if [[ -d "$sdir" ]]; then
                cd "$sdir"
            else
                echo "$1 subdir does not exist" >&2;
                cd "$dir"
            fi ;;

        /*) local sdir="$dir$cmd"
            if [[ -d "$sdir" ]]; then
                if [[ -z "$@" ]]; then
                    cd "$sdir"
                else
                    cdir=$cdir _diraction-dispatch "$sdir" $@
                fi
            else
                echo "$cmd subdir does not exist" >&2;
                cd "$dir"
            fi ;;
        ^*|:*) local sdir="$dir/${cmd#?}"
            if [[ -d "$sdir" ]]; then
                if [[ -z "$@" ]]; then
                    cd "$sdir"
                else
                    cdir=$cdir _diraction-dispatch "$sdir" $@
                fi
            else
                echo "$cmd subdir does not exist" >&2;
                cd "$dir"
            fi ;;

        # §maybe : o, open? (wrapping with glob?)
        b|browser) $DIRACTION_BROWSER "$dir"

            # §TOFIX: BROWSER NAVIGATER bien sur. trouver bonne valeur var env, ou utiliser xdg-open
            # platform specific. §DIG (and fix personnal config)
            ;;

        lc) #§other names?
            ls "$dir" && cd "$dir" ;;
        # §maybe reverse cl: cd then ls
        o|open)
            if [[ -z "$1" ]]; then
            open "$dir"
            else
            open "$dir/$1"
            fi;;
        ed|edit)
            eval "(cd \"$dir\"  && $DIRACTION_EDITOR $@ )" # §check §now eval not necessary
            # §later: once complete and working, duplicate it to v| visual
            # §later: also for quick emacs and vim anyway : em vi
            # §so: extract a generate pattern. _diraction_edit (local functions)
            ;;
        e|"exec"|[,_-]) # ¤>> transfer commands
            # "passe plat" -> command to be executed in folder
            # originaly ':' had this behavior before being repurposed for subirectory prefix
            if [[ -z "$1" ]] ; then ; echo "$fg_bold[red]Nothing to exec!" >&2 ; return 1; fi

            eval "(cd \"$dir\" && $@)"
            # ¤note: might not be necessary to protect (self?) injection...
            # §see: var about evaluation to disable it.
            # §later: make ¤run with no evaluation!!!! [or witch ename with exec]
            # just take a string command.
        ;;

        quoted-exec|,,|--) # Quoted eval, preserve quotes passed to eval.
            eval "(cd \"$dir\" && $(print -r -- "${(q+@)@}"))"
            # -r : Ignore the escape conventions of echo.
        ;;

        # §todo:maybe extract function for the eval.. (local function, named "eval in dir"?)

        ## §todo: other (non transfert) commands?
        ## - todo? add to local todo. (fonction user?)
        ## §todo: task and write [in todo, or other file] (via touch ou cat)

        i|interactive|prompt|shell) # for a bunch of consecutive commands
            # §maybe: add other names
            echo "Entering interactive mode in $fg_bold[blue]$dir$reset_color folder:"
            # §maybe: make a recap. (C-d quit)
            # §note: exit will just exist the loop since we are in subprocess
            echo -n "$DIRACTION_INTERACTIVE_PROMPT" # §maybe: prefix by alias name!
            local icmd # to protect if similar alias
            (cd "$dir" && while read icmd; do

                    echo -n "$reset_color"
                    # §todo: check return code of eval: eval error (syntax), ou interpreted command error.

                    if [[ "$icmd" =~ ^(h|help|\\?) ]] ; then
                        # §maybe: customize some othercommand behavior:
                        echo "You are in the interactive mode of diraction
command will be perfomed in '$dir' (content is evaluated)
you can exit this mode by typing exit, or ^D"
                        else
                        eval "$icmd" |& sed 's/^(eval):1: //'
                    fi

                    # §see how * glob subtitution work.
                    # §maybe: see if could read multiple line?
                    echo -n $DIRACTION_INTERACTIVE_PROMPT
                    done)
            # §todo: color prompt + command
            # completion so over kill...
            echo "$fg_bold[red]Stop playing :)$reset_color  (back in $cdir)" # §todo: see zsh var flag for shortening
            ;;

        '?'|w|who|where)
            echo "$dir"
            ;;

        h|-h|--help|help) cat <<HELP
$fg_bold[green]This is a diraction dispatch function.$reset_color

This one is attached to the $fg_bold[blue]$dir$reset_color directory

If you provide no argument, you will jump in this directory
Otherwise it will perform some action in the context of $fg_bold[blue]$dir$reset_color:
$(for i in "${(@)_DIRACTION_HELP_SUBCOMMAND}"; do echo "- $fg_bold[blue] $i"; done | sed "s/:/ : $reset_color/")

It also accept the following commands you have whitelisted:
$fg_bold[blue]$DIRACTION_DISPATCH_WHITELIST$reset_color
HELP
                          ;;

        *) # handling the remaining
            # if command is whitelisted run it
            if [[ ${DIRACTION_DISPATCH_WHITELIST[(r)$cmd]} == $cmd ]]
                # ¤note: r flag for reverse indexing
            then
                eval "(cd \"$dir\" && $cmd $@)"
            else
                echo "$fg_bold[red]Invalid argument! <$cmd>"
                return 1
            fi;;
    esac
    # §later: for performance reason put most used first!
}

_DIRACTION_HELP_SUBCOMMAND=(
    'ls:List files in the specified folder (alias l)'
    'exec:Exec (through eval) the specified command (alias e - , _ )'
    'quoted-exec:Exec (through quotes eval) the specified command (alias -- ,, )'
    'interactive:Go in interactive mode, to perform several commands (alias i,prompt,shell)'
    '/:Go in some of the subfolder if provided (alias c cd)'
    'edit:Edit the given subfile (alias ed)'
    'browser:Launch browser on the directory (alias b)'
    'tree:Launch tree command (alias t)'
    'where:Indicate the path of attached directory (alias ?, w, who)'
)


## ¤> final configuration
if $DIRACTION_AUTO_CONFIG ;then
    diraction-load-config
fi

## ¤> Cleanup
unset -f -- -diraction-help
