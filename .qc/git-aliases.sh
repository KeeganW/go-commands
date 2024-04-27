#!/bin/bash

# Git Aliases
#
# This file contains aliases for faster base git commands.

# Misc
alias gd='git diff'
alias gl='git log'
alias glol='git log --oneline'
alias gma='git merge --abort'
alias gmv='git mv'
alias gp='git pull'
alias gpu='git push'
alias gpuo='git push origin'
alias gr='git reset'
alias grh='git reset --hard'
alias grs='git reset --soft'
alias grev='git revert'
alias grl='git reflog'
alias grm='git rm'
alias gs='git status'
alias gshno='git show --name-only'

# Adding
alias ga='git add'
alias gall='git add --all'
alias gallcm='git add --all && git commit -m'
alias gac='git add --all && git commit -m'

# Branching
alias gb='git branch'
alias gbd='git branch -D'
alias gbm='git branch -m'

# Commits
alias gco='git commit'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'

# Checkout
alias gc='git checkout'
alias gcb='git checkout -b'
alias gcma='git checkout master'
alias gcmap='git checkout master && git pull'

# Cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'

# Rebase
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias grim='git rebase -i master'

# Stash
alias gap='git apply'
alias gss='git stash'
alias gsp='git stash pop'
alias gsw='git show'
alias gsh='git show'
