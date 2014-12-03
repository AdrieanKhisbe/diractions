Zsh Diractions
==============

<!-- TODO: make a gh-page -->
<!-- Maybe: add version? -->

## Warning

This is an *inbuilding prototype*. So if ever you think about using it, prefer the =master= branch, and expect to update your config. (future dev will occur in dedicated branches when "v0.1" will be released, someday :).)
Development stalled due to the end of summer...

It's working, I use it on my terminal, but it's far wrong being perfect and not yet stable. (notably about configuration)
<!-- §more  -->

**If you have any remark, refactor suggestion or else, just pose an issue ;)**
(I'm aware of the potential security issues: zsh env/function poisoinning, and evaluated code/injections,... but it's aimed to be used only in interactive mode on your shell so as insecure of bash config.
So I would advise not to use it without a glance of the source )


## Aim
The goal of this plugin is enable the user to perform quick actions on registered directory, `cd` into it, `ls` it, `git` it, running some command, ... *(Wait that I get a better pitch)*

<!-- §todo: Add some example -->

## Usage

*Documentation in building*

<!-- Dev notes to do...
  - Définition d'alias.
  - Utilisation simple, saut var
  - Utilisation commandes
  - Configuration alias. (fichier, checkying)
 -->

<!-- ## Installation: wait to see antigen install from public -->

## History

This plugins started out as some growing tweak in my config.
First it was named alvar. (as a compaction of alias and variable) It just created variable about to jump in some dir, and a variable to refer to the directory. Later it was extended to perform some action in these directory.
Then it was then extracted into is own repo, hence the troubled initial history.
With a new repo, he got a new name **Diractions** (*never explain an overobvious pun*)

<!-- TODO : licence mention? -->
