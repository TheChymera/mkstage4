#!/usr/bin/env bats

load test_helper

setup() {
    f test/.hiddenfile
    f test/usr/bin/ping
    f test/usr/bin/lost+found
    f test/usr/src/linux-"$TEST_UNAME"/.config
    f test/usr/src/linux-"$TEST_UNAME"/vmlinux
    f test/lib/modules/"$TEST_UNAME"/mod.ko
    f test/lib64/modules/"$TEST_UNAME"/mod.ko
    f test/dev/sda
    f test/proc/cpuinfo
    f test/run/pid
    d test/sys/fs
    f test/tmp/junk
    d test/media/cdrom
    f test/mnt/1/content
    f test/root/.bash_history
    f test/home/user/.bash_history
    f test/home/user/chroot/var/tmp/file
    f test/boot/kernel
    f test/var/tmp/file
    f test/var/lock/lockfile
    f test/var/run/pid
    f test/var/lib/docker/image
    f test/var/log/messages
    f test/var/log/portage/elog/.keep_sys-apps_portage-0
    mkstage4.sh -q -t test test
}

teardown() {
    rm -rf test test.tar.bz2
}

@test "/usr/bin/ping is included" {
    assert_tar_includes test/usr/bin/ping
}

@test "/usr/bin/lost+found is included" {
    assert_tar_includes test/usr/bin/lost+found
}

@test "/usr/src/linux-uname/.config is included" {
    assert_tar_includes test/usr/src/linux-"$TEST_UNAME"/.config
}

@test "/usr/src/linux-uname/vmlinux is included" {
    assert_tar_includes test/usr/src/linux-"$TEST_UNAME"/vmlinux
}

@test "/lib/modules/uname/mod.ko is included" {
    assert_tar_includes test/lib/modules/"$TEST_UNAME"/mod.ko
}

@test "/lib64/modules/uname/mod.ko is included" {
    assert_tar_includes test/lib64/modules/"$TEST_UNAME"/mod.ko
}

@test "/dev/* is excluded" {
    assert_tar_excludes test/dev/sda
}

@test "/var/tmp/* is excluded" {
    assert_tar_excludes test/var/tmp/file
}

@test "/media/* is excluded" {
    assert_tar_excludes test/media/cdrom
}

@test "/mnt/* is excluded" {
    assert_tar_excludes test/mnt/1
}

@test "/proc/* is excluded" {
    assert_tar_excludes test/proc/cpuinfo
}

@test "/run/* is excluded" {
    assert_tar_excludes test/run/pid
}

@test "/sys/* is excluded" {
    assert_tar_excludes test/sys/fs
}

@test "/tmp/* is excluded" {
    assert_tar_excludes test/tmp/junk
}

@test "/var/lock/* is excluded" {
    assert_tar_excludes test/var/lock/lockfile
}

@test "/var/log/* is excluded" {
    assert_tar_excludes test/var/log/messages
}

@test "/var/run/* is excluded" {
    assert_tar_excludes test/var/run/pid
}

@test "/var/lib/docker/* is excluded" {
    assert_tar_excludes test/var/lib/docker/image
}

@test "/dev/ is included" {
    assert_tar_includes test/dev/
}

@test "/var/tmp/ is included" {
    assert_tar_includes test/var/tmp/
}

@test "/media/ is included" {
    assert_tar_includes test/media/
}

@test "/mnt/ is included" {
    assert_tar_includes test/mnt/
}

@test "/proc/ is included" {
    assert_tar_includes test/proc/
}

@test "/run/ is included" {
    assert_tar_includes test/run/
}

@test "/sys/ is included" {
    assert_tar_includes test/sys/
}

@test "/tmp/ is included" {
    assert_tar_includes test/tmp/
}

@test "/var/lock/ is included" {
    assert_tar_includes test/var/lock/
}

@test "/var/log/ is included" {
    assert_tar_includes test/var/log/
}

@test "/var/run/ is included" {
    assert_tar_includes test/var/run/
}

@test "/var/lib/docker/ is included" {
    assert_tar_includes test/var/lib/docker/
}

@test "/boot/kernel is included" {
    assert_tar_includes test/boot/kernel
}

@test "/.hiddenfile is included" {
    assert_tar_includes test/.hiddenfile
}

@test "/var/log/**/.keep is included" {
    skip "TODO: Not yet implemented"
    assert_tar_includes test/var/log/portage/elog/.keep_sys-apps_portage-0
}

@test "/home/user/.bash_history is included" {
    assert_tar_includes test/home/user/.bash_history
}

@test "/root/.bash_history is included" {
    assert_tar_includes test/root/.bash_history
}

@test "/home/user/chroot/var/tmp/file is included" {
    assert_tar_includes test/home/user/chroot/var/tmp/file
}

# vim: ft=bash
