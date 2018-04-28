# Change settings
gsettings set org.cinnamon.desktop.interface clock-show-seconds true
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-X-Aqua'
gsettings set org.gnome.desktop.interface monospace-font-name 'Inconsolata Medium 10'

# Clean up fonts
echo "Xft.lcdfilter: lcddefault" > "$HOME/.Xresources"

# Install custom zsh themes and overrides
ln -s "$HOME/workspace/scripts/.oh-my-zsh/themes" "$HOME/.oh-my-zsh/custom"
ln -s "$HOME/workspace/scripts/.oh-my-zsh/plugins/pip" "$HOME/.oh-my-zsh/custom/plugins"
