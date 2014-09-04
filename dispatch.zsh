# -*- mode: sh -*-

# §TODO: HEADER §next
# §maybe: rename to dirspatch?
# §later: some way to read config from file. (clear separation of data and function)

# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.




# ¤> Alvar functions
# ¤>> Notes:
# §MAYBE: en faire un vrai plugin zsh!!! [rajouter fonctionnalité au fur et mesure]
# declaration depuis fichier, chaine texte [cf antigen bundle]

# §maybe: also store in hash? (for cleanup for instance)

# ¤>> function
## ¤> Alias&Variable Combo function:
##' ALVAR: Link a directory to create both a variable  '_$2', and a "dispatch" alias '$2'

#  ¤note: si variable déjà définie ne sera pas surchargée
# §bonux: option pour forcer.....

function alvar(){
    local var="_$1" # name of the variable

    # §TODO: check if dir existe, sinon logger message.
    # §maybe log externaly?

    # create variable if not already bound
    if [ -z "${(P)var}" ] ; then
	eval "export $var=$2" # §see: keep export?
    fi

    # create an alias: call to the _alvar-dispach function with directory as argument
    alias "$1"="_alvar-dispatch ${(P)var}"
    # §see: keep var or not? if yes use $var prefixed by \$
}

# ¤> Config
# §see: what prefix? _DIRSPATCH
# ¤>> commands variables
# ¤node: add command variable to enable user
# _DIRSPATCH_EDIT §or just let them and put default in implet
# ¤>> Vars
_ALVAR_DISPATCH_INTERACTIVE_PROMPT="$fg[red]>> $fg[blue]"
# oh yes, yell like zsh!!
# §later: colors

# ¤> Dispatch function
# ¤note: maybe add wrapping command to write the directoring going into it.
# §note: ¤doc: add how should be invocated. [maybe rather in a readme once extracted
function _alvar-dispatch () {
    # §maybe: personal alias if want to use it directly?
    # §see: send var name or directory?
    if [[ -z "$1" ]] || [[ ! -d "$1" ]] ; then
	echo "Invalid usage of dispatch function: $1 is not a dir!" >&2
	# ¤note: >2 consider 2 as a file, need & to precise this is a stream
	return 1
    fi

    local dir=$1
    local cdir=$(pwd)
    local cmd=$2
    shift; shift # get ride of initial args

    # si pas d'argument error
    # > check directory
    case $cmd in
	"") cd $dir ;;
	l) ls $dir;;
	t|tree) tree $dir;;
	c|cd) cd "$1/$3" ;;
	# §maybe find a way to do this in genereic way. (have it for git, make, and so on).

	# §maybe : o, open?
	b|browser) $BROWSER $dir
	    # §TOFIx: BROWSER NAVIGATER bien sur. trouver bonne valeur var env, ou utiliser xdg-open
	    # platform specific. §DIg (and fix personnal config)

	    # §todo: task and write [in todo, or other file]
	    ;;

	ed|edit)
	    # §later: check files exists.
	    eval "(cd \"$dir\"  && ${_DIRSPATCH_EDITOR:-emacs -Q -nw} $@ )"
	    # §later: once complete and working, duplicate it to v| visual
	    # §later: also for quick emacs and vim anyway : em vi
	    # §so: extract a generate pattern. _alvar_edit (local functions)
	    ;;
	e|"exec")
	    if [[ -z "$1" ]] ; then ; echo "$fg[red]Nothing to exec!" >&2 ; return 1; fi

	    # §todo: see doc.
	    #¤note: shift take no argument
	    eval "(cd \"$dir\" && $@ )"
	    # §see: change directory, but not change back if failure?
	    # ¤note: might not be necessary to injection protect..... var about evaluation
	    ;;

	# make ¤run with no evaluation!!!! [or reverse)
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
	# maybe extract function for the eval.. (local function?)

	# §todo: other
	# - todo? add to local todo.
	# - du, ncdu..;


	i|interactive)
	    # §maybe: add other names
	    echo "Entering interactive mode in $dir folder:"
	    echo -n "$_ALVAR_DISPATCH_INTERACTIVE_PROMPT" # §todo: make it bold
	    (cd "$dir" && while read c; do
		    echo -n "$reset_color"
		    eval "$c" || echo "$fg[red]BE CAREFULL!, your evaluation is gonna be wrong otherwise!" >&2
		    # §maybe: laterswitch on some commands: : exit quit, to move out of dir.
		    # §protect about other alvar dispatch?: migth have to use a which a, and grep it against
		    # §see how * glob subtitution work.
		    echo -n $_ALVAR_DISPATCH_INTERACTIVE_PROMPT
		    done)
	    # §todo: color prompt + command
	    # completion so over kill...
	    echo "$fg[red]Stop playing :)$reset_color  (back in $cdir)" # §todo: see zsh var flag for shortening
	    # for a bunch of consecutive commands
	    ;;

	help) echo "$fg[red]Help to do" ;;
	# §TODO: USAGE to write.

	*) echo "$fg[red]Invalid argument! <$cmd>"; return 1 ;;
	# §check: color don't induce space
    esac
}


# ¤> Completion
## §later: do basic completion function for _alvar-dispatch
