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
# ¤> Config
# ¤>> Commands variables
#------------------------------------------------------------------------------#
# ¤>> Vars
## variable accumulating the defuns

declare -A DIRACTION_REGISTER
# §maybe: keep the disabled defuns
export DIRACTION_REGISTER_SERIALIZED

# §NOTE: Arrays are not exported :/
# http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script/5564589#5564589
#  same in zsh; http://stackoverflow.com/questions/18268083/setting-environment-variable-in-zsh-gives-number-expected
# so list only work when sourced!
# §todo: try workaround: @smoser
# §maybe use an alternative storage format? Or make it clear in the readme
# http://stackoverflow.com/questions/688849/associative-arrays-in-shell-scripts/4444841#4444841

# §TOTEST /HERE (sinon serialisation maison)
-diraction-ensure-register (){
    #  declare -A DIRACTION_REGISTER
    set --  DIRACTION_REGISTER_SERIALIZED
    unset DIRACTION_REGISTER && DIRACTION_REGISTER=( $@ )
}
-diraction-serialize-register(){
    DIRACTION_REGISTER_SERIALIZED=$(getopt --shell sh --options "" -- -- "$DIRACTION_REGISTER" )
    DIRACTION_REGISTER_SERIALIZED=${DIRACTION_REGISTER_SERIALIZED# --}
    # eval set -- "$payload"
    #   eval "unset $name && $name=("\$@")"
}
# §later: maybe disable checkying by redefined



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
-set-default DIRACTION_AUTO_CONFIG true
# §bonux: more config
# §bonux: provide documentation too! : store in an array?
unset -- -set-default

# ¤>> constants
DIRACTION_USAGE="usage: new/create <aliasname> <dir>\ndisable enable destroy <aliasname>"
# ¤note: function -set-constant wasn't working
# §later? maybe restore notion of constant?

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

    ## Ensure register is there.

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
	export $var=$(eval echo "$dir")
	# §see: keep export?
	# §readonly: probably better??
    fi
    # create an alias: call to the _diraction-dispach function with directory as argument
    alias "$alias"="_diraction-dispatch $dir" # §later: option to keep var or not
    # §see: keep var or not? if yes use $var prefixed by \$ (to enable to change target,but var consulted each time)

    ## §FIXME : adapt list
    [[ -n "$DIRACTION_REGISTER" ]] && DIRACTION_REGISTER[$alias]="$dir"
}

# ¤>> Other utils functions
##' check if alias attached to diraction
function diraction-exist {
    [[ -n "$DIRACTION_REGISTER[$1]" ]]
}

##' List existing diractions
function diraction-list {
    echo "List of diractions:"
    for a in ${(ko)DIRACTION_REGISTER}; do
	echo "$a\t -  $DIRACTION_REGISTER[$a]"
	# §TODO: indent
    done | sed "s;$HOME;~;" # waiting for regexp
    # beware separation while evaluating
}

##' list existing diraction aliases
function diraction-list-alias {
    echo ${(ko)DIRACTION_REGISTER}
}

##' list existing diraction directories
function diraction-list-dir {
    echo ${(ov)DIRACTION_REGISTER}
}

##' Grep existing diraction to find matching aliases
function diraction-grep {
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

##' grep alias to find matching alias
function diraction-grep-alias {
    if [[ $# == 0 ]]; then
	echo "Please provide something to grep it with" >&2
	return 1
    else
	# §todo: refactor using reverse indexing (302)
	echo "List of diractions alias matching '$@'"
	diraction-list-alias | grep $@
    fi
}

##' disable attached alias
function diraction-disable {
    if diraction-exist $1 ;then
	disable -a $1
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

##' reenable attached alias
function diraction-enable {
    if diraction-exist $1 ;then
	enable -a $1
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

##' destroy alias and variable
function diraction-destroy {
    if diraction-exist $1 ;then
	# §TODO check alias and provided var
	unalias $1
	unset "_$1"
	unset "DIRACTION_REGISTER[$1]"
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}

##' destroy all diraction variables
##' need -f/--force flag to perform
function diraction-destroy-all {
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

##' reset direction environment by first destroying everython then reloading config
function diraction-reset {
    echo "Reseting diraction environment"
    diraction-destroy-all -f
    diraction-load-config # load config
    #diractions.plugin.zsh
    # §maybe: for security issue. add some env flag this has been done?
}

# §TODO: diraction-dump: flux ou dir

##' print help (and banner) for diraction
function diraction-help {
    if [[ $# != 1 ]] ; then
	# §later: colors :D
	cat <<"BANNER"
      ____  _                 __  _
     / __ \(_)________ ______/ /_(_)___  ____  _____
    / / / / / ___/ __ `/ ___/ __/ / __ \/ __ \/ ___/
   / /_/ / / /  / /_/ / /__/ /_/ / /_/ / / / (__  )
  /_____/_/_/   \__,_/\___/\__/_/\____/_/ /_/____/

BANNER
	# ¤note: figlet -f slant Diractions
	# ¤note: "EOF" protect from () eval
	echo $DIRACTION_USAGE
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
    fi
}


################################################################################
# ¤> Config functions
# ¤>> Charging of personnal config

##' Load personal config of user
##' first load predefined function if exist. then load config file
function diraction-load-config {
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
function -diraction-parse-file {
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
function diraction-batch-create {
    cat -n |  sed 's:#.*$::' | sed -r 's:\s+: :g' |
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

	if [[  "${#aline}" -le 1 ]]; then
	    # next: ignore empty line
	elif [[  ! "${#aline}" == 3 ]] ; then
	    echo "At line ${aline[1]}, invalid number of argument: ${aline[2,-1]}" >&2
	    ko=true
	elif [[ $1 == "--ignore-missing-dir" ]]; then
	    diraction-create $aline[2] "$aline[3]" --ignore-missing-dir
	else
	    local dir=$(eval echo "$aline[3]")
	    if [[ -d "$dir" ]]; then
		diraction-create $aline[2] "$dir"
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

##' check if syntax of provided file is correct
## §maybe: can acces it from outside §here
function -diraction-check-file-syntax {
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
function -diraction-check-file-dir {

    if [[ ! -f "$1" ]];then
	echo "File-check-dir: need a file as argument : ${1:-no argument}" >&2
	return 2
    fi

    local ok=true

    (cat -n $1 | grep '^[[:space:]]\+[[:digit:]]\+[[:space:]]\+[^#[:space:]]\+[[:space:]]\+[^#[:space:]]\+' |
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
	    ok=false
	    # §todo: use incr to have number of failing directory?
	fi
	# ¤note: cut sans field c'est TAB
    done
)
    return $ok
}

##' check syntax of config file
# §maybe swap name: config/syntax
function diraction-check-config-syntax {
    if [[ -f ${DIRACTION_DEF_FILE} ]] ; then
	-diraction-check-file-syntax ${DIRACTION_DEF_FILE}
	return $?
    else
	echo "Config file does not exist" >&2
    fi
}
##' check directory existance of config file
function diraction-check-config-dir {
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
# new \ §todo: later when alaias
# §maybe: use a variable to hold the completion commande (or extract from a DIRACTION_CMD_HELP array!)

compdef _diraction diraction

# ¤>>
## §later: do basic completion function for _diraction-dispatch
## §think: decide or not if register completion fonction for all the diractions shortcult?

## ¤> final configuration
if $DIRACTION_AUTO_CONFIG ;then
    diraction-load-config
fi

# perfor a backup of the array in case this is not scripted
-diraction-serialize-register
echo $DIRACTION_REGISTER_SERIALIZED
