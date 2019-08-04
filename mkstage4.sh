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
EXCLUDE_LOST=0
QUIET=0
USER_EXCL=""
S_KERNEL=0
x86_64=0
PARALLEL=0
HAS_PORTAGEQ=0

# Excludes - whitespace delimited list of things to leave out
EXCLUDES_LIST="
 home/*/.bash_history\
 dev\
 var/tmp\
 media\
 mnt\
 proc\
 run\
 sys\
 tmp\
 var/lock\
 var/log\
 var/run\
 var/lib/docker"

EXCLUDES_LIST_PORTAGE="
 var/db/repos/gentoo/*\
 usr/portage*\
 var/cache/distfiles/*"
 
# Excludes function - create tar --exclude=foo options
exclude()
{
  ADDEXCLUDE=$(echo "$1" | sed 's/^\///')
  EXCLUDES+=" --exclude=${TARGET}${ADDEXCLUDE}"
}

# Check if portageq is available
if [ `which portageq` ]
then
	HAS_PORTAGEQ=1
fi

if [ `getconf LONG_BIT` = "64" ]
then
    x86_64=1
fi
USAGE="usage:\n\
  `basename $0` [-q -c -b -l -k -p] [-s || -t <target-mountpoint>] [-e <additional excludes dir*>] <archive-filename> [custom-tar-options]\n\
  -q: activates quiet mode (no confirmation).\n\
  -c: excludes connman network lists.\n\
  -b: excludes boot directory.\n\
  -l: excludes lost+found directory.\n\
  -p: compresses parallelly using pbzip2.\n\
  -e: an additional excludes directory (one dir one -e, donot use it with *).\n\
  -s: makes tarball of current system.\n\
  -k: separately save current kernel modules and src (smaller & save decompression time).\n\
  -t: makes tarball of system located at the <target-mountpoint>.\n\
  -h: displays help message."

# reads options:
while getopts ':t:e:skqcblph' flag; do
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
    k)
      S_KERNEL=1
      ;;
    c)
      EXCLUDE_CONNMAN=1
      ;;
    b)
      EXCLUDE_BOOT=1
      ;;
    l)
      EXCLUDE_LOST=1
      ;;
    e)
      USER_EXCL+=" --exclude=${OPTARG}"
      ;;
    p)
      PARALLEL=1
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

# make sure TARGET path ends with slash
if [ "`echo $TARGET | grep -c '\/$'`" -le "0" ]
then
  TARGET="${TARGET}/"
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

if [ ${S_KERNEL} -eq 1 ]
then
  EXCLUDES_LIST+=" usr/src/*"
  if [ ${x86_64} -eq 1 ]
  then
      EXCLUDES_LIST+=" lib64/modules/*"
  else
      EXCLUDES_LIST+=" lib/modules/*"
  fi
fi


EXCLUDES+=$USER_EXCL

# Exclude backup archive file name
# Exclude portage repository and distfiles by portageq info
# Revert to default, if portageq is not available or backup source is not host system
if [ "$TARGET" == "/" ]
then
  EXCLUDES_LIST+=" ${STAGE4_FILENAME#/}"
  if [ ${HAS_PORTAGEQ} == 1 ]
  then
	  EXCLUDES_LIST+=" $(portageq get_repo_path / gentoo)"
	  EXCLUDES_LIST+=" $(portageq distdir)"
  else
	  EXCLUDES_LIST+="${EXCLUDES_LIST_PORTAGE}"
  fi
else
  EXCLUDES_LIST+="${EXCLUDES_LIST_PORTAGE}"
fi

if [ ${EXCLUDE_CONNMAN} -eq 1 ]
then
  EXCLUDES_LIST+=" var/lib/connman/*"
fi

if [ ${EXCLUDE_BOOT} -eq 1 ]
then
  EXCLUDES_LIST+=" boot/*"
fi

if [ ${EXCLUDE_LOST} -eq 1 ]
then
  EXCLUDES_LIST+=" lost+found"
fi

# Generic tar options:
TAR_OPTIONS="-cpP --ignore-failed-read --xattrs-include='*.*' --numeric-owner"

if [ ${PARALLEL} -eq 1 ] 
then
  if hash pbzip2 2>/dev/null; then
    TAR_OPTIONS+=" --use-compress-prog=pbzip2"
  else
    echo "WARING: pbzip2 isn't installed, single-threaded compressing is used."
    TAR_OPTIONS+=" -j"
  fi
else
  TAR_OPTIONS+=" -j"
fi

# Loop through the final excludes list, before starting
for i in ${EXCLUDES_LIST[@]}
do
	exclude "$i"
done

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
  echo "tar $TAR_OPTIONS $EXCLUDES $OPTIONS -f $STAGE4_FILENAME ${TARGET}*"
  if [ ${S_KERNEL} -eq 1 ]
  then
    echo ""
    echo  "tar $TAR_OPTIONS -f $STAGE4_FILENAME.ksrc ${TARGET}usr/src/linux-$(uname -r)*"
    if [ ${x86_64} -eq 1 ]
    then
        echo ""
        echo  "tar $TAR_OPTIONS -f $STAGE4_FILENAME.kmod ${TARGET}lib64/modules/$(uname -r)*"
    else
        echo ""
        echo  "tar $TAR_OPTIONS -f $STAGE4_FILENAME.kmod ${TARGET}lib/modules/$(uname -r)*"
    fi
  fi
  echo ""
  echo -n "Type \"yes\" to continue or anything else to quit: "
  read AGREE
fi

# start stage4 creation:
if [ "$AGREE" == "yes" ]
then
  tar $TAR_OPTIONS $EXCLUDES $OPTIONS -f $STAGE4_FILENAME ${TARGET}*
  if [ ${S_KERNEL} -eq 1 ]
  then
    tar $TAR_OPTIONS -f $STAGE4_FILENAME.ksrc ${TARGET}usr/src/linux-$(uname -r)*
    if [ ${x86_64} -eq 1 ]
    then
        tar $TAR_OPTIONS -f $STAGE4_FILENAME.kmod ${TARGET}lib64/modules/$(uname -r)*
    else
        tar $TAR_OPTIONS -f $STAGE4_FILENAME.kmod ${TARGET}lib/modules/$(uname -r)*
    fi
  fi
fi

exit 0
