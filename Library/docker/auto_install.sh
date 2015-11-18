### auto_install.sh

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

auto_spec()
{
    printf '%s\n' "$@" | auto_spec__filter
}

auto_spec__filter()
{
    sed -e '
/^opam:/{
 s/:/|/
 s/^[^@]*$/&@REPOSITORY/g
 s/@/|/
}

/^bsdowl:/{
 s/:/|/
}
'
}

auto_install()
{
    local method restarg
    while IFS='|' read method restarg; do
        (IFS='|'; set --  ${restarg}; auto_install__${method} "$@")
    done
}

auto_install__autoconf()
{
    (cd "$1" || exit 1
     if [ -r './configure.ac' ] && ! [ -r './configure' ]; then
         autoconf
     fi)
}

auto_install__opam()
{
    case "$2" in
        REPOSITORY) opam install "$1";;
        *) (auto_install__opam_pin "$1" "$2");;
    esac
}

auto_install__opam_pin()
{
    local devrepo

    devrepo=$(opam info --field dev-repo "$1")
    git clone --depth 1 --single-branch --branch "$2"\
        "${devrepo}" "/opt/local/var/sources/$1"

    auto_install__autoconf "/opt/local/var/sources/$1"
    opam pin --yes add "$1" "/opt/local/var/sources/$1"
}


auto_install__bsdowl()
{
    auto_install__autoconf "/opt/local/var/sources/$1"
    (cd "/opt/local/var/sources/$1"
     if [ -x './configure' ]; then
         './configure' --prefix '/opt/local'
     fi)

    (cd "/opt/local/var/sources/$1"
     bmake -I /usr/share/bsdowl all
     bmake -I /usr/share/bsdowl install)
}

auto_install__init()
{
    opam init --compiler 4.02.3
}

OPAMROOT='/opt/opam'
export OPAMROOT

auto_install_init='no'

while getopts 'i' OPTION; do
    case "${OPTION}" in
        i)	auto_install_init='yes';;
        ?)	exit 64;;
    esac
done
shift $(expr ${OPTIND} - 1)

if [ "${auto_install_init}" = 'yes' ]; then
    auto_install__init
fi

if [ $# -lt 1 ]; then exit 0; fi
eval $(opam config env)
auto_spec "$@" | auto_install
