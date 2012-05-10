Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51910 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279Ab2EJREW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 13:04:22 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "Linux NFS mailing list" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull one bugfix for the NFS client
Date: Thu, 10 May 2012 17:04:20 +0000
Message-ID: <1336669458.3962.8.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-FwuHNlfYtb9Ko+nP81I5"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-FwuHNlfYtb9Ko+nP81I5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull from the signed tag "nfs-for-3.4-5" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs=
-for-3.4-5

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 net/sunrpc/auth_gss/gss_mech_switch.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

commit 7bdf7415a6b8ec31f86b3ad3eaa241257ecb7c4c
Author: Steve Dickson <steved@redhat.com>
Date:   Thu May 3 11:47:08 2012 -0400

    auth_gss: the list of pseudoflavors not being parsed correctly
   =20
    gss_mech_list_pseudoflavors() parses a list of registered mechanisms.
    On that list contains a list of pseudo flavors which was not being
    parsed correctly, causing only the first pseudo flavor to be found.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-FwuHNlfYtb9Ko+nP81I5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJPq/USAAoJEGcL54qWCgDy8H0P/jBkHFM6gC8nJOoIzH0aogaZ
Mn3vNRFDvDtO4o5YvBN1olf5XBHwupkNHXNljjrw4w1Rpjr/Dnykh28axZYOOXmR
3tTC4XYeoAAcra+j5I9l8nNmTzt5C55BaUA7cgv04xJhvywcdusgKMzc59GoBcFz
vrNmDsnuy4EV8Mj5fL8acCHaGZKc3wpTNE1jdbrmXIQUE9JYV6p4NoyThLc3aRj2
3Q8KIC+P/a+O7xDBw6YsK3qzzoSQDtoZuajP0lieolGCnITZiZ18KhmNQaC4OEDy
PYBmlIoy+raAA4HAqelFsddd8h/mRQA5pxm/OqzDYqvOpbpOPX4UMZDZn9scALZq
5oy3CUA8t5rtrI5tgd+dhBQmKrJNE6BJVVBmfDYxrGk4Vvfrn2U1YKaMGM86+znI
x4ZNvVLfywfZh4E9QT4sj/c5E/PMN9L1QUD5uWfcaxZ73ABfSq2LqOJbpCYET9V9
GMfuHECpT4ENicZbzYGMccdeOiKphy+DmsKFy8yy3pmr3XD5XU79xCF94Kgcjum+
rCAuD7QZjb47x1K5mOlaX8k/bFgblt050WwTCGXSrh4p89/qpMmK+762UcuEgUYo
YaJ87SLi9E3h84CbLGdxQ9Ql9jRR8SGSC+BQg/t47Vzw5UGw0at2k8yyJs6jkQRE
0KX3PI2vRP1sgzksqFZf
=zX6E
-----END PGP SIGNATURE-----

--=-FwuHNlfYtb9Ko+nP81I5--
