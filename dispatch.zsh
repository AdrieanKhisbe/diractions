# -*- mode: sh -*-
# §TODO: HEADER
# §TODO: Creating function!! [extract from personnal config!]
# §later: some way to read config from file. (clear separation of data and function)


# §todo: function to scratch register it to a draft for intergrate then in alias_dir.

# ¤note: _dispatch is a zsh (or omz) reserved name for completion
# ¤note: function return code by specify value.


# §note: ¤doc: add how shoul be invocated.

# ¤note: maybe add wrapping command to write the directoring going into it.


# ¤> Alvar functions
# ¤>> Notes:
# §todo: create a $1 function instead of alias.
#        see what do do with arg. maybe use option switch, or rather keyword commandes
#         in a rake style. deva exec mi
# §tweak: check if file exist!
# §MAYBE: en faire un vrai plugin zsh!!! [rajouter fonctionnalité au fur et mesure]
# declaration depuis fichier, chaine texte [cf antigen bundle]
# -> bonux, a la cask ou autre. serait fonction [ou script?]
# argument, exec, ls..?? make, etc.


# §maybe: also store in hash? (for cleanup for instance)

# ¤>> function
## ¤> Alias&Variable Combo function:
##' ALVAR: crée un alias, et une variable préfixée par _
#    @$1: le nom,
#    @$2: le dossier
#  ¤note: si variable déjà définie ne sera pas surchargée
# §bonux: option pour forcer.....

	function alvar(){
	    local var="_$1"

	    # cree variable si pas déjà définie
	    # §TODO: check si dossier existe, sinon logger message.
	    # stocke dans variable, et une fonction pour afficher
	    if [ -z "${(P)var}" ] ; then
	    eval "export $var"="$2"
	    fi
	    alias "$1"="cd ${(P)var}"

	    # ¤note; proto!! [when working remove the leading ¤
	    alias "¤$1"="_alvar-dispatch ${(P)var}"
	    # §see: keep var or not? if yes use $var prefixed by \$
	}





# ¤> Dispatch function
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

	*) echo "fg[red]Invalid argument! <$cmd>"; return 1 ;;
	# §check: color don't induce space
    esac
}

_ALVAR_DISPATCH_INTERACTIVE_PROMPT="$fg[red]>> $fg[blue]"
# oh yes, yell like zsh!!
