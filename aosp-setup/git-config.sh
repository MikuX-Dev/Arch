#!/usr/bin/env bash

read -p "Are you setting up for first time [Y/n]" ft

if [[ $ft =~ ^[yY]$ ]]; then

  echo "Setting up with .ssh"

  # Start the SSH agent and add keys
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/github_rsa
  ssh-add ~/.ssh/gitlab_rsa

  # Test SSH connections
  ssh -T git@github.com
  ssh -T git@gitlab.com

  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/config
  chmod 600 ~/.ssh/github_rsa
  chmod 644 ~/.ssh/github_rsa.pub
  chmod 600 ~/.ssh/gitlab_rsa
  chmod 644 ~/.ssh/gitlab_rsa.pub
  chmod 644 ~/.ssh/known_hosts

  # Set your global username and email
  git config --global user.name "MikuX-Dev"
  git config --global user.email "abinishanth3464@gmail.com"

  # Set default text editor (optional)
  # git config --global core.editor ""

else
  echo "Setting up without .ssh"

  # Set your global username and email
  git config --global user.name "MikuX-Dev"
  git config --global user.email "abinishanth3464@gmail.com"

  # Set default text editor (optional)
  # git config --global core.editor ""
fi

printf "\n"
echo "Done!"
