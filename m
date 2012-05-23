Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34454 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810Ab2EWNDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 09:03:40 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/4] NFSv4.1 cache mdsthreshold values on OPEN
Date: Wed, 23 May 2012 05:02:35 -0400
Message-Id: <1337763757-1566-2-git-send-email-andros@netapp.com>
In-Reply-To: <1337763757-1566-1-git-send-email-andros@netapp.com>
References: <1337763757-1566-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c         |    2 ++
 fs/nfs/nfs4proc.c      |   38 +++++++++++++++++++++++++++++++++-----
 fs/nfs/pnfs.c          |   12 ++++++++++++
 fs/nfs/pnfs.h          |   21 +++++++++++++++++++++
 include/linux/nfs_fs.h |    1 +
 5 files changed, 69 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9ad81ce..889f7e5 100644
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
index 78784e5..d84c633 100644
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
@@ -1806,6 +1813,11 @@ static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
+	if (ctx_th && server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
+		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
+		if (!opendata->f_attr.mdsthreshold)
+			goto err_opendata_put;
+	}
 	if (dentry->d_inode != NULL)
 		opendata->state = nfs4_get_open_state(dentry->d_inode, sp);
 
@@ -1831,11 +1843,19 @@ static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode
 			nfs_setattr_update_inode(state->inode, sattr);
 		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
 	}
+
+	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server))
+		*ctx_th = opendata->f_attr.mdsthreshold;
+	else
+		kfree(opendata->f_attr.mdsthreshold);
+	opendata->f_attr.mdsthreshold = NULL;
+
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
 	return 0;
 err_opendata_put:
+	kfree(opendata->f_attr.mdsthreshold);
 	nfs4_opendata_put(opendata);
 err_put_state_owner:
 	nfs4_put_state_owner(sp);
@@ -1845,14 +1865,21 @@ out_err:
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
@@ -2176,7 +2203,8 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	struct nfs4_state *state;
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, ctx->cred);
+	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr,
+			     ctx->cred, &ctx->mdsthreshold);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
 	ctx->state = state;
@@ -2778,7 +2806,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		fmode = ctx->mode;
 	}
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred);
+	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred, NULL);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5d09a36..cbcb6ae 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1630,3 +1630,15 @@ out_free:
 	kfree(data);
 	goto out;
 }
+
+struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
+{
+	struct nfs4_threshold *thp;
+
+	thp = kzalloc(sizeof(*thp), GFP_NOFS);
+	if (!thp) {
+		dprintk("%s mdsthreshold allocation failed\n", __func__);
+		return NULL;
+	}
+	return thp;
+}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7980756..29fd23c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -227,6 +227,7 @@ int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head,
 			const struct nfs_pgio_completion_ops *compl_ops);
 int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head,
 			const struct nfs_pgio_completion_ops *compl_ops);
+struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 
 /* nfs4_deviceid_flags */
 enum {
@@ -360,6 +361,14 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
+static inline bool
+pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
+		   struct nfs_server *nfss)
+{
+	return (dst && src && src->bm != 0 &&
+					nfss->pnfs_curr_ld->id == src->l_type);
+}
+
 #ifdef NFS_DEBUG
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 #else
@@ -485,6 +494,18 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	return 0;
 }
 
+static inline bool
+pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
+		   struct nfs_server *nfss)
+{
+	return false;
+}
+
+static inline struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
+{
+	return NULL;
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

