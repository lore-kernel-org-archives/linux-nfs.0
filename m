Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33806 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156Ab2GLDrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 23:47:08 -0400
Date: Thu, 12 Jul 2012 13:46:57 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 callback: too many open  connections, consider increasing the
 number of threads.
Message-ID: <20120712134657.18a23174@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Kgu6ReJydZIyi7XEKM.7ma9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Kgu6ReJydZIyi7XEKM.7ma9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Trond et al.

 we have a customer who reports getting the message:
        [10879512.275305] NFSv4 callback: too many open  connections, consi=
der increasing the number of threads.
        [10879512.275315] NFSv4 callback: too many open  connections, consi=
der increasing the number of threads.
        [10879517.276133] __ratelimit: 133011 callbacks suppressed

Of course you cannot increase the number of threads handling callbacks.

The patch below will get rid of the message - which is presumably mostly ju=
st
noise - or possibly change it to
   NFSv4 callback: too many open connections, consider increasing the max n=
umber of connections
if the number of connections gets too high.

This isn't much good as this patch doesn't allow the max number to be
increased.
Do we want to make the max number of callback connections configurable, or
should we find a way to silence that message.
(For lockd that message is valid as there is a sysctl to change the max
number of connections for lockd).

Thanks,
NeilBrown


diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 23ff18f..1129c42 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -265,6 +265,10 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt =
*xprt)
 		ret =3D -ENOMEM;
 		goto out_err;
 	}
+	/* As there is only one thread so we need to over-ride the
+	 * default maximum of 80 connections
+	 */
+	serv->sv_maxconn =3D 1024;
=20
 	ret =3D svc_bind(serv, net);
 	if (ret < 0) {

--Sig_/Kgu6ReJydZIyi7XEKM.7ma9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT/5IsTnsnt1WYoG5AQI56RAAu1VTzFFS5BYMdhcavjOEeWS59PgnoZ2v
CgYy3TSaCJp1nRGcsZHj9rxDGTZ/qT0DDijkHkp0AKXVnn6jQwTUjvgR9QzJgJ4E
7zXO8pRCfQCTxDKQsHVmp/tjoo5+hfLA+7dryS2EJdsjhwXJqmL7S+N/a2CkK/dd
GFVnhl6Nerqw9AuHK/t4Y+s7yKtFx5qoKVGc4hgfCj/rQrXtVK830oO92Cg5XrdJ
7W36+zce5o2Iu3rBdNHU9upCTgVFxurIJPG55guKUsM5U2avURFX/oLSj33LCQgA
eklbvwsE7J/48Ql38TprgrvqSPAp/eHqroABxrNcqKKD6XcnsrYte2PRBsWH473P
g/LqmQHigAim9skTT5lLQ9DeBxCz95NegWQCiqHppX+XFMbRIiPU7kn5j3b4n6XL
VKSTuEjyEdBi+2uueWHPI8UOkHOSuEhgG/T+3RjrMskoHWt6yRJBTdyOWk21cfDV
VbgzBJEoGbuiTOb9S6mr1L4Q58YSqoztjM0xcuCUtzqIB9FnMHvwgv2er4DLwhj5
dlNxzfyiYfb/tdHWpb1la1MihhARC8viCzIxaQbFC2on3t4BOHPWAEXau0fHDCPZ
ObUjxuSegYshGujYKxU/eeqKA3vMzVBOLmrFaNneO3q634H/2Kfl+zkINA8UblyG
1fxgJ8VId/Y=
=6DMO
-----END PGP SIGNATURE-----

--Sig_/Kgu6ReJydZIyi7XEKM.7ma9--
