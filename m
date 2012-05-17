Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761998Ab2ERBX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 21:23:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 2/4] NFSv4.1 cache mdsthreshold values on OPEN
Date: Thu, 17 May 2012 15:48:20 -0400
Message-Id: <1337284102-3372-2-git-send-email-andros@netapp.com>
In-Reply-To: <1337284102-3372-1-git-send-email-andros@netapp.com>
References: <1337284102-3372-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>

	net/sunrpc/xprt.c.rej
---
 fs/nfs/inode.c         |    2 ++
 fs/nfs/nfs4proc.c      |   26 +++++++++++++++++++++-----
 fs/nfs/pnfs.c          |   35 +++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h          |    9 +++++++++
 include/linux/nfs_fs.h |    1 +
 5 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9f17cd1..850d158 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -641,6 +641,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
+	ctx->mdsthreshold = NULL;
 	return ctx;
 }
 
@@ -669,6 +670,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 		put_rpccred(ctx->cred);
 	dput(ctx->dentry);
 	nfs_sb_deactive(sb);
+	kfree(ctx->mdsthreshold);
 	kfree(ctx);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e6ab15f..ec782f9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1781,7 +1781,14 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct
 /*
  * Returns a referenced nfs4_state
  */
-static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred, struct nfs4_state **res)
+static int _nfs4_do_open(struct inode *dir,
+			struct dentry *dentry,
+			fmode_t fmode,
+			int flags,
+			struct iattr *sattr,
+			struct rpc_cred *cred,
+			struct nfs4_state **res,
+			struct nfs4_threshold **ctx_th)
 {
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
@@ -1831,6 +1838,7 @@ static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode
 			nfs_setattr_update_inode(state->inode, sattr);
 		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
 	}
+	pnfs_cache_mdsthreshold(server, ctx_th, &opendata->f_attr.mdsthreshold);
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
@@ -1845,14 +1853,21 @@ out_err:
 }
 
 
-static struct nfs4_state *nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
+static struct nfs4_state *nfs4_do_open(struct inode *dir,
+					struct dentry *dentry,
+					fmode_t fmode,
+					int flags,
+					struct iattr *sattr,
+					struct rpc_cred *cred,
+					struct nfs4_threshold **ctx_th)
 {
 	struct nfs4_exception exception = { };
 	struct nfs4_state *res;
 	int status;
 
 	do {
-		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred, &res);
+		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
+				       &res, ctx_th);
 		if (status == 0)
 			break;
 		/* NOTE: BAD_SEQID means the server and client disagree about the
@@ -2176,7 +2191,8 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	struct nfs4_state *state;
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, ctx->cred);
+	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr,
+			     ctx->cred, &ctx->mdsthreshold);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
 	ctx->state = state;
@@ -2778,7 +2794,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		fmode = ctx->mode;
 	}
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred);
+	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred, NULL);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6fdeca2..5d78a90 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1626,3 +1626,38 @@ out_free:
 	kfree(data);
 	goto out;
 }
+
+/*
+ * Cache the mdsthreshold values from OPEN. Always overwrite old values.
+ *
+ * dst@: the nfs_open_context mdsthreshold pointer
+ * src@: the mdsthreshold from the server
+ */
+void
+pnfs_cache_mdsthreshold(struct nfs_server *server, struct nfs4_threshold **dst,
+			struct nfs4_threshold *src)
+{
+	dprintk("--> %s dst %p\n", __func__, dst);
+
+	if (!pnfs_enabled_sb(server) || !dst || src->bm == 0 ||
+	    server->pnfs_curr_ld->id != src->l_type)
+		return;
+
+	if (*dst == NULL) {
+		struct nfs4_threshold *th;
+
+		/* The threshold is a hint: just return if allocation fails */
+		th = kzalloc(sizeof(*th), GFP_NOFS);
+		if (!th) {
+			dprintk("%s mdsthreshold allocation failed\n",
+				__func__);
+			return;
+		}
+		*dst = th;
+	}
+	memcpy(*dst, src, sizeof(struct nfs4_threshold));
+
+	dprintk("%s bm=0x%x rd_sz=%llu wr_sz=%llu rd_io=%llu wr_io=%llu\n",
+		__func__, (*dst)->bm, (*dst)->rd_sz, (*dst)->wr_sz,
+		(*dst)->rd_io_sz, (*dst)->wr_io_sz);
+}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f20054b..21ff8cd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -222,6 +222,9 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       gfp_t gfp_flags);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
+void pnfs_cache_mdsthreshold(struct nfs_server *server,
+			     struct nfs4_threshold **dst,
+			     struct nfs4_threshold *src);
 
 /* nfs4_deviceid_flags */
 enum {
@@ -480,6 +483,12 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	return 0;
 }
 
+static inline void
+pnfs_cache_mdsthreshold(struct nfs_server *server, struct nfs4_threshold **dst,
+			struct nfs4_threshold *src)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6cc7dba..ca4a707 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -102,6 +102,7 @@ struct nfs_open_context {
 	int error;
 
 	struct list_head list;
+	struct nfs4_threshold	*mdsthreshold;
 };
 
 struct nfs_open_dir_context {
-- 
1.7.7.6

