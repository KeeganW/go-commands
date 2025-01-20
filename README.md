# Go Commands
Welcome to Go Commands, a handy tool designed to streamline your command line experience by providing quick access to frequently used commands, shortcuts, and resources. Inspired by the simplicity and efficiency of go links, this application brings the same convenience directly to your terminal.

## Quick Start
After cloning the repo run `./setup.sh`. After restarting your terminal, you should then be able to run `go help` for more information. If you are a golang developer, you an change the trigger keyword from `go` to anything of your choice by changing `GC_TRIGGER_WORD` in `.env`, then running the setup again.

## What are Go Links?
Go links are simple shortcuts or aliases that redirect users to specific URLs. They offer a concise and memorable way to access frequently visited websites or internal resources.

## Why Go Commands?
Go Commands extends this concept to the terminal environment, allowing users to create and manage custom shortcuts for their most commonly used commands. Whether it's navigating to a frequently accessed directory, running complex scripts, or executing routine tasks, Go Commands simplifies running these things to a few short words, and makes sharing them to peers easy.

## Why Not Just Use Alias?
Aliases are powerful tools, which most people use. However, there are a few minor inconveniences:
1. Limited Portability: Shell aliases are specific to the shell environment in which they are defined. If you switch to a different shell or use multiple shells, you'll need to redefine your aliases in each environment.
2. Maintenance Overhead: Managing a large number of aliases can become cumbersome over time. As your list of shortcuts grows in your shell profile, it can become difficult to remember what they all are for, leading to potential clutter and confusion.
3. Collision Risk: Since aliases are global within the shell environment, there's a risk of accidentally overriding or conflicting with existing aliases or system commands. This can lead to unexpected behavior and errors.
4. Limited Functionality: Shell aliases are primarily used for simple text substitutions. They lack the flexibility and functionality offered by dedicated tools like Go Commands, which can handle more complex scenarios such as nested naming and custom function integration.

# Key Features
Custom Shortcuts: Create personalized aliases for commands, directories, or any CLI command you frequently use.
Grouped Shortcuts: Some shortcuts belong together (looking at you `cd home` and `cd code`). Group your shortcuts within the nested structure to simplify your command structure and improve command recollection.
Efficient Navigation: Instantly access frequently used resources without typing lengthy directory structures.
Automatic Documentation: Documentation and autocompletion scripts are automatically generated for you, making it even easier to remember those obscure shortcuts.
(Still in progress) Centralized Management: Easily manage, update, and share your go commands across multiple devices and environments.
(Still in progress) Interactive Interface: User-friendly interface for seamless interaction and configuration.
(Still in progress) Smart Dynamic Commands: In specific directories, have commands become available as needed. While working in one repo, have a set of commands quickly available which are separate from those in other directories.

# Getting Started
To get started with Go Commands, simply clone this repository and run the following:
```bash
./setup.sh
```
Once this setup is complete in your command line, you will need to reset your environment. In the last line of output from the previous command there should be a command you can run, but you can also more simply close your command line environment and re-open it. 

# Modification
Once installed, you can begin creating your own custom shortcuts and enhancing your command line workflow. To do this, make modifications to the `.commands.json` file in this repo. After making edits, repeat the [getting started](#getting-started) process.

## Adding New Commands
To add new commands, create a new json object in `.commands.json` with two fields:
```json
{
  "name": "<The name of the command you want to shortcut this by.>",
  "command": "<The actual command you want to run.>"
}
```

## Adding New Directory Commands
You may want to logically group some commands together. This can be done with the `commands` field in a go command. Here is an example:

```json
{
  "name": "cd",
  "command": "cd",
  "description": "This is a simple passthrough to the cd function. You could call `go cd ~` and it would behave just like `cd ~`.",
  "commands": [
    {
      "name": "code",
      "command": "cd $GC_CODE_ROOT",
      "description": "Navigate to the directory where you keep all of your code."
    },
    {
      "name": "gc",
      "command": "cd $GC_CODE_ROOT/go-commands",
      "description": "Navigate to the go commands directory.",
      "commands": [
        {
          "name": "core",
          "command": "cd $GC_CODE_ROOT/go-commands/.gc",
          "description": "Navigate to the go commands core files directory."
        }
      ]
    }
  ]
}
```

In the above case, we could then type `go cd gc core` to navigate to the `.gc` directory in this repository, instead of trying to remember `~/Code/go-commands/.gc`. As you can see this flexable structure allows us to create organized commands which are easier to remember than the commands the represent.

## Adding custom functions
Of course you may already have a significant amount of custom functions already written for automating your day to day life. As long as it is callable from the command line, you should be fine to add it as a new command, calling it how you would normally! If you are writing a new custom function for the first time, you can place it directly into your profile file, or in `.gc/extra-functions.sh` as well.

# Usage
Use your new commands!

```bash
go cd code
```

# Feedback
Have feedback, suggestions, or feature requests? We'd love to hear from you! Feel free to open an issue on GitHub or reach out to us directly.

# License
CommandLine Go-Links is licensed under the MIT License.

# Additional Notes

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

1. Create a github.io page, and tie to gocommands.io
2. Make this read from a remote location, so people can share commands and aliases with each other
3. Make an interface for changing commands easily (a website holding configurations that is pulled from?)
4. Smart commands: based on current directory, make certain commands come to the front and be available over others
