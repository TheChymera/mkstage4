#!/usr/bin/env bats

load test_helper

setup() {
    f test/usr/bin/ping
    f test/usr/src/linux-"$test_uname"/.config
    f test/usr/src/linux-"$test_uname"/vmlinux
    f test/lib/modules/"$test_uname"/mod.ko
    f test/lib64/modules/"$test_uname"/mod.ko
    mkstage4.sh -k -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2 test.tar.bz2.ksrc test.tar.bz2.kmod
}

@test "/usr/bin/ping is included" {
    assert_tar_includes test/usr/bin/ping
}

@test "/usr/src/linux-uname/.config is excluded" {
    assert_tar_excludes test/usr/src/linux-"$test_uname"/.config
}

@test "/usr/src/linux-uname/vmlinux is excluded" {
    assert_tar_excludes test/usr/src/linux-"$test_uname"/vmlinux
}

@test "/lib/modules/uname/mod.ko is excluded" {
    assert_tar_excludes test/lib/modules/"$test_uname"/mod.ko
}

@test "/lib64/modules/uname/mod.ko is excluded" {
    assert_tar_excludes test/lib64/modules/"$test_uname"/mod.ko
}

@test "/usr/src/linux-uname/.config is included" {
    assert_tar_includes test/usr/src/linux-"$test_uname"/.config test.tar.bz2.ksrc
}

@test "/usr/src/linux-uname/vmlinux is included" {
    assert_tar_includes test/usr/src/linux-"$test_uname"/vmlinux test.tar.bz2.ksrc
}

@test "/lib/modules/uname/mod.ko is included" {
    assert_tar_includes test/lib/modules/"$test_uname"/mod.ko test.tar.bz2.kmod
}

@test "/lib64/modules/uname/mod.ko is included" {
    assert_tar_includes test/lib64/modules/"$test_uname"/mod.ko test.tar.bz2.kmod
}

# vim: ft=bash
