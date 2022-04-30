#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2164
# shellcheck disable=SC2181
# shellcheck disable=SC2188

clear

# check for debug environment variable for this script
# set DEBUG=1 to enable debug output from library functions
if [ -n "${RUNPUBLISHCD_DEBUG}" ]; then
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

# make sure $srctdir folder exists
if [ -d "${workspacefolder}/${srcdir}" ]; then
    debugecho "            src directory: \"${workspacefolder}/${srcdir}\""
else
    debugecho "src directory: \"${workspacefolder}/${srcdir}\" does not exist"
    exit 1
fi
cd "${workspacefolder}/${srcdir}"

# remove previous publish folder if it exists
[ -d publish ] && rm -rf publish

# generate self-contained linux executable
dotnet publish \
    -c Release \
    -o ../publish/linux-x64 \
    -p:PublishReadyToRun=true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    --self-contained true \
    -p:IncludeNativeLibrariesForSelfExtract=true \
    -r:linux-x64

if [ $? -ne 0 ]; then
    echo "dotnet publish failed!"
    exit 1
fi

# generate self-contained executable
dotnet publish \
    -c Release \
    -o ../publish/win10-x64 \
    -p:PublishReadyToRun=true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    --self-contained true \
    -p:IncludeNativeLibrariesForSelfExtract=true \
    -r:win10-x64

if [ $? -ne 0 ]; then
    echo "dotnet publish failed!"
    exit 1
fi

echo " "
echo "-------------------------------------------------------------------------------"

echo "publish/ directory now contains self-contained executable for:"
echo "      Linux: publish/linux-x64/"$(getprojectname)
echo "    Windows: publish/win10-x64/"$(getprojectname)

exit 0
