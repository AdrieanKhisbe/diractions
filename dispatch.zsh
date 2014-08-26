# -*- mode: sh -*-

# §todo: function to scratch register it to a draft for intergrate then in alias_dir.

# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.


# §note: ¤doc: add how shoul be invocated.

function _alvar-dispatch () {
    # §maybe: personal alias if want to use it directly?
    # §see: send var name or directory?
    if [[ -z "$1" ]] || [[ ! -d "$1" ]] ; then
	echo "Invalid usage of dispatch function: $1 is not a dir!" >&2
	# ¤note: >2 consider 2 as a file, need & to precise this is a stream
	return 1
    fi

    local dir=$1 ; local cdir=$(pwd)
    # si pas d'argument error
    # > check directory
    case $2 in
	"") cd $dir ;;
	l|ls) ls $dir;;
	t|tree) tree $dir;;
	c|cd) cd "$1/$3" ;;
	# §maybe find a way to do this in genereic way. (have it for git, make, and so on).
	e|"exec")
	    if [[ -z "$3" ]] ; then ; echo "Nothing to exec!" >&2 ; return 1; fi

	    # get ride of initial args
	    shift; shift

	    # §todo: see doc.
	    #¤note: shift take no argument
	    eval "(cd \"$dir\" && $@ )"
	    # §see: change directory, but not change back if failure?
	    # ¤note: might not be necessary to injection protect..... var about evaluation
	    ;;

	# make ¤run with no evaluation!!!! [or reverse)
	# just take a string command.
	# how to decide name??

	# §todo: other
	# - todo? add to local todo.
	# - git?
	# - make?
	# - du, ncdu..;
	# ¤note: later, env var list of permitted values. [gs, etc. nom alias autorisés?]

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

	help) echo "Help to do" ;;
	*) echo "Invalid argument! <$2>"; return 1 ;;
    esac
}

_ALVAR_DISPATCH_INTERACTIVE_PROMPT="$fg[red]>> $fg[blue]"
# oh yes, yell like zsh!!
