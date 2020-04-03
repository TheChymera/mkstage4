#!/bin/bash
# checks if run as root:
if [ "$(whoami)" != 'root' ]
then
	echo "$(basename "$0"): must be root."
	exit 1
fi

#set flag variables to null
EXCLUDE_BOOT=0
EXCLUDE_CONFIDENTIAL=0
EXCLUDE_LOST=0
QUIET=0
USER_EXCL=()
USER_INCL=()
S_KERNEL=0
PARALLEL=0
HAS_PORTAGEQ=0

if command -v portageq &>/dev/null
then
	HAS_PORTAGEQ=1
fi

USAGE="usage:\n\
	$(basename "$0") [-q -c -b -l -k -p] [-s || -t <target-mountpoint>] [-e <additional excludes dir*>] [-i <additional include target>] <archive-filename> [custom-tar-options]\n\
	-q: activates quiet mode (no confirmation).\n\
	-c: excludes some confidential files (currently only .bash_history and connman network lists).\n\
	-b: excludes boot directory.\n\
	-l: excludes lost+found directory.\n\
	-p: compresses parallelly using pbzip2.\n\
	-e: an additional excludes directory (one dir one -e, donot use it with *).\n\
	-i: an additional target to include. This has higher precedence than -e, -t, and -s.\n\
	-s: makes tarball of current system.\n\
	-k: separately save current kernel modules and src (smaller & save decompression time).\n\
	-t: makes tarball of system located at the <target-mountpoint>.\n\
	-h: displays help message."

# reads options:
while getopts ":t:e:i:skqcblph" flag
do
	case "$flag" in
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
			EXCLUDE_CONFIDENTIAL=1
			;;
		b)
			EXCLUDE_BOOT=1
			;;
		l)
			EXCLUDE_LOST=1
			;;
		e)
			USER_EXCL+=("--exclude=${OPTARG}")
			;;
		i)
			USER_INCL+=("${OPTARG}")
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

if [ -z "$TARGET" ]
then
	echo "$(basename "$0"): no target specified."
	echo -e "$USAGE"
	exit 1
fi

# make sure TARGET path ends with slash
if [[ "$TARGET" != */ ]]
then
	TARGET="${TARGET}/"
fi

# shifts pointer to read mandatory output file specification
shift $((OPTIND - 1))
ARCHIVE=$1

# checks for correct output file specification
if [ -z "$ARCHIVE" ]
then
	echo "$(basename "$0"): no archive file name specified."
	echo -e "$USAGE"
	exit 1
fi

# checks for quiet mode (no confirmation)
if ((QUIET))
then
	AGREE="yes"
fi

# determines if filename was given with relative or absolute path
if (($(grep -c '^/' <<< "$ARCHIVE") > 0))
then
	STAGE4_FILENAME="${ARCHIVE}.tar.bz2"
else
	STAGE4_FILENAME="$(pwd)/${ARCHIVE}.tar.bz2"
fi

#Shifts pointer to read custom tar options
shift
mapfile -t OPTIONS <<< "$@"
# Handle when no options are passed
((${#OPTIONS[@]} == 1)) && [ -z "${OPTIONS[0]}" ] && unset OPTIONS

if ((S_KERNEL))
then
	USER_EXCL+=("--exclude=${TARGET}usr/src/*")
	USER_EXCL+=("--exclude=${TARGET}lib*/modules/*")
fi


# Excludes:
EXCLUDES=(
	"--exclude=${TARGET}dev/*"
	"--exclude=${TARGET}var/tmp/*"
	"--exclude=${TARGET}media/*"
	"--exclude=${TARGET}mnt/*/*"
	"--exclude=${TARGET}proc/*"
	"--exclude=${TARGET}run/*"
	"--exclude=${TARGET}sys/*"
	"--exclude=${TARGET}tmp/*"
	"--exclude=${TARGET}var/lock/*"
	"--exclude=${TARGET}var/log/*"
	"--exclude=${TARGET}var/run/*"
	"--exclude=${TARGET}var/lib/docker/*"
)

EXCLUDES_DEFAULT_PORTAGE=(
	"--exclude=${TARGET}var/db/repos/gentoo/*"
	"--exclude=${TARGET}var/cache/distfiles/*"
	"--exclude=${TARGET}usr/portage/*"
)

EXCLUDES+=("${USER_EXCL[@]}")

INCLUDES=(
)

INCLUDES+=("${USER_INCL[@]}")

if [ "$TARGET" == '/' ]
then
	EXCLUDES+=("--exclude=$(realpath "$STAGE4_FILENAME")")
	if ((HAS_PORTAGEQ))
	then
		EXCLUDES+=("--exclude=$(portageq get_repo_path / gentoo)/*")
		EXCLUDES+=("--exclude=$(portageq distdir)/*")
	else
		EXCLUDES+=("${EXCLUDES_DEFAULT_PORTAGE[@]}")
	fi
else
	EXCLUDES+=("${EXCLUDES_DEFAULT_PORTAGE[@]}")
fi

if ((EXCLUDE_CONFIDENTIAL))
then
	EXCLUDES+=("--exclude=${TARGET}home/*/.bash_history")
	EXCLUDES+=("--exclude=${TARGET}root/.bash_history")
	EXCLUDES+=("--exclude=${TARGET}var/lib/connman/*")
fi

if ((EXCLUDE_BOOT))
then
	EXCLUDES+=("--exclude=${TARGET}boot/*")
fi

if ((EXCLUDE_LOST))
then
	EXCLUDES+=("--exclude=lost+found")
fi

# Generic tar options:
TAR_OPTIONS=(-cpP --ignore-failed-read "--xattrs-include='*.*'" --numeric-owner)

if ((PARALLEL))
then
	if command -v pbzip2 &>/dev/null; then
		TAR_OPTIONS+=("--use-compress-prog=pbzip2")
	else
		echo "WARING: pbzip2 isn't installed, single-threaded compressing is used." >&2
		TAR_OPTIONS+=("-j")
	fi
else
	TAR_OPTIONS+=("-j")
fi

# if not in quiet mode, this message will be displayed:
if [[ "$AGREE" != 'yes' ]]
then
	echo "Are you sure that you want to make a stage 4 tarball of the system"
	echo "located under the following directory?"
	echo "$TARGET"
	echo
	echo "WARNING: since all data is saved by default the user should exclude all"
	echo "security- or privacy-related files and directories, which are not"
	echo "already excluded by mkstage4 options (such as -c), manually per cmdline."
	echo "example: \$ $(basename "$0") -s /my-backup --exclude=/etc/ssh/ssh_host*"
	echo
	echo "COMMAND LINE PREVIEW:"
	echo 'tar' "${TAR_OPTIONS[@]}" "${INCLUDES[@]}" "${EXCLUDES[@]}" "${OPTIONS[@]}" -f "$STAGE4_FILENAME" "${TARGET}"
	if ((S_KERNEL))
	then
		echo
		echo 'tar' "${TAR_OPTIONS[@]}" -f "$STAGE4_FILENAME.ksrc" "${TARGET}usr/src/linux-$(uname -r)"
		echo 'tar' "${TAR_OPTIONS[@]}" -f "$STAGE4_FILENAME.kmod" "${TARGET}lib"*"/modules/$(uname -r)"
	fi
	echo
	echo -n 'Type "yes" to continue or anything else to quit: '
	read -r AGREE
fi

# start stage4 creation:
if [ "$AGREE" == 'yes' ]
then
	tar "${TAR_OPTIONS[@]}" "${INCLUDES[@]}" "${EXCLUDES[@]}" "${OPTIONS[@]}" -f "$STAGE4_FILENAME" "${TARGET}"
	if ((S_KERNEL))
	then
		tar "${TAR_OPTIONS[@]}" -f "$STAGE4_FILENAME.ksrc" "${TARGET}usr/src/linux-$(uname -r)"
		tar "${TAR_OPTIONS[@]}" -f "$STAGE4_FILENAME.kmod" "${TARGET}lib"*"/modules/$(uname -r)"
	fi
fi
