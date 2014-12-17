Zsh Diractions
==============

*Doing Anything, Anywhere, from here*

<!-- TODO: make a gh-page (and absorb most of the content?) Ou soyons fou, read the doc -->

## Aim
The goal of this plugin is enable the user to perform quick actions on registered directory, `cd` into it, `ls` it, `git` it, running some command, ... *(Wait that I get a better pitch)*
§HERE

use to quick navigation, and use as shortcut in file command
all prefixed by _

map nom nemotechniques. Directory indexing. -> alias and var

Example. Suppose that I have an hypothetical XXX directory that i use a alot.


*This is just a glimpse of what you can do, more *

<!-- §todo: Add some example -->

## Warning

This is still an *inbuilding prototype*. So if you are using it by directly cloning the repo rathen than antigen, prefer the master branch.
It's working, I use it on my terminal (for a long time), but some glitch are possible, mainly with latest feature introduced. I'm using it with Zsh 5.0.2, and unaware of minimal zsh version required. (probably 4.3 at least)

**If you have any remark, refactor suggestion or you are using it and had some unexpected behavior or bug (*soooory*), just post an issue ;)**

(I'm aware of the potential security issues: zsh env/function poisoinning, and evaluated code/injections,... but it's aimed to be used only in interactive mode on your shell so as insecure as a shell bash config.
So for now, I would advise not to use it without a glance of the source)

## Usage

*Documentation in building*

###

### Use you diraction

§todo: Liste des principales commandes, argument.
Celle des passes plats.

###

### Other
<!-- Dev notes to do...
  - Définition d'alias.
  - Utilisation simple, saut var
  - Utilisation commandes

## Installation

## Configuration
<!-- Blala conf, main plus importantes -->
### Your Diractions
List of predefined diraction can be customized in two way

#### The Diraction Config file
§todo

##### Checkying the config

#### The custom hook




### Variables


## History

This plugins started out as some growing tweak in my config.
First it was named alvar. (as a compaction of alias and variable) It just created variable about to jump in some dir, and a variable to refer to the directory. Later it was extended to perform some action in these directory.
Then it was then extracted into is own repo, hence the troubled initial history.
With a new repo, he got a new name **Diractions** (*never explain an overobvious pun*),
and is growing ever since with new functionnalities.

After some fall stall, we might reach the first major version around the new year.

<!-- §TODO: contribution note -->

<!-- TODO : licence mention? -->
<!-- Maybe: add version? -->

<!-- §maybe: analytics? -->
