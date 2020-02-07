#!/bin/bash

test_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$test_directory/..:$PATH"

# export so that uname hook in mkstage4.sh has access to var
export TEST_UNAME="test-uname"
uname() { echo "$TEST_UNAME"; }
export -f uname

# bypasses mkstage4.sh root check
whoami() { echo "root"; }
export -f whoami

skip_if_not_root() {
    if [ "$EUID" -ne 0 ]; then
        skip "Must be root for this test."
    fi
}

d() {
    mkdir -p "${1}"
}

f() {
    mkdir -p "$(dirname "${1}")" && touch "${1}"
}

assert_tar_includes() {
    test -f "${1}" || test -d "${1}"
    tar --list -f "${2-test.tar.bz2}" | grep -q "^${1}$"
}

assert_tar_includes_partial() {
    tar --list -f "${2-test.tar.bz2}" | grep -q "${1}"
}

assert_tar_excludes() {
    test -f "${1}" || test -d "${1}"
    ! tar --list -f "${2-test.tar.bz2}" | grep -q "^${1}$"
}

assert_tar_excludes_partial() {
    ! tar --list -f "${2-test.tar.bz2}" | grep -q "${1}"
}
