dnl autoconf macros for BSD Owl
dnl
dnl Copyright © 2015 Michael Grünewald

# AC_WITH_OCAML_SITE_LIB
# ----------------------
# Define an option --with-ocaml-site-lib which governs the variable
# WITH_OCAML_SITE_LIB.  This variable is substituted.

AC_DEFUN([AC_WITH_OCAML_SITE_LIB],
[AC_ARG_WITH([ocaml-site-lib],
    [AS_HELP_STRING([--with-ocaml-site-lib],
      [install under OCaml site-lib's directory])],
    [WITH_OCAML_SITE_LIB=${with_ocaml_site_lib}],
    [WITH_OCAML_SITE_LIB=no])
  AC_SUBST([WITH_OCAML_SITE_LIB])
])
