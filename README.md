# mkstage4

![CI](https://github.com/TheChymera/mkstage4/workflows/CI/badge.svg)

This is a Bash script to create stage 4 tarballs either for the running system, or a system at a specified mount point.
The script was inspired by an earlier [mkstage4 script](https://github.com/gregf/bin/blob/master/mkstage4) by Greg Fitzgerald (unmaintained as of 2012) which itself was a revamped edition of the [original mkstage4](http://blinkeye.ch/dokuwiki/doku.php/projects/mkstage4) by Reto Glauser (unmaintained as of 2009).

More information on mkstage4 can be found on the following blogs, though instructions may be outdated compared to the current version, best documented by this `README` file:

* English: [mkstage4 - Stage 4 Tarballs Made Easy](http://tutorials.chymera.eu/blog/2014/05/18/mkstage4-stage4-tarballs-made-easy/).

## Installation

The script can be run directly from its containing folder (and thus, is installed simply by downloading or cloning it from here - and adding run permissions):

```bash
git clone https://github.com/TheChymera/mkstage4.git /your/mkstage4/directory
cd /your/mkstage4/directory
chmod +x mkstage4.sh
```

For [Gentoo Linux](http://en.wikipedia.org/wiki/Gentoo_linux) and [Derivatives](http://en.wikipedia.org/wiki/Category:Gentoo_Linux_derivatives), mkstage4 is also available in [Portage](http://en.wikipedia.org/wiki/Portage_(software)) via the base Gentoo overlay.
On any Gentoo system, just run the following command:

```bash
emerge app-backup/mkstage4
```

## Usage

*If you are running the script from the containing folder (first install method) please make sure you use the `./mkstage4.sh` command instead of just `mkstage4`!*

Archive your current system (mounted at /):

```bash
mkstage4 -s archive_name
```

Archive a system located at a custom mount point:

```bash
mkstage4 -t /custom/mount/point archive_name
```

Command line arguments:

```console
mkstage4.sh [-q -c -b -l -k -p] [-s || -t <target-mountpoint>] [-e <additional excludes dir*>] <archive-filename> [custom-tar-options]
  -q: activates quiet mode (no confirmation).
  -c: excludes connman network lists.
  -b: excludes boot directory.
  -l: excludes lost+found directory.
  -p: compresses parallelly using pbzip2.
  -e: an additional excludes directory (one dir one -e).
  -s: makes tarball of current system.
  -k: separately save current kernel modules and src (creates smaller archives and saves decompression time).
  -t: makes tarball of system located at the <target-mountpoint>.
  -C: specify tar compression (shows available on runtime and default is bz2)
  -h: displays help message.
```

## System Tarball Extraction

### Single-threaded

Tarballs created with mkstage4 can be extracted with:

```bash
tar xvjpf archive_name.tar.bz2
```

To preserve binary attributes and use numeric owner identifiers (considered good practice on Gentoo), you can simply append the relevant flags to the respective `tar` commands, e.g.:

```bash
tar xvjpf archive_name.tar.bz2 --xattrs-include='*.*' --numeric-owner
```

If you use the `-k` option, extract the `src` and modules archives separately:

```bash
tar xvjpf archive_name.tar.bz2.kmod
tar xvjpf archive_name.tar.bz2.ksrc
```

### Multi-threaded

If you have a parallel de/compressor installed, you can extract the archive with one of the respective commands:

#### `pbzip2`

```bash
tar -I pbzip2 -xvf archive_name.tar.bz2 --xattrs-include='*.*' --numeric-owner
```

#### `xz`

```bash
tar -I 'xz -T0' -xvf archive_name.tar.xz --xattrs-include='*.*' --numeric-owner
```

#### `gzip`

Similarly to other compressors, `gzip` uses a separate binary for parallel decompression:

```bash
tar -I unpigz -xvf archive_name.tar.gz --xattrs-include='*.*' --numeric-owner
```

## Dependencies

*Please note that these are very basic dependencies and should already be included in any Linux system.*

* **[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))** - in [Portage](http://en.wikipedia.org/wiki/Portage_(software)) as **[app-shells/bash](https://packages.gentoo.org/packages/app-shells/bash)**
* **[tar](https://en.wikipedia.org/wiki/Tar_(computing))** - in Portage as **[app-arch/tar](https://packages.gentoo.org/packages/app-arch/tar)**
* **[bzip2](https://gitlab.com/federicomenaquintero/bzip2)** - in Portage as **[app-arch/bzip2](https://packages.gentoo.org/packages/app-arch/bzip2)** (single thread, default compression)


**Optionals**:
*If one the following is installed the archive will be compressed using multiple parallel threads when available, in order of succession:*

* `-C xz`:
  * **[xz](https://tukaani.org/xz/)** - in Portage as **[app-arch/xz](https://packages.gentoo.org/packages/app-arch/xz-utils)**, (parallel)
  * **[pixz](https://github.com/vasi/pixz)** - in Portage as **[app-arch/pixz](https://packages.gentoo.org/packages/app-arch/pixz)**, (parallel, indexed)

* `-C bz2`:
  * **[pbzip2](https://launchpad.net/pbzip2/)** - in Portage as **[app-arch/pbzip2](https://packages.gentoo.org/packages/app-arch/pbzip2)**, (parallel)
  * **[lbzip2](https://github.com/kjn/lbzip2/)** - in Portage as **[app-arch/lbzip2](https://packages.gentoo.org/packages/app-arch/lbzip2)**, (parallel, faster and more efficient)

* `-C gz`:
  * **[gzip](https://www.gnu.org/software/gzip/)** - in Portage as **[app-arch/gzip](https://packages.gentoo.org/packages/app-arch/gzip)**, (single thread)
  * **[pigz](https://www.zlib.net/pigz/)** - in Portage as **[app-arch/pigz](https://packages.gentoo.org/packages/app-arch/pigz)**, (parallel)

* `-C lrz`:
  * **[lrzip](https://github.com/ckolivas/lrzip/)** - in Portage as **[app-arch/lrzip](https://packages.gentoo.org/packages/app-arch/lrzip)**, (parallel)

* `-C lz`:
  * **[lzip](https://www.nongnu.org/lzip/)** - in Portage as **[app-arch/lzip](https://packages.gentoo.org/packages/app-arch/lzip)**, (single thread)
  * **[plzip](https://www.nongnu.org/lzip/plzip.html)** - in Portage as **[app-arch/plzip](https://packages.gentoo.org/packages/app-arch/plzip)**, (parallel)

* `-C lz4`:
  * **[lz4](https://github.com/lz4/lz4)** - in Portage as **[app-arch/lz4](https://packages.gentoo.org/packages/app-arch/lz4)**, (parallel)

* `-C lzo`:
  * **[lzop](https://www.lzop.org/)** - in Portage as **[app-arch/lzop](https://packages.gentoo.org/packages/app-arch/lzop)**, (parallel)

* `-C zstd`:
  * **[zstd](https://facebook.github.io/zstd/)** - in Portage as **[app-arch/zstd](https://packages.gentoo.org/packages/app-arch/zstd)**, (parallel)

---
Released under the GPLv3 license.
Project led by Horea Christian (address all correspondence to: chr@chymera.eu).
