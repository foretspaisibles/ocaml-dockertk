# generated automatically by aclocal 1.15 -*- Autoconf -*-

# Copyright (C) 1996-2014 Free Software Foundation, Inc.

# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
m4_include([Library/Autoconf/bsdowl.m4])
m4_include([Library/Autoconf/ocaml.m4])


# AC_PATH_PROG_REQUIRE
# --------------------
# A variant of AC_PATCH_PROG which fails if it cannot find its
# program.

AC_DEFUN([AC_PATH_PROG_REQUIRE],
[AC_PATH_PROG([$1], [$2], [no])dnl
 AS_IF([test "${$1}" = 'no'], [AC_MSG_ERROR([Program $2 not found.])], [])])
