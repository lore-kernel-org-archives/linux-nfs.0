From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/10] nfsd41: Backchannel: Setup sequence information
Date: Fri,  4 Sep 2009 19:32:39 +0300
Message-ID: <1252081959-19665-1-git-send-email-bhalevy@panasas.com>
References: <4AA13DE3.8020800@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:28015 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933755AbZIDQcj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 12:32:39 -0400
In-Reply-To: <4AA13DE3.8020800@panasas.com>
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
[define and initialize cl_cb_seq_nr here]
[pulled out unused defintion of nfsd4_cb_done]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |   62 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    1 +
 3 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 32ea3f5..da36a46 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -521,6 +521,67 @@ nfsd4_probe_callback(struct nfs4_client *clp)
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
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
@@ -560,6 +621,7 @@ static void nfsd4_cb_recall_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfsd4_cb_recall_ops = {
+	.rpc_call_prepare = nfsd4_cb_prepare,
 	.rpc_call_done = nfsd4_cb_recall_done,
 	.rpc_release = nfsd4_cb_recall_release,
 };
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 957f6e5..b2ffa3b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1335,6 +1335,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			unconf->cl_cb_conn.cb_minorversion =
 				cstate->minorversion;
 			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
+			unconf->cl_cb_seq_nr = 1;
 			nfsd4_probe_callback(unconf);
 		}
 		conf = unconf;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 234e9af..b621428 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -222,6 +222,7 @@ struct nfs4_client {
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
+	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
-- 
1.6.4

