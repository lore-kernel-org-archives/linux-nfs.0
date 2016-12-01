Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35049 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759718AbcLAWTd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:33 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so4680618ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:33 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/26] pNFS: Delay getting the layout header in CB_LAYOUTRECALL handlers
Date: Thu,  1 Dec 2016 17:19:04 -0500
Message-Id: <20161201221922.15657-9-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-8-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of grabbing the layout, we want to get the inode so that we
can reduce races between layoutget and layoutrecall when the server
does not support call referring.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 99 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 67 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e9aa235e9d10..f073a6d2c6a5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -110,20 +110,52 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 #if defined(CONFIG_NFS_V4_1)
 
 /*
- * Lookup a layout by filehandle.
+ * Lookup a layout inode by stateid
  *
- * Note: gets a refcount on the layout hdr and on its respective inode.
- * Caller must put the layout hdr and the inode.
+ * Note: returns a refcount on the inode and superblock
+ */
+static struct inode *nfs_layout_find_inode_by_stateid(struct nfs_client *clp,
+		const nfs4_stateid *stateid)
+{
+	struct nfs_server *server;
+	struct inode *inode;
+	struct pnfs_layout_hdr *lo;
+
+restart:
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		list_for_each_entry(lo, &server->layouts, plh_layouts) {
+			if (stateid != NULL &&
+			    !nfs4_stateid_match_other(stateid, &lo->plh_stateid))
+				continue;
+			inode = igrab(lo->plh_inode);
+			if (!inode)
+				continue;
+			if (!nfs_sb_active(inode->i_sb)) {
+				rcu_read_lock();
+				spin_unlock(&clp->cl_lock);
+				iput(inode);
+				spin_lock(&clp->cl_lock);
+				goto restart;
+			}
+			return inode;
+		}
+	}
+
+	return NULL;
+}
+
+/*
+ * Lookup a layout inode by filehandle.
+ *
+ * Note: returns a refcount on the inode and superblock
  *
- * TODO: keep track of all layouts (and delegations) in a hash table
- * hashed by filehandle.
  */
-static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
-		struct nfs_fh *fh)
+static struct inode *nfs_layout_find_inode_by_fh(struct nfs_client *clp,
+		const struct nfs_fh *fh)
 {
 	struct nfs_server *server;
 	struct nfs_inode *nfsi;
-	struct inode *ino;
+	struct inode *inode;
 	struct pnfs_layout_hdr *lo;
 
 restart:
@@ -134,37 +166,38 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 				continue;
 			if (nfsi->layout != lo)
 				continue;
-			ino = igrab(lo->plh_inode);
-			if (!ino)
-				break;
-			spin_lock(&ino->i_lock);
-			/* Is this layout in the process of being freed? */
-			if (nfsi->layout != lo) {
-				spin_unlock(&ino->i_lock);
-				iput(ino);
+			inode = igrab(lo->plh_inode);
+			if (!inode)
+				continue;
+			if (!nfs_sb_active(inode->i_sb)) {
+				rcu_read_lock();
+				spin_unlock(&clp->cl_lock);
+				iput(inode);
+				spin_lock(&clp->cl_lock);
 				goto restart;
 			}
-			pnfs_get_layout_hdr(lo);
-			spin_unlock(&ino->i_lock);
-			return lo;
+			return inode;
 		}
 	}
 
 	return NULL;
 }
 
-static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp,
-		struct nfs_fh *fh)
+static struct inode *nfs_layout_find_inode(struct nfs_client *clp,
+		const struct nfs_fh *fh,
+		const nfs4_stateid *stateid)
 {
-	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
 
 	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
-	lo = get_layout_by_fh_locked(clp, fh);
+	inode = nfs_layout_find_inode_by_stateid(clp, stateid);
+	if (!inode)
+		inode = nfs_layout_find_inode_by_fh(clp, fh);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
 
-	return lo;
+	return inode;
 }
 
 /*
@@ -213,18 +246,20 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
 	LIST_HEAD(free_me_list);
 
-	lo = get_layout_by_fh(clp, &args->cbl_fh);
-	if (!lo) {
-		trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, NULL,
-				&args->cbl_stateid, -rv);
+	ino = nfs_layout_find_inode(clp, &args->cbl_fh, &args->cbl_stateid);
+	if (!ino)
 		goto out;
-	}
 
-	ino = lo->plh_inode;
 	pnfs_layoutcommit_inode(ino, false);
 
 
 	spin_lock(&ino->i_lock);
+	lo = NFS_I(ino)->layout;
+	if (!lo) {
+		spin_unlock(&ino->i_lock);
+		goto out;
+	}
+	pnfs_get_layout_hdr(lo);
 	rv = pnfs_check_callback_stateid(lo, &args->cbl_stateid);
 	if (rv != NFS_OK)
 		goto unlock;
@@ -258,10 +293,10 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	/* Free all lsegs that are attached to commit buckets */
 	nfs_commit_inode(ino, 0);
 	pnfs_put_layout_hdr(lo);
+out:
 	trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, ino,
 			&args->cbl_stateid, -rv);
-	iput(ino);
-out:
+	nfs_iput_and_deactive(ino);
 	return rv;
 }
 
-- 
2.9.3

