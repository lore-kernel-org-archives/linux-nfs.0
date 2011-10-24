Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56786 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755434Ab1JXXZs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Oct 2011 19:25:48 -0400
Date: Tue, 25 Oct 2011 10:25:49 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS/sunrpc: don't use a credential with extra groups.
Message-ID: <20111025102549.6e8b3fe2@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Dj3y5F93c1jD0udVCK+C6Yd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Dj3y5F93c1jD0udVCK+C6Yd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Trond,
 A customer hit this bug recently - which seems to have been around forever=
 -
 at least since 2.6.16.

 I suspect few people would risk hitting it, but our customer does
 interesting things with group lists (presumably some least-privilege polic=
y)
 and they managed to trigger it for us.

NeilBrown



=46rom 80b7771c0e18f755a6b9679e6c3b9d1449ba40ee Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Tue, 25 Oct 2011 10:17:06 +1100
Subject: [PATCH] NFS/sunrpc: don't use a credential with extra groups.

The sunrpc layer keeps a cache of recently used credentials and
'unx_match' is used to find the credential which matches the current
process.

However unx_match allows a match when the cached credential has extra
groups at the end of uc_gids list which are not in the process group list.

So if a process with a list of (say) 4 group accesses a file and gains
access because of the last group in the list, then another process
with the same uid and gid, and a gid list being the first tree of the
gids of the original process tries to access the file, it will be
granted access even though it shouldn't as the wrong rpc credential
will be used.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/auth_unix.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 4cb70dc..e50502d 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -129,6 +129,9 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcr=
ed, int flags)
 	for (i =3D 0; i < groups ; i++)
 		if (cred->uc_gids[i] !=3D GROUP_AT(acred->group_info, i))
 			return 0;
+	if (groups < NFS_NGROUPS &&
+	    cred->uc_gids[groups] !=3D NOGROUP)
+		return 0;
 	return 1;
 }
=20
--=20
1.7.7


--Sig_/Dj3y5F93c1jD0udVCK+C6Yd
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTqXz/Tnsnt1WYoG5AQKEXBAAmax7lTGtaKL5u7vp3VcS6K1wF3SM9wyJ
MDBaKgOjIu24ZpKJIxBCm6TCcXd6V0INhcMZmGkdqxcWcx++ZLIT6b70qncsIeEN
DjDLWb2PAt0g2ZCLjZJFn0x4U/Y6BuUb+chqapXcyBz3vK22pwmLwUIISZuoq0v+
WwSPmj/jbAUesvAFEIO5CHNO/qMWldcIQ4QsEJCfjGHd0p4K9YLNDooOJI4KSt32
nHB3dDf1IfruwoYDkKpxqsrzv1ww6Guz8nCijx94CfHFl6ILEZSmlDihzWMabE4r
616vQhj3SAxl/Z4mtTys5tDd6/y05rBwRudJYMq3RKMtAoE2pL17wtxXX7MybBfk
pgtkm00cIK9MO3Wrf2JOKM6nSS8eVkUMPiGqTqdy/kOe4oUsiHwgNcQgBaYZtFej
BWfSrnjtJ5/FN9pJSSVyNGTe7CRQvwkTmJZuhEw55Rwi6ozQmkcIhU4PZkBJvcTo
QXSUfM7Qkx65OeFaSRhbgAKLpHPUglwfo5czq8t7b3x4sEKuHo0rP3iAXG6w7wd/
3KeqVkThzZcIv+FukGEFfdERKeoq6pxOjmlhGe/dISr+V6RNHs6j+xUZYcsUzbio
ybYOu8Aw9LaV5ha+CVrFu8l7NXy97hSIsGY69vXeNcjBUXJ3C2p9T+TCQm1N9JWA
amkG9T68mxI=
=w2Jf
-----END PGP SIGNATURE-----

--Sig_/Dj3y5F93c1jD0udVCK+C6Yd--
