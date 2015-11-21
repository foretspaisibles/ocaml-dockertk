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

FROM ubuntu:wily
ADD Library/docker/apt-setup.sh /root/apt-setup.sh
RUN sh /root/apt-setup.sh
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y\
 autoconf\
 awscli\
 bmake\
 bsdowl\
 docker-engine\
 ocaml\
 opam
RUN opam init --root=/opt/opam --compiler=4.02.3
ADD Library/docker/auto_install.sh /root/auto_install.sh
RUN sh /root/auto_install.sh\
 opam:mixture@master\
 opam:lemonade@master\
 opam:rashell@master\
 opam:gasoline@master\
 opam:yojson\
 opam:atdgen\
 opam:base64\
 opam:broken\
 opam:lwt
RUN install -d /opt/local/var/sources/dockertk
ADD . /opt/local/var/sources/dockertk
RUN sh /root/auto_install.sh\
 bsdowl:dockertk
ENV CAML_LD_LIBRARY_PATH="/opt/opam/4.02.3/lib/stublibs"\
 OPAMROOT="/opt/opam"\
 MANPATH="/opt/opam/4.02.3/man:"\
 PERL5LIB="/opt/opam/4.02.3/lib/perl5"\
 OCAML_TOPLEVEL_PATH="/opt/opam/4.02.3/lib/toplevel"\
 PATH="/opt/opam/4.02.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
