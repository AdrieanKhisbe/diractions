############################################################################
# DIR          #  Make some stupid pitch/quote around there               ##
#    ACTIONS   #        Doing Anything, Anywhere                          ##
############################################################################

# §TODO: HEADER §next (+licence) §now :)
# §bonux: mini stupid logo. :) (paaaneaux)
# §see: if meta data convention in zsh plugins

# §rawidea: (for a v15)  function suite?
# for create diractions new dir val?
#  alaso: delete, disable, other

# §later: some way to read config from file. (clear separation of data and function)

# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.

################################################################################
# ¤> "Alvar" diractions functions
# ¤>> Notes:
# declaration des alvar depuis fichier, chaine texte [cf antigen bundle]
# §maybe: also store in hash? (for cleanup for instance)

#------------------------------------------------------------------------------#
# ¤>> Functions
## §FIXME: Update documentation
# §todo: see convention for zsh fonction doc. (see OMZ)
##' Alias&Variable Combo function:
##' Diraction: Link a directory to create both a variable  '_$2', and a "dispatch" alias '$2'
##'  ¤note: si variable déjà définie ne sera pas surchargée
# §bonux: option pour forcer.....


function diraction(){

    # §TODO: check arguments

    local var="_$2" # name of the variable
    case $1 in

	create|new) # ¤note: name dir
	    # §maybe: extract function diraction-create to invoke directly

	    # §TODO: check if dir existe, sinon logger message.
	    # §maybe: log externaly?

	    # create variable if not already bound
	    if [ -z "${(P)var}" ] ; then
		eval "export $var=$3" # §see: keep export?
		# §readonly: probably better?
		# §later: register in hasg
	    fi
	    # ¤note: create an alias: call to the _diraction-dispach function with directory as argument
	    alias "$1"="_diraction-dispatch ${(P)var}" # §later: option to keep var or not
	    # §see: keep var or not? if yes use $var prefixed by \$
	    ;; #
	disable) disable -a $2 ;;
	enable)  enable -a $2 ;;
	destroy) unalias $2 ;;
	# §todo: check if $2. using function might be a security issue... (since can't prevent redefine)

	# §LATER: LIST! (get list of alias.) # when hash table to store them!

	*) echo "No such subcommand" >&2; return 1 ;;
	esac
}

################################################################################
# ¤> Config
# ¤>> Commands variables
# ¤node: add command variable to enable user
# _DIRACTION_EDIT §or just let them and put default in implet
#------------------------------------------------------------------------------#
# ¤>> Vars
_DIRACTION_INTERACTIVE_PROMPT="$fg[red]>> $fg[blue]"  # §todo: make it bold
# oh yes, yell like a zsh var!!

################################################################################
# ¤> Dispatch function
# ¤note: maybe add wrapping command to write the directoring going into it.
# §note: ¤doc: add how should be invocated. [maybe rather in a readme once extracted
# ¤note: as may expect, no local function (was a stupid idea)
# check b dont come polute: otherwise use _diraction_functions

# §todo: refactor: extract dir check, file edit, and else and EVAL DIR!!!
function _diraction-dispatch () {
    # §see: send var name or directory?

    local dir=$1   cdir=$PWD   # capture first arguments
    shift # get ride of initial args

    # §todo: perf -> dir checking at creation time!!
    if [[ -z "$dir" ]] || [[ ! -d "$dir" ]] ; then
	# ¤later: something if same?
	echo "Invalid usage of dispatch function: $dir is not a dir!" >&2
	# ¤note: >2 consider 2 as a file, need & to precise this is a stream
	return 1
    fi

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
## §later: do basic completion function for _diraction-dispatch
