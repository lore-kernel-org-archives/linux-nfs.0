From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 08/10] nfsd41: Backchannel: Setup sequence information
Date: Fri,  1 May 2009 02:06:36 +0300
Message-ID: <1241132796-32622-1-git-send-email-bhalevy@panasas.com>
References: <49FA2D86.8060402@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31382 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755644AbZD3XGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:06:45 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
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
after our RPC reply has been received.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[define cl_cb_seq_nr here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |  109 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/state.h |    1 +
 2 files changed, 110 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 14535b2..2bf2cd4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -507,6 +507,115 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 }
 
 /*
+ * There's currently a single callback channel slot.
+ * If the slot is available, then mark it busy.  Otherwise, set the
+ * thread for sleeping on the callback RPC wait queue.
+ */
+static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
+		struct rpc_task *task)
+{
+	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	struct nfs4_rpc_res *res = task->tk_msg.rpc_resp;
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
+	/* We'll need the clp during XDR encoding and decoding */
+	args->args_seq.cbs_clp = clp;
+	res->res_seq = &args->args_seq;
+
+out:
+	dprintk("%s status=%d\n", __func__, status);
+	return status;
+}
+
+struct nfsd4_cb_data {
+	struct nfs4_client *clp;
+};
+
+/*
+ * FIXME: cb_sequence should support referring call lists, cachethis, multiple
+ * slots, and mark callback channel down on communication errors.
+ */
+static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_client *clp = ((struct nfsd4_cb_data *)calldata)->clp;
+	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	u32 minorversion = clp->cl_callback.cb_minorversion;
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
+	struct nfs4_client *clp = ((struct nfsd4_cb_data *)calldata)->clp;
+
+	dprintk("%s: minorversion=%d\n", __func__,
+		clp->cl_callback.cb_minorversion);
+
+	if (clp->cl_callback.cb_minorversion) {
+		/* No need for lock, access serialized in nfsd4_cb_prepare */
+		++clp->cl_cb_seq_nr;
+		clear_bit(0, &clp->cl_cb_slot_busy);
+		rpc_wake_up_next(&clp->cl_cb_waitq);
+		dprintk("%s: freed slot, new seqid=%d\n", __func__,
+			clp->cl_cb_seq_nr);
+	}
+}
+
+struct rpc_call_ops nfsd4_cb_ops = {
+	.rpc_call_prepare = nfsd4_cb_prepare,
+	.rpc_call_done = nfsd4_cb_done
+};
+
+static int nfsd4_cb_sync(struct nfs4_client *clp, struct rpc_message *msg,
+			 int flags)
+{
+	int status;
+	struct rpc_task *task;
+	struct nfsd4_cb_data data = {
+		.clp = clp
+	};
+
+	struct rpc_task_setup task_setup = {
+		.rpc_client = clp->cl_callback.cb_client,
+		.rpc_message = msg,
+		.callback_ops = &nfsd4_cb_ops,
+		.callback_data = &data,
+		.flags = flags
+	};
+
+	task = rpc_run_task(&task_setup);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = task->tk_status;
+	rpc_put_task(task);
+	return status;
+}
+
+/*
  * called with dp->dl_count inc'ed.
  */
 void
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f204ca8..432b5d1 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -212,6 +212,7 @@ struct nfs4_client {
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
+	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
-- 
1.6.2.1

