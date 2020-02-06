#!/usr/bin/env bats

load test_helper

setup() {
    f test/usr/bin/lost+found
    f test/lost+found
    f test/home/user/.dotfile
    f test/home/user/chroot/var/tmp/file
    f test/home/user/ccache/file
    f test/root/ccache/file
    f test/etc/secrets/key
    mkstage4.sh -q -t test test0
    mkstage4.sh \
        -e 'test/lost+found' \
        -e 'user/.*' \
        -e 'test/home/user/chroot/var/tmp/file' \
        -e 'ccache/*' \
        -e 'secrets' \
        -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2 test0.tar.bz2
}

@test "-e '/lost+found'" {
    assert_tar_includes test/usr/bin/lost+found test0.tar.bz2
    assert_tar_includes test/usr/bin/lost+found

    assert_tar_includes test/lost+found test0.tar.bz2
    assert_tar_excludes test/lost+found
}

@test "-e 'user/.*'" {
    assert_tar_includes test/home/user/.dotfile test0.tar.bz2
    assert_tar_excludes test/home/user/.dotfile
    assert_tar_includes test/home/user/
}

@test "-e 'test/home/user/chroot/var/tmp/file'" {
    assert_tar_includes test/home/user/chroot/var/tmp/file test0.tar.bz2
    assert_tar_excludes test/home/user/chroot/var/tmp/file
}

@test "-e 'ccache/*'" {
    assert_tar_includes test/home/user/ccache/file test0.tar.bz2
    assert_tar_excludes test/home/user/ccache/file
    assert_tar_includes test/home/user/ccache/

    assert_tar_includes test/root/ccache/file test0.tar.bz2
    assert_tar_excludes test/root/ccache/file
    assert_tar_includes test/root/ccache/
}

@test "-e 'secrets'" {
    assert_tar_includes test/etc/secrets/key test0.tar.bz2
    assert_tar_excludes test/etc/secrets/key
    assert_tar_excludes test/etc/secrets/
}

# vim: ft=bash
