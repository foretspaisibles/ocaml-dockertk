### Makefile -- Project Docker Toolkit

# Docker Toolkit (https://github.com/michipili/dockertk)
# This file is part of Docker Toolkit
#
# Copyright © 2015 Michael Grünewald
#
# This file must be used under the terms of the CeCILL-B.
# This source file is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at
# http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt

PACKAGE=	dockertk
VERSION=	0.1.1-current
OFFICER=	michipili@gmail.com

MODULE=		ocaml.prog:docker_gc

EXTERNAL+=      ocaml.findlib:gasoline
EXTERNAL+=      ocaml.findlib:lemonade
EXTERNAL+=      ocaml.findlib:lwt.ppx
EXTERNAL+=      ocaml.findlib:rashell
EXTERNAL+=      ocaml.findlib:str

CONFIGURE+=     Makefile.config.in
CONFIGURE+=     docker_gc/dockerGc_Configuration.ml.in

.include "generic.project.mk"

### End of file `Makefile'
