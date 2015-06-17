Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35477 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbbFQN5q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 09:57:46 -0400
Received: by pdbnf5 with SMTP id nf5so40848067pdb.2
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jun 2015 06:57:45 -0700 (PDT)
Message-ID: <55817CCE.1030704@gmail.com>
Date: Wed, 17 Jun 2015 21:57:34 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH v2] nfsd: nfsd4_cb_sequence_done() for processing more cb
 errors
References: <556D8C8D.50205@gmail.com>
In-Reply-To: <556D8C8D.50205@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pnfs layout, nfsd got error NFS4ERR_SEQ_MISORDERED.
It is caused by nfs return NFS4ERR_DELAY before validate_seqid(),
don't update the sequnce id, but nfsd updates the sequnce id !!!

According to RFC5661 20.9.3,
" If CB_SEQUENCE returns an error, then the state of the slot
(sequence ID, cached reply) MUST NOT change."

This patch introduce a new helper nfsd4_cb_sequence_done() for
processing more callback errors as client.

v2, 
thanks Christoph's advice of adding a helper process errors as client

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 122 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/state.h        |   1 +
 2 files changed, 93 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ce8d3f2..6fce478 100644
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
@@ -451,8 +451,8 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
 	if (cb->cb_minorversion == 0)
 		return 0;
 
-	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_status);
-	if (unlikely(status || cb->cb_status))
+	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_seq_status);
+	if (unlikely(status || cb->cb_seq_status))
 		return status;
 
 	return decode_cb_sequence4resok(xdr, cb);
@@ -526,7 +526,7 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 
 	if (cb != NULL) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status || cb->cb_status))
+		if (unlikely(status || cb->cb_seq_status))
 			return status;
 	}
 
@@ -616,7 +616,7 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 
 	if (cb) {
 		status = decode_cb_sequence4res(xdr, cb);
-		if (unlikely(status || cb->cb_status))
+		if (unlikely(status || cb->cb_seq_status))
 			return status;
 	}
 	return decode_cb_op_status(xdr, OP_CB_LAYOUTRECALL, &cb->cb_status);
@@ -874,6 +874,11 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_client *clp = cb->cb_clp;
 	u32 minorversion = clp->cl_minorversion;
 
+	/*
+	 * cb_seq_status is only set in decode_cb_sequence4res,
+	 * and so will remain 1 if an rpc level failure occurs.
+	 */
+	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	cb->cb_minorversion = minorversion;
 	if (minorversion) {
@@ -883,6 +888,84 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback *cb)
+{
+	struct nfs4_client *clp = cb->cb_clp;
+	struct nfsd4_session *session = clp->cl_cb_session;
+	bool ret = true;
+
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
+
+	switch (cb->cb_seq_status) {
+	case 0:
+		/*
+		 * No need for lock, access serialized in nfsd4_cb_prepare
+		 *
+		 * RFC5661 20.9.3
+		 * If CB_SEQUENCE returns an error, then the state of the slot
+		 * (sequence ID, cached reply) MUST NOT change.
+		 */
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
+	}
+
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
 static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
@@ -891,30 +974,8 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 	dprintk("%s: minorversion=%d\n", __func__,
 		clp->cl_minorversion);
 
-	if (clp->cl_minorversion) {
-		/* No need for lock, access serialized in nfsd4_cb_prepare */
-		if (!task->tk_status)
-			++clp->cl_cb_session->se_cb_seq_nr;
-		clear_bit(0, &clp->cl_cb_slot_busy);
-		rpc_wake_up_next(&clp->cl_cb_waitq);
-		dprintk("%s: freed slot, new seqid=%d\n", __func__,
-			clp->cl_cb_session->se_cb_seq_nr);
-	}
-
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
+	if (!nfsd4_cb_sequence_done(task, cb))
 		return;
-	}
 
 	if (cb->cb_status) {
 		WARN_ON_ONCE(task->tk_status);
@@ -1090,6 +1151,7 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_msg.rpc_resp = cb;
 	cb->cb_ops = ops;
 	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
+	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	cb->cb_need_restart = false;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index dbc4f85..d975165 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -67,6 +67,7 @@ struct nfsd4_callback {
 	struct rpc_message cb_msg;
 	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
+	int cb_seq_status;
 	int cb_status;
 	bool cb_need_restart;
 };
-- 
2.4.3

