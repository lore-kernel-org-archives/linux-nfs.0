Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:38265 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbbCIUFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 16:05:07 -0400
Received: by qgdz60 with SMTP id z60so31465980qgd.5
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 13:05:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4.1: Convert pNFS deviceid to use kfree_rcu()
Date: Mon,  9 Mar 2015 16:05:00 -0400
Message-Id: <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use of synchronize_rcu() when unmounting and potentially freeing a lot
of deviceids is problematic. There really is no reason why we can't just
use kfree_rcu() here.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/blocklayout/dev.c                  | 2 +-
 fs/nfs/filelayout/filelayoutdev.c         | 2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 fs/nfs/objlayout/objio_osd.c              | 2 +-
 fs/nfs/pnfs.h                             | 1 +
 fs/nfs/pnfs_dev.c                         | 6 ++----
 6 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 5aed4f98df41..e535599a0719 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -33,7 +33,7 @@ bl_free_deviceid_node(struct nfs4_deviceid_node *d)
 		container_of(d, struct pnfs_block_dev, node);
 
 	bl_free_device(dev);
-	kfree(dev);
+	kfree_rcu(dev, node.rcu);
 }
 
 static int
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 4f372e224603..4946ef40ba87 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -55,7 +55,7 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 			nfs4_pnfs_ds_put(ds);
 	}
 	kfree(dsaddr->stripe_indices);
-	kfree(dsaddr);
+	kfree_rcu(dsaddr, id_node.rcu);
 }
 
 /* Decode opaque device data and return the result */
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index e2c01f204a95..77a2d026aa12 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -30,7 +30,7 @@ void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
 {
 	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
 	nfs4_pnfs_ds_put(mirror_ds->ds);
-	kfree(mirror_ds);
+	kfree_rcu(mirror_ds, id_node.rcu);
 }
 
 /* Decode opaque device data and construct new_ds using it */
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 24e1d7403c0b..8b5e0e687d5e 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -57,7 +57,7 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 
 	dprintk("%s: free od=%p\n", __func__, de->od.od);
 	osduld_put_device(de->od.od);
-	kfree(de);
+	kfree_rcu(d, rcu);
 }
 
 struct objio_segment {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 635f0865671c..a1fc16c971a7 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -302,6 +302,7 @@ struct nfs4_deviceid_node {
 	unsigned long 			flags;
 	unsigned long			timestamp_unavailable;
 	struct nfs4_deviceid		deviceid;
+	struct rcu_head			rcu;
 	atomic_t			ref;
 };
 
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index aa2ec0015183..bf23ac97d57d 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -175,8 +175,8 @@ __nfs4_find_get_deviceid(struct nfs_server *server,
 	rcu_read_lock();
 	d = _lookup_deviceid(server->pnfs_curr_ld, server->nfs_client, id,
 			hash);
-	if (d != NULL)
-		atomic_inc(&d->ref);
+	if (d != NULL && !atomic_inc_not_zero(&d->ref))
+		d = NULL;
 	rcu_read_unlock();
 	return d;
 }
@@ -236,7 +236,6 @@ nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
 	}
 	hlist_del_init_rcu(&d->node);
 	spin_unlock(&nfs4_deviceid_lock);
-	synchronize_rcu();
 
 	/* balance the initial ref set in pnfs_insert_deviceid */
 	if (atomic_dec_and_test(&d->ref))
@@ -321,7 +320,6 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
 	if (hlist_empty(&tmp))
 		return;
 
-	synchronize_rcu();
 	while (!hlist_empty(&tmp)) {
 		d = hlist_entry(tmp.first, struct nfs4_deviceid_node, tmpnode);
 		hlist_del(&d->tmpnode);
-- 
2.1.0

