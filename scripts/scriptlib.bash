#!/bin/bash
# shellcheck disable=SC2034

# Copyright 2022 © Dan Melton, aka VXDguy.  All rights reserved.
# Licensed under GNU General Public License version 3.0, which
# is available at https://www.gnu.org/licenses/gpl-3.0.en.html
# as well as the full license text at LICENSE.md distributed with
# this software.

# scriptlib.bash: helper library of common functions for "C# Template"

# global variables

# subdirectory array and shortcuts
# subdir[0] is project source
# subdir[1] is test source
# subdir[2] is output folder for coverage report
declare -a subdir=("src" "test" "coverage")

# shortcuts
srcdir=${subdir[0]}
testdir=${subdir[1]}
coveragedir=${subdir[2]}

donotrunasroot() {
    userid=$(id -u)
    if [ "${userid}" -eq 0 ]; then
        echo "Do not run this script as root."
        exit 1
    fi
    return 0
}

debugecho() {
    local red=$(tput setaf 1)
    local clear=$(tput sgr0)
    if [ -z "${DEBUG}" ]; then
        return 0
    fi

    echo -e $red"DEBUG: $*"$clear >&2
}

getworkspacedirectory() {
    # full path of current directory
    local currentdir=""
    local upperdir=""
    local projectdir=""

    currentdir=$(realpath .)
    debugecho "Realpath if current directory: \"${currentdir}\""

    upperdir=$(dirname "${currentdir}")

    # get to project directory, project direct has "src" subdirectory
    [ -d "${srcdir}" ] && projectdir="${currentdir}"
    [ -z "${projectdir}" ] && [ -d "${upperdir}/${srcdir}" ] && projectdir=${upperdir}

    # echo "Project directory: ${projectdir}"
    echo "${projectdir}"

    # set exit code
    [ -d "${projectdir}"/"${srcdir}" ] && return 0

    debugecho "Marker for workspace doesn't exist!"
    debugecho "${projectdir}"/"${srcdir}"
    debugecho "Script can't find workspace directory!"
    exit 1

}

getprojectname() {
    pushd $(getworkspacedirectory)/src >/dev/null
    if [ $? -ne 0 ]; then
        debugecho "pushd failed trying to change to $(getworkspacedirectory)/src)"
        return 1
    fi
    ls -b *.csproj | grep -o '^[^.]*'
    popd >/dev/null
    return 0
}
