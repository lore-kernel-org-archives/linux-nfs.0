Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62796 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab1ADRMY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 12:12:24 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V6 10/11] NFS add session back channel draining
Date: Tue,  4 Jan 2011 12:11:43 -0500
Message-Id: <1294161104-4555-3-git-send-email-andros@netapp.com>
In-Reply-To: <1294161104-4555-2-git-send-email-andros@netapp.com>
References: <1294161104-4555-1-git-send-email-andros@netapp.com>
 <1294161104-4555-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Currently session draining only drains the fore channel.
The back channel processing must also be drained.

Use the back channel highest_slot_used to indicate that a callback is being
processed by the callback thread.  Move the session complete to be per channel.

When the session is draininig, wait for any current back channel processing
to complete and stop all new back channel processing by returning NFS4ERR_DELAY
to the back channel client.

Drain the back channel, then the fore channel.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.h         |    3 ++-
 fs/nfs/callback_proc.c    |    7 +++++++
 fs/nfs/callback_xdr.c     |   35 +++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |   26 +++++++++++++++++++-------
 fs/nfs/nfs4state.c        |   29 ++++++++++++++++++++++-------
 include/linux/nfs_fs_sb.h |    2 +-
 6 files changed, 86 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 25e8802..b678e3e 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -138,6 +138,8 @@ extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
 					 void *dummy,
 					 struct cb_process_state *cps);
 
+extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
+extern void nfs4_cb_take_slot(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
@@ -145,7 +147,6 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_process_state *cps);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
-
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b70e46d..c1bead2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -253,6 +253,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (clp == NULL)
 		goto out;
 
+	/* state manager is resetting the session */
+	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
+		status = NFS4ERR_DELAY;
+		goto out;
+	}
+
 	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
 	if (status)
 		goto out;
@@ -273,6 +279,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_slotid = args->csa_slotid;
 	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	nfs4_cb_take_slot(clp);
 	cps->clp = clp; /* put in nfs4_callback_compound */
 
 out:
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 85cbb8f..9dbccf4 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -596,6 +596,37 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS_OK);
 }
 
+static void nfs4_callback_free_slot(struct nfs4_session *session)
+{
+	struct nfs4_slot_table *tbl = &session->bc_slot_table;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	/*
+	 * Let the state manager know callback processing done.
+	 * A single slot, so highest used slotid is either 0 or -1
+	 */
+	tbl->highest_used_slotid--;
+	nfs4_check_drain_bc_complete(session);
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
+static void nfs4_cb_free_slot(struct nfs_client *clp)
+{
+	if (clp && clp->cl_session)
+		nfs4_callback_free_slot(clp->cl_session);
+}
+
+/* A single slot, so highest used slotid is either 0 or -1 */
+void nfs4_cb_take_slot(struct nfs_client *clp)
+{
+	struct nfs4_slot_table *tbl = &clp->cl_session->bc_slot_table;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	tbl->highest_used_slotid++;
+	BUG_ON(tbl->highest_used_slotid != 0);
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
 #else /* CONFIG_NFS_V4_1 */
 
 static __be32
@@ -604,6 +635,9 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 }
 
+static void nfs4_cb_free_slot(struct nfs_client *clp)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static __be32
@@ -725,6 +759,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
+	nfs4_cb_free_slot(cps.clp);
 	nfs_put_client(cps.clp);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6652e39..fcf2658 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -355,9 +355,9 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
 }
 
 /*
- * Signal state manager thread if session is drained
+ * Signal state manager thread if session fore channel is drained
  */
-static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
+static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
 {
 	struct rpc_task *task;
 
@@ -371,8 +371,20 @@ static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
 	if (ses->fc_slot_table.highest_used_slotid != -1)
 		return;
 
-	dprintk("%s COMPLETE: Session Drained\n", __func__);
-	complete(&ses->complete);
+	dprintk("%s COMPLETE: Session Fore Channel Drained\n", __func__);
+	complete(&ses->fc_slot_table.complete);
+}
+
+/*
+ * Signal state manager thread if session back channel is drained
+ */
+void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
+{
+	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state) ||
+	    ses->bc_slot_table.highest_used_slotid != -1)
+		return;
+	dprintk("%s COMPLETE: Session Back Channel Drained\n", __func__);
+	complete(&ses->bc_slot_table.complete);
 }
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -389,7 +401,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slot);
-	nfs41_check_drain_session_complete(res->sr_session);
+	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 }
@@ -4781,17 +4793,17 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	if (!session)
 		return NULL;
 
-	init_completion(&session->complete);
-
 	tbl = &session->fc_slot_table;
 	tbl->highest_used_slotid = -1;
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
+	init_completion(&tbl->complete);
 
 	tbl = &session->bc_slot_table;
 	tbl->highest_used_slotid = -1;
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
+	init_completion(&tbl->complete);
 
 	session->session_state = 1<<NFS4_SESSION_INITING;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 11290de..fb23a32 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -143,6 +143,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 	return status;
 }
 
+/*
+ * Back channel returns NFS4ERR_DELAY for new requests when
+ * NFS4_SESSION_DRAINING is set so there is no work to be done when draining
+ * is ended.
+ */
 static void nfs4_end_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
@@ -166,22 +171,32 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
-static int nfs4_begin_drain_session(struct nfs_client *clp)
+static int nfs4_wait_on_slot_tbl(struct nfs4_slot_table *tbl)
 {
-	struct nfs4_session *ses = clp->cl_session;
-	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
-
 	spin_lock(&tbl->slot_tbl_lock);
-	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
 	if (tbl->highest_used_slotid != -1) {
-		INIT_COMPLETION(ses->complete);
+		INIT_COMPLETION(tbl->complete);
 		spin_unlock(&tbl->slot_tbl_lock);
-		return wait_for_completion_interruptible(&ses->complete);
+		return wait_for_completion_interruptible(&tbl->complete);
 	}
 	spin_unlock(&tbl->slot_tbl_lock);
 	return 0;
 }
 
+static int nfs4_begin_drain_session(struct nfs_client *clp)
+{
+	struct nfs4_session *ses = clp->cl_session;
+	int ret = 0;
+
+	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
+	/* back channel */
+	ret = nfs4_wait_on_slot_tbl(&ses->bc_slot_table);
+	if (ret)
+		return ret;
+	/* fore channel */
+	return nfs4_wait_on_slot_tbl(&ses->fc_slot_table);
+}
+
 int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1eaa054..e93ada0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -197,6 +197,7 @@ struct nfs4_slot_table {
 						 * op for dynamic resizing */
 	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
 						 * the new max_slots */
+	struct completion complete;
 };
 
 static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
@@ -213,7 +214,6 @@ struct nfs4_session {
 	unsigned long			session_state;
 	u32				hash_alg;
 	u32				ssv_len;
-	struct completion		complete;
 
 	/* The fore and back channel */
 	struct nfs4_channel_attrs	fc_attrs;
-- 
1.6.6

