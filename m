Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51848 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbD3Juh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 05:50:37 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: split transport vs operation errors for callbacks
Date: Thu, 30 Apr 2015 11:49:23 +0200
Message-Id: <1430387365-24348-2-git-send-email-hch@lst.de>
In-Reply-To: <1430387365-24348-1-git-send-email-hch@lst.de>
References: <1430387365-24348-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must only increment the sequence id if the client has seen and responded
to a request.  If we failed to deliver it to the client we must resend with
the same sequence id.  So just like the client track errors at the transport
level differently from those returned in the XDR.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 60 ++++++++++++++++++++------------------------------
 fs/nfsd/state.h        |  1 +
 2 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5827785..cd58b7c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -224,7 +224,7 @@ static int nfs_cb_stat_to_errno(int status)
 }
 
 static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
-			       enum nfsstat4 *status)
+			       int *status)
 {
 	__be32 *p;
 	u32 op;
@@ -235,7 +235,7 @@ static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
 	op = be32_to_cpup(p++);
 	if (unlikely(op != expected))
 		goto out_unexpected;
-	*status = be32_to_cpup(p);
+	*status = nfs_cb_stat_to_errno(be32_to_cpup(p));
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -446,22 +446,16 @@ out_overflow:
 static int decode_cb_sequence4res(struct xdr_stream *xdr,
 				  struct nfsd4_callback *cb)
 {
-	enum nfsstat4 nfserr;
 	int status;
 
 	if (cb->cb_minorversion == 0)
 		return 0;
 
-	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &nfserr);
-	if (unlikely(status))
-		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		goto out_default;
-	status = decode_cb_sequence4resok(xdr, cb);
-out:
-	return status;
-out_default:
-	return nfs_cb_stat_to_errno(nfserr);
+	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_status);
+	if (unlikely(status || cb->cb_status))
+		return status;
+
+	return decode_cb_sequence4resok(xdr, cb);
 }
 
 /*
@@ -524,26 +518,19 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 				  struct nfsd4_callback *cb)
 {
 	struct nfs4_cb_compound_hdr hdr;
-	enum nfsstat4 nfserr;
 	int status;
 
 	status = decode_cb_compound4res(xdr, &hdr);
 	if (unlikely(status))
-		goto out;
+		return status;
 
 	if (cb != NULL) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status))
-			goto out;
+		if (unlikely(status || cb->cb_status))
+			return status;
 	}
 
-	status = decode_cb_op_status(xdr, OP_CB_RECALL, &nfserr);
-	if (unlikely(status))
-		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		status = nfs_cb_stat_to_errno(nfserr);
-out:
-	return status;
+	return decode_cb_op_status(xdr, OP_CB_RECALL, &cb->cb_status);
 }
 
 #ifdef CONFIG_NFSD_PNFS
@@ -621,24 +608,18 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 				  struct nfsd4_callback *cb)
 {
 	struct nfs4_cb_compound_hdr hdr;
-	enum nfsstat4 nfserr;
 	int status;
 
 	status = decode_cb_compound4res(xdr, &hdr);
 	if (unlikely(status))
-		goto out;
+		return status;
+
 	if (cb) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status))
-			goto out;
+		if (unlikely(status || cb->cb_status))
+			return status;
 	}
-	status = decode_cb_op_status(xdr, OP_CB_LAYOUTRECALL, &nfserr);
-	if (unlikely(status))
-		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		status = nfs_cb_stat_to_errno(nfserr);
-out:
-	return status;
+	return decode_cb_op_status(xdr, OP_CB_LAYOUTRECALL, &cb->cb_status);
 }
 #endif /* CONFIG_NFSD_PNFS */
 
@@ -918,7 +899,8 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 
 	if (clp->cl_minorversion) {
 		/* No need for lock, access serialized in nfsd4_cb_prepare */
-		++clp->cl_cb_session->se_cb_seq_nr;
+		if (!task->tk_status)
+			++clp->cl_cb_session->se_cb_seq_nr;
 		clear_bit(0, &clp->cl_cb_slot_busy);
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
@@ -935,6 +917,11 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 	if (cb->cb_done)
 		return;
 
+	if (cb->cb_status) {
+		WARN_ON_ONCE(task->tk_status);
+		task->tk_status = cb->cb_status;
+	}
+
 	switch (cb->cb_ops->done(cb, task)) {
 	case 0:
 		task->tk_status = 0;
@@ -1099,6 +1086,7 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_ops = ops;
 	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
 	INIT_LIST_HEAD(&cb->cb_per_client);
+	cb->cb_status = 0;
 	cb->cb_done = true;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bde45d9..e791985 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -68,6 +68,7 @@ struct nfsd4_callback {
 	struct rpc_message cb_msg;
 	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
+	int cb_status;
 	bool cb_done;
 };
 
-- 
1.9.1

