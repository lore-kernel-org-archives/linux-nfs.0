Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42849 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632Ab1FABa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 21:30:27 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: fix umount of pnfs filesystems
Date: Tue, 31 May 2011 21:30:04 -0400
Message-Id: <1306891804-8070-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Unmounting a pnfs filesystem hangs using filelayout and possibly others.
This fixes the use of the rcu protected node by making use of a new 'tmpnode'
for the temporary purge list. Also, the spinlock shouldn't be held when calling
synchronize_rcu().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Fix proposed by Trond

 fs/nfs/pnfs.h     |    1 +
 fs/nfs/pnfs_dev.c |   11 +++++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 48d0a8e..96bf4e6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -186,6 +186,7 @@ int pnfs_ld_read_done(struct nfs_read_data *);
 /* pnfs_dev.c */
 struct nfs4_deviceid_node {
 	struct hlist_node		node;
+	struct hlist_node		tmpnode;
 	const struct pnfs_layoutdriver_type *ld;
 	const struct nfs_client		*nfs_client;
 	struct nfs4_deviceid		deviceid;
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index c65e133..81e642f 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -174,6 +174,7 @@ nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
 			const struct nfs4_deviceid *id)
 {
 	INIT_HLIST_NODE(&d->node);
+	INIT_HLIST_NODE(&d->tmpnode);
 	d->ld = ld;
 	d->nfs_client = nfs_client;
 	d->deviceid = *id;
@@ -241,21 +242,25 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
 	struct hlist_node *n, *next;
 	HLIST_HEAD(tmp);
 
+	spin_lock(&nfs4_deviceid_lock);
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
 		if (d->nfs_client == clp && atomic_read(&d->ref)) {
 			hlist_del_init_rcu(&d->node);
-			hlist_add_head(&d->node, &tmp);
+			hlist_add_head(&d->tmpnode, &tmp);
 		}
 	rcu_read_unlock();
+	spin_unlock(&nfs4_deviceid_lock);
 
 	if (hlist_empty(&tmp))
 		return;
 
 	synchronize_rcu();
-	hlist_for_each_entry_safe(d, n, next, &tmp, node)
+	while (!hlist_empty(&tmp)) {
 		if (atomic_dec_and_test(&d->ref))
 			d->ld->free_deviceid_node(d);
+		hlist_del_init(&d->tmpnode);
+	}
 }
 
 void
@@ -263,8 +268,6 @@ nfs4_deviceid_purge_client(const struct nfs_client *clp)
 {
 	long h;
 
-	spin_lock(&nfs4_deviceid_lock);
 	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
 		_deviceid_purge_client(clp, h);
-	spin_unlock(&nfs4_deviceid_lock);
 }
-- 
1.7.5.2

