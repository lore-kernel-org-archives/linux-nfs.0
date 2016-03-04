Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50440 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbcCDGUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2016 01:20:23 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 04 Mar 2016 17:20:13 +1100
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall()
 detects a race
Message-ID: <87y49ylq76.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


sunrpc_cache_pipe_upcall() can detect a race if CACHE_PENDING is no longer
set.  In this case it aborts the queuing of the upcall.
However it has already taken a new counted reference on "h" and
doesn't "put" it, even though it frees the data structure holding the refer=
ence.

So let's delay the "cache_get" until we know we need it.

Fixes: f9e1aedc6c79 ("sunrpc/cache: remove races with queuing an upcall.")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/cache.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

I found this when I was looking for something else.  Testing hasn't
shown a bug, and nor has it shown that this is bug-free.  But it looks
right.

NeilBrown


diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 273bc3a35425..008c25d1b9f9 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1182,14 +1182,14 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *d=
etail, struct cache_head *h)
 	}
=20
 	crq->q.reader =3D 0;
=2D	crq->item =3D cache_get(h);
 	crq->buf =3D buf;
 	crq->len =3D 0;
 	crq->readers =3D 0;
 	spin_lock(&queue_lock);
=2D	if (test_bit(CACHE_PENDING, &h->flags))
+	if (test_bit(CACHE_PENDING, &h->flags)) {
+		crq->item =3D cache_get(h);
 		list_add_tail(&crq->q.list, &detail->queue);
=2D	else
+	} else
 		/* Lost a race, no longer PENDING, so don't enqueue */
 		ret =3D -EAGAIN;
 	spin_unlock(&queue_lock);
=2D-=20
2.7.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW2SkdAAoJEDnsnt1WYoG56yMQAIfAQj/7f2QM5FQXrkeoKZfg
i36uSlLNaAemFEeNm2YaWU9T/pxuyqPaSLaBUDwmxQGGAPRI4ReRlMbSx/M/mggw
MDbSe1iJrMBhrkevrRE1Xpxavd1shE4B0u1pTtDMFHKhYV5xdPb+Gap4xuUxFoF+
KeX4KgDyCVJ1JYmPSKpSlcgD5D3y8YQVYlNzZ6j9LRNJcMheMqWM/ZbzcnKADkwp
lapRnhhDTCOwlLSpOpWRXdFvNJMTdBQCjvb2/ZpXf4ZtOsAKgJXHGYtOBOZHVU2O
rgtfADTF3Ax2fv1VHQQ139XpWnLoJynGyiImTB/3mQBHOecbJQxIXkDtAIgeAD1C
IV9g3FEazi1fflS5ogSTAn/QX4z1iolBEOK1Dkwsuv2+bbwVM55RuQV/ncFayPSL
pdq7upGUbZGPtaOytKrrC9gLFMEQ+mi5EpohDpsZChfSZk+YtJ6S0noel2fdYf9/
JvdyT1D1WtURmsoqdANLKVGPPvyQVXHWeBrCbBVZD5sj8qJCrh1BTruescCvk3mq
W3PDeFLtwXr1HEUQBFPqSGugjW6+QQZDWMYxMgRDgdeZsWIjPIDuz7fiavJZi5oX
nEQISE40aVqudcNw+MWx4CuerGF6g8dYz9LJP5SIhcaIN131O5819nepfISwLE5w
JxztPoq6gVWpRCSIEq2N
=cnUs
-----END PGP SIGNATURE-----
--=-=-=--
