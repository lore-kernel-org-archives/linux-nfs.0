Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:43962 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753641AbeE3SG0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:26 -0400
Received: by mail-io0-f193.google.com with SMTP id t6-v6so4130796iob.10
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:26 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.24
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:24 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/19] pnfs: Add LAYOUTGET to OPEN of a new file
Date: Wed, 30 May 2018 14:05:44 -0400
Message-Id: <20180530180553.38769-11-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-10-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

This triggers when have no pre-existing inode to attach to.
The preexisting case is saved for later.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c  | 20 ++++++++++--
 fs/nfs/nfs4state.c |  8 +++++
 fs/nfs/pnfs.c      | 81 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pnfs.h      | 17 ++++++++++
 4 files changed, 121 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 771439971759..a73c83f17a86 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -86,6 +86,7 @@
 	| ATTR_MTIME_SET)
 
 struct nfs4_opendata;
+static void nfs4_layoutget_release(void *calldata);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
@@ -878,6 +879,10 @@ nfs4_sequence_process_interrupted(struct nfs_client *client,
 
 #else	/* !CONFIG_NFS_V4_1 */
 
+static void nfs4_layoutget_release(void *calldata)
+{
+}
+
 static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	return nfs40_sequence_done(task, res);
@@ -1245,6 +1250,8 @@ static void nfs4_opendata_free(struct kref *kref)
 			struct nfs4_opendata, kref);
 	struct super_block *sb = p->dentry->d_sb;
 
+	if (p->lgp)
+		nfs4_layoutget_release(p->lgp);
 	nfs_free_seqid(p->o_arg.seqid);
 	nfs4_sequence_free_slot(&p->o_res.seq_res);
 	if (p->state != NULL)
@@ -2335,8 +2342,10 @@ static int nfs4_run_open_task(struct nfs4_opendata *data,
 	if (!ctx) {
 		nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, 1);
 		data->is_recover = true;
-	} else
+	} else {
 		nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, 0);
+		pnfs_lgopen_prepare(data, ctx);
+	}
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -2816,7 +2825,10 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		nfs_inode_attach_open_context(ctx);
 		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			nfs4_schedule_stateid_recovery(server, state);
+		else
+			pnfs_parse_lgopen(state->inode, opendata->lgp, ctx);
 	}
+
 out:
 	return ret;
 }
@@ -8718,13 +8730,15 @@ static void nfs4_layoutget_release(void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
 	struct inode *inode = lgp->args.inode;
-	struct nfs_server *server = NFS_SERVER(inode);
-	size_t max_pages = max_response_pages(server);
+	size_t max_pages = lgp->args.layout.pglen / PAGE_SIZE;
 
 	dprintk("--> %s\n", __func__);
 	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	nfs4_free_pages(lgp->args.layout.pages, max_pages);
 	pnfs_put_layout_hdr(NFS_I(inode)->layout);
+	if (inode)
+		pnfs_put_layout_hdr(NFS_I(inode)->layout);
+	put_rpccred(lgp->cred);
 	put_nfs_open_context(lgp->args.ctx);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c10a422efe6f..2bf2eaa08ca7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -77,6 +77,14 @@ const nfs4_stateid invalid_stateid = {
 	.type = NFS4_INVALID_STATEID_TYPE,
 };
 
+const nfs4_stateid current_stateid = {
+	{
+		/* Funky initialiser keeps older gcc versions happy */
+		.data = { 0x0, 0x0, 0x0, 0x1, 0 },
+	},
+	.type = NFS4_SPECIAL_STATEID_TYPE,
+};
+
 static DEFINE_MUTEX(nfs_clid_init_mutex);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 07f1bbd9100c..a0a2484c3aed 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -934,7 +934,7 @@ pnfs_find_server(struct inode *inode, struct nfs_open_context *ctx)
 static struct nfs4_layoutget *
 pnfs_alloc_init_layoutget_args(struct inode *ino,
 	   struct nfs_open_context *ctx,
-	   nfs4_stateid *stateid,
+	   const nfs4_stateid *stateid,
 	   const struct pnfs_layout_range *range,
 	   gfp_t gfp_flags)
 {
@@ -978,7 +978,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	lgp->args.ctx = get_nfs_open_context(ctx);
 	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
-	lgp->cred = ctx->cred;
+	lgp->cred = get_rpccred(ctx->cred);
 	return lgp;
 }
 
@@ -1943,6 +1943,83 @@ pnfs_sanity_check_layout_range(struct pnfs_layout_range *range)
 	return true;
 }
 
+extern const nfs4_stateid current_stateid;
+
+static void _lgopen_prepare_attached(struct nfs4_opendata *data,
+				     struct nfs_open_context *ctx)
+{
+	/* STUB */
+}
+
+static void _lgopen_prepare_floating(struct nfs4_opendata *data,
+				     struct nfs_open_context *ctx)
+{
+	struct pnfs_layout_range rng = {
+		.iomode = (data->o_arg.fmode & FMODE_WRITE) ?
+			  IOMODE_RW: IOMODE_READ,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+	struct nfs4_layoutget *lgp;
+
+	lgp = pnfs_alloc_init_layoutget_args(NULL, ctx, &current_stateid,
+					     &rng, GFP_KERNEL);
+	if (!lgp)
+		return;
+	data->lgp = lgp;
+	data->o_arg.lg_args = &lgp->args;
+	data->o_res.lg_res = &lgp->res;
+}
+
+void pnfs_lgopen_prepare(struct nfs4_opendata *data,
+			 struct nfs_open_context *ctx)
+{
+	struct nfs_server *server = NFS_SERVER(data->dir->d_inode);
+
+	if (!(pnfs_enabled_sb(server) &&
+	      server->pnfs_curr_ld->flags & PNFS_LAYOUTGET_ON_OPEN))
+		return;
+	/* Could check on max_ops, but currently hardcoded high enough */
+	if (data->state)
+		_lgopen_prepare_attached(data, ctx);
+	else
+		_lgopen_prepare_floating(data, ctx);
+}
+
+void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
+		       struct nfs_open_context *ctx)
+{
+	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_segment *lseg;
+	u32 iomode;
+
+	if (!lgp || lgp->res.layoutp->len == 0)
+		return;
+	if (!lgp->args.inode) {
+		/* Need to grab lo */
+		spin_lock(&ino->i_lock);
+		lo = pnfs_find_alloc_layout(ino, ctx, GFP_KERNEL);
+		atomic_inc(&lo->plh_outstanding);
+		spin_unlock(&ino->i_lock);
+		lgp->args.inode = ino;
+	} else
+		lo = NFS_I(lgp->args.inode)->layout;
+	pnfs_get_layout_hdr(lo);
+
+	lseg = pnfs_layout_process(lgp);
+	atomic_dec(&lo->plh_outstanding);
+	if (IS_ERR(lseg)) {
+		/* ignore lseg, but would like to mark not to try lgopen */
+		/* clear some lo flags - first and fail ???? */
+	} else {
+		iomode = lgp->args.range.iomode;
+		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
+		pnfs_put_lseg(lseg);
+	}
+	pnfs_clear_first_layoutget(lo);
+	pnfs_put_layout_hdr(lo);
+}
+
 struct pnfs_layout_segment *
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 964a7227ea97..b110c09ea89c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -35,6 +35,8 @@
 #include <linux/nfs_page.h>
 #include <linux/workqueue.h>
 
+struct nfs4_opendata;
+
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
@@ -378,6 +380,10 @@ void pnfs_layout_mark_request_commit(struct nfs_page *req,
 				     struct pnfs_layout_segment *lseg,
 				     struct nfs_commit_info *cinfo,
 				     u32 ds_commit_idx);
+void pnfs_lgopen_prepare(struct nfs4_opendata *data,
+			 struct nfs_open_context *ctx);
+void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
+		       struct nfs_open_context *ctx);
 
 static inline bool nfs_have_layout(struct inode *inode)
 {
@@ -778,6 +784,17 @@ static inline bool nfs4_refresh_layout_stateid(nfs4_stateid *dst,
 {
 	return false;
 }
+
+static inline void pnfs_lgopen_prepare(struct nfs4_opendata *data,
+		struct nfs_open_context *ctx)
+{
+}
+
+static inline void pnfs_parse_lgopen(struct inode *ino,
+		struct nfs4_layoutget *lgp,
+		struct nfs_open_context *ctx)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 #if IS_ENABLED(CONFIG_NFS_V4_2)
-- 
2.17.0

