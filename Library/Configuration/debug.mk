### debug.mk -- Configuration for developement

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

.if !empty(THISMODULE:Mocaml.*)
COMPILE=		byte_code
USES+=			debug
.endif

### End of file `debug.mk'
