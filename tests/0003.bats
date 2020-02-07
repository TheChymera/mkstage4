#!/usr/bin/env bats

load test_helper

setup() {
    f test/usr/bin/ping
    f test/usr/src/linux-"$TEST_UNAME"/.config
    f test/usr/src/linux-"$TEST_UNAME"/vmlinux
    f test/usr/src/linux-different-uname/.config
    f test/usr/src/linux-different-uname/vmlinux
    f test/lib/modules/"$TEST_UNAME"/mod.ko
    f test/lib64/modules/"$TEST_UNAME"/mod.ko
    f test/lib/modules/different-uname/mod.ko
    f test/lib64/modules/different-uname/mod.ko
    mkstage4.sh -k -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2 test.tar.bz2.ksrc test.tar.bz2.kmod
}

@test "/usr/bin/ping is included" {
    assert_tar_includes test/usr/bin/ping
}

@test "/usr/src/ is included" {
    assert_tar_includes test/usr/src/
}

@test "/lib/modules/ is included" {
    assert_tar_includes test/lib/modules/
}

@test "/lib64/modules/ is included" {
    assert_tar_includes test/lib64/modules/
}

@test "/usr/src/linux-$TEST_UNAME/ is excluded" {
    assert_tar_excludes test/usr/src/linux-"$TEST_UNAME"/
}

@test "/usr/src/linux-different-uname/ is excluded" {
    assert_tar_excludes test/usr/src/linux-different-uname/
}

@test "/lib/modules/$TEST_UNAME/ is excluded" {
    assert_tar_excludes test/lib/modules/"$TEST_UNAME"/
}

@test "/lib/modules/different-uname/ is excluded" {
    assert_tar_excludes test/lib/modules/different-uname/
}

@test "/lib64/modules/$TEST_UNAME/ is excluded" {
    assert_tar_excludes test/lib64/modules/"$TEST_UNAME"/
}

@test "/lib64/modules/different-uname/ is excluded" {
    assert_tar_excludes test/lib64/modules/different-uname/
}

@test "/usr/src/linux-$TEST_UNAME/.config is included in ksrc" {
    assert_tar_includes test/usr/src/linux-"$TEST_UNAME"/.config test.tar.bz2.ksrc
}

@test "/usr/src/linux-$TEST_UNAME/vmlinux is included in ksrc" {
    assert_tar_includes test/usr/src/linux-"$TEST_UNAME"/vmlinux test.tar.bz2.ksrc
}

@test "/usr/src/linux-different-uname/ is excluded in ksrc" {
    assert_tar_excludes test/usr/src/linux-different-uname/ test.tar.bz2.ksrc
}

@test "/lib/modules/$TEST_UNAME/mod.ko is included in kmod" {
    assert_tar_includes test/lib/modules/"$TEST_UNAME"/mod.ko test.tar.bz2.kmod
}

@test "/lib64/modules/$TEST_UNAME/mod.ko is included in kmod" {
    assert_tar_includes test/lib64/modules/"$TEST_UNAME"/mod.ko test.tar.bz2.kmod
}

@test "/lib/modules/different-uname/ is excluded in kmod" {
    assert_tar_excludes test/lib/modules/different-uname/ test.tar.bz2.kmod
}

@test "/lib64/modules/different-uname/ is excluded in kmod" {
    assert_tar_excludes test/lib64/modules/different-uname/ test.tar.bz2.kmod
}

# vim: ft=bash
