#!/usr/bin/env sh

logg() {
  echo "\033[1;42m==>\033[0m $1"
}

logr() {
  echo "\033[1;33m==>\033[0m $1"
}

exit_with_msg() {
  logr "$1"
  exit 1
}

create_ssh_key() {
  logg "Creating a new SSH key, please answer all the questions."
  ssh-keygen -t rsa -C "$OWNER_EMAIL"
}

install_homebrew() {
  type brew
  if [ $? == 0 ]; then
    logg "Homebrew package manager already installed, updating..."
    brew update
  else
    logg "Installing Homebrew package manager..."
    yes '' |  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit_with_msg "Failed to install Homebrew, aborting."
  fi
}

install_homebrew_bundle() {
  brew bundle
}

set_sensible_security_defaults() {
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Please contact $OWNER_NAME at $OWNER_EMAIL if this laptop was lost."
  #TODO: enable disk encryption
}

set_custom_preferences() {
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 20
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
  sudo defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark
  dark-mode --mode Dark
  chflags nohidden ~/Library
  mkdir ~/Pictures/Screenshots
  defaults write com.apple.screencapture location ~/Pictures/Screenshots
  sudo scutil --set HostName darkstar 
}

setup_git() {
  git config --global user.name "$OWNER_NAME"
  git config --global user.email "$OWNER_EMAIL"
  git config --global color.ui true

  logg "Set the below key on github account and then test with: ssh -T git@github.com"
  cat ~/.ssh/id_rsa.pub
}

setup_java_with_jenv() {
  if [ $(grep 'jenv' ~/.zshrc | wc -l | sed 's/ //g') != '2' ]; then
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc
    jenv enable-plugin export
    source ~/.zshrc
  fi

  for i in $(du -s /Library/Java/JavaVirtualMachines/* | grep jdk | cut -f 2) ; do
    yes 'y' | jenv add $i/Contents/Home
  done
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

read -p "Please enter your name: " OWNER_NAME
read -p "Please enter your email address: " OWNER_EMAIL

create_ssh_key
install_homebrew
install_homebrew_bundle
set_sensible_security_defaults
set_custom_preferences
setup_git
setup_java_with_jenv
install_oh_my_zsh

#TODO setup dotfiles
#TODO install_last_software_updates

