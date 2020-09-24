#!/bin/bash
#TODO: upgrade git and use git-worktree.
set -e
shopt -s extglob

BOLD_CYAN="\033[1m\033[36m"
NORMAL="\033[0m"

echo -e "${BOLD_CYAN}Cleaning public directory${NORMAL}"
cd public
# Delete all files except .git
rm -rf ./*
rm .nojekyll
# Ensure that the current branch is master.
git reset --hard HEAD
git checkout master
# Bypassing jekyll
touch .nojekyll
cd ..

echo -e "${BOLD_CYAN}Building site${NORMAL}"
hugo

echo -e "${BOLD_CYAN}Pushing site${NORMAL}"
cd public
git add --all .
git commit -m "rebuild site"
git push origin master

cd ..
git checkout src
