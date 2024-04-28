#!/bin/bash


gc_help () {
  # Starting text
  echo -e "\nUsage: GC_TRIGGER_WORD COMMAND [COMMANDS] [OPTIONS]\n\nA framework for creating go commands, shortcuts for your CLI.\n\nCommands:"

  # A helper function which displays the name and description of a given command
  gc_help_recursive_print () {
    local json="$1"
    local prefix="$2"
    local name=$(echo "$json" | jq -r '.name')
    local description=$(echo "$json" | jq -r '.description')
    if [ "$description" != "null" ]; then
      echo "$prefix$name - $description"
    else
      echo "$prefix$name"
    fi

    # Loop over all commands if they exist, calling recursively.
    echo "$json" | jq -c '.commands[]?' | while read -r child ; do
      prefix_child="$prefix  "
      gc_help_recursive_print "$child" "$prefix_child"
    done
  }

  # Loop over first order, calling recursive print
  echo "$(cat ~/.gc/commands.json)" | jq -rc '.[]' | while read -r child ; do
    gc_help_recursive_print "$child" "  "
  done
}


gc_update () {
  cd GC_CODE_ROOT
  cd GC_REPO_NAME
  git checkout master
  git pull origin master
  ./setup.sh
}


git_full_commit_push () {
  local branch=${1:-"$USER-fixes"}
  local message=${2:-"Small fixes."}
  local current_branch=$(git branch --show-current)
  local repo_name=$(basename `git rev-parse --show-toplevel`)
  git checkout -b "$branch"
  git add -A
  git commit -m "$message"
  git push --set-upstream origin "$branch"
  echo "Use the following template for your merge request:"
  echo "GC_GIT_REMOTE/GC_GIT_USERNAME/$repo_name/compare/$current_branch...$branch"
}
