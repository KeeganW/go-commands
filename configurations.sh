#!/bin/bash
export GC_TRIGGER_WORD="go"
export GC_GIT_USERNAME="$USER"
export GC_GIT_REMOTE="https://github.com"
export GC_CODE_ROOT="${PWD%/*}"
export GC_REPO_ID="KeeganW/go-commands"
export GC_REPO_NAME="${PWD##*/}"
export GC_REPO_NAME="${result:-/}"  # to correct for the case where PWD=/
