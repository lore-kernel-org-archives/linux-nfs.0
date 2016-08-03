Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37858 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932669AbcHCXxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 19:53:41 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 04 Aug 2016 09:33:15 +1000
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Revert "SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose"
Message-ID: <87a8gtpgw4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This reverts commit 4b0ab51db32eba0f48b7618254742f143364a28d.

This change causes 'rpc.nfsd' to hang for long time if rpcbind is not
available.
If
   --no-nfs-version 2 --no-nfs-version 3
is given, the delay is about 6.5 minutes.  When trying to register
all versions, the delay is over half an hour.
Before this commit, and after reverting it, nfsd fails (when v3 is
requested) or succeeds (when only v4 is requested) immediately.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/xprtsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 111767ab124a..2a938055e95b 100644
=2D-- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -795,6 +795,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 	xs_sock_reset_connection_flags(xprt);
 	/* Mark transport as closed and wake up all pending tasks */
 	xprt_disconnect_done(xprt);
+	xprt_force_disconnect(xprt);
 }
=20
 /**
=2D-=20
2.9.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXon88AAoJEDnsnt1WYoG5P/QQAKJocPLcwiqBMZslj3JaY0Wu
10vl0Gyx2YeIELsXQyJGFy87V1ZMK14bKX/LSr0pDqJTtBdHn2ZhNcE1EsBRLQqx
iAbsOGcNh54fc4vKRjCNqUdhDzTs9QAdx/In1Y07sPqweSMGp/oPUMOqHIp5Qrth
TMBk4+KVxdIE2F7gxmof0XdJGE9/scohZk5plGao6cII1Pp0jNKwSw+j/O41S51D
mePzKkuJd+ixR7NLz+cG235FKljq4lE275uO/MRcxzvTkF2aszrCGX3s6BxhAHLa
ljk1hQ/ikw92SrVflawMou5hGo2Cb1nspEBJXWmq90d+jzAzv5gIa4FFQrh/dAhH
0Aosrx3R/7rFDxQTJ34wpEt1cAslK1gDJD+OC1jCnDcmAnVtSZDVPH1hQolhF3Xa
cA6FHsLOWshCfx3QnID0bmU3cMT2FvLBVnJ1xmK0+ToYD9Jf8DJxdupM1oqfPtr2
El7YMsO2F9hxeCWj1yp1IaVM9fsH9JtX/P7//8UNa8vBo7zgtN5+4fu0co9dJdhv
rqy/XpML9E7zduSdOmpbwp/w/elxhLi94GoC5ZQD4K0c6TOoFpENWmYngUFmtYwf
jO4EqxylFrRwkRaQ9SX3SMv3bY0NZtYbEWsKXQpG9Bttzwk3fiVM8KBu7lwFFDRS
SzXD/FqbJ0cruJBZmYJf
=GNKY
-----END PGP SIGNATURE-----
--=-=-=--
