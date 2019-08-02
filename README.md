# mkstage4

This is a Bash script to create stage 4 tarballs either for the running system, or a system at a specified mount point.
The script is a new edition of an earlier [mkstage4 script](https://github.com/gregf/bin/blob/master/mkstage4) by Greg Fitzgerald (unmaintained as of 2012) which is itself a revamped edition of the [original mkstage4](http://blinkeye.ch/dokuwiki/doku.php/projects/mkstage4) by Reto Glauser (unmaintaied as of 2009). 
 
More information on mkstage4 can be found on its own Chymeric Tutorials article: [mkstage4 - Stage 4 Tarballs Made Easy](http://tutorials.chymera.eu/blog/2014/05/18/mkstage4-stage4-tarballs-made-easy/). 

Chinese Introduction [中文说明](http://liuk.io/blog/gentoo-stage4)

## Installation

The script can be run directly from its containing folder (and thus, is installed simply by downloading or cloning it from here - and adding run permissions):

```bash
git clone https://github.com/TheChymera/mkstage4.git /your/mkstage4/directory
cd /your/mkstage4/directory
chmod +x mkstage4.sh
```

For [Gentoo Linux](http://en.wikipedia.org/wiki/Gentoo_linux) and [Derivatives](http://en.wikipedia.org/wiki/Category:Gentoo_Linux_derivatives), mkstage4 is also available in [Portage](http://en.wikipedia.org/wiki/Portage_(software)) via the base Gentoo overlay.
On any Gentoo system, just run the following command:

```
emerge app-backup/mkstage4
```

## Usage

*If you are running the script from the containing folder (first install method) please make sure you use the `./mkstage4.sh` command instead of just `mkstage4`!*

Archive your current system (mounted at /):

```bash
mkstage4 -s archive_name
```

Archive system located at a custom mount point:

```bash
mkstage4 -t /custom/mount/point archive_name
```

Command line arguments:

```
  mkstage4.sh [-q -c -b -l -k -p] [-s || -t <target-mountpoint>] [-e <additional excludes dir*>] <archive-filename> [custom-tar-options]
  -q: activates quiet mode (no confirmation).
  -c: excludes connman network lists.
  -b: excludes boot directory.
  -l: excludes lost+found directory.
  -p: compresses parallelly using pbzip2.
  -e: an additional excludes directory (one dir one -e).
  -s: makes tarball of current system.
  -k: separately save current kernel modules and src (smaller & save decompression time).
  -t: makes tarball of system located at the <target-mountpoint>.
  -h: displays help message.
```

## Extract Tarball

Tarballs created with mkstage4 can be extracted with:

```bash
tar xvjpf archive_name.tar.bz2
```

If you use -k option, extract src & modules separately

```bash
tar xvjpf archive_name.tar.bz2.kmod
tar xvjpf archive_name.tar.bz2.ksrc
```

If you have install pbzip2, you can extract parallelly with:
```bash
tar -I pbzip2 -xvf archive_name.tar.bz2
```

## Dependencies

* **[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))** - in [Portage](http://en.wikipedia.org/wiki/Portage_(software)) as **app-shells/bash**
* **[tar](https://en.wikipedia.org/wiki/Tar_(computing))** - in Portage as **app-arch/tar**
* **[pbzip2](https://launchpad.net/pbzip2)** (optional, if it is installed the archive can be compressed using multiple parallel threads) - in Portage as
**app-arch/pbzip2**

*Please note that these are very basic dependencies and should already be included in any Linux system.*

---
Released under the GPLv3 license.
Project led by Horea Christian (address all correspondence to: chr@chymera.eu).
