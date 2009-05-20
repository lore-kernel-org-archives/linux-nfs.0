From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [RFC 08/11] nfsd41: Backchannel: Setup sequence information
Date: Tue, 19 May 2009 20:00:25 -0700
Message-ID: <1242788428-18723-8-git-send-email-Ricardo.Labiaga@netapp.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com>
 <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-7-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57430 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288AbZETDAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 23:00:32 -0400
In-Reply-To: <1242788428-18723-7-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 fs/nfsd/nfs4callback.c     |   78 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/state.h |    1 +
 2 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0b5c4a6..b739cc9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -533,6 +533,83 @@ nfsd4_probe_callback(struct nfs4_client *clp)
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
+	}
+}
+
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
@@ -572,6 +649,7 @@ static void nfsd4_cb_recall_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfsd4_cb_recall_ops = {
+	.rpc_call_prepare = nfsd4_cb_prepare,
 	.rpc_call_done = nfsd4_cb_recall_done,
 	.rpc_release = nfsd4_cb_recall_release,
 };
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 261cd73..9191497 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -198,6 +198,7 @@ struct nfs4_client {
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
+	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
-- 
1.5.4.3

