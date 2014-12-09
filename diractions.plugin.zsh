############################################################################
# DIR          #  Doing Anything, Anywhere                                ##
#    ACTIONS   #                           From there                     ##
############################################################################

# Diractions: Doing Anything, Anywhere, from here
# Author: Adriean Khisbe
# Homepage: http://github.com/AdrieanKhisbe/diractions
# License: MIT License<Adriean.Khisbe@live.fr

# §bonux: mini stupid logo. :) (paaaneaux)

################################################################################
# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.

# §SEE: WERE TO PUT UTILS FUCTION? TOP OR BOTTOM?
# §TODO: Check dependancy handling


################################################################################
# ¤> "Alvar" diractions functions
# ¤>> Notes:

#------------------------------------------------------------------------------#
# ¤>> Functions
## §FIXME: Update documentation
# §todo: see convention for zsh fonction doc. (see OMZ)

##' Command dispatcher
##' ¤note: inspired from Antigen Shrikant Sharat Kandula
function diraction(){

    if [[ $# == 0 ]]; then
        echo "Please provide a command\n${DIRACTION_USAGE}" >&2
        return 1
    fi
    local cmd=$1
    shift

    if functions "diraction-$cmd" > /dev/null; then
	# ¤note: functions print all function or specified one
        "diraction-$cmd" "$@"
    else
	 echo "No such subcommand\n${DIRACTION_USAGE}" >&2;
	 return 1
    fi
}



##' ¤>> Alias&Variable Combo function:
##' Diraction-create: Link a directory to create both a variable '_$1', and a "dispatch" alias '$1'
##' ¤note: si variable déjà définie ne sera pas surchargée
##' §bonux: option pour forcer..... --ignore-missing-dir
## §TODO: HERE would need to refactor to handle option if want to place if in the end
function diraction-create(){

    if [[ $# -lt 2 ]]; then
        echo "Wrong Number of arguments\ndiraction-create <alias> <dir>" >&2
        return 1
    fi

    local alias=$1
    local var="_$alias"
    local dir="$2"

    if [[ "--ignore-missing-dir" != "$3" ]] && [[ ! -d "$dir" ]]; then
        echo "diraction: $dir is not a real directory ($var)
you can force creation adding --ignore-missing-dir flag" >&2
        return 2
	# §maybe: log dir is missing. count numb of miss
    fi

    # create variable if not already bound
    if [ -z "${(P)var}" ] ; then
	# ¤note: déréférencement de variable: ${(P)var}
	export $var="$dir" # §see: keep export?
	# §readonly: probably better?
	# §TODO: check expand full name
	# §later: register in hash!!
    fi
    # create an alias: call to the _diraction-dispach function with directory as argument
    alias "$alias"="_diraction-dispatch $dir" # §later: option to keep var or not
    # §see: keep var or not? if yes use $var prefixed by \$ (to enable to change target,but var consulted each time)

    # register the variable
    DIRACTION_DEFUNS[$alias]="$dir"
}

# ¤>> Other utils functions
function diraction-check { # exist?
    # §later: update with future index
    [[ -n $1 ]] && local var="_$1" && [[ -d ${(P)var} ]]
}

function diraction-list {
    echo "List of diractions:"
    for a in ${(ko)DIRACTION_DEFUNS}; do
	echo "$a\t -  $DIRACTION_DEFUNS[$a]"
	# §TODO: indent
	# §TODO: Replace /home/$USER by ~
    done | sed "s;$HOME;~;" # waiting for regexp
    # beware separation while evaluating
}

function diraction-list-alias {
    echo ${(ko)DIRACTION_DEFUNS}
}
function diraction-list-dir {
    echo ${(ov)DIRACTION_DEFUNS}
}

function diraction-grep {
    if [[ $# == 0 ]]; then
	echo "Please provide something to grep it with" >&2
	return 1
    else
	echo "List of diractions: matching '$@'"
	for a in ${(ko)DIRACTION_DEFUNS}; do
	    echo "$a\t -  $DIRACTION_DEFUNS[$a]"
	    # §TODO: indent
	done | grep $@
    fi
}

##' grep alias to find matching alias
function diraction-grep-alias {
    if [[ $# == 0 ]]; then
	echo "Please provide something to grep it with" >&2
	return 1
    else
	echo "List of diractions alias matching '$@'"
	diraction-list-alias | grep $@
    fi
}

# §TODO: SETUP + SETUP
# §call to config + flag

##' disable attached alias
function diraction-disable {
    if diraction-check $1 ;then
	disable -a $1
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

##' reenable attached alias
function diraction-enable {
    if diraction-check $1 ;then
	enable -a $1
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

##' destroy alias and variable
function diraction-destroy {
    if diraction-check $1 ;then
	# §TODO check alias and provided var
	unalias $1
	unset "_$1"
	unset "DIRACTION_DEFUNS[$1]"
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

function diraction-destroy-all {
    if [[ "-f" == $1  ]] || [[ "--force" == $1  ]]
    then
	for a in ${(k)DIRACTION_DEFUNS}; do
	    diraction-destroy $a
	done
    else
	echo "If you wanna really destroy all diraction add the -f/--force flag" >&2
	return 1
    fi
}

function diraction-reset {
    echo "Reseting diraction environment"
    diraction-destroy-all -f
    -diraction-config # load config
    #diractions.plugin.zsh
    # §maybe: for security issue. add some env flag this has been done?
}

function diraction-help {
    if [[ $# != 1 ]] ; then
	echo $DIRACTION_USAGE
    else
	if diraction-check $1 ;then
	    "$1 diraction is bound to ${DIRACTION_DEFUNS[$1]} the directory"
	else
	    cat <<EOF
There is no diraction named $1
For more help about diraction please run 'diraction help'.
EOF
	fi
	# §MAYBE: rather make a doc about existing commands?
    fi
}

################################################################################
# ¤> Config
# ¤>> Commands variables
#------------------------------------------------------------------------------#
# ¤>> Vars
## variable accumulating the defuns
declare -A DIRACTION_DEFUNS # §todo: change
# §maybe: keep the disabled defuns

# soit une liste de defun déjà défini et stockée dans var
-set-default () {
    # ¤note: from antigen
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
    # §see: make it not exportable?
}

-set-default DIRACTION_INTERACTIVE_PROMPT "$fg[red]>> $fg[blue]"  # §todo: make it bold
# oh yes, yell like a zsh var!!
-set-default DIRACTION_EDITOR ${EDITOR:-vi}
-set-default DIRACTION_DEF_FILE "$HOME/.diractions" # §TODO: choix de specifier soit le fichier
# système à réaliser!
-set-default DIRACTION_BROWSER # §todo: update
# §bonux: more config
# §bonux: provide documentation too!
unset -- -set-default

# ¤>> constants
# §todo: same util func
-set-constant () {
    eval "test -z \"\$$1\" && readonly $1='$2'"
}

-set-constant DIRACTION_USAGE "usage: new/create <aliasname> <dir>\ndisable enable destroy <aliasname>"
# §MORE?
unset -- -set-constant

# ¤>> Charging of personnal config

#
function -diraction-config {
    ## two options, function or file.
    ## load both, function taking precedence

    # Load personal function if existing
    # §todo: doc
    if functions "diraction-personal-config" > /dev/null; then
	# §later: add security about function content?
	# §maybe: set the name of the function as a custom variable
	#  "$(functions diraction-personal-config | grep "^[[:space:]]*diraction-")"
	diraction-personal-config
    fi

    if [[ -f "$DIRACTION_DEF_FILE" ]] && ! -diraction-parse-file "$DIRACTION_DEF_FILE" ; then
	echo "Error while parsing $DIRACTION_DEF_FILE, please it has check correct syntax" >&2
	return 1
    fi
}

##' parse file as diraction definition
function -diraction-parse-file {
    if [[ ! -f "$1" ]]
    then
	echo 'diraction parse file need to be given a file!' >&2
	return 2;
    else
	cat $1 | sed 's/~/$HOME/' | diraction-batch-create --ignore-missing-dir
	return $?
    fi
}

##' function to create a set of batch definition from sdin
function diraction-batch-create {
    grep '^[[:space:]]*[^[:space:]#]' |
    # kill comment for the eval
    sed 's:#.*$::' | while read line; do
	# §maybe: add check only two elem by ligne
        # Using `eval` so that we can use the shell-style quoting in each line
        # piped to `antigen-bundles`.   ¤note: inspired form antigen

	# §HERE maybe capture line, and check just two elem.
        local fail=$(eval "diraction-create $line $1") # §transfer ignore arg
	if $fail ; then return $fail ; fi
    done
    # §FIXME: will complain if folder does  not exist when created!
    # §todo add a bypass to create!?
}

## §TODO: CHECK FUNCTION. status, to have config file

################################################################################
# ¤> Dispatch function
# ¤note: maybe add wrapping command to write the directoring going into it.
# §note: ¤doc: add how should be invocated. [maybe rather in a readme once extracted
# ¤note: as may expect, no local function (was a stupid idea)
# check dont come polute: otherwise use _diraction_functions

# §todo: refactor: file edit, and else and EVAL DIR!!!
function _diraction-dispatch () {
    # §see: send var name or directory?

    local dir=$1 cdir=$PWD  # capture first arguments
    shift                   # get ride of initial args


    # ¤note: disabled checking for performance issue.
    #        assume that function that was correctly created with diraction-create

    if [[ -n "$1" ]]; then
	# capture command and shift
	local cmd="$1"
	shift # ¤note: shift take no argument
    else
	# just jump to the dir
	cd $dir ; return $?
    fi

    ## §todo: local eval §maybe. §see

    case $cmd in
	l) ls $dir;; # §maybe: add other args?
	t|tree) tree $dir;;
	c|cd) cd "$1/$3" ;;
	# §maybe find a way to do this in genereic way. (have it for git, make, and so on).

	# §maybe : o, open? (wrapping with glob?)
	b|browser) $DIRACTION_BROWSER $dir

	    # §TOFIX: BROWSER NAVIGATER bien sur. trouver bonne valeur var env, ou utiliser xdg-open
	    # platform specific. §DIG (and fix personnal config)
	    ;;

	lc) #§other names?
	    ls $dir && cd $dir ;;
	# §maybe reverse cl: cd then ls
	ed|edit)
	    # §later: check files exists.
	    eval "(cd \"$dir\"  && $DIRACTION_EDITOR $@ )"
	    # §later: once complete and working, duplicate it to v| visual
	    # §later: also for quick emacs and vim anyway : em vi
	    # §so: extract a generate pattern. _diraction_edit (local functions)
	    ;;
	e|"exec")
	    if [[ -z "$1" ]] ; then ; echo "$fg[red]Nothing to exec!" >&2 ; return 1; fi
	    eval "(cd \"$dir\" && $@ )"
	    # ¤note: might not be necessary to protect injection.....
	    # §see: var about evaluation to disable it.
	    ;;

	# §later: make ¤run with no evaluation!!!! [or witch ename with exec]
	# just take a string command.

	## ¤>> transfer commands
	# build tools + files utils
	make|rake|sbt|gradle|git|cask|bundler| \
	    ncdu|du|nemo|nautilus|open|xdg-open|ls)
	    # ¤note: others to add
	    # ¤note: later, env var list of permitted values. [gs, etc. nom alias autorisés?]
	    # §idea: extract to the "*)" pattern and perfom a list match with list
	    # ¤later: check function exist: otherwise :(eval):1: command not found: nautilus
	    eval "(cd \"$dir\" && $cmd $@)" ;;

	# §check; quote: protection?
	# §todoNOW: extract function for the eval.. (local function?)
	# eval in dir?

	## §todo: other (non transfert) commands?
	## - todo? add to local todo. (fonction user?)
        ## §todo: task and write [in todo, or other file] (via touch ou cat)

	i|interactive|prompt|shell)
	     # for a bunch of consecutive commands
	    # §maybe: add other names
	    echo "Entering interactive mode in $dir folder:"
	    # §maybe: make a recap. (C-d quit)
	    # §note: exit will just exist the loop since we are in subprocess
	    echo -n "$DIRACTION_INTERACTIVE_PROMPT" # §maybe: prefix by alias name!
	    local icmd # to protect if similar alias
	    (cd "$dir" && while read icmd; do

		    echo -n "$reset_color"
		    # §todo: check return code of eval: eval error (synctax), ou interpreted command error.
		    eval "$icmd"

		    # §maybe: customize some command behavior: ? q ?
		    # §see how * glob subtitution work.
		    echo -n $DIRACTION_INTERACTIVE_PROMPT
		    done)
	    # §todo: color prompt + command
	    # completion so over kill...
	    echo "$fg[red]Stop playing :)$reset_color  (back in $cdir)" # §todo: see zsh var flag for shortening

	    ;;

	help) echo "$fg[green]This is a diraction dispatch function.

This one is attached to the $dir directory
If you provide no argument, you will jump in the associated directory
Oherwise it will perform some action in the context of the directory

For instance with l or ls it will list file inside.
With e/exec you will perform a command in the context of the directory
If you have a set of command to to, you can use the i/interactive subcommand
"
	    # §TODO: more DOC (editor, and so on)
	    # §bonux: more precise about targeted command (help)
	    ;;

	# default
	*)  echo "$fg[red]Invalid argument! <$cmd>"; return 1 ;;
	# §todo : transwwer allowed command!
    esac
    # §later: for performance reason put most used first!

}

################################################################################
# ¤> Completion
# ¤>> utils diraction
compdef _diraction diraction

_diraction () {     # ¤sync
    # Setup diraction's autocompletion
    compadd  \
	create \
	disable enable \
	destroy destory-all reset \
	list list-alias list-dir \
	grep grep-alias \
	help
}
	# new \ §later when alaias
compdef _diraction diraction

# ¤>>
## §later: do basic completion function for _diraction-dispatch
## §think: decide or not if register completion fonction for all the diractions shortcult?


## ¤> final configuration
-diraction-config # load config
