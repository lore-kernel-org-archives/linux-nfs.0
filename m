Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43365 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab1EVXsg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:48:36 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 08/38] SQUASHME: pnfs: use global deviceid cache for CB_NOTIFY_DEVICEID
Date: Mon, 23 May 2011 02:47:57 +0300
Message-Id: <1306108077-28096-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c     |    6 +----
 fs/nfs/nfs4filelayout.c    |    1 -
 fs/nfs/nfs4filelayout.h    |    1 -
 fs/nfs/nfs4filelayoutdev.c |   36 ---------------------------
 fs/nfs/pnfs.h              |    2 +-
 fs/nfs/pnfs_dev.c          |   58 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 60 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fc96057..fb5e5b9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -275,14 +275,10 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 		}
 
 	found:
-		if (!server->pnfs_curr_ld->delete_deviceid) {
-			res = cpu_to_be32(NFS4ERR_NOTSUPP);
-			break;
-		}
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
 				"deleting instead\n", __func__);
-		server->pnfs_curr_ld->delete_deviceid(clp, &dev->cbd_dev_id);
+		nfs4_delete_deviceid(clp, &dev->cbd_dev_id);
 	}
 
 out:
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 43284d9..c181a8b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -881,7 +881,6 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 	.free_deviceid_node	= filelayout_free_deveiceid_node,
-	.delete_deviceid	= filelayout_delete_deviceid,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 4289dbf..cebe01e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -101,6 +101,5 @@ extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
-void filelayout_delete_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f23a7f4..5914659 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -553,42 +553,6 @@ nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 	nfs4_put_deviceid_node(&dsaddr->id_node);
 }
 
-static struct nfs4_file_layout_dsaddr *
-nfs4_fl_unhash_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
-{
-	struct nfs4_file_layout_dsaddr *d;
-	struct hlist_node *n;
-	long hash = nfs4_fl_deviceid_hash(id);
-
-	dprintk("%s: hash %ld\n", __func__, hash);
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &filelayout_deviceid_cache[hash], node)
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id)))
-			goto found;
-	rcu_read_unlock();
-	return NULL;
-
-found:
-	rcu_read_unlock();
-	spin_lock(&filelayout_deviceid_lock);
-	hlist_del_init_rcu(&d->node);
-	spin_unlock(&filelayout_deviceid_lock);
-	synchronize_rcu();
-
-	return d;
-}
-
-void
-filelayout_delete_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
-{
-	struct nfs4_file_layout_dsaddr *d;
-
-	d = nfs4_fl_unhash_deviceid(clp, id);
-	/* balance the initial ref taken in decode_and_add_device */
-	if (d && atomic_dec_and_test(&d->ref))
-		nfs4_fl_free_deviceid(d);
-}
-
 /*
  * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
  * Then: ((res + fsi) % dsaddr->stripe_count)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 64ebd76..7f29e3a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,7 +94,6 @@ struct pnfs_layoutdriver_type {
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
-	void (*delete_deviceid)(const struct nfs_client *, const struct nfs4_deviceid *);
 };
 
 struct pnfs_layout_hdr {
@@ -174,6 +173,7 @@ struct nfs4_deviceid_node {
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_delete_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
 			     const struct pnfs_layoutdriver_type *,
 			     const struct nfs_client *,
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 3cd7854..d205b18 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -94,6 +94,64 @@ fail:
 }
 EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
+/*
+ * Unhash and put deviceid
+ *
+ * @clp nfs_client associated with deviceid
+ * @id the deviceid to unhash
+ *
+ * @ret the unhashed node, if found and dereferenced to zero, NULL otherwise.
+ */
+struct nfs4_deviceid_node *
+nfs4_unhash_put_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+	long hash = nfs4_deviceid_hash(id);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id)))
+			goto found;
+	rcu_read_unlock();
+	return NULL;
+
+found:
+	rcu_read_unlock();
+	spin_lock(&nfs4_deviceid_lock);
+	hlist_del_init_rcu(&d->node);
+	spin_unlock(&nfs4_deviceid_lock);
+	synchronize_rcu();
+
+	/* balance the initial ref set in pnfs_insert_deviceid */
+	if (atomic_dec_and_test(&d->ref))
+		return d;
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(nfs4_unhash_put_deviceid);
+
+/*
+ * Delete a deviceid from cache
+ *
+ * @clp struct nfs_client qualifying the deviceid
+ * @id deviceid to delete
+ */
+void
+nfs4_delete_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
+	struct nfs4_deviceid_node *d;
+
+	d = nfs4_unhash_put_deviceid(clp, id);
+	if (!d)
+		return;
+	if (d->ld->free_deviceid_node)
+		d->ld->free_deviceid_node(d);
+	else
+		kfree(d);
+}
+EXPORT_SYMBOL_GPL(nfs4_delete_deviceid);
+
 void
 nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
 			const struct pnfs_layoutdriver_type *ld,
-- 
1.7.3.4

