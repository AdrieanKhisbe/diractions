# test script before to get crazy with the config
echo "Sourcing ZshRc"
source ~/.zshrc


echo "Launching Test"
alias shpec="${ZSH:-zsh} -c 'disable -r end; . $HOME/.antigen/bundles/rylnd/shpec/bin/shpec'" # §hack §unstable
shpec
