Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55237 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2IQGq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 02:46:56 -0400
Date: Mon, 17 Sep 2012 16:46:34 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS4: avoid underflow when converting error to pointer.
Message-ID: <20120917164634.4c8320a7@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/IGoYi2DZlMyPHPlVfu3tdFy"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/IGoYi2DZlMyPHPlVfu3tdFy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In nfs4_create_sec_client, 'flavor' can hold a negative error
code (returned from nfs4_negotiate_security), even though it
is an 'enum' and hence unsigned.

The code is careful to cast it to an (int) before testing if it
is negative, however it doesn't cast to an (int) before calling
ERR_PTR.

On a machine where "void*" is larger than "int", this results in
the unsigned equivalent of -1 (e.g. 0xffffffff) being converted
to a pointer.  Subsequent code determines that this is not
negative, and so  dereferences it with predictable results.

So: cast 'flavor' to a (signed) int before passing to ERR_PTR.

cc: Benny Halevy <bhalevy@tonian.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 017b4b0..9bc56f6 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -198,7 +198,7 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt=
 *clnt, struct inode *ino
=20
 	flavor =3D nfs4_negotiate_security(inode, name);
 	if ((int)flavor < 0)
-		return ERR_PTR(flavor);
+		return ERR_PTR((int)flavor);
=20
 	clone =3D rpc_clone_client(clnt);
 	if (IS_ERR(clone))

--Sig_/IGoYi2DZlMyPHPlVfu3tdFy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFbHUTnsnt1WYoG5AQK2YRAAk2BhvArWu48pmjIt/hxYEGgI2AKilFhd
lE1hnE3f2uXQE6Cd3FwNHKCjNY0DZYfk9E4y6i2JD7bngrVKRCSJOBUAUIcqFgU2
+pbJY707oiTj23CJTvfunLEM5SKfxPrwiqZZwtxdQo0guW2lYlMpGaYJkKlmDhG9
LfBX0gEh0YaDrvPSTusKrT/hQ4agnzfD5ETa1OjX9Lwe63JOJEFNtwxpN3SaGgNJ
jU0iZX0m/HHP5Lr+K6acMlfN9VtdTAoO2REsgtkjf3vDqRJ2CwzAPGMT0tgjGrYj
GR0wrno9yBlrjWcAiEQSY33ujvU+KjNyU39aUBoK9H0hD7eakQGc0OL3eNlXnKJ1
3WLyXZb+Y/6BfcOe9Db8oC92oFGAyg5w4FzUavYS44NG1ZlDKGF7+0T3FG2NNJvS
SeiTSMVA9Rko8k2hxlKsq6mhk8+hHM5+p6PQs9YdlzQOFEJ/Mg6qV+2ruIz61GxB
hUnOVrtsYZ515/mKYpqsnUAaolTdhnpbb3rpid2OBWjojYGOuFnU8nr1WNCo5wpg
6SVPZl/d/TsHl+wOt+2SbtgGALsnbwVIZfHqN4rpBPzpOWZBzFrIVd9A37LIZL+9
G/aMiqix+Bc7gcDQ9+ZC1U/y5GZr0KprQuT1QikxUgNAJhHo/rswxTY4gAHyRMKi
j9HX8+Y0tig=
=ZpOG
-----END PGP SIGNATURE-----

--Sig_/IGoYi2DZlMyPHPlVfu3tdFy--
