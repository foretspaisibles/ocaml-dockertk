### apt-setup.sh

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

apt-key add - <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQINBFUXZhABEADkYJb7CISo8527v8lB2lBwHmu6y2PighOKxf+kDMNuBR9ZuPnE
0VblaQcPfH77QYJYdDKMOTAQS+joSApWjJPd8efUEI1zTh2Cpjx7i1co4qTGirW8
iShuyw/U2Usd9lpWQY9jjSg6gQaEvHJ7wDfxPSMqkVQ+ILbFqxn80yV8RpuFLBgZ
Tv9TRbVcmdBNhO1QJidiKa6lBevXXR7hbXOzXTjs6JKQ0yfjxX7AQpGY2PbyvPcY
isC4W1CoIGAVNqDCaDL1/OLHgnVOoKYtYzMdi4aWB8cgUins8/vmTkEJZrA5uE7h
QLhToJu2X3VYD1rOkyk7oWKBx9PaXZlMcvKb1GejK7D54vs1erfA0kw5bmiAj+Tz
eb8CrA7L59iT1a6nsfj5qs9KwpGVGLTfuyhWcnFVBzWAGdlGOrzVzR9ngq1kNCun
l78D/qu6vV5JbeL/44D2RFa4wPG4Zu9Q0vo2srmr00BRZeAOamlWFinEvZCY22n9
PZDS64Z1czb2xtIv7lNSyY6bBwglJTSwpKbYnYenCeuRVkpGWwuUZnRNZWDtU+Nd
yds6Po3vV8lZU/cmbExnQu2QghLVwM5bEFYtreWgkF2Z1GTv+t/4TBGjmbL2S+lj
V/jlHdir3EjcSEQB7SsOKemx6AE03Unvp3QQavnpFurrCdGrDLoB2NxKwwARAQAB
tCRMYXVuY2hwYWQgUFBBIGZvciBNaWNoYWVsIEdyw7xuZXdhbGSJAjgEEwECACIF
AlUXZhACGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJECwORDYci2WybRUP
/1XHCV3QIwXaJ8qhPHT/Kv6YG01KfP6ohFbvnq3rX8Ipl7kwP/BjxdwWzIr1/KIa
PS0K7QLSvJoCo9iznnnMV2KYD+5blGgjgZnKI2McYZ5bOOB4OEt+73j9NmOXBdGp
wm+gY7tXmmRC8qb+nZ/aqM9Lg0oUCxIcvj1+hVjYsG/bn0RgmR/hB7/pWwO/pmfA
h6z/tnGTTg+u/arL8S3lTnFHezOUNGrahMAv818Y+hFWJx0ayd3/GzFEeZLZRH2O
oaNaFTrRsoQIAuYfmdf1n9nl0GhhQ306/m3eRlEyZbnt5pkS5HMreRa5vg95thOO
ldz3OvSWheMIvk/WtWKmW/QmRnJNCHds4n61bby8rq3pJ2imy0ude4S880m0/Hbi
Uccpk86GZfHTgt3OMFLkq9Bt90PAo5EEfszVCVE/fBhLw02kgusjKBrhyXiFFSLP
ioXzQKFFRbbgLyhaD5yirZ6N//Mef4WUjrp/sFKqZIiLCgk/e0DJ6NaLiGmEOwIm
UoPHXsW+InwijFKOFDkwPe098LaVSpCRr/3HOiC8nksEE3pzJDsVIBTYsIr0rk+S
l5WIsvePRlnci+0jfv5MfFnAQcLfjS8bxb4NKFS3Bq9vKvGDnx3vZGlV0WNedgis
vpvDK8k4J7T/6CSj0ZUwGZ8hURBkudoPNASZAEg0+G8K
=nCz6
-----END PGP PUBLIC KEY BLOCK-----
EOF

apt-key adv\
        --keyserver 'hkp://pgp.mit.edu:80'\
        --recv-keys 58118E89F3A912897C070ADBF76221572C52609D


cat >> /etc/apt/sources.list <<EOF
deb http://ppa.launchpad.net/michipili/quintly/ubuntu wily main
deb-src http://ppa.launchpad.net/michipili/quintly/ubuntu wily main
deb https://apt.dockerproject.org/repo ubuntu-wily main
EOF

apt-get install -y apt-transport-https
apt-get update -y
apt-get upgrade -y

rm -f /root/apt-setup.sh
