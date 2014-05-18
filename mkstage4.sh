#!/bin/bash

# checks if run as root:
if ! [ "`whoami`" == "root" ]
then
  echo "`basename $0`: must be root."
  exit 1
fi

# reads options:
while getopts ':t:sqc' flag; do
  case "${flag}" in
    t)
      TARGET="$OPTARG"
      ;;
    s)
      TARGET="/"
      ;;
    q)
      QUIET=1
      ;;
    c)
      EXCLUDE_CONNMAN=1
      ;;
    b)
      EXCLUDE_BOOT=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# shifts pointer to read mandatory output file specification
shift $(($OPTIND - 1))
ARCHIVE=$1

# checks for correct output file specification
if [ "$ARCHIVE" == "" ]
then
  echo "`basename $0`: no archive file name specified."
  echo "syntax:"
  echo "\$ `basename $0` [-q -c -b] [-s || -t <target-mountpoint>] <archive-filename> [custom-tar-options]"
  echo "-q: activates quiet mode (no confirmation)."
  echo "-c: excludes connman network lists."
  echo "-b: excludes boot directory."
  echo "-s: makes tarball of current system."
  echo "-t: makes tarball of system located at the <target-mountpoint>."
  exit 1
fi

# checks for quiet mode (no confirmation)
if [ ${QUIET} -eq 1 ]
then
  AGREE="yes"
fi

# determines if filename was given with relative or absolute path
if [ "`echo $ARCHIVE | grep -c '\/'`" -gt "0" ] && \
[ "`echo $ARCHIVE | grep -c '^\/'`" -gt "0" ]
then
  STAGE4_FILENAME="${ARCHIVE}.tar.bz2"
else
  STAGE4_FILENAME="`pwd`/${ARCHIVE}.tar.bz2"
fi

#Shifts pointer to read custom tar options
shift;OPTIONS="$@"

# Excludes:
EXCLUDES="\
--exclude=${TARGET}proc/* \
--exclude=${TARGET}sys/* \
--exclude=${TARGET}tmp/* \
--exclude=${TARGET}mnt/*/* \
--exclude=${TARGET}var/lock/* \
--exclude=${TARGET}var/log/* \
--exclude=${TARGET}var/run/* \
--exclude=${TARGET}.bash_history \
--exclude=${TARGET}lost+found \
--exclude=${TARGET}usr/portage/*"

if [ "$TARGET" == "/" ]
then
  EXCLUDES+=" --exclude=$STAGE4_FILENAME"
fi

if [ ${EXCLUDE_CONNMAN} -eq 1 ]
then
  EXCLUDES+=" --exclude=${TARGET}var/lib/connman/*"
fi

if [ ${EXCLUDE_BOOT} -eq 1 ]
then
  EXCLUDES+=" --exclude=${TARGET}boot/*"
fi

# Generic tar options:
TAR_OPTIONS="-cjpP --ignore-failed-read -f"

# if not in quiet mode, this message will be displayed:
if [ "$AGREE" != "yes" ]
then
  echo "Are you sure that you want to make a stage 4 tarball of the system"
  echo "located under $TARGET ?"
  echo ""
  echo "!!! The option --exclude=${TARGET}mnt/*/* is not yet tested! It should"
  echo "include all the mount points, but exclude mounted data."
  echo ""
  echo "WARNING: since all data is saved by default the user should exclude all"
  echo "security- or privacy-related files and directories manually per cmdline."
  echo "example: \$ `basename $0` -s /my-backup --exclude=/etc/ssh/ssh_host*"
  echo ""
  echo -e "COMMAND LINE PREVIEW:\n\$ tar $TAR_OPTIONS $STAGE4_FILENAME $TARGET $EXCLUDES $OPTIONS"
  echo ""
  echo -n "Type \"yes\" to continue or anything else to quit: "
  read AGREE
fi

# start stage4 creation:
if [ "$AGREE" == "yes" ]
then
  tar $TAR_OPTIONS $STAGE4_FILENAME $TARGET $EXCLUDES $OPTIONS
fi

exit 0
