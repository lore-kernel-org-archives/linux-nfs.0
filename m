Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43349 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab1EVXrw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:47:52 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 07/38] SQUASHME: pnfs: use nfs_client to qualify deviceid for cb_notify_deviceid
Date: Mon, 23 May 2011 02:47:13 +0300
Message-Id: <1306108033-28060-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c     |    2 +-
 fs/nfs/nfs4filelayout.h    |    2 +-
 fs/nfs/nfs4filelayoutdev.c |    8 ++++----
 fs/nfs/pnfs.h              |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 95107fe..fc96057 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -282,7 +282,7 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
 				"deleting instead\n", __func__);
-		server->pnfs_curr_ld->delete_deviceid(&dev->cbd_dev_id);
+		server->pnfs_curr_ld->delete_deviceid(clp, &dev->cbd_dev_id);
 	}
 
 out:
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 8601656..4289dbf 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -101,6 +101,6 @@ extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
-void filelayout_delete_deviceid(struct nfs4_deviceid *);
+void filelayout_delete_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f7f0bb8..f23a7f4 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -554,7 +554,7 @@ nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 }
 
 static struct nfs4_file_layout_dsaddr *
-nfs4_fl_unhash_deviceid(struct nfs4_deviceid *id)
+nfs4_fl_unhash_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_file_layout_dsaddr *d;
 	struct hlist_node *n;
@@ -563,7 +563,7 @@ nfs4_fl_unhash_deviceid(struct nfs4_deviceid *id)
 	dprintk("%s: hash %ld\n", __func__, hash);
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node)
-		if (!memcmp(&d->deviceid, id, sizeof(*id)))
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id)))
 			goto found;
 	rcu_read_unlock();
 	return NULL;
@@ -579,11 +579,11 @@ found:
 }
 
 void
-filelayout_delete_deviceid(struct nfs4_deviceid *id)
+filelayout_delete_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_file_layout_dsaddr *d;
 
-	d = nfs4_fl_unhash_deviceid(id);
+	d = nfs4_fl_unhash_deviceid(clp, id);
 	/* balance the initial ref taken in decode_and_add_device */
 	if (d && atomic_dec_and_test(&d->ref))
 		nfs4_fl_free_deviceid(d);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index fa19c97..64ebd76 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,7 +94,7 @@ struct pnfs_layoutdriver_type {
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
-	void (*delete_deviceid)(struct nfs4_deviceid *);
+	void (*delete_deviceid)(const struct nfs_client *, const struct nfs4_deviceid *);
 };
 
 struct pnfs_layout_hdr {
-- 
1.7.3.4

