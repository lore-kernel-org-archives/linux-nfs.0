Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46398 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751722AbdGXFgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Jul 2017 01:36:13 -0400
From: NeilBrown <neilb@suse.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 24 Jul 2017 15:36:03 +1000
Subject: [PATCH] SUNRPC: ECONNREFUSED should cause a rebind.
cc: linux-nfs@vger.kernel.org
Message-ID: <87vamiwg58.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you
 - mount and NFSv3 filesystem
 - do some file locking which requires the server
   to make a GRANT call back
 - unmount
 - mount again and do the same locking

then the second attempt at locking suffers a 30 second delay.
Unmounting and remounting causes lockd to stop and restart,
which causes it to bind to a new port.
The server still thinks the old port is valid and gets ECONNREFUSED
when trying to contact it.
ECONNREFUSED should be seen as a hard error that is not worth
retrying.  Rebinding is the only reasonable response.

This patch forces a rebind if that makes sense.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/clnt.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2e49d1f892b7..69a9e5953744 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1903,6 +1903,14 @@ call_connect_status(struct rpc_task *task)
 	task->tk_status =3D 0;
 	switch (status) {
 	case -ECONNREFUSED:
+		/* A positive refusal suggests a rebind is needed. */
+		if (RPC_IS_SOFTCONN(task))
+			break;
+		if (clnt->cl_autobind) {
+			rpc_force_rebind(clnt);
+			task->tk_action =3D call_bind;
+			return;
+		}
 	case -ECONNRESET:
 	case -ECONNABORTED:
 	case -ENETUNREACH:
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll1h0YACgkQOeye3VZi
gbni1hAAjqZgLvVH6CHRQ4Si33TbdFOtsNbiW3g0g7ZCUiUVwnpqyHxBYmnbEq+5
R74HtmlD54lhBscqkppdk6ZrqkYc75e9GVKPPHc80ubQhs67CkHD7gudUb77oxF2
oqPKktqTHGTRnWnaPYYxY7LSejgjCMaf3K0BYd5vathcZXZo1lJ+DwV0Ydd2h2fO
phnWOevMf/jmXOiZIRlTAW1fOqoBpYw+CjSMaHoact8PSka/CiuCqnVc9yqJ8FIa
yjGeI70axgGUCnfq36rY53tkntzMU8daIgJjTCmvnunQMsCP6C5/m+wQrdv18aCd
mbSP6vYuDZhc/5wa7U+KNUGiBEnqt2GC9dtkwFitWvBk6rqGMK+nyri7ecklhw+B
Y0pjXEGvuJiuAU/PYIB+aw4RvS/IK6A2FhUzzqenNAPJcWayw2uWQ1H55x/zzaBS
HaRHsaAyx8CM14LZoZV4jpQT1FPBeYqaSiR1Wy71f4jRhCYYzl03+JoHHRL4TIPi
+6VF5f9pnDuYM2KoQBQKptbaZROwDUtoXj4VQSVH0g7oRQx64SBzODgPVHfLg/fT
t7AkfzWlUfQodnaT1IbSFzryxudmREh+TCTqkGFdYg0H862IsuLn4bdqGCYYHumq
RzaiNc761ojHYCTGlgCVtd9Qpmz4/iJxZ0mxGYMqxz4Mzz1mYDU=
=qIYB
-----END PGP SIGNATURE-----
--=-=-=--
