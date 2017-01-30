Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58162 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752105AbdA3GRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 01:17:48 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 30 Jan 2017 17:17:00 +1100
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSDv4: use export cache flushtime for changeid on V4ROOT objects.
Message-ID: <87mve9rs0z.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you change the set of filesystems that are exported, then
the contents of various directories in the NFSv4 pseudo-root
is likely to change.  However the change-id of those
directories is currently tied to the underlying directory,
so the clinet may not see the changes in a timely fashion.

This patch changes the change-id number to be derived from the
"flush_time" of the export cache.  Whenever any changes are
made to the set of exported filesystems, this flush_time is
updated.  The result is that clients see changes to the set
of exported filesystems much more quickly, often immediately.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfsd/nfs4xdr.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8fae53ce21d1..dbff0122b784 100644
=2D-- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1966,9 +1966,13 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *arg=
p)
 	DECODE_TAIL;
 }
=20
=2Dstatic __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode=
 *inode)
+static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *=
inode,
+			     struct svc_export *exp)
 {
=2D	if (IS_I_VERSION(inode)) {
+	if (exp->ex_flags & NFSEXP_V4ROOT) {
+		*p++ =3D cpu_to_be32(convert_to_wallclock(exp->cd->flush_time));
+		*p++ =3D 0;
+	} else if (IS_I_VERSION(inode)) {
 		p =3D xdr_encode_hyper(p, inode->i_version);
 	} else {
 		*p++ =3D cpu_to_be32(stat->ctime.tv_sec);
@@ -2490,7 +2494,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc=
_fh *fhp,
 		p =3D xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
=2D		p =3D encode_change(p, &stat, d_inode(dentry));
+		p =3D encode_change(p, &stat, d_inode(dentry), exp);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
 		p =3D xdr_reserve_space(xdr, 8);
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliO2lwACgkQOeye3VZi
gbljUBAAhXLewqzgA+AWGyr04qefa6Wax8l+fFxmB+3jUbuaL6x/ZDNggM2tVis1
lW9l9iGY+B88C2HxMYo+JQUxQckp7OR9XQuiZSnxy4y9Tr2/A9igP9/GkHLpic6e
o6+GJ7BwQZe6gXZtr1Q4MmHIkSV3qNAd1mQcfjOzEImkQ6cPEAtn3Y/W9sGkHgJ/
xJep7aGcdRGnDYAmDVOgcJCqcPgS1KWIEFx4YTM82NkmfFYrRCJqYw/y26dSNpSJ
dmdEuTEZm600HgbDJcyB7h0IoU5KTFm7iSk5mnGZtARyYfM0L7QqetV7M0+LFPLA
8W9V6yhLAlEu/KRzz+ohlCHlRf6kofkSXAitj1XQmF9BB+ftUxKxwn0a1Yp7T8Bq
nvL0khhQ2t9ESsklqAZDqLbEicaC17nGv1UvlyM+lZI1FLo/tedBzfrsdlhQ3fyE
wEBcNr93pGgYHD40Pn4kXchUr1UwhENMwmBFYOA7AAzfPhadJB40lh6XOc4TUSQn
fVct5Whu/Z+ZVRm0n+VtrOPmByBp/zzj+E/4wUjUg+kT5MQ6p7BpJbgmGqtQnzJX
9j3+cskC39qHOHc2CuzfklRi/HJ2YAFpXro3c+CXRUW0eSl4JyUnIIAmrHwDueLB
U96VF76bJPnm7/7PQ6y/jUA32I+L5Utg6lJDFGbKqkkip/BiEz8=
=1JxE
-----END PGP SIGNATURE-----
--=-=-=--
