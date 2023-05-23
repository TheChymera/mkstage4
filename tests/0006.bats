#!/usr/bin/env bats

load test_helper

setup() {
    f test/var/db/repos/gentoo/app-backup/mkstage4/ebuild
    f test/var/db/repos/science/sci-biology/fsl/ebuild
    f test/var/cache/distfiles/mkstage4.tar.gz
    f test/usr/portage/Manifest
    mkstage4.sh -q -t test test
}

teardown() {
    #rm -rf test test.tar.bz2
    echo lala
}

@test "/var/db/repos/gentoo/ is included" {
    assert_tar_includes test/var/db/repos/gentoo/
}

@test "/var/db/repos/gentoo/app-backup is excluded" {
    assert_tar_excludes_partial test/var/db/repos/gentoo/app-backup
}

@test "/var/db/repos/science/ is included" {
    assert_tar_includes test/var/db/repos/gentoo/
}

@test "/var/db/repos/science/sci-biology is excluded" {
    assert_tar_excludes_partial test/var/db/repos/gentoo/app-backup
}

@test "/var/cache/distfiles/mkstage4.tar.gz is excluded" {
    assert_tar_excludes test/var/cache/distfiles/mkstage4.tar.gz
}

@test "/var/cache/distfiles/ is included" {
    assert_tar_includes test/var/cache/distfiles/
}

@test "/usr/portage/Manifest is excluded" {
    assert_tar_excludes test/usr/portage/Manifest
}

@test "/usr/portage/ is included" {
    assert_tar_includes test/usr/portage/
}

# vim: ft=bash
