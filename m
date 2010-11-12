Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756036Ab0KLIt0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:26 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fS025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:20 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/22] pnfs-submit: roc add layoutreturn op to close compound
Date: Fri, 12 Nov 2010 03:48:40 -0500
Message-Id: <1289551724-18575-19-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c       |   73 +++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4state.c      |   18 +-----------
 fs/nfs/nfs4xdr.c        |   14 ++++++++-
 fs/nfs/pnfs.c           |   64 +++++++++++++++++++++++++++++++++++++----
 fs/nfs/pnfs.h           |    1 +
 include/linux/nfs_xdr.h |   19 ++++++++++++
 6 files changed, 143 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6223c6a..2b47c59 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -74,6 +74,8 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
+static void nfs4_layoutreturn_set_stateid(struct inode *ino,
+					  struct nfs4_layoutreturn_res *res);
 
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1821,16 +1823,6 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	return err;
 }
 
-struct nfs4_closedata {
-	struct path path;
-	struct inode *inode;
-	struct nfs4_state *state;
-	struct nfs_closeargs arg;
-	struct nfs_closeres res;
-	struct nfs_fattr fattr;
-	unsigned long timestamp;
-};
-
 static void nfs4_free_closedata(void *data)
 {
 	struct nfs4_closedata *calldata = data;
@@ -1840,6 +1832,17 @@ static void nfs4_free_closedata(void *data)
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
 	path_put(&calldata->path);
+	if (calldata->res.op_bitmask & NFS4_HAS_LAYOUTRETURN) {
+		struct pnfs_layout_hdr *lo = NFS_I(calldata->inode)->layout;
+
+		spin_lock(&lo->inode->i_lock);
+		lo->plh_block_lgets--;
+		lo->plh_outstanding--;
+		if (!pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
+		spin_unlock(&lo->inode->i_lock);
+		put_layout_hdr(lo->inode);
+	}
 	kfree(calldata);
 }
 
@@ -1869,6 +1872,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
+			if (calldata->res.op_bitmask & NFS4_HAS_LAYOUTRETURN)
+				nfs4_layoutreturn_set_stateid(calldata->inode,
+							&calldata->res.lr_res);
 			renew_lease(server, calldata->timestamp);
 			nfs4_close_clear_stateid_flags(state,
 					calldata->arg.fmode);
@@ -1920,8 +1926,27 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 
-	if (calldata->arg.fmode == 0)
+	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
+		/* Are there layout segments to return on close? */
+		if (pnfs_roc(calldata)) {
+			struct nfs_inode *nfsi = NFS_I(calldata->inode);
+			if (pnfs_return_layout_barrier(nfsi,
+						&calldata->arg.lr_args.range)) {
+				dprintk("%s: waiting on barrier\n", __func__);
+				/* FIXME race with wake here */
+				rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
+				spin_lock(&calldata->inode->i_lock);
+				nfsi->layout->plh_block_lgets--;
+				nfsi->layout->plh_outstanding--;
+				if (!pnfs_layoutgets_blocked(nfsi->layout, NULL))
+					rpc_wake_up(&nfsi->lo_rpcwaitq_stateid);
+				spin_unlock(&calldata->inode->i_lock);
+				put_layout_hdr(calldata->inode);
+				return;
+			}
+		}
+	}
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
@@ -5587,6 +5612,7 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 
 		if (pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
 			dprintk("%s: waiting on barrier\n", __func__);
+			/* FIXME race with wake here */
 			rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
 			return;
 		}
@@ -5602,6 +5628,19 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static void nfs4_layoutreturn_set_stateid(struct inode *ino,
+					  struct nfs4_layoutreturn_res *res)
+{
+	struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
+
+	spin_lock(&ino->i_lock);
+	if (res->lrs_present)
+		pnfs_set_layout_stateid(lo, &res->stateid, true);
+	else
+		BUG_ON(!list_empty(&lo->segs));
+	spin_unlock(&ino->i_lock);
+}
+
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
@@ -5620,16 +5659,8 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		nfs_restart_rpc(task, lrp->clp);
 		return;
 	}
-	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
-		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-
-		spin_lock(&lo->inode->i_lock);
-		if (lrp->res.lrs_present)
-			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-		else
-			BUG_ON(!list_empty(&lo->segs));
-		spin_unlock(&lo->inode->i_lock);
-	}
+	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE))
+		nfs4_layoutreturn_set_stateid(lrp->args.inode, &lrp->res);
 	dprintk("<-- %s\n", __func__);
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ceb0d66..784f122 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -601,24 +601,8 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 	if (!call_close) {
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
-	} else {
-		u32 roc_iomode;
-		struct nfs_inode *nfsi = NFS_I(state->inode);
-
-		if (has_layout(nfsi) &&
-		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
-			struct pnfs_layout_range range = {
-				.iomode = roc_iomode,
-				.offset = 0,
-				.length = NFS4_MAX_UINT64,
-			};
-
-			pnfs_return_layout(state->inode, &range, NULL,
-					   RETURN_FILE, wait);
-		}
-
+	} else
 		nfs4_do_close(path, state, gfp_mask, wait);
-	}
 }
 
 void nfs4_close_state(struct path *path, struct nfs4_state *state, fmode_t fmode)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f530c7e..adb4c47 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -438,12 +438,14 @@ static int nfs4_stat_to_errno(int);
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_close_maxsz + \
-				 encode_getattr_maxsz)
+				 encode_getattr_maxsz + \
+				 encode_layoutreturn_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_close_maxsz + \
-				 decode_getattr_maxsz)
+				 decode_getattr_maxsz + \
+				 decode_layoutreturn_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
@@ -2143,6 +2145,8 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
+	if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
+		encode_layoutreturn(&xdr, &args->lr_args, &hdr);
 	encode_nops(&hdr);
 	return 0;
 }
@@ -5719,6 +5723,12 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
+	/*
+	 * With the forgetful model, we pay no attention to the
+	 * layoutreturn status.
+	 */
+	if (res->op_bitmask & NFS4_HAS_LAYOUTRETURN)
+		decode_layoutreturn(&xdr, &res->lr_res);
 out:
 	return status;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 22abf83..76cfb11 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -623,6 +623,63 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	return ret;
 }
 
+/*
+ * Return on close
+ *
+ * No LAYOUTRETURNS can be sent when BULK RECALL flag is set.
+ * FIXME: add layoutcommit operation if layoutcommit_needed is true.
+ */
+bool
+pnfs_roc(struct nfs4_closedata *data)
+{
+	struct nfs4_layoutreturn_args *lr_args = &data->arg.lr_args;
+	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_segment *lseg, *tmp;
+	struct pnfs_layout_range range = {
+		.length = NFS4_MAX_UINT64,
+	};
+	LIST_HEAD(tmp_list);
+	bool found = false;
+
+	spin_lock(&data->inode->i_lock);
+	lo = NFS_I(data->inode)->layout;
+	if (!lo || lo->roc_iomode == 0 ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+		goto out_nolayout;
+
+	range.iomode = lo->roc_iomode;
+	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
+		if (should_free_lseg(&lseg->range, &range)) {
+			mark_lseg_invalid(lseg, &tmp_list);
+			found = true;
+		}
+	if (found == false)
+		goto out_nolayout;
+	/* Stop new and drop response to outstanding LAYOUTGETS */
+	lo->plh_block_lgets++;
+	lo->plh_outstanding++;
+	/* Reference matched in pnfs_layoutreturn_release */
+	get_layout_hdr(lo);
+
+	spin_unlock(&data->inode->i_lock);
+
+	pnfs_free_lseg_list(&tmp_list);
+
+	lr_args->reclaim = 0;
+	lr_args->layout_type = NFS_SERVER(data->inode)->pnfs_curr_ld->id;
+	lr_args->return_type = RETURN_FILE;
+	lr_args->range = range;
+	lr_args->inode = data->inode;
+	data->res.op_bitmask |= NFS4_HAS_LAYOUTRETURN;
+	data->arg.op_bitmask |= NFS4_HAS_LAYOUTRETURN;
+
+	return true;
+
+out_nolayout:
+	spin_unlock(&data->inode->i_lock);
+	return false;
+}
+
 static int
 return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
@@ -997,13 +1054,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	*lgp->lsegpp = lseg;
 	pnfs_insert_layout(lo, lseg);
 
-	if (res->return_on_close) {
-		/* FI: This needs to be re-examined.  At lo level,
-		 * all it needs is a bit indicating whether any of
-		 * the lsegs in the list have the flags set.
-		 */
+	if (res->return_on_close)
 		lo->roc_iomode |= res->range.iomode;
-	}
 
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7fd1f5d..916a057 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -234,6 +234,7 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
 				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
+bool pnfs_roc(struct nfs4_closedata *data);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f472405..6c4ba71 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -351,12 +351,18 @@ struct nfs_open_confirmres {
 /*
  * Arguments to the close call.
  */
+
+/* op_bitmask bits */
+#define NFS4_HAS_LAYOUTRETURN  0x01
+
 struct nfs_closeargs {
 	struct nfs_fh *         fh;
 	nfs4_stateid *		stateid;
 	struct nfs_seqid *	seqid;
 	fmode_t			fmode;
 	const u32 *		bitmask;
+	u32			op_bitmask; /* which optional ops to encode */
+	struct nfs4_layoutreturn_args	lr_args; /* optional */
 	struct nfs4_sequence_args	seq_args;
 };
 
@@ -365,8 +371,21 @@ struct nfs_closeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
+	u32			op_bitmask; /* which optional ops encoded */
+	struct nfs4_layoutreturn_res	lr_res; /* optional */
 	struct nfs4_sequence_res	seq_res;
 };
+
+struct nfs4_closedata {
+	struct path path;
+	struct inode *inode;
+	struct nfs4_state *state;
+	struct nfs_closeargs arg;
+	struct nfs_closeres res;
+	struct nfs_fattr fattr;
+	unsigned long timestamp;
+};
+
 /*
  *  * Arguments to the lock,lockt, and locku call.
  *   */
-- 
1.7.2.1

