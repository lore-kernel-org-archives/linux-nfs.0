Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36364 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbbFXIdr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 04:33:47 -0400
Received: by paceq1 with SMTP id eq1so24659061pac.3
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2015 01:33:46 -0700 (PDT)
Message-ID: <558A6B61.7010808@gmail.com>
Date: Wed, 24 Jun 2015 16:33:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH v3] nfsd: New helper nfsd4_cb_sequence_done() for processing
 more cb errors
References: <556D8C8D.50205@gmail.com> <55817CCE.1030704@gmail.com> <20150623213401.GB25319@fieldses.org>
In-Reply-To: <20150623213401.GB25319@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to Christoph's advice, this patch introduce
a new helper nfsd4_cb_sequence_done() for processing
more callback errors as client.

v3, base on Bruce's for-4.2 branch.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 122 +++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h        |   2 +-
 2 files changed, 88 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a492018..e7f50c4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -435,12 +435,12 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	 */
 	status = 0;
 out:
-	if (status)
-		nfsd4_mark_cb_fault(cb->cb_clp, status);
+	cb->cb_seq_status = status;
 	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	status = -EIO;
+	goto out;
 }
 
 static int decode_cb_sequence4res(struct xdr_stream *xdr,
@@ -451,11 +451,10 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
 	if (cb->cb_minorversion == 0)
 		return 0;
 
-	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_status);
-	if (unlikely(status || cb->cb_status))
+	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_seq_status);
+	if (unlikely(status || cb->cb_seq_status))
 		return status;
 
-	cb->cb_update_seq_nr = true;
 	return decode_cb_sequence4resok(xdr, cb);
 }
 
@@ -527,7 +526,7 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 
 	if (cb != NULL) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status || cb->cb_status))
+		if (unlikely(status || cb->cb_seq_status))
 			return status;
 	}
 
@@ -617,7 +616,7 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 
 	if (cb) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status || cb->cb_status))
+		if (unlikely(status || cb->cb_seq_status))
 			return status;
 	}
 	return decode_cb_op_status(xdr, OP_CB_LAYOUTRECALL, &cb->cb_status);
@@ -876,7 +875,11 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	u32 minorversion = clp->cl_minorversion;
 
 	cb->cb_minorversion = minorversion;
-	cb->cb_update_seq_nr = false;
+	/*
+	 * cb_seq_status is only set in decode_cb_sequence4res,
+	 * and so will remain 1 if an rpc level failure occurs.
+	 */
+	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	if (minorversion) {
 		if (!nfsd41_cb_get_slot(clp, task))
@@ -885,15 +888,30 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
-static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
+static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback *cb)
 {
-	struct nfsd4_callback *cb = calldata;
 	struct nfs4_client *clp = cb->cb_clp;
+	struct nfsd4_session *session = clp->cl_cb_session;
+	bool ret = true;
 
-	dprintk("%s: minorversion=%d\n", __func__,
-		clp->cl_minorversion);
+	if (!clp->cl_minorversion) {
+		/*
+		 * If the backchannel connection was shut down while this
+		 * task was queued, we need to resubmit it after setting up
+		 * a new backchannel connection.
+		 *
+		 * Note that if we lost our callback connection permanently
+		 * the submission code will error out, so we don't need to
+		 * handle that case here.
+		 */
+		if (task->tk_flags & RPC_TASK_KILLED)
+			goto need_restart;
+
+		return true;
+	}
 
-	if (clp->cl_minorversion) {
+	switch (cb->cb_seq_status) {
+	case 0:
 		/*
 		 * No need for lock, access serialized in nfsd4_cb_prepare
 		 *
@@ -901,29 +919,63 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 		 * If CB_SEQUENCE returns an error, then the state of the slot
 		 * (sequence ID, cached reply) MUST NOT change.
 		 */
-		if (cb->cb_update_seq_nr)
-			++clp->cl_cb_session->se_cb_seq_nr;
-
-		clear_bit(0, &clp->cl_cb_slot_busy);
-		rpc_wake_up_next(&clp->cl_cb_waitq);
-		dprintk("%s: freed slot, new seqid=%d\n", __func__,
-			clp->cl_cb_session->se_cb_seq_nr);
+		++session->se_cb_seq_nr;
+		break;
+	case -ESERVERFAULT:
+		++session->se_cb_seq_nr;
+	case 1:
+	case -NFS4ERR_BADSESSION:
+		nfsd4_mark_cb_fault(cb->cb_clp, cb->cb_seq_status);
+		ret = false;
+		break;
+	case -NFS4ERR_DELAY:
+		if (!rpc_restart_call(task))
+			goto out;
+
+		rpc_delay(task, 2 * HZ);
+		return false;
+	case -NFS4ERR_BADSLOT:
+		goto retry_nowait;
+	case -NFS4ERR_SEQ_MISORDERED:
+		if (session->se_cb_seq_nr != 1) {
+			session->se_cb_seq_nr = 1;
+			goto retry_nowait;
+		}
+		break;
+	default:
+		dprintk("%s: unprocessed error %d\n", __func__,
+			cb->cb_seq_status);
 	}
 
-	/*
-	 * If the backchannel connection was shut down while this
-	 * task was queued, we need to resubmit it after setting up
-	 * a new backchannel connection.
-	 *
-	 * Note that if we lost our callback connection permanently
-	 * the submission code will error out, so we don't need to
-	 * handle that case here.
-	 */
-	if (task->tk_flags & RPC_TASK_KILLED) {
-		task->tk_status = 0;
-		cb->cb_need_restart = true;
+	clear_bit(0, &clp->cl_cb_slot_busy);
+	rpc_wake_up_next(&clp->cl_cb_waitq);
+	dprintk("%s: freed slot, new seqid=%d\n", __func__,
+		clp->cl_cb_session->se_cb_seq_nr);
+
+	if (task->tk_flags & RPC_TASK_KILLED)
+		goto need_restart;
+out:
+	return ret;
+retry_nowait:
+	if (rpc_restart_call_prepare(task))
+		ret = false;
+	goto out;
+need_restart:
+	task->tk_status = 0;
+	cb->cb_need_restart = true;
+	return false;
+}
+
+static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
+{
+	struct nfsd4_callback *cb = calldata;
+	struct nfs4_client *clp = cb->cb_clp;
+
+	dprintk("%s: minorversion=%d\n", __func__,
+		clp->cl_minorversion);
+
+	if (!nfsd4_cb_sequence_done(task, cb))
 		return;
-	}
 
 	if (cb->cb_status) {
 		WARN_ON_ONCE(task->tk_status);
@@ -1099,8 +1151,8 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_msg.rpc_resp = cb;
 	cb->cb_ops = ops;
 	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
+	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
-	cb->cb_update_seq_nr = false;
 	cb->cb_need_restart = false;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4874ce5..583ffc1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -67,8 +67,8 @@ struct nfsd4_callback {
 	struct rpc_message cb_msg;
 	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
+	int cb_seq_status;
 	int cb_status;
-	bool cb_update_seq_nr;
 	bool cb_need_restart;
 };
 
-- 
2.4.3

