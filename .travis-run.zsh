# test script before to get crazy with the config
echo "Sourcing ZshRc"
source ~/.zshrc


echo "Launching Test"
alias shpec="${ZSH:-zsh} -c 'disable -r end; . $HOME/.antigen/repos/https-COLON--SLASH--SLASH-github.com-SLASH-rylnd-SLASH-shpec.git/bin/shpec'" # §hack §unstable
shpec
