Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8893 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab1EWQe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:34:27 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 01/26] NFSv4.1: use struct nfs_client to qualify deviceid
Date: Mon, 23 May 2011 19:34:14 +0300
Message-Id: <1306168454-10905-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

deviceids are unique per server, per layout type.
Therefore, in the global cache in the files layout driver
deviceids from different servers may clash so we need
to qualify them with a struct nfs_client that represents
the nfs server that returned the deviceid.

Introduced in 2.6.39 commit ea8eecdd
"NFSv4.1 move deviceid cache to filelayout driver"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c    |    2 +-
 fs/nfs/nfs4filelayout.h    |    3 ++-
 fs/nfs/nfs4filelayoutdev.c |    9 ++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be79dc9..ff47fdf 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -440,7 +440,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	}
 
 	/* find and reference the deviceid */
-	dsaddr = nfs4_fl_find_get_deviceid(id);
+	dsaddr = nfs4_fl_find_get_deviceid(NFS_SERVER(lo->plh_inode)->nfs_client, id);
 	if (dsaddr == NULL) {
 		dsaddr = get_device_info(lo->plh_inode, id, gfp_flags);
 		if (dsaddr == NULL)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 2b461d7..301b955 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -60,6 +60,7 @@ struct nfs4_pnfs_ds {
 
 struct nfs4_file_layout_dsaddr {
 	struct hlist_node		node;
+	struct nfs_client		*nfs_client;
 	struct nfs4_deviceid		deviceid;
 	atomic_t			ref;
 	unsigned long			flags;
@@ -101,7 +102,7 @@ u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs4_deviceid *dev_id);
+nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index db07c7a..42e3266 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -431,7 +431,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 	dsaddr->stripe_indices = stripe_indices;
 	stripe_indices = NULL;
 	dsaddr->ds_num = num;
-
+	dsaddr->nfs_client = NFS_SERVER(ino)->nfs_client;
 	memcpy(&dsaddr->deviceid, &pdev->dev_id, sizeof(pdev->dev_id));
 
 	for (i = 0; i < dsaddr->ds_num; i++) {
@@ -516,7 +516,7 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_fl
 	}
 
 	spin_lock(&filelayout_deviceid_lock);
-	d = nfs4_fl_find_get_deviceid(&new->deviceid);
+	d = nfs4_fl_find_get_deviceid(new->nfs_client, &new->deviceid);
 	if (d) {
 		spin_unlock(&filelayout_deviceid_lock);
 		nfs4_fl_free_deviceid(new);
@@ -610,16 +610,15 @@ nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 }
 
 struct nfs4_file_layout_dsaddr *
-nfs4_fl_find_get_deviceid(struct nfs4_deviceid *id)
+nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
 {
 	struct nfs4_file_layout_dsaddr *d;
 	struct hlist_node *n;
 	long hash = nfs4_fl_deviceid_hash(id);
 
-
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node) {
-		if (!memcmp(&d->deviceid, id, sizeof(*id))) {
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
 			if (!atomic_inc_not_zero(&d->ref))
 				goto fail;
 			rcu_read_unlock();
-- 
1.7.3.4

