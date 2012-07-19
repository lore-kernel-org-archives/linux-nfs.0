Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46734 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260Ab2GSGqA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jul 2012 02:46:00 -0400
Date: Thu, 19 Jul 2012 16:46:02 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 callback: too many open  connections, consider increasing the
 number of threads.
Message-ID: <20120719164602.7d5aadaf@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Ayg78SY6UqX1dxpkHj.8jVE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Ayg78SY6UqX1dxpkHj.8jVE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


[resending - with more current address for trond]

Hi Trond et al.

 we have a customer who reports getting the message:
        [10879512.275305] NFSv4 callback: too many open  connections,
 consider increasing the number of threads. [10879512.275315] NFSv4 callbac=
k:
 too many open  connections, consider increasing the number of threads.
 [10879517.276133] __ratelimit: 133011 callbacks suppressed

Of course you cannot increase the number of threads handling callbacks.

The patch below will get rid of the message - which is presumably mostly ju=
st
noise - or possibly change it to
   NFSv4 callback: too many open connections, consider increasing the max
number of connections if the number of connections gets too high.

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
@@ -265,6 +265,10 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt
*xprt) ret =3D -ENOMEM;
 		goto out_err;
 	}
+	/* As there is only one thread so we need to over-ride the
+	 * default maximum of 80 connections
+	 */
+	serv->sv_maxconn =3D 1024;
=20
 	ret =3D svc_bind(serv, net);
 	if (ret < 0) {

--Sig_/Ayg78SY6UqX1dxpkHj.8jVE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUAetKjnsnt1WYoG5AQJuQRAAqXsPPJYMWjz6Yx0rf44nX+Dlp1F+evAw
5ArKwO77WzjdKeRQ5NHjjZ2Pr0JgC965G7khikjCqHO0LAePafpeCWGe/NrESisr
opE9cztqW4ljg2H+EWXJjJUe8TpgZimmdFkFmy7dDAxn6Rv3sSM68r65HMfENtPT
LTE51IGLN4DNQKvtWEnzBt3/QDDfhb750O6UcIq90zAfnUKF73QfiHbvmiVN0V9d
wWDHUpboiF9sIFNw+y/N9k+rbye1hEkYzX0UHg+W7oaeVUMiadMmx1IsWfo79eo+
sgsOSTwHhm+Mmj40K+OJnOlIFeB7c3CNF9Ek9Lyd1OKzqj/IvMwri8ARcVAEUcNF
q9MNn2MWPhr2hxTp8eA80XJ/flhj8Z7/r+UzV+AvbccRHlgIpkSW8D4PGIOCJjWL
joecndMAldAtiFUfof8vr6VBwvDV5aKErxmoCQw2QKVREni2i5ict2OtCcWzDOAE
USpoTxTv6fV407cYxvm96vDZlp7FEr72qc9jdyz5pcfwGmNjIrh8GqCnmDdRxJx+
8l9KBForqm28PAzbeq8yrjIljIvD520TJiqj/1lPvMnD88maqKxE4aPpwc2f7iE0
TY6ycVYcrG7bTbyHPYePzrS1Glu26lGFE+Y/S/3sr0sTOye7d1qCctQ/I7V0QraW
+S9tnJ/+GGY=
=fzX6
-----END PGP SIGNATURE-----

--Sig_/Ayg78SY6UqX1dxpkHj.8jVE--
