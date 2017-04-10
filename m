Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43099 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751685AbdDJCWR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 9 Apr 2017 22:22:17 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 10 Apr 2017 12:22:09 +1000
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: fix usage of mempools.
Message-ID: <87wpatvw6m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When passed GFP flags that allow sleeping (such as
GFP_NOIO), mempool_alloc() will never return NULL, it will
wait until memory is available.

This means that we don't need to handle failure, but that we
do need to ensure one thread doesn't call mempool_alloc()
twice on the one pool without queuing or freeing the first
allocation.  If multiple threads did this during times of
high memory pressure, the pool could be exhausted and a
deadlock could result.

pnfs_generic_alloc_ds_commits() attempts to allocate from
the nfs_commit_mempool while already holding an allocation
from that pool.  This is not safe.  So change
nfs_commitdata_alloc() to take a flag that indicates whether
failure is acceptable.

In pnfs_generic_alloc_ds_commits(), accept failure and
handle it as we currently do.  Else where, do not accept
failure, and do not handle it.

Even when failure is acceptable, we want to succeed if
possible.  That means both
 - using an entry from the pool if there is one
 - waiting for direct reclaim is there isn't.

We call mempool_alloc(GFP_NOWAIT) to achieve the first, then
kmem_cache_alloc(GFP_NOIO|__GFP_NORETRY) to achieve the
second.  Each of these can fail, but together they do the
best they can without blocking indefinitely.

Also, don't test for failure when allocating from
nfs_wdata_mempool.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/pnfs_nfs.c      | 16 +++++-----------
 fs/nfs/write.c         | 35 +++++++++++++++++++++--------------
 include/linux/nfs_fs.h |  2 +-
 3 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 7250b95549ec..1edf5b84aba5 100644
=2D-- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -217,7 +217,7 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *c=
info,
 	for (i =3D 0; i < fl_cinfo->nbuckets; i++, bucket++) {
 		if (list_empty(&bucket->committing))
 			continue;
=2D		data =3D nfs_commitdata_alloc();
+		data =3D nfs_commitdata_alloc(false);
 		if (!data)
 			break;
 		data->ds_commit_index =3D i;
@@ -283,16 +283,10 @@ pnfs_generic_commit_pagelist(struct inode *inode, str=
uct list_head *mds_pages,
 	unsigned int nreq =3D 0;
=20
 	if (!list_empty(mds_pages)) {
=2D		data =3D nfs_commitdata_alloc();
=2D		if (data !=3D NULL) {
=2D			data->ds_commit_index =3D -1;
=2D			list_add(&data->pages, &list);
=2D			nreq++;
=2D		} else {
=2D			nfs_retry_commit(mds_pages, NULL, cinfo, 0);
=2D			pnfs_generic_retry_commit(cinfo, 0);
=2D			return -ENOMEM;
=2D		}
+		data =3D nfs_commitdata_alloc(true);
+		data->ds_commit_index =3D -1;
+		list_add(&data->pages, &list);
+		nreq++;
 	}
=20
 	nreq +=3D pnfs_generic_alloc_ds_commits(cinfo, &list);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a3be42..bdfe5a7c5874 100644
=2D-- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -60,14 +60,28 @@ static mempool_t *nfs_wdata_mempool;
 static struct kmem_cache *nfs_cdata_cachep;
 static mempool_t *nfs_commit_mempool;
=20
=2Dstruct nfs_commit_data *nfs_commitdata_alloc(void)
+struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail)
 {
=2D	struct nfs_commit_data *p =3D mempool_alloc(nfs_commit_mempool, GFP_NOI=
O);
+	struct nfs_commit_data *p;
=20
=2D	if (p) {
=2D		memset(p, 0, sizeof(*p));
=2D		INIT_LIST_HEAD(&p->pages);
+	if (never_fail)
+		p =3D mempool_alloc(nfs_commit_mempool, GFP_NOIO);
+	else {
+		/* It is OK to do some reclaim, not no safe to wait
+		 * for anything to be returned to the pool.
+		 * mempool_alloc() cannot handle that particular combination,
+		 * so we need two separate attempts.
+		 */
+		p =3D mempool_alloc(nfs_commit_mempool, GFP_NOWAIT);
+		if (!p)
+			p =3D kmem_cache_alloc(nfs_cdata_cachep, GFP_NOIO |
+					     __GFP_NOWARN | __GFP_NORETRY);
+		if (!p)
+			return NULL;
 	}
+
+	memset(p, 0, sizeof(*p));
+	INIT_LIST_HEAD(&p->pages);
 	return p;
 }
 EXPORT_SYMBOL_GPL(nfs_commitdata_alloc);
@@ -82,8 +96,7 @@ static struct nfs_pgio_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_pgio_header *p =3D mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
=20
=2D	if (p)
=2D		memset(p, 0, sizeof(*p));
+	memset(p, 0, sizeof(*p));
 	return p;
 }
=20
@@ -1705,19 +1718,13 @@ nfs_commit_list(struct inode *inode, struct list_he=
ad *head, int how,
 	if (list_empty(head))
 		return 0;
=20
=2D	data =3D nfs_commitdata_alloc();
=2D
=2D	if (!data)
=2D		goto out_bad;
+	data =3D nfs_commitdata_alloc(true);
=20
 	/* Set up the argument struct */
 	nfs_init_commit(data, head, NULL, cinfo);
 	atomic_inc(&cinfo->mds->rpcs_out);
 	return nfs_initiate_commit(NFS_CLIENT(inode), data, NFS_PROTO(inode),
 				   data->mds_ops, how, 0);
=2D out_bad:
=2D	nfs_retry_commit(head, NULL, cinfo, 0);
=2D	return -ENOMEM;
 }
=20
 int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 287f34161086..1b29915247b2 100644
=2D-- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -502,7 +502,7 @@ extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_single_page(struct inode *inode, struct page *page, bool=
 launder);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 extern int  nfs_commit_inode(struct inode *, int);
=2Dextern struct nfs_commit_data *nfs_commitdata_alloc(void);
+extern struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail);
 extern void nfs_commit_free(struct nfs_commit_data *data);
=20
 static inline int
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljq7FEACgkQOeye3VZi
gbnQYhAAo0FlqZaMV0KGFwrOrElBJX/xrMHv7gz/LnhuGM2Nj6JEttNTrT37Oplt
HAbed28i3vLP/T3UwbtI4cMH/q8IRSmXCaTXslYp03+Lm1qWEkdX7mBY32HyxEAg
VegfR9wtbjVcSGP5+E2/cL8S7mbW5J+Y0sKsJhl/NHccBVvVTT2EkaiaA0ggF6oi
lFz0hd4JRl6BJ6pVj3RUl9lPp9rFmcRTxWYTlN/bF/8uQ+CJF/mWseKoiJlYptc7
wl1ZSUsaBMrh66YWK7D9c1sfCD/eOXEl5AxITmTZngbjUWMgIJcjpj/eTagL+ZMT
XPPkEEeVwI9Bk6ChYOCZmfF+utpzERyEhp+RjSBx3iQaqnf9Xg66K9cjdDfulj4t
vIb1bh5JQFiaAVIbPakqNq3srRHT0BJssI/Gg/2VRVVDVyn8EqfqFuuQ2Zsvcz94
MqggkPXsH3WuJ6L5djhVggNdciLDG2OE7LPR5OKG1Xv6RPM/DY7AiWM+AWrRkS26
xmMZpYQBkqwSBYj5ovv3lj8NGxMjgdFwqf2OENZXdhy41nlq1UwmUos0R+UCdO6S
YT+YRB2CgGyUqSFo0rqmehWxw7Rrxmyr7U6hYRLKB2CygJHJ8GJphMUxqzOq/rfM
iKlQpquadWLQR9PQtfbJqHgQceSBdScXigNOhvTwrLQ0sG63hlQ=
=ZFTz
-----END PGP SIGNATURE-----
--=-=-=--
