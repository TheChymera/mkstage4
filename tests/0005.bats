#!/usr/bin/env bats

load test_helper

setup() {
    f test/var/lib/connman/file
    mkstage4.sh -c -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2
}

@test "/var/lib/connman/file is excluded" {
    assert_tar_excludes test/var/lib/connman/file
}

@test "/var/lib/connman/ is included" {
    assert_tar_includes test/var/lib/connman/
}

# vim: ft=bash
