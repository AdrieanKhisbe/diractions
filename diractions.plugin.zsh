############################################################################
# DIR          #  Make some stupid pitch/quote around there               ##
#    ACTIONS   #        Doing Anything, Anywhere                          ##
############################################################################

# §TODO: HEADER §next (+licence) §now :)
# §bonux: mini stupid logo. :) (paaaneaux)
# §see: if meta data convention in zsh plugins

# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.

################################################################################
# ¤> "Alvar" diractions functions
# ¤>> Notes:
# §doing
# declaration des alvar depuis fichier, chaine texte [cf antigen bundle]
# §todo: also store in hash? (for cleanup for instance)



#------------------------------------------------------------------------------#
# ¤>> Functions
## §FIXME: Update documentation
# §todo: see convention for zsh fonction doc. (see OMZ)

#' Command dispatcher
function diraction(){

    if [[ $# == 0 ]]; then
        echo "Please provide a command\n${_DIRACTION_USAGE}" >&2
        return 1
    fi

    # §TODO §NOW §maybe: employ same pattern than antigen function

    local cmd=$1
    local alias="$2" # §todo: check no space

    case $cmd in
	create|new) diraction-create $alias $3 ;;
	disable) diraction-disable  $alias ;;
	enable) diraction-enable  $alias ;;
	destroy) diraction-destroy $alias ;;
	help) echo $_DIRACTION_USAGE;;
	# §LATER: LIST! (get list of alias.) # when hash table to store them!

	*) echo "No such subcommand" >&2; return 1 ;;
    esac
}

##' ¤>> Alias&Variable Combo function:
##' Diraction-create: Link a directory to create both a variable '_$1', and a "dispatch" alias '$1'
##' ¤note: si variable déjà définie ne sera pas surchargée
##' §bonux: option pour forcer.....
function diraction-create(){

    if [[ $# != 2 ]]; then
        echo "Wrong Number of arguments\ndiraction-create <alias> <dir>" >&2
        return 1
    fi

    local alias=$1
    local var="_$alias"
    local dir="$2"

    if [[ ! -d "$dir" ]]; then
        echo "diraction: $dir is not a real directory" >&2
        return 2
    fi

    # create variable if not already bound
    if [ -z "${(P)var}" ] ; then
	# ¤note: déréférencement de variable: ${(P)var}
	export $var="$dir" # §see: keep export?
	# §readonly: probably better?
	# §TODO: check expand full name
	# §later: register in hash!!
    fi
    # ¤doc: create an alias: call to the _diraction-dispach function with directory as argument
    alias "$alias"="_diraction-dispatch $dir" # §later: option to keep var or not
    # §see: keep var or not? if yes use $var prefixed by \$ (to enable to change target,but var consulted each time)
}

# ¤>> Other utils functions
function diraction-check { # exist?
    # §later: update with future index
    [[ -n $1 ]] && local var="_$1" && [[ -d ${(P)var} ]]
}

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
    else
	echo "Provided argument is not a registered diraction" >&2
	return 1
    fi
}


################################################################################
# ¤> Config
# ¤>> Commands variables
# ¤node: add command variable to enable user
# §HERE
# _DIRACTION_EDIT §or just let them and put default in implet
# _DIRACTION_DEFUNS, _DIRARATION_DEF_FILE: choix de specifier soit le fichier
# soit une liste de defun déjà défini et stockée dans var
#------------------------------------------------------------------------------#
# ¤>> Vars
# §TODO: default, so that user can customize.
# §see: edit??

_DIRACTION_INTERACTIVE_PROMPT="$fg[red]>> $fg[blue]"  # §todo: make it bold
# oh yes, yell like a zsh var!!

# ¤>> constants
readonly _DIRACTION_USAGE="usage: new/create <aliasname> <dir>\ndisable enable destroy <aliasname>"
# §maybe: dis, cause problem when resourcing file. (if not set )

################################################################################
# ¤> Dispatch function
# ¤note: maybe add wrapping command to write the directoring going into it.
# §note: ¤doc: add how should be invocated. [maybe rather in a readme once extracted
# ¤note: as may expect, no local function (was a stupid idea)
# check dont come polute: otherwise use _diraction_functions

# §todo: refactor: file edit, and else and EVAL DIR!!!
function _diraction-dispatch () {
    # §see: send var name or directory?

    local dir=$1   cdir=$PWD   # capture first arguments
    shift # get ride of initial args

    # ¤note: disabled checking for performance issue.
    #        assume that function that was correctly created with diraction-create

    if [[ -n "$1" ]]; then
	# capture command and shift
	local cmd="$1"
	shift
    else
	# just jump to the dir
	cd $dir ; return $?
    fi

    case $cmd in
	l) ls $dir;; # §maybe: add other args?
	t|tree) tree $dir;;
	c|cd) cd "$1/$3" ;;
	# §maybe find a way to do this in genereic way. (have it for git, make, and so on).

	# §maybe : o, open?
	b|browser) $BROWSER $dir

	    # §TOFIX: BROWSER NAVIGATER bien sur. trouver bonne valeur var env, ou utiliser xdg-open
	    # platform specific. §DIG (and fix personnal config)
	    ;;

	lc) #§other names?
	    ls $dir && cd $dir ;;
	# §maybe reverse cl: cd then ls
	ed|edit)
	    # §later: check files exists.
	    eval "(cd \"$dir\"  && ${_DIRSPATCH_EDITOR:-emacs -Q -nw} $@ )"
	    # §later: once complete and working, duplicate it to v| visual
	    # §later: also for quick emacs and vim anyway : em vi
	    # §so: extract a generate pattern. _diraction_edit (local functions)
	    ;;
	e|"exec")
	    if [[ -z "$1" ]] ; then ; echo "$fg[red]Nothing to exec!" >&2 ; return 1; fi

	    # §todo: see doc.
	    #¤note: shift take no argument
	    eval "(cd \"$dir\" && $@ )"
	    # §see: change directory, but not change back if failure?
	    # ¤note: might not be necessary to injection protect..... var about evaluation
	    ;;

	# §later: make ¤run with no evaluation!!!! [or reverse)
	# just take a string command.
	# how to decide name??

	## ¤>> transfer commands
	# build tools + files utils
	make|rake|sbt|gradle|git|cask|bundler| \
	    ncdu|du|nemo|nautilus|open|xdg-open|ls)
	    # ¤note: others to add
	    # ¤note: later, env var list of permitted values. [gs, etc. nom alias autorisés?]
	    # ¤later: check functione xist: otherwise :(eval):1: command not found: nautilus
	    eval "(cd \"$dir\" && $cmd $@)" ;;

	# §check; quote: protection?
	# §maybe: extract function for the eval.. (local function?)
	# eval in dir?

	# §todo: other transfer commande?
	# - todo? add to local todo. (fonction user?)
        # §todo: task and write [in todo, or other file] (via touch ou cat

	i|interactive)
	    # §maybe: add other names
	    echo "Entering interactive mode in $dir folder:"
	    echo -n "$_DIRACTION_INTERACTIVE_PROMPT"
	    (cd "$dir" && while read c; do
		    # §todo: make a recap. (C-d quit)
		    echo -n "$reset_color"
		    # §todo: check return code of eval: eval error (synctax), ou interpreted command error.
		    eval "$c" || echo "$fg[red]BE CAREFULL!, your evaluation is gonna be wrong otherwise!" >&2 # modif
		    # §maybe: laterswitch on some commands: : exit quit, to move out of dir.
		    # §protect about other alvar dispatch?: migth have to use a which a, and grep it against
		    # §see how * glob subtitution work.
		    echo -n $_DIRACTION_INTERACTIVE_PROMPT
		    done)
	    # §todo: color prompt + command
	    # completion so over kill...
	    echo "$fg[red]Stop playing :)$reset_color  (back in $cdir)" # §todo: see zsh var flag for shortening
	    # for a bunch of consecutive commands
	    ;;

	help) echo "$fg[red]Help to do" ;;
	# §TODO: USAGE to write.

	*) echo "$fg[red]Invalid argument! <$cmd>"; return 1 ;;
    esac
    # §later: for perfomance reason put most used first!

}

# ¤> Completion
# ¤>> utils diraction
compdef _diraction diraction

_diraction () {     # ¤sync
    # Setup diraction's autocompletion
    compadd  \
	create \
	new \
	disable \
	enable \
	destroy \
	help
}
compdef _diraction diraction

# ¤>>
## §later: do basic completion function for _diraction-dispatch
## §think: decide or not if register completion fonction for all the diractions shortcult?
