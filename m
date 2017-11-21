Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34368 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbdKUVXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Nov 2017 16:23:49 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 22 Nov 2017 08:23:41 +1100
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs: remove dead code from nfs_encode_fh()
Message-ID: <87tvxn1g2q.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This code can never be used as the IS_AUTOMOUNT(inode)
case has already been handled.
So remove it to avoid confusion.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/export.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 83fd09fc8f77..2b80a6652818 100644
=2D-- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -48,10 +48,6 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_le=
n, struct inode *parent)
 		*max_len =3D len;
 		return FILEID_INVALID;
 	}
=2D	if (IS_AUTOMOUNT(inode)) {
=2D		*max_len =3D FILEID_INVALID;
=2D		goto out;
=2D	}
=20
 	p[FILEID_HIGH_OFF] =3D NFS_FILEID(inode) >> 32;
 	p[FILEID_LOW_OFF] =3D NFS_FILEID(inode);
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloUmV0ACgkQOeye3VZi
gbkoZA/6AnZ4cZ4XtZWw0u01RAxxBn45RTjALrPYTp9eoi3N/9Hbi0tqhEdOT417
zUxoTUYhpMZ5NjdwF8BRZ0IlEEqThjVzEKYBZsha6DdtO2T0oOOUOqbTv3SG0xHH
q+kFHQdjeY6cIBHPp23p0/h6+x8PttRjXIIp3Pjwof0gS949B0feKXI/35DdS1ke
X8uhiUecAoQyh6N7sDymeCnnvk7doD7RuBBMhMhp7VXjptdq2TLFeqqfQ5meJx25
a9jo2mpCfFXC6BgKj2hQv4iXFc0IEXpiAVTsp+FrDKz712s+LQ5EOye5J53KkiFw
GPd4g/8ZiWC9EJM3IIKQStEfS2u7A1FXrWsMivO/QLqS91yCmYfgDIaoKUiE6elF
Td51FmUTe13kcYJHiqJ9bIe4cFQ7vn8h0uOiy6tXjzaKNopgTbNuVrtFqu/1op9j
iyjW1771JivARym/aHEPz7SXYk7abTfVG5DvB/wWaUTH90UzuRsrtkkLGAGNLWcw
i+bebP8L156hyaTBXqC8+7IleJURn9QAUHPemWADIOU1vkKgApneLOVVq2IoSIAu
NZRplAJkVL+Q570Bc3Ld1kCZUVuVF7O88Se/k8ZbPSR3M5TTicU9ubLXCcw82iWA
0bbABnAke4HqDdqv8ddATu+R0lQSt41Ztg/pPnYD9NMr34f+zns=
=w9Fw
-----END PGP SIGNATURE-----
--=-=-=--
