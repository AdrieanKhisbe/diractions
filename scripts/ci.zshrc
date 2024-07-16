
if [ -f ~/.antidote/antidote.zsh ]; then
     source ~/.antidote/antidote.zsh
fi
if [ -f /usr/local/opt/antidote/share/antidote/antidote.zsh ]; then
     source /usr/local/opt/antidote/share/antidote/antidote.zsh
fi

antidote bundle rylnd/shpec
