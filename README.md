# The missing Docker Toolkit

This addresses a few shortcomings of the base **docker** toolkit.  As
this technology currently enjoys a growing user base, I hope that this
toolkit will be helpful to many.  This *missing Docker Toolkit*
provides two important tools:

- A garbage collector **docker_gc** which allows for automatic removal
  of outdated docker images according to complex criterions, such as
  “keep the 3 last images of our product, the very last image of our
  base linux distribution, otherwise remove everything which as least
  three days old.”

- **STILL IN DEVELOPEMENT** A docker builder **docker_build** which
  automatically assemble a docker context of dynamic parts, such as
  source code repositories, or online resources.

**The missing Docker Toolkit** is based on [Rashell][rashell-home], a
shell-programming library for OCaml.

[![Build Status](https://travis-ci.org/michipili/dockertk.svg?branch=master)](https://travis-ci.org/michipili/dockertk?branch=master)


## Docker garbage collector

The docker garbage collector applies a policy defined in the
configuration file `~/.docker/docker_gc.conf` to determine which
locally found images are considered obsolete and to be removed.

A policy is a list associating predicates recognising docker images to
preservation rules telling if recognised images are to be removed.
The following predicates are available:

- *True* recognises all images.
- *False* recognises no image.
- *Age(n)* recognises images whose age is at least the given number of days.
- *Repository(r)* recognises images belonging to the given repository.
- *Dandling* recognises anonymous, leaf, images.
- *And(a,b)* recognises images recognised by *a* and *b*.
- *Or(a,b)* recognises images recognised by *a* or *b*.
- *Not(p)* recognises images not recognised by *p*.


The following actions can be associated to a predicate:

- *Delete* requires the deletion of images recognised by the
  associated predicate.
- *PreserveAll* requires the preservation of images recongised by the
  assocaited predicate.
- *PreserveRecent(n)* requires the preservation of the *n* most recent
  images recognised by the assocaited predicate.

When applying a policy, the first predicate recognising an image
determines if this image should be preserved or not.  The
*PreserveRecent(n)* predicates guarantees that at most *n* images are
preserved among the images recognised by the predicate, even if some
are preserved by a previous policy association.

Here is an example configuraiton file, to be saved in
`~/.docker/docker_gc.conf`:

```conf
# Lines starting with a hash sign are comments,
#  so are empty lines

Dandling                            : Delete
Not(Age(3))                         : PreserveAll
Repository("organisation/repo")     : PreserveRecent(3)
True                                : Delete
```


## Free software

The missing Docker Toolkit is free software: copying it and
redistributing it is very much welcome under conditions of the
[CeCILL-B][licence-url] licence agreement, found in the
[COPYING][licence-en] and [COPYING-FR][licence-fr] files of the
distribution.


## Setup guide

The **missing Docker Toolkit** is written in [ocaml](ocaml-home) and
it is easy to install using **opam** and its *pinning* feature.  In a
shell visiting the repository, say

```console
% autoconf
% opam pin add dockertk .
```

It is also possible to install the **missing Docker Toolkit**
manually.  The installation procedure is based on the portable build
system [BSD Owl Scripts][bsdowl-home] written for BSD Make.

1. Verify that prerequisites are installed:
   - BSD Make
   - [BSD OWl][bsdowl-install]
   - OCaml
   - GNU Autoconf
   - [lemonade][lemonade-home]
   - [rashell][rashell-home]

2. Get the source, either by cloning the repository or by exploding a
   [distribution tarball](releases).

3. Optionally run `autoconf` to produce a configuration script. This
   is only required if the script is not already present.

4. Run `./configure`, you can choose the installation prefix with
   `--prefix`.

5. Run `make build`.

6. Optionally run `make test` to test your build.

7. Finally run `make install`.

Depending on how **BSD Make** is called on your system, you may need to
replace `make` by `bsdmake` or `bmake` in steps 5, 6, and 7.
The **GNU Make** program usually give up the ghost, croaking
`*** missing separator. Stop.` when you mistakingly use it instead of
**BSD Make**.

Step 7 requires that you can `su -` if you are not already `root`.


Michael Grünewald in Schwerin, on November 8, 2015


  [licence-url]:        http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html
  [licence-en]:         COPYING
  [licence-fr]:         COPYING-FR
  [bsdowl-home]:        https://github.com/michipili/bsdowl
  [bsdowl-install]:     https://github.com/michipili/bsdowl/wiki/Install
  [lemonade-home]:      https://github.com/michipili/lemonade
  [ocaml-home]:         https://github.com/ocaml/ocaml
  [rashell-home]:       https://github.com/michipili/rashell
