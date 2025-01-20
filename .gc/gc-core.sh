#!/bin/bash

# GC Core
#
# This file holds the core logic in calculating what command the user is actually trying to use, using the
# base-commands.json file. We loop over their inputs finding the best match, then actually execute that match.

# Here we source all of the relevant functions that have been written
source ~/.gc/git-aliases.sh
source ~/.gc/extra-functions.sh

gc_check_gc_version () {
  curl_response=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$GC_REPO_ID/branches/master)
  remote_master_sha=$(echo "$curl_response" | jq -r '.commit.sha | .[:8]')
  local_master_sha=$(git rev-parse master | cut -c 1-8)

  # Ensure that we actually got a response. If not, then we just ignore it.
  if [ "$remote_master_sha" != "null" ]; then
      if [ "$local_master_sha" != "$remote_master_sha" ]; then
        echo "There have been updates to quick-commands, please run 'gc update'"
      fi
  fi
}

go () {
  # Check to see if we have the most recent version available
  gc_check_gc_version

  # Function to search for matching objects recursively
  search_objects() {
    local json="$1"
    local arg="$2"
    local result=$(echo "$json" | jq -r "select(type == \"array\") | .[] | select(.name == \"$arg\")")
    echo "$result"
  }

  best_command=""
  found_args=""
  current_json="$(cat ~/.gc/commands.json)"
  for arg in "$@"; do
    # Call the recursive function to search for matching objects
    matching_objects=$(search_objects "$current_json" "$arg")

    # Handle any matching objects
    if [ -n "$matching_objects" ]; then
      # echo -e "Matching objects for arg '$arg':\n$matching_objects"

      # Save the command, as it is the best we have so far
      best_command=$matching_objects
      found_args="$found_args$arg > "

      # Update the new json to search for the next arg
      current_json=$(echo "$matching_objects" | jq -r '.commands?')
    else
      # No matching objects, so stop trying to loop through. Maybe was arg?
      # TODO maybe we can use best_command and args to figure out if we are exiting incorrectly or not
      # echo "No matching objects found for arg '$arg'"
      break
    fi
  done

  # -r flag removes double quotes by using raw mode
  full_command=$(echo "$best_command" | jq -r ".command")

  # Actually run the command
  echo "running $full_command..."
  if [ "$full_command" != "null" ]; then
    eval "$full_command"
  else
    echo "No 'command' defined on '${found_args%???}'."
  fi
}

# Uncomment below to enable calling this file directly for testing.
# Call it by `sh .gc/.gc-code.sh <commands>`
go "${@:1}"
