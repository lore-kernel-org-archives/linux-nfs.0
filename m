From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 6/8] pnfs-submit: change layouts list to be similar to the other state list management
Date: Wed,  5 May 2010 10:00:56 -0700
Message-ID: <1273078858-1923-7-git-send-email-batsakis@netapp.com>
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
 <1273078858-1923-2-git-send-email-batsakis@netapp.com>
 <1273078858-1923-3-git-send-email-batsakis@netapp.com>
 <1273078858-1923-4-git-send-email-batsakis@netapp.com>
 <1273078858-1923-5-git-send-email-batsakis@netapp.com>
 <1273078858-1923-6-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19638 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562Ab0FGF12 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 01:27:28 -0400
In-Reply-To: <1273078858-1923-6-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current design keeps a list (nfs_client) of inodes having layouts.
In order to make that code more similar to delegation handling (and in general to the rest of the NFS code),
this patch changes the list element to layouts directly.
No backpointer from the layout to the inode is needed as the inode can be accesed by a container_of() call

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback_proc.c    |    9 +++++++--
 fs/nfs/client.c           |    2 +-
 fs/nfs/inode.c            |    8 +++++---
 fs/nfs/pnfs.c             |   10 ++++------
 include/linux/nfs_fs.h    |    4 +---
 include/linux/nfs_fs_sb.h |    2 +-
 6 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index acd72b7..0400dbe 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -76,7 +76,6 @@ static int (*nfs_validate_delegation_stateid(struct nfs_client *clp))(struct nfs
 	return nfs4_validate_delegation_stateid;
 }
 
-
 __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 {
 	struct nfs_client *clp;
@@ -140,6 +139,7 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
 			    const struct cb_pnfs_layoutrecallargs *args)
 {
 	struct nfs_inode *nfsi;
+	struct pnfs_layout_type *layout;
 	struct nfs_server *server;
 	struct inode *ino = NULL;
 
@@ -147,9 +147,14 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
 		__func__, args->cbl_recall_type, clp);
 
 	spin_lock(&clp->cl_lock);
-	list_for_each_entry(nfsi, &clp->cl_lo_inodes, lo_inodes) {
+	list_for_each_entry(layout, &clp->cl_layouts, lo_layouts) {
+		nfsi = PNFS_NFS_INODE(layout);
+		if (!nfsi)
+			continue;
+
 		dprintk("%s: Searching inode=%lu\n",
 			__func__, nfsi->vfs_inode.i_ino);
+
 		if (args->cbl_recall_type == RETURN_FILE) {
 		    if (nfs_compare_fh(&args->cbl_fh, &nfsi->fh))
 			continue;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 963fc19..448c565 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -157,7 +157,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
 #if defined(CONFIG_NFS_V4_1)
-	INIT_LIST_HEAD(&clp->cl_lo_inodes);
+	INIT_LIST_HEAD(&clp->cl_layouts);
 #endif
 	nfs_fscache_get_client_cookie(clp);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ade797e..722e76f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1363,9 +1363,11 @@ static void pnfs_destroy_inode(struct nfs_inode *nfsi)
 		pnfs_destroy_layout(nfsi);
 
 	BUG_ON(!list_empty(&nfsi->layout.segs));
-if (nfsi->layout.refcount) printk("%s: layout.refcount %d\n", __func__, nfsi->layout.refcount);
+	if (nfsi->layout.refcount)
+		dprintk("%s: layout.refcount %d\n", __func__,
+			nfsi->layout.refcount);
 	BUG_ON(nfsi->layout.refcount);
-	BUG_ON(!list_empty(&nfsi->lo_inodes));
+	BUG_ON(!list_empty(&nfsi->layout.lo_layouts));
 	BUG_ON(nfsi->layout.ld_data);
 #endif /* CONFIG_NFS_V4_1 */
 }
@@ -1381,10 +1383,10 @@ void nfs_destroy_inode(struct inode *inode)
 static void pnfs_init_once(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	INIT_LIST_HEAD(&nfsi->lo_inodes);
 	init_waitqueue_head(&nfsi->lo_waitq);
 	spin_lock_init(&nfsi->lo_lock);
 	seqlock_init(&nfsi->layout.seqlock);
+	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
 	INIT_LIST_HEAD(&nfsi->layout.segs);
 	nfsi->layout.refcount = 0;
 	nfsi->layout.ld_data = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 52879f6..546e2f4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -370,10 +370,10 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
 		io_ops->free_layout(lo->ld_data);
 		lo->ld_data = NULL;
 
-		/* Unlist the inode. */
+		/* Unlist the layout. */
 		clp = NFS_SERVER(&nfsi->vfs_inode)->nfs_client;
 		spin_lock(&clp->cl_lock);
-		list_del_init(&nfsi->lo_inodes);
+		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
 out:
@@ -889,10 +889,8 @@ alloc_init_layout(struct inode *ino)
 
 	BUG_ON(lo->ld_data != NULL);
 	lo->ld_data = ld_data;
-	seqlock_init(&lo->seqlock);
 	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
-	INIT_LIST_HEAD(&lo->segs);
 	lo->roc_iomode = 0;
 	return lo;
 }
@@ -948,8 +946,8 @@ get_lock_alloc_layout(struct inode *ino)
 			lock_current_layout(nfsi);
 
 			spin_lock(&clp->cl_lock);
-			if (list_empty(&nfsi->lo_inodes))
-				list_add_tail(&nfsi->lo_inodes, &clp->cl_lo_inodes);
+			if (list_empty(&lo->lo_layouts))
+				list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
 			spin_unlock(&clp->cl_lock);
 		} else
 			lo = ERR_PTR(-ENOMEM);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index eb95dbf..764d061 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -99,6 +99,7 @@ struct posix_acl;
 
 struct pnfs_layout_type {
 	int refcount;
+	struct list_head lo_layouts;	/* other client layouts */
 	struct list_head segs;		/* layout segments list */
 	int roc_iomode;			/* iomode to return on close, 0=none */
 	seqlock_t seqlock;		/* Protects the stateid */
@@ -204,9 +205,6 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 #if defined(CONFIG_NFS_V4_1)
-	/* Inodes having layouts */
-	struct list_head	lo_inodes;
-
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
 	struct pnfs_layout_type layout;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 76eb08d..8d93182 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -86,7 +86,7 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
-	struct list_head	cl_lo_inodes;	/* Inodes having layouts */
+	struct list_head	cl_layouts;
 	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.2.5

