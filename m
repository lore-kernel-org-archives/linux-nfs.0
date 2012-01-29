Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23669 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031Ab2A2WPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Jan 2012 17:15:05 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull 1 bugfix for the NFS client
Date: Sun, 29 Jan 2012 22:14:58 +0000
Message-ID: <1327875297.6246.1.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-x7voXplEQHfTeGV9L5fl"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-x7voXplEQHfTeGV9L5fl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull from the signed tag "nfs-for-3.3-3" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tag nfs-=
for-3.3-3

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 net/sunrpc/auth_generic.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

commit 875ad3f8e7dff6bc1d053e5bfe73d8e8d2e6ae67
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 23 12:49:36 2012 -0500

    SUNRPC: Fix machine creds in generic_create_cred and generic_match
   =20
    - generic_create_cred needs to copy the '.principal' field.
    - generic_match needs to ignore the groups and match on the '.principal=
'
      field.
   =20
    This fixes an Oops that was introduced by commit 68c9715 (SUNRPC:
    Clean up the RPCSEC_GSS service ticket requests)
   =20
    Reported-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-x7voXplEQHfTeGV9L5fl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJPJcThAAoJEGcL54qWCgDyigIP/iJkRkVvzJ6uaLpxiCvHRrY7
GJeHmcl1NqpJ+lkxITxqelYacXMIedRXtPwwbsMkqE6WGIAo9QWmjoPR8fHjt/3w
R0nhtwnmWgkW47apE3RI0RmZCIKLxtCJ1Vx+AlSnd4fNkih+M6h5uvVGOnhIjyl9
JliaNNPi54Tqfop5aqoapxUYeCpg0mqR2MSuFXG9M3tSglyVPhEul6ymPBHX+iu1
8ztVqEuuy8F+cxKEB77S8ZXODWx2E6+m5wlrasPk0lR/vpF+cwZcTCoryFMGrlh/
/Wm18N1v2WwxH31p3rCL5ktm/+xI31tHcLMVIlKLqcZW8WmI0QXxTOF1hEPrKk5S
3GQGgtrmV3B3mJidlBZTiyinJ5fE7D0xa7jYNhQH1tZ/XwMWEP/gw2q8I16s7Nm1
xl7Dz0rlZ5/d86o+sbm1gXyAoE8MEmvmFuH/djlCqnRwXYWXXSRe2/qjWWS+zvgT
leQUta1IvlmnXmO072ajsCr4iLT/q6LYwMZD6tHFugNZSeRhYtHLr4k0XNRkMnVa
DIv5FvX+d8+fa9/T2qp3HzWOj1l9jY0qwmhWA+NiLcEwCgkO2DkA4tTKo+DWJxR2
90gJFCSoz8Be5fOyk7SaLMgFz6Ebhd9IMP44S8rDhCkixX79OTUR2dpbwrUvJjdU
5gzewCTDuaqcANY98eGS
=b+9N
-----END PGP SIGNATURE-----

--=-x7voXplEQHfTeGV9L5fl--
