Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56294 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab2GaEk2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 00:40:28 -0400
Date: Tue, 31 Jul 2012 14:40:12 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 callback: too many open  connections, consider increasing
 the number of threads.
Message-ID: <20120731144012.6d49b114@notabene.brown>
In-Reply-To: <1343690182.8362.6.camel@lade.trondhjem.org>
References: <20120719164602.7d5aadaf@notabene.brown>
	<1343690182.8362.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/hK.P=ZE6qRB670x12t5lfTR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/hK.P=ZE6qRB670x12t5lfTR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 30 Jul 2012 23:16:23 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> Hi Neil,
>=20
> Could you please add the missing s-o-b?
>=20
> Cheers
>   Trond

Here 'tis.  Thanks.

NeilBrown

From: NeilBrown <neilb@suse.de>
Date: Tue, 31 Jul 2012 14:33:39 +1000
Subject: [PATCH] nfs: increase number of permitted callback connections.

By default a sunrpc service is limited to (N+3)*20 connections
where N is the number of threads.  This is 80 when N=3D=3D1.
If this number is exceeded a warning is printed suggesting that
the number of threads be increased.  However with services which
run a single thread, this is impossible.

For such services there is a ->sv_maxconn setting that can be
used to forcibly increase the limit, and silence the message.
This is used by lockd.

The nfs client uses a sunrpc service to handle callbacks and
it too is single-threaded, so to avoid the useless messages,
and to allow a reasonable number of concurrent connections,
we need to set ->sv_maxconn.  1024 seems like a good number.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 23ff18f..9cb1215 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -265,6 +265,10 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt =
*xprt)
 		ret =3D -ENOMEM;
 		goto out_err;
 	}
+	/* As there is only one thread we need to over-ride the
+	 * default maximum of 80 connections
+	 */
+	serv->sv_maxconn =3D 1024;
=20
 	ret =3D svc_bind(serv, net);
 	if (ret < 0) {

--Sig_/hK.P=ZE6qRB670x12t5lfTR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUBdhrDnsnt1WYoG5AQIB3xAApWvPXmrU/HzX3TT4kCYfKhbLEokeOTvT
wC79qwkc9begsdDIp03OeHqNp/uydFZjAHJwfhIEipqMz+PCtVfuJvq3fsJJIDAz
NvevQhQIzgECcZkQW6/jaHbfajCBH2ouZ5mHSAPfygRLsAtZC+8hsLBSa1Xo/SqC
hVld06ZSTd/bsbzeobnGZWp/NQ3m821XmJfZ7I6yJQnVZxF1K2VQ6mh+Q2PL8Hly
tB99jh22S2WS/rqzbLShunasbxSHerV4psgqe6SLOt0VWIdOW4W/uzZTXPwYH+rl
mVcZfLkz9hL0CDBq5iJxAVvLM+xVQhkSeCHgs6zo7SsAfKdhECQt9dXlD5A7eDX7
TLRioh/XS0j0ZTsz1/q7q06850gamxnGy4Shrx+yCMtRRwTQ8aAKaJaISPUf8hBP
kz27koX/tXQYXytE/YNj2lo0npLOWMH2iHQtfQnEIkmo0xfPtT2hbzF1nU2g64QF
w43XI9c1SNczPuJOaotVUkze9JjnQmEVscLLGHu2OW+/SmR2yLYQSQGq1VS0WFEJ
XPl2NMI1Vno3GWf/SzAC95jbLZbE6r4a8CmBaakQPKBG+xzCIxgTW2qgwN84qcS5
mGZfP8Ye1loIvK8aerovmVRkJ8a1SStLa94i42Piu4edZ5f1krf6V6LVwXJxrWQd
14SCuNBxzPQ=
=RmXV
-----END PGP SIGNATURE-----

--Sig_/hK.P=ZE6qRB670x12t5lfTR--
