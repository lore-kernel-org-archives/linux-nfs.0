From: andros@netapp.com
Subject: [PATCH_V2 1/1] NFS add session back channel draining
Date: Mon,  6 Dec 2010 22:19:42 -0500
Message-ID: <1291691982-2170-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604Ab0LHPGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 10:06:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 fs/nfs/callback.h         |    1 +
 fs/nfs/callback_proc.c    |    6 ++++++
 fs/nfs/callback_xdr.c     |   17 +++++++++++++++++
 fs/nfs/nfs4proc.c         |   26 +++++++++++++++++++-------
 fs/nfs/nfs4state.c        |   29 ++++++++++++++++++++++-------
 include/linux/nfs_fs_sb.h |    2 +-
 6 files changed, 66 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 85a7cfd..434233e 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -131,6 +131,7 @@ extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
+extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2950fca..7a976ef 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -287,6 +287,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (clp == NULL)
 		goto out;
 
+	/* state manager is resetting the session */
+	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
+		status = NFS4ERR_DELAY;
+		goto out_putclient;
+	}
+
 	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
 	if (status)
 		goto out_putclient;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 05af212..0a5e32d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -593,6 +593,20 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
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
 #else /* CONFIG_NFS_V4_1 */
 
 static __be32
@@ -601,6 +615,9 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 }
 
+static void nfs4_callback_free_slot(struct nfs4_session *session)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static __be32
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a653ff..b48f607 100644
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
@@ -4767,17 +4779,17 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
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
index f575a31..0082483 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -142,6 +142,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
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
@@ -165,21 +170,31 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
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
+	
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
 
 int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 452d964..8ded472 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -196,6 +196,7 @@ struct nfs4_slot_table {
 						 * op for dynamic resizing */
 	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
 						 * the new max_slots */
+	struct completion complete;
 };
 
 static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
@@ -212,7 +213,6 @@ struct nfs4_session {
 	unsigned long			session_state;
 	u32				hash_alg;
 	u32				ssv_len;
-	struct completion		complete;
 
 	/* The fore and back channel */
 	struct nfs4_channel_attrs	fc_attrs;
-- 
1.6.6

