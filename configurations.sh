#!/bin/bash
export QC_TRIGGER_WORD="qc"
export QC_GIT_USERNAME="$USER"
export QC_GIT_REMOTE="https://github.com"
export QC_CODE_ROOT="${PWD%/*}"
export QC_REPO_NAME=${PWD##*/}
export QC_REPO_NAME=${result:-/}  # to correct for the case where PWD=/
