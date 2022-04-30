#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2164
# shellcheck disable=SC2181
# shellcheck disable=SC2188
# shellcheck disable=SC2034

# Runs `dotnet test` with settings to generate code coverage reports.
#
# Environment expectations:
#
# Folder Structure:
#   ${workspace}/*.sln                      --> one *.sln, your solution file for this project
#   ${workspace}/scripts/runcoverage.sh     --> This script
#   ${workspace}/src/*.csproj               --> one *.csproj, your program
#   ${workspace}/test/*.csproj              --> one *.csproj, your test suite
#
# Scripts current working directory may be different than ${workspace}:
#     ${workspace}
#     ${workspace}/src/
#     ${workspace}/test/
#     ${workspace}/scripts/

clear

# check for debug environment variable for this script
# set DEBUG=1 to enable debug output from library functions
if [ -n "${RUNCOVERAGE_DEBUG}" ]; then
    DEBUG=1
fi

# include script library
libdir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# shellcheck source=scripts/scriptlib.bash
source "${libdir}/scriptlib.bash"

# running as root will cause permission problems
donotrunasroot

# base directory must exist
workspacefolder=$(getworkspacedirectory)
if [ $? -ne 0 ]; then
    debugecho "Script can't find workspace directory!"
    exit 1
fi
[ ! -d "${workspacefolder}" ] && debugecho "Workspace directory does not exist!" && exit 1

debugecho "workspace directory: \"${workspacefolder}\""
cd "${workspacefolder}"

# make sure $testdir folder exists
if [ -d "${workspacefolder}/${testdir}" ]; then
    debugecho "           test directory: \"${workspacefolder}/${testdir}\""
else
    debugecho "test directory: \"${workspacefolder}/${testdir}\" does not exist"
    exit 1
fi
cd "${workspacefolder}/${testdir}"

# remove previous test folder if it exists
[ -d testlogs ] && rm -rf testlogs

TS=$(date +%Y%m%d-%H%M%S)

# run coverage and tests
dotnet test \
    --collect:"XPlat Code Coverage" \
    --configuration=Debug \
    --results-directory "$workspacefolder/$testdir/testlogs"

# if all tests didn't pass, then echo failed and exit, else echo passes and continue
if [[ $? -ne 0 ]]; then
    debugecho " "
    debugecho "Tests failed!"
    exit
else
    debugecho " "
    debugecho "Tests passed!"
fi

# Report goes in clean folder
[ -d "${workspacefolder}/${coveragedir}" ] && rm -rf "${workspacefolder}/${coveragedir}"
mkdir "${workspacefolder}/${coveragedir}"

# find Coverlet report file (newest XML file)
reportfile=$(find . -name "*.xml" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

debugecho "Report file: ${reportfile}"
debugecho "Basename   : ""$(basename ""${reportfile}"")"

# copy report file to clean folder
cp "${reportfile}" ${workspacefolder}/${coveragedir}/

# generate mhtml report file
reportgenerator \
    -reports:"${reportfile}" \
    -targetdir:"${workspacefolder}/${coveragedir}" \
    -reporttypes:"Html" \
    -sourcedirs:"${workspacefolder}/${srcdir}" \
    -title:"$(basename \"${workspacefolder})\"" \
    -tag:"debug version"

# archive testlog results, otherwise there will be multile coverage XML files
cd "${workspacefolder}/${testdir}/testlogs"

debugecho " "
debugecho "Archive directory is \"$(pwd)\""
zip -rum9 -xtestarchive.zip testarchive.zip *

# open coverage report
xdg-open "${workspacefolder}/${coveragedir}/index.html"

sleep 5s

exit
