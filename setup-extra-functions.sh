#!/bin/bash

# Using these for guides
# https://stackoverflow.com/questions/9000698/completion-when-program-has-sub-commands
# https://www.dolthub.com/blog/2021-11-15-zsh-completions-with-subcommands/

source ./configurations.sh

#######################################
# Generate the autocompletion file for zsh.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes to `build/_<trigger word>
#######################################
gc_autocomplete_generation () {
  FILE_WRITE="build/_$GC_TRIGGER_WORD"

  # Write starting text at the top of the file
  initial_autocomplete="#compdef $GC_TRIGGER_WORD\n"
  echo -e "$initial_autocomplete" > "$FILE_WRITE"

  #######################################
  # Save the input to file
  # Globals:
  #   None
  # Arguments:
  #   core_name - The name of the function we are writing
  #   values - The values set to add to this function
  #   sub_menus - The sub_menus we want to allow access to
  # Outputs:
  #   Writes to `build/_<trigger word>
  #######################################
  save_loop_to_file () {
    local core_name="$1"
    local values="$2"
    local sub_menus="$3"

    values_only="_$core_name() {\n  _values \"$core_name command\"$values\n}\n"
    sub_menu_with_values="_$core_name() {\n  local line state\n\n  _arguments -C \\\\\n    \"1: :->cmds\" \\\\
    \"*::arg:->args\"\n  case \"\$state\" in\n    cmds)\n      _values \"$core_name command\" $values\n      ;;
    args)\n      case \$line[1] in$sub_menus\n      esac\n      ;;\n  esac\n}\n"

    # In some cases we only want to write values, and don't care about sub menus (when there are no more commands)
    if [[ $sub_menus == "" ]]; then
      echo -e "$values_only" >> "$FILE_WRITE"
    else
      echo -e "$sub_menu_with_values" >> "$FILE_WRITE"
    fi
  }

  #######################################
  # Displays the name and description of a given command.
  # Globals:
  #   None
  # Arguments:
  #   json - The json to parse to get the command.
  # Outputs:
  #   echos a formatted value string representing the value in autocomplete readable format
  #######################################
  gc_autocomplete_generation_values () {
    local json="$1"
    local name
    name=$(echo "$json" | jq -r '.name')
    local description
    description=$(echo "$json" | jq -r '.description')

    sub_menu=$(echo "$json" | jq -c '.commands[]?')
    echo "\"${name}[${description}]\""
  }

  #######################################
  # Displays the sub command options for a given command.
  # Globals:
  #   None
  # Arguments:
  #   json - The json to parse to get the command.
  #   prefix - The prefix to put in front of the name of this command.
  # Outputs:
  #   echos a formatted value string representing the value in autocomplete readable format
  #######################################
  gc_autocomplete_generation_sub_menu () {
    local json="$1"
    local prefix="$2"
    local name
    name=$(echo "$json" | jq -r '.name')
    local description
    description=$(echo "$json" | jq -r '.description')

    sub_menu=$(echo "$json" | jq -c '.commands[]?')
    if [[ $sub_menu == "" ]]; then
      echo ""
    else
      echo -e "        $name)\n          _${prefix}_${name}\n          ;;"
    fi
  }

  #######################################
  # Get both values and nested commands, and print them to the file, for a given json blob.
  # Globals:
  #   None
  # Arguments:
  #   json - The json to parse to get the command.
  #   jq_value - The parse options to use with jq.
  #   write_name - The name of this command.
  #   prefix - The prefix to put in front of the name of this command.
  # Outputs:
  #   echos a formatted value string representing the value in autocomplete readable format
  #######################################
  gc_autocomplete_get_and_write () {
    json="$1"
    jq_value="$2"
    write_name="$3"
    write_name_prefix="$4"
    # Get all the leaves for this specific node
    all_leaf_values=""
    while IFS= read -r child
    do
      leaf_values=$(gc_autocomplete_generation_values "$child")
      if [[ $leaf_values != "" ]]; then
        all_leaf_values="$all_leaf_values \\\\\n        $leaf_values"
      fi
    done < <(echo "$json" | jq -c "$jq_value")

    # Get all the nodes under this specific node
    all_nested_values=""
    while IFS= read -r child
    do
      nested_values=$(gc_autocomplete_generation_sub_menu "$child" "$write_name_prefix")
      if [[ $nested_values != "" ]]; then
        all_nested_values="$all_nested_values\n$nested_values"
      fi
    done < <(echo "$json" | jq -c "$jq_value")

    # Save this node to the file
    if [[ $all_leaf_values != "" ]]; then
      save_loop_to_file "$write_name" "$all_leaf_values" "$all_nested_values"
    fi
  }

  #######################################
  # Recursively go through the provided json to generate the autocompletion file.
  # Globals:
  #   None
  # Arguments:
  #   json - The json to parse to get the command.
  #   prefix - The prefix to put in front of the name of this command.
  # Outputs:
  #   echos a formatted value string representing the value in autocomplete readable format
  #######################################
  gc_autocomplete_generation_recursive () {
    local json="$1"
    local prefix="$2"
    local name=$(echo "$json" | jq -r '.name')
    local description=$(echo "$json" | jq -r '.description')

    gc_autocomplete_get_and_write "$json" ".commands[]?" "${prefix}_${name}"

    # Loop over all commands if they exist, calling recursively.
    echo "$json" | jq -c '.commands[]?' | while read -r child ; do
      prefix_child="${prefix}_${name}"
      gc_autocomplete_generation_recursive "$child" "$prefix_child"
    done
  }

  gc_autocomplete_get_and_write "$(cat ~/.gc/commands.json)" ".[]" "$GC_TRIGGER_WORD" "$GC_TRIGGER_WORD"

  # Loop over first order, calling recursive print
  cat ~/.gc/commands.json | jq -rc '.[]' | while read -r child ; do
    gc_autocomplete_generation_recursive "$child" "$GC_TRIGGER_WORD"
  done

  echo -e "_$GC_TRIGGER_WORD \"\$@\"" >> "$FILE_WRITE"
}

gc_man_page_generation () {
  FILE_WRITE="build/$GC_TRIGGER_WORD.1"

  echo -e ".TH $GC_TRIGGER_WORD 1" > "$FILE_WRITE"
  {
    echo -e ".SH NAME",
    echo -e "$GC_TRIGGER_WORD \\\\- A way to quickly generate your own custom aliases to common commands you run.",
    echo -e ".SH SYNOPSIS",
    echo -e "$GC_TRIGGER_WORD COMMAND [COMMANDS] [OPTIONS]",
    echo -e ".SH DESCRIPTION",
    echo -e "$GC_TRIGGER_WORD is a framework for creating custom functions and aliases, which make it easier to remember and use commands you use every day.",
    echo -e ".SH OPTIONS"
  } >> "$FILE_WRITE"

  # A helper function which displays the name and description of a given command
  gc_help_recursive_print () {
    local json="$1"
    local prefix="$2"
    local name=$(echo "$json" | jq -r '.name')
    local description=$(echo "$json" | jq -r '.description')
    if [ "$description" != "null" ]; then
      echo "$prefix$name - $description" >> "$FILE_WRITE"
    else
      echo "$prefix$name" >> "$FILE_WRITE"
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

  {
    echo -e ".SH SEE ALSO",
    echo -e "git(1)"
    echo -e ".SH AUTHOR"
    echo -e "Keegan Williams (github.io/keeganw)"
  } >> "$FILE_WRITE"
}
