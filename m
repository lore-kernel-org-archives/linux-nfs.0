Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47704 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbbAMWmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2015 17:42:38 -0500
Date: Tue, 13 Jan 2015 15:17:43 +1300
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>, "L. A. Walsh" <suse@tlinx.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Cc: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] locks: fix NULL-deref in generic_delete_lease
Message-ID: <20150113151743.7c260163@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/k1Zo20/ttWbC7mPfwiJZPPh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/k1Zo20/ttWbC7mPfwiJZPPh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



commit 0efaa7e82f02fe69c05ad28e905f31fc86e6f08e
  locks: generic_delete_lease doesn't need a file_lock at all

moves the call to fl->fl_lmops->lm_change() to a place in the
code where fl might be a non-lease lock.
When that happens, fl_lmops is NULL and an Oops ensures.

So add an extra test to restore correct functioning.

Reported-by: Linda Walsh <suse@tlinx.org>
Link: https://bugzilla.suse.com/show_bug.cgi?id=3D912569
Cc: stable@vger.kernel.org (v3.18)
Fixes: 0efaa7e82f02fe69c05ad28e905f31fc86e6f08e
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/locks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index 735b8d3fa78c..59e2f905e4ff 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1702,7 +1702,7 @@ static int generic_delete_lease(struct file *filp)
 			break;
 	}
 	trace_generic_delete_lease(inode, fl);
-	if (fl)
+	if (fl && IS_LEASE(fl))
 		error =3D fl->fl_lmops->lm_change(before, F_UNLCK, &dispose);
 	spin_unlock(&inode->i_lock);
 	locks_dispose_list(&dispose);
--=20
2.1.1


--Sig_/k1Zo20/ttWbC7mPfwiJZPPh
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVLSARznsnt1WYoG5AQLhUA//Zv3VewujZyvH6XOaZhtBQhBXH4SliyDx
iU9cXIokBw8w/Zmf0BV4PTEbb/uIEM87PV1QBIIy7L/4hfv92d+R6lERNfExxIsV
WaZHqDbdG2TdRLyyAAM4EFaBWTkt4Gw+8n2WIoLpexkByyJ1sxrZRpnr/+vuwSXB
VYI05EfXdABlcNW/iLKdj+NKqlYrCB2q3Qy3Zl9ypS5y8k7atd+3IZt0sMsIbWc0
IruNNPENynWSvC93rq4bdQzsKI0g0FhdyPCXhTubHbFXFCRSx+OL4saawxvQRzJm
2QfxWP25lRB9PZAh+ZLP64cTmJ4KuanJJzAsBi9JfDAJ6kZ0i8cWKguIM11yYZNZ
gH6bD0qJyYOJpZb3+qrNw58LfhBUgBDl78MbQLYc+Xyq9JN4aP31PmMDm+YGlUk0
uZa/QryukapkX5HEgjpuPDtdiKLl5WKB6firq/X7Nr1+kI9dcbxqSEQrct7Tkw3g
llt1XV5cgKAcdU1LUlWGj693p+vGz2akb/ARglv8Q6MIeW/8q1tu6il9/yBjuxfG
avEi5baSy3V2MAJElcPBAzYEbriz1WiQ2g/URuflb5fcMgCY7C5YiHx+E1sW1/qP
FJoHpoQhRxYY9eDxSE2n80GjGAqIi9PyXW9eiX4XwPilCVRdsUrJDH6uavsk9vTs
KYAt0sgTViY=
=L+kz
-----END PGP SIGNATURE-----

--Sig_/k1Zo20/ttWbC7mPfwiJZPPh--
