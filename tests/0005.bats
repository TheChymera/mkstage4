#!/usr/bin/env bats

load test_helper

setup() {
    f test/var/lib/connman/file
    f test/root/.bash_history
    f test/home/user/.bash_history
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

@test "/home/user/.bash_history is exlucded" {
    assert_tar_excludes test/home/user/.bash_history
}

@test "/home/user/ is included" {
    assert_tar_includes test/home/user/
}

@test "/root/.bash_history is exlucded" {
    assert_tar_excludes test/root/.bash_history
}

@test "/root/ is included" {
    assert_tar_includes test/root/
}

# vim: ft=bash
