From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 41/44] nfsd41: Backchannel: Setup sequence information
Date: Tue, 16 Jun 2009 04:21:10 +0300
Message-ID: <1245115270-8155-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2703
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757784AbZFPBVK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:21:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Follows the model used by the NFS client.  Setup the RPC prepare and done
function pointers so that we can populate the sequence information if
minorversion == 1.  rpc_run_task() is then invoked directly just like
existing NFS client operations do.

nfsd4_cb_prepare() determines if the sequence information needs to be setup.
If the slot is in use, it adds itself to the wait queue.

nfsd4_cb_done() wakes anyone sleeping on the callback channel wait queue
after our RPC reply has been received.  It also sets the task message
result pointer to NULL to clearly indicate we're done using it.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[define cl_cb_seq_nr here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |   83 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/state.h |    1 +
 2 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a661ae4..70e1af2 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -529,6 +529,88 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	do_probe_callback(clp);
 }
 
+/*
+ * There's currently a single callback channel slot.
+ * If the slot is available, then mark it busy.  Otherwise, set the
+ * thread for sleeping on the callback RPC wait queue.
+ */
+static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
+		struct rpc_task *task)
+{
+	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	u32 *ptr = (u32 *)clp->cl_sessionid.data;
+	int status = 0;
+
+	dprintk("%s: %u:%u:%u:%u\n", __func__,
+		ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
+		rpc_sleep_on(&clp->cl_cb_waitq, task, NULL);
+		dprintk("%s slot is busy\n", __func__);
+		status = -EAGAIN;
+		goto out;
+	}
+
+	/*
+	 * We'll need the clp during XDR encoding and decoding,
+	 * and the sequence during decoding to verify the reply
+	 */
+	args->args_seq.cbs_clp = clp;
+	task->tk_msg.rpc_resp = &args->args_seq;
+
+out:
+	dprintk("%s status=%d\n", __func__, status);
+	return status;
+}
+
+/*
+ * TODO: cb_sequence should support referring call lists, cachethis, multiple
+ * slots, and mark callback channel down on communication errors.
+ */
+static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_delegation *dp = calldata;
+	struct nfs4_client *clp = dp->dl_client;
+	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	u32 minorversion = clp->cl_cb_conn.cb_minorversion;
+	int status = 0;
+
+	args->args_seq.cbs_minorversion = minorversion;
+	if (minorversion) {
+		status = nfsd41_cb_setup_sequence(clp, task);
+		if (status) {
+			if (status != -EAGAIN) {
+				/* terminate rpc task */
+				task->tk_status = status;
+				task->tk_action = NULL;
+			}
+			return;
+		}
+	}
+	rpc_call_start(task);
+}
+
+static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_delegation *dp = calldata;
+	struct nfs4_client *clp = dp->dl_client;
+
+	dprintk("%s: minorversion=%d\n", __func__,
+		clp->cl_cb_conn.cb_minorversion);
+
+	if (clp->cl_cb_conn.cb_minorversion) {
+		/* No need for lock, access serialized in nfsd4_cb_prepare */
+		++clp->cl_cb_seq_nr;
+		clear_bit(0, &clp->cl_cb_slot_busy);
+		rpc_wake_up_next(&clp->cl_cb_waitq);
+		dprintk("%s: freed slot, new seqid=%d\n", __func__,
+			clp->cl_cb_seq_nr);
+
+		/* We're done looking into the sequence information */
+		task->tk_msg.rpc_resp = NULL;
+	}
+}
+
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
@@ -568,6 +650,7 @@ static void nfsd4_cb_recall_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfsd4_cb_recall_ops = {
+	.rpc_call_prepare = nfsd4_cb_prepare,
 	.rpc_call_done = nfsd4_cb_recall_done,
 	.rpc_release = nfsd4_cb_recall_release,
 };
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 6f1a25e..5aaafbb 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -216,6 +216,7 @@ struct nfs4_client {
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
+	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
-- 
1.6.3

