#!/bin/sh
# Example for use of GNU gettext.
# This file is in the public domain.
#
# Script for cleaning all autogenerated files.

test ! -f Makefile || make distclean
rm -rf autom4te.cache

# Brought in by explicit copy.
rm -f m4/nls.m4
rm -f m4/po.m4
rm -f m4/progtest.m4
rm -f po/remove-potcdate.sin

# Brought in by explicit copy.
rm -f m4/csharpcomp.m4
rm -f m4/csharpexec.m4
rm -f m4/csharpexec-test.exe
rm -f m4/csharp.m4
rm -f csharpcomp.sh.in
rm -f csharpexec.sh.in

# Generated by aclocal.
rm -f aclocal.m4

# Generated by autoconf.
rm -f configure

# Generated or brought in by automake.
rm -f Makefile.in
rm -f m4/Makefile.in
rm -f po/Makefile.in
rm -f compile
rm -f install-sh
rm -f missing
rm -f config.guess
rm -f config.sub
rm -f po/*.pot
rm -f po/stamp-po
for f in po/*/*.resources.dll; do
  if test -f "$f"; then
    rm -f "$f"
    rmdir `echo $f | sed -e 's,/[^/]*$,,'`
  fi
done
