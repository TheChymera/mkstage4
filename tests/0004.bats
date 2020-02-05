#!/usr/bin/env bats

load test_helper

setup() {
    f test/boot/kernel
    d test/boot/boot
    mkstage4.sh -b -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2
}

@test "/boot/kernel is excluded" {
    assert_tar_excludes test/boot/kernel
}

@test "/boot/boot is included" {
    skip "TODO: Not yet implemented"
    assert_tar_includes test/boot/boot
}

# vim: ft=bash
