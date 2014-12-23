Zsh Diractions
==============

*Doing Anything, Anywhere, from here*

<!-- TODO: make a gh-page (and absorb most of the content?) Ou soyons fou, read the doc -->

## Aim
The goal of this plugin is *directory indexing*, map a short logical/mnemotechnical name to directory to quickly access them, or perform action in them.
Thanks to **diraction** user can perform quick actions on its registered directory, `cd` into it, `ls` it, `git` it, running some command, or refering to them in any command with short variable to denote them.

### Example:
Suppose that I have a hypothetical `favdir` and `mydir` directories that i use a alot.
Here are a simple scenario: you go in `favdir`, see what file there is then copy one in `mydir` using the variable.
Then checkying has been copied to the directory with `mydir ls`.

```sh
[~]        >> favdir
[~_favdir] >> ls
              some-file
[~_favdir] >> cp some-file $_mydir
[~_favdir] >> mydir ls
              other-file some-file
```

<!-- §todo: Add some other example, gif of example
§see: ho to do them -->

*This is just a glimpse of what you can do, if you wanna see more [scroll down a bit](#Usage)*

<!-- §see: inner link document -->

## Warning

This is still an inbuilding young plugin. So if you are using it by directly cloning the repo rather than using antigen, prefer the `master` branch.
It's working, I use it on my terminal (for a long time), but some glitches are possible, mainly with latest feature introduced. I'm using it with *Zsh* 5.0.2, and unaware of minimal zsh version required. (probably 4.3 at least)

**If you have any remark, refactor suggestion or you are using it and had some unexpected behavior or bug (*soooory*), just post an issue ;)**

(I'm aware of the potential security issues: zsh env/function poisoinning, and evaluated code/injections,... but it's aimed to be used only in interactive mode on your shell so as insecure as a shell bash config.
So for now, I would advise not to use it without a glance of the source)

The diraction aliases point to a "dispatch function" taking the attached directory as first argument. (then subcommand, and its eventual arguments)

## Usage

Here is some more in depth description about how to use *Diractions*.
*Diraction* is both a function suite, and the function aliases and vars it will create for you.

### Define your own diractions
First step is to define your *diractions*, associate name to your most used directory.

+ you simply create a new diraction with `diraction create <name> <directory>`
  - by default it will check if directory exist
  - to bypass this check use the `--ignore-missing-dir`
+ you can also create many *diractions* with the `batch-create` command. it readss STDIN (so pipe a file to it, or use here docs) which can be usefull in configs.

   ```sh
   diraction batch-create <<DIR
   dir1 /long/dir/one
   dir2 /long/dir/2
   DIR
   ```
+ You can see the existing *diraction* using `list`, `list-alias`, `list-dir` and even `grep` throught them

### Use you diraction

Now that you have a *diraction* it's time to use it. :)
Simpliest way is to just type it's name to go in the attached directory.

Here are the main commands. Commands that are executed in the context of the diraction:
- `l|ls` : just some ls
- `c|cd <subdir>` : jump in the subdirectory specified
- `ed|edit <filename>` : edit the file (being relative to the diractoin)
- `e|exec <your quoted command>` : exec the command (use single quote for the variabe to be evaluated)
- `i|interactive|prompt|shell` : to run several command in the context of the diraction directory

<!-- §todo: Celle des passes plats. -->

You can also use the diraction variable in any command. `$_mydir` will be expanded to the attached directory.

### Autres Commandes Diractions

- `disable <dirname>` : disable attached alias
- `enable <dirname>` : reenable it
- `destroy <dirname>` : destroy the alias.
- `destroy-all` : destroy all the existing diractions, need a `-f`, `--force` argument
- `reset` : destroy the diraction and reload them from the configuration

and of course, the `help` subcommand

## Installation
"Installation" is far simple, just get the file and source it.
Other wise if you use [antigen](https://github.com/zsh-users/antigen) (*which I recommend*), just add **diractions** to your bundles as `AdrieanKhisbe/diractions`

## Configuration

### Your Diractions
*Diractions* are not meant to be defined by hand each time, of course there is ways to persist your diractions.
This can be done in two way:

#### The Diraction Config file

You can store your *diraction* definition in the `DIRACTION_DEF_FILE` which is `~/.diractions` by default.
It just consist in a file having on each line two fields, the name of the diractions, then it's dir
You can put comments if you want, shell style `#`, and use environment variables `$HOME` or diractions variables `$_somepreviouslydefineddir`

Here is some sample
```sh
  # here are some diraction definition
  ssp  /some/stupid/path
  yasp "$_ssp/yet/another/stupid/path"
```

<!-- ##### Checkying the config -->
You can check your definition file is correct by using the `diraction check config` command

#### The custom hook

Another to customize diractions is to define a function named `diraction-personal-config`.

This functions is executed by the `diraction-load-config` if it exists.
Definitions in the function will take precedence

Here is some Example:

```zsh
    diraction-personal-config (){
    # put your config here
 	diraction-batch-create <<DIR
	    dir1  /my/path/number1
		yasp  /yet/another/stupid/path
    DIR
   }
```

### Customs
There is also some variables to customize the behavior of diraction to fit your needs.

Here are the main ones:
- `DIRACTION_AUTO_CONFIG` : is the config automaticaly loaded after loading of plugin, true by default
- `DIRACTION_DEF_FILE` : the name of the file containing your diraction definition
- `DIRACTION_EDITOR` : which editor command is used for the edit command
- `DIRACTION_INTERACTIVE_PROMPT` : the "prompt" for the "interactive" command

## History

This plugins started out as some growing *tweak* in my zsh personal config.
First it was named *alvar*. (as a compaction of alias and variable) It just created an alias to jump in some dir, and a variable to refer to the directory. Later it was extended to perform some action in these directories.
Then it was then extracted into is own repo, hence the troubled initial history.
With a new repo, he got a new name **Diractions** (*never explain an overobvious pun*),
and is growing ever since with new functionnalities. :)

After some fall stall, we might reach the first major version around the new year.

<!-- Maybe list of feature introduced after 1 will go there? -->

<!-- §TODO: contribution note -->

<!-- TODO : licence mention? -->
<!-- Maybe: add version? -->

<!-- §maybe: analytics? -->

### Changelog
*Coming soon*
