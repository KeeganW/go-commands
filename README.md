# Quick Commands

A way to quickly generate your own custom aliases to common commands you run.

## Usage

Modify a single file, `.qc/commands.json`, to add new commands. For example, if we wanted to add a quick command for `git add -A`, we could write the following in the file:

```json
{
  "name": "gall",
  "command": "git add -A"
}
```

After adding the new command, add it to your profile's alias:

```bash
./setup.sh
```

Finally, use your new command!

```bash
qc gall
```

## Advanced Usage

Obviously, the normal usage doesn't have much advantage over just writing your own aliases. You could simply add a new alias, `alias gall="git add -A"` to your profile. The only advantage here is gathering all the aliases in one place and updating them quickly, with a few bells and whistles. 

That is where the nested command structure comes in. Want to add all your git aliases under one common name? Use the `commands` marker!

```json
{
  "name": "git",
  "command": "git",
  "commands": [
    {
      "name": "aa",
      "description": "Add all modified files.",
      "command": "git add -A"
    },
    {
      "name": "c",
      "command": "git commit -m $1"
    },
    {
      "name": "fcp",
      "title": "Full Commit and Push",
      "description": "Creates a new branch with name argument 1, adds all current files, commits the files with message argument 2, and pushes the new branch.",
      "command": "git checkout -b $1 && git add -A && git commit -m $2 && git push"
    }
  ]
}
```

With this structure you can start to write more complex json to create easy to remember aliases. In the above example, we can simplify the process for doing everything needed to make a new PR: `qc git fcp test-branch "New test commit"`

## Complex Functions

Some commands are too complex to simply call from a simple file. To handle this, complex functions can be added to the `/scripts/qc-extra-functions.sh` file. These bash functions can be referenced from your json configs to make an easier time scripting complex functionality.

Here is an example of doing that:

```bash
# In /scripts/qc-functions.sh
print_something () {
  echo Hello $2
  return 5
}
```

Then in `/commands.json`
```json
{
  "name": "print",
  "command": "print_something"
}
```

## Other Configurations

If you want to change other things about how this system works, please see `/configurations.sh`.

For example, in here you can change the `QC_TRIGGER_WORD` from something other than `qc` (for example, to your company name, or `go` if you aren't a golang developer).

## Additional Notes

### Fast Setup

The longer running parts of the setup script can be skipped, which is especially useful when running the setup script multiple times in a row.

```bash
./setup.sh fast
```

### Debugging Completions
See [this link](https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reset-the-completion-cache) for cache busting in ZSH.

`rm "$ZSH_COMPDUMP" && exec zsh`

In general, it appears that when generating the latest autocomplete script, it doesn't work correctly until an arbitrary event happens. It is unclear whether it is a user edits the file, or the values are (somehow) correctly cache busted.

## Future Work

1. Make this read from a remote location, so people can share commands and aliases with each other
