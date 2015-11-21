#!/bin/sh

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

entrypoint='/opt/local/bin/docker_gc'

docker_cert_path()
{
    printf '%s' "${DOCKER_CERT_PATH}"\
        | sed -e "s@^${HOME}@/home@"
}

docker run -it --rm\
       --user root\
       --volume "${HOME:?}:/home"\
       --env HOME='/home'\
       --env DOCKER_TLS_VERIFY="${DOCKER_TLS_VERIFY}"\
       --env DOCKER_HOST="${DOCKER_HOST}"\
       --env DOCKER_CERT_PATH="$(docker_cert_path)"\
       --entrypoint "${entrypoint}"\
       'dockertk' "$@"
