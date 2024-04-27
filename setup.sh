#!/bin/bash

# Import variables from the configurations script
source ./configurations.sh
source ./setup-extra-functions.sh

# Install the script and its components
echo "Installing scripts and their components into your home"
mkdir -p ~/.qc
cp -R .qc/ ~/.qc/

# Use configurations to make changes in code
echo "Updating scripts with your configurations"
perl -i -pe "s/qc \(\) {/$QC_TRIGGER_WORD () {/" ~/.qc/qc-core.sh
perl -i -pe "s/QC_GIT_REMOTE/${QC_GIT_REMOTE//\//\\/}/g" ~/.qc/extra-functions.sh
perl -i -pe "s/QC_GIT_USERNAME/$QC_GIT_USERNAME/g" ~/.qc/extra-functions.sh
perl -i -pe "s/QC_TRIGGER_WORD/$QC_TRIGGER_WORD/g" ~/.qc/extra-functions.sh
perl -i -pe "s/QC_CODE_ROOT/$QC_CODE_ROOT/g" ~/.qc/extra-functions.sh
perl -i -pe "s/QC_REPO_NAME/$QC_REPO_NAME/g" ~/.qc/extra-functions.sh

# Add all values in ./configurations.sh to ~/.qc/
# Save the current Internal Field Separator, and change it to newline
OLDIFS=$IFS
IFS=$'\n'
# Loop over all variables in the system.
for var in $(set)
do
  # Check if the variable starts with the prefix 'QC_'.
    if [[ $var == QC_* ]]
    then
      # Append the variable and its value to the output file.
      echo "export $var" >> ~/.qc/qc-core.sh
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

# Do custom OS setups
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
qc_autocomplete_generation

# Update man page (test if man path exists, if it does, create the directory for standard man pages, then cp file there)
echo "Generating man page"
qc_man_page_generation

echo "Copying man page"
[ -d /usr/local/share/man/ ] && mkdir -p /usr/local/share/man/man1 && cp build/$QC_TRIGGER_WORD.1 /usr/local/share/man/man1/

# Setup autocompletion content
case $SHELL in
*/zsh )
	# Setup future uses
	grep -qxF "source ~/.qc/qc-core.sh" ~/.zshrc || echo "source ~/.qc/qc-core.sh" >> ~/.zshrc

	# Setup autocompletion directory
	mkdir -p ~/.oh-my-zsh/completions
	echo "Copying autocompletion"
	cp build/_$QC_TRIGGER_WORD ~/.oh-my-zsh/completions/

	# Add autocompletion directory to your path
	grep -qxF "fpath=(~/.oh-my-zsh/completions \$fpath)" ~/.zshrc || echo "fpath=(~/.oh-my-zsh/completions \$fpath)" >> ~/.zshrc

  echo "Setup complete! Please use the following to restart your shell: exec zsh"
	;;
*/bash | */sh )
	# Setup future uses (test for bashrc vs bash_profile. See if line exists, if it doesnt, then add it)
	test -f ~/.bashrc && grep -qxF "source ~/.qc/qc-core.sh" ~/.bashrc || echo "source ~/.qc/qc-core.sh" >> ~/.bashrc
	test -f ~/.bash_profile && grep -qxF "source ~/.qc/qc-core.sh" ~/.bash_profile || echo "source ~/.qc/qc-core.sh" >> ~/.bash_profile

	# TODO: write autocompletion script using https://sourabhbajaj.com/mac-setup/BashCompletion/

  echo "Setup complete! Please use the following to restart your shell: source ~/.bashrc"
	;;
* )
	echo "You are using an unsupported shell, $SHELL. Please make an issue requesting support for setup on github!"
esac
