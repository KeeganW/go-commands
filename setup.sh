#!/bin/bash

# Check if there is an env file. If not, create it
ENV_FILE_PATH=".env"
if [ ! -f "$ENV_FILE_PATH" ]; then
  touch "$ENV_FILE_PATH"
  cat <<EOF >> $ENV_FILE_PATH
GC_TRIGGER_WORD="go"
GC_GIT_USERNAME="$USER"
GC_GIT_REMOTE="https://github.com"
GC_CODE_ROOT="${PWD%/*}"
GC_REPO_ID="KeeganW/go-commands"
GC_REPO_NAME="${PWD##*/}"
GC_REPO_NAME="${result:-/}"  # to correct for the case where PWD=/
EOF
fi

# Import variables from the configurations script
source $ENV_FILE_PATH
source ./extra-setup-functions.sh

# Install the script and its components
echo "Installing scripts and their components into your home"
mkdir -p ~/.gc
cp -R .gc/ ~/.gc/

# Use configurations to make changes in code
echo "Updating scripts with your configurations"
perl -i -pe "s/go \(\) {/$GC_TRIGGER_WORD () {/" ~/.gc/gc-core.sh
perl -i -pe "s/GC_REPO_ID/${GC_REPO_ID//\//\\/}/g" ~/.gc/extra-functions.sh
perl -i -pe "s/GC_GIT_REMOTE/${GC_GIT_REMOTE//\//\\/}/g" ~/.gc/extra-functions.sh
perl -i -pe "s/GC_GIT_USERNAME/$GC_GIT_USERNAME/g" ~/.gc/extra-functions.sh
perl -i -pe "s/GC_TRIGGER_WORD/$GC_TRIGGER_WORD/g" ~/.gc/extra-functions.sh
perl -i -pe "s/GC_CODE_ROOT/${GC_CODE_ROOT//\//\\/}/g" ~/.gc/extra-functions.sh
perl -i -pe "s/GC_REPO_NAME/${GC_REPO_NAME//\//\\/}/g" ~/.gc/extra-functions.sh

# Add all values in .env to ~/.gc/
# Save the current Internal Field Separator, and change it to newline
OLDIFS=$IFS
IFS=$'\n'
# Loop over all variables in the system.
for var in $(set)
do
  # Check if the variable starts with the prefix 'GC_'.
    if [[ $var == GC_* ]]
    then
      # Append the variable and its value to the output file.
      echo "export $var" >> ~/.gc/gc-core.sh
    fi
done
# Restore the original Internal Field Separator.
IFS=$OLDIFS

# Get the OS type the user is on
uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN:${uname_out}"
esac

# Do custom OS setups, but skip if the "fast" keyword exists
if [[ $1 != "fast" ]] ; then
  if [[ $machine == "Mac" ]] ; then
    # Update or install homebrew
    echo "Checking for homebrew..."
    which -s brew
    if [[ $? != 0 ]] ; then
      echo "Homebrew not found, installing"
      # Install Homebrew
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
      echo "Homebrew found, updating"
      brew update
    fi

    # Add jq
    echo "Installing jq"
    brew install jq
  else
    echo "Please ensure jq is installed!"
  fi
fi

mkdir -p build

# Generate the latest autocompletion file
echo "Generating autocompletion file"
gc_autocomplete_generation

# Update man page (test if man path exists, if it does, create the directory for standard man pages, then cp file there)
echo "Generating man page"
gc_man_page_generation

echo "Copying man page"
cp build/$GC_TRIGGER_WORD.1 /opt/homebrew/share/man/man1

# Setup autocompletion content
case $SHELL in
*/zsh )
	# Setup future uses
	grep -qxF "source ~/.gc/gc-core.sh" ~/.zshrc || echo "source ~/.gc/gc-core.sh" >> ~/.zshrc

	# Setup autocompletion directory
	mkdir -p ~/.oh-my-zsh/completions
	echo "Copying autocompletion"
	cp build/_$GC_TRIGGER_WORD ~/.oh-my-zsh/completions/

	# Add autocompletion directory to your path
	grep -qxF "fpath=(~/.oh-my-zsh/completions \$fpath)" ~/.zshrc || echo "fpath=(~/.oh-my-zsh/completions \$fpath)" >> ~/.zshrc

  echo "Setup complete! Please use the following to restart your shell: exec zsh"
	;;
*/bash | */sh )
	# Setup future uses (test for bashrc vs bash_profile. See if line exists, if it doesnt, then add it)
	test -f ~/.bashrc && grep -qxF "source ~/.gc/gc-core.sh" ~/.bashrc || echo "source ~/.gc/gc-core.sh" >> ~/.bashrc
	test -f ~/.bash_profile && grep -qxF "source ~/.gc/gc-core.sh" ~/.bash_profile || echo "source ~/.gc/gc-core.sh" >> ~/.bash_profile

	# TODO: write autocompletion script using https://sourabhbajaj.com/mac-setup/BashCompletion/

  echo "Setup complete! Please use the following to restart your shell: source ~/.bashrc"
	;;
* )
	echo "You are using an unsupported shell, $SHELL. Please make an issue requesting support for setup on github!"
esac
