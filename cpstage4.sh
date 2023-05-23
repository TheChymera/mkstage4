#!/usr/bin/env bash

# checks if run as root:
if [ "$(whoami)" != 'root' ]
then
	echo "$(basename "$0"): must be root."
	exit 1
fi

# set flag variables to null/default
EXCLUDE_BOOT=0
EXCLUDE_LOST=0
QUIET=0
HAS_PORTAGEQ=0

if command -v portageq &>/dev/null
then
	HAS_PORTAGEQ=1
fi

USAGE="Usage:\n\
	$(basename "$0") [-b -c -k -l -q] [-e <additional excludes dir*>] <source> <destination>\n\
	Positional Arguments:\n\
		<source>: from where to copy system files.\n\
		<destination>: where to copy system files to.\n\
	Flags:\n\
		-b: excludes boot directory.\n\
		-c: excludes some confidential files (currently only .bash_history and connman network lists).\n\
		-e: an additional excludes directory (one dir one -e, donot use it with *).\n\
		-l: excludes lost+found directory.\n\
		-q: activate quiet mode (no confirmation).\n\
		-h: display help message."

# reads options:
while getopts ":e:bcelqh" flag
do
	case "$flag" in
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
		q)
			QUIET=1
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

# shifts pointer to read mandatory output file specification
shift $((OPTIND - 1))
SOURCE=${1}
DESTINATION=${2}

if [ -z "$SOURCE" ]
then
	echo "$(basename "$0"): no source specified."
	echo -e "$USAGE"
	exit 1
fi
if [ -z "$DESTINATION" ]
then
	echo "$(basename "$0"): no source specified."
	echo -e "$USAGE"
	exit 1
fi

# make sure SOURCE path ends with slash
if [[ "$SOURCE" != */ ]]
then
	SOURCE="${SOURCE}/"
fi
# make sure DESTINATION path ends with slash
if [[ "$DESTINATION" != */ ]]
then
	DESTINATION="${DESTINATION}/"
fi

# checks for quiet mode (no confirmation)
if ((QUIET))
then
	AGREE="yes"
fi

# Excludes:
EXCLUDES=(
	"--exclude=${SOURCE}dev/*"
	"--exclude=${SOURCE}var/tmp/*"
	"--exclude=${SOURCE}media/*"
	"--exclude=${SOURCE}mnt/*/*"
	"--exclude=${SOURCE}proc/*"
	"--exclude=${SOURCE}run/*"
	"--exclude=${SOURCE}sys/*"
	"--exclude=${SOURCE}tmp/*"
	"--exclude=${SOURCE}var/lock/*"
	"--exclude=${SOURCE}var/log/*"
	"--exclude=${SOURCE}var/run/*"
	"--exclude=${SOURCE}var/lib/docker/*"
)

EXCLUDES_DEFAULT_PORTAGE=(
	"--exclude=${SOURCE}var/db/repos/gentoo/*"
	"--exclude=${SOURCE}var/cache/distfiles/*"
	"--exclude=${SOURCE}usr/portage/*"
)

EXCLUDES+=("${USER_EXCL[@]}")

if [ "$SOURCE" == '/' ]
then
	if ((HAS_PORTAGEQ))
	then
		PORTAGEQ_REPOS=$(portageq get_repos /)
		for i in ${PORTAGEQ_REPOS}; do
			EXCLUDES+=("--exclude="$(portageq get_repo_path / "${i}")/*)
		done
		EXCLUDES+=("--exclude=$(portageq distdir)/*")
	else
		EXCLUDES+=("${EXCLUDES_DEFAULT_PORTAGE[@]}")
	fi
else
	EXCLUDES+=("${EXCLUDES_DEFAULT_PORTAGE[@]}")
fi

if ((EXCLUDE_BOOT))
then
	EXCLUDES+=("--exclude=${SOURCE}boot/*")
fi

if ((EXCLUDE_CONFIDENTIAL))
then
	EXCLUDES+=("--exclude=${SOURCE}home/*/.bash_history")
	EXCLUDES+=("--exclude=${SOURCE}root/.bash_history")
	EXCLUDES+=("--exclude=${SOURCE}var/lib/connman/*")
fi

if ((EXCLUDE_LOST))
then
	EXCLUDES+=("--exclude=lost+found")
fi

# Generic tar options:
RSYNC_OPTIONS=(
	-avxHAXS
	--numeric-ids
	"--info=progress2"
	)

# if not in quiet mode, this message will be displayed:
if [[ "$AGREE" != 'yes' ]]
then
	echo "Are you sure that you want to copy system files located under"
	echo "$SOURCE"
	echo "to the following directory"
	echo "$DESTINATION"
	echo
	echo "WARNING: since all data is copied by default the user should exclude all"
	echo "security- or privacy-related files and directories, which are not"
	echo "already excluded, manually per cmdline."
	echo "example: \$ $(basename "$0") --exclude=/etc/ssh/ssh_host* <source> <destination>"
	echo
	echo "COMMAND LINE PREVIEW:"
	echo 'rsync' "${RSYNC_OPTIONS[@]}" "${EXCLUDES[@]}" "${SOURCE}" "${DESTINATION}"
	echo
	echo -n 'Type "yes" to continue or anything else to quit: '
	read -r AGREE
fi

# start stage4 creation:
if [ "$AGREE" == 'yes' ]
then
	rsync "${RSYNC_OPTIONS[@]}" "${EXCLUDES[@]}" "${SOURCE}" "${DESTINATION}"
fi
