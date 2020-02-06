#!/usr/bin/env bats

load test_helper

setup() {
    f test/usr/bin/ping
    f test/usr/bin/lost+found
    f test/lost+found
    mkstage4.sh -q -l -t test test
}

teardown() {
    rm -rf test test.tar.bz2
}

@test "/usr/bin/ping is included" {
    assert_tar_includes test/usr/bin/ping
}

@test "/usr/bin/lost+found is excluded" {
    assert_tar_excludes test/usr/bin/lost+found
}

@test "/lost+found is excluded" {
    assert_tar_excludes test/lost+found
}

# vim: ft=bash
