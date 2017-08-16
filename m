Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50613 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752769AbdHPCrg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Aug 2017 22:47:36 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 16 Aug 2017 12:47:27 +1000
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: remove jiffies field from access cache
Message-ID: <874lt8ns8w.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This field hasn't been used since commit 57b691819ee2 ("NFS: Cache
access checks more aggressively").

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

I noticed this while reading the code.  Not very significant, but worth
fixing I thought.

Thanks,
NeilBrown



 fs/nfs/dir.c           | 4 ----
 fs/nfs/nfs4proc.c      | 1 -
 include/linux/nfs_fs.h | 1 -
 3 files changed, 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3522b1249019..5ceaeb1f6fb6 100644
=2D-- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2260,7 +2260,6 @@ static int nfs_access_get_cached(struct inode *inode,=
 struct rpc_cred *cred, str
 		spin_lock(&inode->i_lock);
 		retry =3D false;
 	}
=2D	res->jiffies =3D cache->jiffies;
 	res->cred =3D cache->cred;
 	res->mask =3D cache->mask;
 	list_move_tail(&cache->lru, &nfsi->access_cache_entry_lru);
@@ -2296,7 +2295,6 @@ static int nfs_access_get_cached_rcu(struct inode *in=
ode, struct rpc_cred *cred,
 		goto out;
 	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_ACCESS))
 		goto out;
=2D	res->jiffies =3D cache->jiffies;
 	res->cred =3D cache->cred;
 	res->mask =3D cache->mask;
 	err =3D 0;
@@ -2344,7 +2342,6 @@ void nfs_access_add_cache(struct inode *inode, struct=
 nfs_access_entry *set)
 	if (cache =3D=3D NULL)
 		return;
 	RB_CLEAR_NODE(&cache->rb_node);
=2D	cache->jiffies =3D set->jiffies;
 	cache->cred =3D get_rpccred(set->cred);
 	cache->mask =3D set->mask;
=20
@@ -2432,7 +2429,6 @@ static int nfs_do_access(struct inode *inode, struct =
rpc_cred *cred, int mask)
 	cache.mask =3D NFS_MAY_LOOKUP | NFS_MAY_EXECUTE
 		     | NFS_MAY_WRITE | NFS_MAY_READ;
 	cache.cred =3D cred;
=2D	cache.jiffies =3D jiffies;
 	status =3D NFS_PROTO(inode)->access(inode, &cache);
 	if (status !=3D 0) {
 		if (status =3D=3D -ESTALE) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d90132642340..3af528df515b 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2258,7 +2258,6 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		mask =3D NFS4_ACCESS_READ;
=20
 	cache.cred =3D cred;
=2D	cache.jiffies =3D jiffies;
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
=20
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5cc91d6381a3..e34ae8d0dddb 100644
=2D-- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -49,7 +49,6 @@
 struct nfs_access_entry {
 	struct rb_node		rb_node;
 	struct list_head	lru;
=2D	unsigned long		jiffies;
 	struct rpc_cred *	cred;
 	__u32			mask;
 	struct rcu_head		rcu_head;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmTskEACgkQOeye3VZi
gbnOxQ//WA8bNesTJLqMp5CGfWj7H8Dsg9Q8lFZF4/gSKLu6U33OwuGGfIQlDR0L
sCzEJYAk3Mj8DVw3MB9er6d9rBAQ4PWGVP1jn7i4HzS4qNC+5ZbmKXLd/c3XueWr
gfs2MgyoXWuh0ijoZgBIe5llwb1txfao22oYaemmysWtZ/3Dq1pCj0cwmaUGQrm4
JUgGhXwokHz72bzXE9QuYjcNlHN3hJl8eK4TyAnaf5V3P07yHxLxTqJGPDEUFMAq
GuMgnzh+KW9mEefF2BFNT1VVCljkSHPmaDGAoXLmHjWkB+cBe0rcvLPHAyVSRi6v
iSd/PB1gYue2yvJYhO+LK38tRQY7ug1mgmxMbJzWjxeg8O2YJ1y+Si1+T036jFTr
hFvlQvi6N5mp40UbQc4IAMA5DMCkKZotlAs8XLu7qSc+GdgIncOMjT0YfY97lo+7
sBrIRR7RAICDibb1hSTphjgPiUbvzEagNLwm4VbCh6aUCFe8l/k4Duk7fXiioMTN
0meX3Yj2XEOnvpOKxtZba0f/53qSGpuqT/t6V5xG+glpSzZWdyECh6F3vnuaeaMY
XAmP48uC6fchEt0sEW/7FeJDhrfVwCbarUaJf439UR1TrKeRpRWdLPZnx5d+Gu5Y
FJ+9EwabClPrZDUbZrsFeWvPr5VaChh4MO0nvk8hO+SG0D2CvcY=
=GWyD
-----END PGP SIGNATURE-----
--=-=-=--
