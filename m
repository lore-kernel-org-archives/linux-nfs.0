Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43964 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab2BVKNR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 05:13:17 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull 4 bugfixes for the NFS client
Date: Wed, 22 Feb 2012 10:13:10 +0000
Message-ID: <1329905589.3043.10.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-kJE3mws0/5SmWWp9H1Qr"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-kJE3mws0/5SmWWp9H1Qr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull from the signed tag "nfs-for-3.3-4" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tag nfs-=
for-3.3-4

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4proc.c       |  130 ++++++++++++++++++++-----------------------=
----
 fs/nfs/nfs4state.c      |    2 +
 fs/nfs/nfs4xdr.c        |    5 ++-
 include/linux/nfs_xdr.h |    2 +-
 4 files changed, 62 insertions(+), 77 deletions(-)

commit abe9a6d57b4544ac208401f9c0a4262814db2be4
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Thu Feb 16 11:17:05 2012 -0500

    NFSv4: fix server_scope memory leak
   =20
    server_scope would never be freed if nfs4_check_cl_exchange_flags() ret=
urned
    non-zero
   =20
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Cc: stable@vger.kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f86f36a6ae625eda87a13e1ea102a908e08f491b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 14 20:33:19 2012 -0500

    NFSv4.1: Fix a NFSv4.1 session initialisation regression
   =20
    Commit aacd553 (NFSv4.1: cleanup init and reset of session slot tables)
    introduces a regression in the session initialisation code. New tables
    now find their sequence ids initialised to 0, rather than the mandated
    value of 1 (see RFC5661).
   =20
    Fix the problem by merging nfs4_reset_slot_table() and nfs4_init_slot_t=
able().
    Since the tbl->max_slots is initialised to 0, the test in
    nfs4_reset_slot_table for max_reqs !=3D tbl->max_slots will automatical=
ly
    pass for an empty table.
   =20
    Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9f9a03150969e4bd9967c20bce67c4de769058f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Feb 9 15:31:36 2012 -0500

    NFSv4: Ensure we throw out bad delegation stateids on NFS4ERR_BAD_STATE=
ID
   =20
    To ensure that we don't just reuse the bad delegation when we attempt t=
o
    recover the nfs4_state that received the bad stateid error.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org

commit 331818f1c468a24e581aedcbe52af799366a9dfe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 3 18:30:53 2012 -0500

    NFSv4: Fix an Oops in the NFSv4 getacl code
   =20
    Commit bf118a342f10dafe44b14451a1392c3254629a1f (NFSv4: include bitmap
    in nfsv4 get acl data) introduces the 'acl_scratch' page for the case
    where we may need to decode multi-page data. However it fails to take
    into account the fact that the variable may be NULL (for the case where
    we're not doing multi-page decode), and it also attaches it to the
    encoding xdr_stream rather than the decoding one.
   =20
    The immediate result is an Oops in nfs4_xdr_enc_getacl due to the
    call to page_address() with a NULL page pointer.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: Andy Adamson <andros@netapp.com>
    Cc: stable@vger.kernel.org


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-kJE3mws0/5SmWWp9H1Qr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJPRL+1AAoJEGcL54qWCgDyW0AP/34kcBzJPVEn5QGucYUwYb1J
EJKXF0SG32jdayRQjnGr+eFt2tCDotxRn8yJGyMLbcGimcgVEbfchpFzas5cKm8F
TM4n4EjCRUqLq0BL7dD3QbCSbcUqP+OZ20DfHJlHVC1inZyfdLwoJCHU0PfHJ/ld
YVuUfgZzwyoYIxnybk9j/zQpLOYABMwLKQ+F/m0CxNNY15id1ThRN+nmCnQM0YR3
e+y8XIn9TZnkJ8YLBRhmXZOm+S1Kh/LWBuUZCFkiQohkFdHR61eXwok47B5Ikyfu
BBOkf86mDWnIz8qVb3YXS+pfVTF8tv2gElGEITYDjZUjrAtPTXZKNlqVI34U/CeA
YNlwTcT+/pfRIxwrPTe0Xs2S4GCkRo81M9HER5ozzJar0D2zJOFD/EEG1ATIkY+l
CywnjblRhE+k0ZSxSQXeUOISit7cbRqU/H0QMx9iOTHvw5ZZQiWxRkNztqdoC58p
Lds6PABiBZUd1qH4L7VCSUQwqmTeLFYey6L062fdy53QcXuhBM2vW7V3+t+dbj78
MG8vpwHDoQj5qpYtKdnjySCb6a+ZKAEaAhBjRlAkqjwFPMoRTfBzvepVGCGxpJVo
TpABeAKZy341qBcZJW6QrhVyhb5L2bXdU9r5Bd+4W4+IqIo1q3Q9wcovqVk/mo44
NnxVixxFPkV3x7J7NoU3
=ub8E
-----END PGP SIGNATURE-----

--=-kJE3mws0/5SmWWp9H1Qr--
