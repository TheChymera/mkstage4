#!/usr/bin/env bats

load test_helper

setup() {
    f test/home/user/.dotfile
    f test/home/user/.keep
    f test/etc/ssh/key
    f test/etc/ssh/config
    f test/boot/boot
    f test/boot/kernel
    f test/mnt/5/media
    mkstage4.sh \
        -i 'test/home/user/.keep' \
        -e 'user/.*' \
        -i 'test/etc/ssh/config' \
        -e 'ssh' \
        -b \
        -i 'test/boot/boot' \
        -i 'test/mnt/5' \
        -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2
}

@test "-i 'test/home/user/.keep and -e 'user/.*'" {
    assert_tar_excludes test/home/user/.dotfile
    assert_tar_includes test/home/user/.keep
}

@test "-i 'test/etc/ssh/config and -e 'ssh'" {
    assert_tar_excludes test/etc/ssh/key
    assert_tar_includes test/etc/ssh/config
}

@test "-i 'test/boot/boot' and -b" {
    assert_tar_excludes test/boot/kernel
    assert_tar_includes test/boot/boot
}

@test "-i 'test/mnt/5'" {
    assert_tar_includes test/mnt/5/media
}

# vim: ft=bash
