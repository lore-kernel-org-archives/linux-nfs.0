From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 8/9] SQUASHME: pnfs: use only pnfs_layoutreturn_type
Date: Wed,  9 Dec 2009 12:28:37 +0200
Message-ID: <1260354517-12541-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:14858 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754703AbZLIK2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:28:32 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   12 ++++++------
 fs/nfs/callback_xdr.c  |    4 ++--
 fs/nfs/inode.c         |    2 +-
 fs/nfs/nfs4proc.c      |    4 ++--
 fs/nfs/nfs4state.c     |    2 +-
 fs/nfs/pnfs.c          |   14 +++++++-------
 fs/nfs/pnfs.h          |    6 +++---
 7 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 7c5e8ee..a2ea863 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -132,10 +132,10 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
 	list_for_each_entry(nfsi, &clp->cl_lo_inodes, lo_inodes) {
 		dprintk("%s: Searching inode=%lu\n",
 			__func__, nfsi->vfs_inode.i_ino);
-		if (args->cbl_recall_type == RECALL_FILE) {
+		if (args->cbl_recall_type == RETURN_FILE) {
 		    if (nfs_compare_fh(&args->cbl_fh, &nfsi->fh))
 			continue;
-		} else if (args->cbl_recall_type == RECALL_FSID) {
+		} else if (args->cbl_recall_type == RETURN_FSID) {
 			server = NFS_SERVER(&nfsi->vfs_inode);
 			if (server->fsid.major != args->cbl_fsid.major ||
 			    server->fsid.minor != args->cbl_fsid.minor)
@@ -195,11 +195,11 @@ static int pnfs_recall_layout(void *data)
    then return layouts, resume after layoutreturns complete
  */
 
-	if (rl.cbl_recall_type == RECALL_FILE) {
+	if (rl.cbl_recall_type == RETURN_FILE) {
 		status = pnfs_return_layout(inode, &rl.cbl_seg, &rl.cbl_stateid,
-					    RECALL_FILE);
+					    RETURN_FILE);
 		if (status)
-			dprintk("%s RECALL_FILE error: %d\n", __func__, status);
+			dprintk("%s RETURN_FILE error: %d\n", __func__, status);
 		goto out;
 	}
 
@@ -209,7 +209,7 @@ static int pnfs_recall_layout(void *data)
 	/* FIXME: This loop is inefficient, running in O(|s_inodes|^2) */
 	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
 		/* XXX need to check status on pnfs_return_layout */
-		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RECALL_FILE);
+		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE);
 		iput(ino);
 	}
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 1cbf81b..453c7c8 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -248,7 +248,7 @@ static unsigned decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
 	args->cbl_layoutchanged = ntohl(*p++);
 	args->cbl_recall_type = ntohl(*p++);
 
-	if (likely(args->cbl_recall_type == RECALL_FILE)) {
+	if (likely(args->cbl_recall_type == RETURN_FILE)) {
 		status = decode_fh(xdr, &args->cbl_fh);
 		if (unlikely(status != 0))
 			goto out;
@@ -259,7 +259,7 @@ static unsigned decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
 		status = decode_stateid(xdr, &args->cbl_stateid);
 		if (unlikely(status != 0))
 			goto out;
-	} else if (args->cbl_recall_type == RECALL_FSID) {
+	} else if (args->cbl_recall_type == RETURN_FSID) {
 		p = read_buf(xdr, 2 * sizeof(uint64_t));
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e71e842..cdaf9f1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1386,7 +1386,7 @@ void nfs4_clear_inode(struct inode *inode)
 	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 #ifdef CONFIG_PNFS
-	pnfs_return_layout(inode, NULL, NULL, RECALL_FILE);
+	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
 #endif /* CONFIG_PNFS */
 }
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87f58bd..c897a85 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2254,7 +2254,7 @@ pnfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
 	    pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
-		pnfs_return_layout(inode, NULL, NULL, RECALL_FILE);
+		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE);
 	return nfs4_proc_setattr(dentry, fattr, sattr);
 }
 #endif /* CONFIG_PNFS */
@@ -5438,7 +5438,7 @@ static void nfs4_pnfs_layoutreturn_release(void *calldata)
 	dprintk("--> %s return_type %d lo %p\n", __func__,
 		lrp->args.return_type, lrp->lo);
 
-	if (lrp->lo && (lrp->args.return_type == RECALL_FILE)) {
+	if (lrp->lo && (lrp->args.return_type == RETURN_FILE)) {
 		if (!lrp->res.lrs_present)
 			pnfs_set_layout_stateid(lrp->lo, &zero_stateid);
 		pnfs_layout_release(lrp->lo, &lrp->lo->lretcount,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 63f7785..f519fe3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -519,7 +519,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 			range.iomode = nfsi->layout.roc_iomode;
 			range.offset = 0;
 			range.length = NFS4_MAX_UINT64;
-			pnfs_return_layout(state->inode, &range, NULL, RECALL_FILE);
+			pnfs_return_layout(state->inode, &range, NULL, RETURN_FILE);
 		}
 #endif /* CONFIG_PNFS */
 		nfs4_do_close(path, state, wait);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6b88c68..3a05422 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -680,7 +680,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 static int
 return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	      const nfs4_stateid *stateid, /* optional */
-	      enum pnfs_layoutrecall_type type, struct pnfs_layout_type *lo)
+	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo)
 {
 	struct nfs4_pnfs_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -690,7 +690,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
-		if (lo && (type == RECALL_FILE))
+		if (lo && (type == RETURN_FILE))
 			pnfs_layout_release(lo, &lo->lretcount, NULL);
 		goto out;
 	}
@@ -714,7 +714,7 @@ out:
 int
 _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		    const nfs4_stateid *stateid, /* optional */
-		    enum pnfs_layoutrecall_type type)
+		    enum pnfs_layoutreturn_type type)
 {
 	struct pnfs_layout_type *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -730,7 +730,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		arg.offset = 0;
 		arg.length = ~0;
 	}
-	if (type == RECALL_FILE) {
+	if (type == RETURN_FILE) {
 		if (nfsi->layoutcommit_ctx) {
 			status = pnfs_layoutcommit_inode(ino, 1);
 			if (status) {
@@ -1697,7 +1697,7 @@ pnfs_writeback_done(struct nfs_write_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RECALL_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
 		pnfs_initiate_write(data, NFS_CLIENT(data->inode),
 				    pdata->call_ops, pdata->how);
 	}
@@ -1828,7 +1828,7 @@ pnfs_read_done(struct nfs_read_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RECALL_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
 		pnfs_initiate_read(data, NFS_CLIENT(data->inode),
 				   pdata->call_ops);
 	}
@@ -2054,7 +2054,7 @@ pnfs_commit_done(struct nfs_write_data *data)
 			.length = data->args.count,
 		};
 		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RECALL_FILE);
+		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE);
 		pnfs_initiate_commit(data, NFS_CLIENT(data->inode),
 				     pdata->call_ops, pdata->how);
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9810ff3..a8933b4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -39,7 +39,7 @@ int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
-			enum pnfs_layoutrecall_type);
+			enum pnfs_layoutreturn_type);
 void set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id);
 void unmount_pnfs_layoutdriver(struct super_block *sb);
 int pnfs_use_read(struct inode *inode, ssize_t count);
@@ -227,13 +227,13 @@ static inline void pnfs_modify_new_request(struct nfs_page *req,
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
-				     enum pnfs_layoutrecall_type type)
+				     enum pnfs_layoutreturn_type type)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss) &&
-	    (type != RECALL_FILE || has_layout(nfsi)))
+	    (type != RETURN_FILE || has_layout(nfsi)))
 		return _pnfs_return_layout(ino, lseg, stateid, type);
 
 	return 0;
-- 
1.6.5.1

