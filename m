Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51553 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756370Ab1D1Tu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Apr 2011 15:50:29 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: move pnfs layouts to nfs_server structure
Date: Thu, 28 Apr 2011 15:50:08 -0400
Message-Id: <1304020208-32475-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Layouts should be tracked per nfs_server (aka superblock)
instead of per struct nfs_client, which may have multiple FSIDs associated
with it.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>

Revised to handle multiple nfs_servers with the same FSID
---
 fs/nfs/callback_proc.c    |   57 ++++++++++++++++++++++++++++----------------
 fs/nfs/client.c           |    4 +--
 fs/nfs/pnfs.c             |   13 ++++++++--
 include/linux/nfs_fs_sb.h |    2 +-
 4 files changed, 48 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2f41dcce..935700b 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -111,6 +111,7 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 static u32 initiate_file_draining(struct nfs_client *clp,
 				  struct cb_layoutrecallargs *args)
 {
+	struct nfs_server *server;
 	struct pnfs_layout_hdr *lo;
 	struct inode *ino;
 	bool found = false;
@@ -118,21 +119,28 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	LIST_HEAD(free_me_list);
 
 	spin_lock(&clp->cl_lock);
-	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
-		if (nfs_compare_fh(&args->cbl_fh,
-				   &NFS_I(lo->plh_inode)->fh))
-			continue;
-		ino = igrab(lo->plh_inode);
-		if (!ino)
-			continue;
-		found = true;
-		/* Without this, layout can be freed as soon
-		 * as we release cl_lock.
-		 */
-		get_layout_hdr(lo);
-		break;
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		list_for_each_entry(lo, &server->layouts, plh_layouts) {
+			if (nfs_compare_fh(&args->cbl_fh,
+					   &NFS_I(lo->plh_inode)->fh))
+				continue;
+			ino = igrab(lo->plh_inode);
+			if (!ino)
+				continue;
+			found = true;
+			/* Without this, layout can be freed as soon
+			 * as we release cl_lock.
+			 */
+			get_layout_hdr(lo);
+			break;
+		}
+		if (found)
+			break;
 	}
+	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
+
 	if (!found)
 		return NFS4ERR_NOMATCHING_LAYOUT;
 
@@ -154,6 +162,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 static u32 initiate_bulk_draining(struct nfs_client *clp,
 				  struct cb_layoutrecallargs *args)
 {
+	struct nfs_server *server;
 	struct pnfs_layout_hdr *lo;
 	struct inode *ino;
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
@@ -167,18 +176,24 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 	};
 
 	spin_lock(&clp->cl_lock);
-	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		if ((args->cbl_recall_type == RETURN_FSID) &&
-		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
-			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
-			continue;
-		if (!igrab(lo->plh_inode))
+		    memcmp(&server->fsid, &args->cbl_fsid,
+			   sizeof(struct nfs_fsid)))
 			continue;
-		get_layout_hdr(lo);
-		BUG_ON(!list_empty(&lo->plh_bulk_recall));
-		list_add(&lo->plh_bulk_recall, &recall_list);
+
+		list_for_each_entry(lo, &server->layouts, plh_layouts) {
+			if (!igrab(lo->plh_inode))
+				continue;
+			get_layout_hdr(lo);
+			BUG_ON(!list_empty(&lo->plh_bulk_recall));
+			list_add(&lo->plh_bulk_recall, &recall_list);
+		}
 	}
+	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
+
 	list_for_each_entry_safe(lo, tmp,
 				 &recall_list, plh_bulk_recall) {
 		ino = lo->plh_inode;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 139be96..1c927cf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -188,9 +188,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
-#if defined(CONFIG_NFS_V4_1)
-	INIT_LIST_HEAD(&clp->cl_layouts);
-#endif
 	nfs_fscache_get_client_cookie(clp);
 
 	return clp;
@@ -1060,6 +1057,7 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);
 	INIT_LIST_HEAD(&server->delegations);
+	INIT_LIST_HEAD(&server->layouts);
 
 	atomic_set(&server->active, 0);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ff681ab..6a5d0a4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -371,11 +371,17 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 void
 pnfs_destroy_all_layouts(struct nfs_client *clp)
 {
+	struct nfs_server *server;
 	struct pnfs_layout_hdr *lo;
 	LIST_HEAD(tmp_list);
 
 	spin_lock(&clp->cl_lock);
-	list_splice_init(&clp->cl_layouts, &tmp_list);
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		if (!list_empty(&server->layouts))
+			list_splice_init(&server->layouts, &tmp_list);
+	}
+	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
 
 	while (!list_empty(&tmp_list)) {
@@ -759,7 +765,8 @@ pnfs_update_layout(struct inode *ino,
 		   enum pnfs_iomode iomode)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
-	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
+	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
 	bool first = false;
@@ -803,7 +810,7 @@ pnfs_update_layout(struct inode *ino,
 		 */
 		spin_lock(&clp->cl_lock);
 		BUG_ON(!list_empty(&lo->plh_layouts));
-		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
+		list_add_tail(&lo->plh_layouts, &server->layouts);
 		spin_unlock(&clp->cl_lock);
 	}
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..2cc467f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -77,7 +77,6 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
-	struct list_head	cl_layouts;
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
@@ -149,6 +148,7 @@ struct nfs_server {
 	struct rb_root		openowner_id;
 	struct rb_root		lockowner_id;
 #endif
+	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
 
-- 
1.7.4.2

