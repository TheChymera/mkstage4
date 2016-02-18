#!/bin/bash

# checks if run as root:
if ! [ "`whoami`" == "root" ]
then
  echo "`basename $0`: must be root."
  exit 1
fi

#set flag variables to null
EXCLUDE_BOOT=0
EXCLUDE_CONNMAN=0
EXCLUDE_LOST=1
QUIET=0
USAGE="usage:\n\
  `basename $0` [-q -c -b] [-s || -t <target-mountpoint>] <archive-filename> [custom-tar-options]\n\
  -q: activates quiet mode (no confirmation).\n\
  -c: excludes connman network lists.\n\
  -b: excludes boot directory.\n\
  -l: includes lost+found directory.\n\
  -s: makes tarball of current system.\n\
  -t: makes tarball of system located at the <target-mountpoint>.\n\
  -h: displays help message."

# reads options:
while getopts ':t:sqcblh' flag; do
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
    l)
      EXCLUDE_LOST=0
      ;;
    h)
      echo -e "$USAGE"
      exit 0
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

if [ "$TARGET" == "" ]
then
  echo "`basename $0`: no target specified."
  echo -e "$USAGE"
  exit 1
fi

# shifts pointer to read mandatory output file specification
shift $(($OPTIND - 1))
ARCHIVE=$1

# checks for correct output file specification
if [ "$ARCHIVE" == "" ]
then
  echo "`basename $0`: no archive file name specified."
  echo -e "$USAGE"
  exit 1
fi

# checks for quiet mode (no confirmation)
if [ ${QUIET} -eq 1 ]
then
  AGREE="yes"
fi

# determines if filename was given with relative or absolute path
if [ "`echo $ARCHIVE | grep -c '^\/'`" -gt "0" ]
then
  STAGE4_FILENAME="${ARCHIVE}.tar.bz2"
else
  STAGE4_FILENAME="`pwd`/${ARCHIVE}.tar.bz2"
fi

#Shifts pointer to read custom tar options
shift;OPTIONS="$@"

# Excludes:
EXCLUDES="\
--exclude=.bash_history \
--exclude=dev/* \
--exclude=media/* \
--exclude=mnt/*/* \
--exclude=proc/* \
--exclude=run/* \
--exclude=sys/* \
--exclude=tmp/* \
--exclude=usr/portage/* \
--exclude=var/lock/* \
--exclude=var/log/* \
--exclude=var/run/*"

if [ "$TARGET" == "/" ]
then
  EXCLUDES+=" --exclude=${STAGE4_FILENAME#/}"
fi

if [ ${EXCLUDE_CONNMAN} -eq 1 ]
then
  EXCLUDES+=" --exclude=var/lib/connman/*"
fi

if [ ${EXCLUDE_BOOT} -eq 1 ]
then
  EXCLUDES+=" --exclude=boot/*"
fi

if [ ${EXCLUDE_LOST} -eq 1 ]
then
  EXCLUDES+=" --exclude=lost+found"
fi

# Generic tar options:
TAR_OPTIONS="-cjpP --ignore-failed-read -f"

# if not in quiet mode, this message will be displayed:
if [ "$AGREE" != "yes" ]
then
  echo "Are you sure that you want to make a stage 4 tarball of the system"
  echo "located under the following directory?"
  echo "$TARGET"
  echo ""
  echo "WARNING: since all data is saved by default the user should exclude all"
  echo "security- or privacy-related files and directories, which are not"
  echo "already excluded by mkstage4 options (such as -c), manually per cmdline."
  echo "example: \$ `basename $0` -s /my-backup --exclude=/etc/ssh/ssh_host*"
  echo ""
  echo "COMMAND LINE PREVIEW:"
  echo "cd $TARGET && tar $TAR_OPTIONS $STAGE4_FILENAME * $EXCLUDES $OPTIONS"
  echo ""
  echo -n "Type \"yes\" to continue or anything else to quit: "
  read AGREE
fi

# start stage4 creation:
if [ "$AGREE" == "yes" ]
then
  cd $TARGET && tar $TAR_OPTIONS $STAGE4_FILENAME * $EXCLUDES $OPTIONS
fi

exit 0
