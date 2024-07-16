# test script before to get crazy with the config
echo "Sourcing ZshRc"
source ~/.zshrc


echo "Launching Test"
alias shpec="${ZSH:-zsh} -c 'disable -r end; . $(find $(antidote home) -name shpec|grep bin)'"
shpec
