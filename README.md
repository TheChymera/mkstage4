#mkstage4

Nash script to create stage 4 tarballs either for the running system, or a system at a specified mount point.
The script is a new edition of the [mkstage4 script by Greg Fitzgerald](https://github.com/gregf/bin/blob/master/mkstage4) (unmaintained as of 2012) which is itself a revamped edition of the [original mkstage4](http://blinkeye.ch/dokuwiki/doku.php/projects/mkstage4) by Reto Glauser (unmaintaied as of 2009).  
More information on this script can be found on the respective [Chymeric Tutorials article](http://tutorials.chymera.eu/blog/2014/05/18/mkstage4-stage4-tarballs-made-easy/). 

##Usage

Running mksatge4 from its own directory:

```bash
cd /your/mkstage4/directory
chmod +x mkstage4.sh
```

Archive your current system (mounted at /):

```bash
./mkstage4.sh -s archive_name
```

Archive system located at a custom mount point:

```bash
./mkstage4.sh -t /custom/mount/point archive_name
```

Other options:

* ```-q``` (quiet) prompts of confirmation.
* ```-b``` (no-boot) excludes the ```/boot``` (or ```/cutom/mount/point/boot```).
* ```-c``` (no-connman) excludes connman saved networks directory.

##Extract Tarball

Tarballs created with mkstage4 can be extracted with:

```bash
tar xvjpf archive_name.tar.bz2
```

##Dependencies:

* **[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))** - in [Portage](http://en.wikipedia.org/wiki/Portage_(software)) as **app-shells/bash**
* **[tar](https://en.wikipedia.org/wiki/Tar_(computing))** - in Portage as **app-arch/tar**

Please note that these are very basic dependencies and should be already included in any Linux system.

##Meta
Released under the GPLv3 license.
Project led by Horea Christian (address all correspondence to: h.chr@mail.ru).
