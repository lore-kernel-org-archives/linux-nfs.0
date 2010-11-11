Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35026 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932196Ab0KKCLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 21:11:23 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] pnfs-submit: add back channel draining
Date: Thu, 11 Nov 2010 09:10:39 -0500
Message-Id: <1289484640-4100-3-git-send-email-andros@netapp.com>
In-Reply-To: <1289484640-4100-2-git-send-email-andros@netapp.com>
References: <1289484640-4100-1-git-send-email-andros@netapp.com>
 <1289484640-4100-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Currently the state manager only waits for the fore channel to drain.
The back channel processing must also be considered.
The current complete is really for the forechannel. Add a back channel complete.
Once the fore channel is drained, the state manager is the only thread
running - except for the back channel thread.

Have the state manager thread wait for the any current back channel processing
to complete (drain) before proceeding.

When the state manager is draining, stop all new back channel processing by
returning NFS4ERR_DELAY to the back channel client.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |    6 ++++++
 fs/nfs/callback_xdr.c     |    1 +
 fs/nfs/internal.h         |    1 +
 fs/nfs/nfs4proc.c         |   26 +++++++++++++++++++-------
 fs/nfs/nfs4state.c        |   21 +++++++++++++++++++--
 include/linux/nfs_fs_sb.h |    2 +-
 6 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6ba528a..9a2c051 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -630,6 +630,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
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
index e05d1b3..67ad022 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -782,6 +782,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		 * A single slot, so highest used slotid is either 0 or -1
 		 */
 		tbl->highest_used_slotid--;
+		nfs41_check_drain_bc_complete(cps.session);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("%s highest_used_slotid %d\n", __func__,
 			tbl->highest_used_slotid);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 755e555..1ec5b95 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -311,6 +311,7 @@ extern int _nfs4_call_sync_session(struct nfs_server *server,
 				   struct nfs4_sequence_res *res,
 				   int cache_reply);
 
+void nfs41_check_drain_bc_complete(struct nfs4_session *ses);
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bf179bb..ab34149 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -357,9 +357,9 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
 }
 
 /*
- * Signal state manager thread if session is drained
+ * Signal state manager thread if session fore channel is drained
  */
-static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
+static void nfs41_check_drain_fc_complete(struct nfs4_session *ses)
 {
 	struct rpc_task *task;
 
@@ -373,8 +373,20 @@ static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
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
+void nfs41_check_drain_bc_complete(struct nfs4_session *ses)
+{
+	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state) ||
+	    ses->bc_slot_table.highest_used_slotid != -1)
+		return;
+	dprintk("%s COMPLETE: Session Back Channel Drained\n", __func__);
+	complete(&ses->bc_slot_table.complete);
 }
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -391,7 +403,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slot);
-	nfs41_check_drain_session_complete(res->sr_session);
+	nfs41_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 }
@@ -4864,17 +4876,17 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
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
index 784f122..304cd30 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -147,6 +147,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
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
@@ -175,12 +180,24 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	struct nfs4_session *ses = clp->cl_session;
 	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
 
+	/* fore channel */
 	spin_lock(&tbl->slot_tbl_lock);
 	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
 	if (tbl->highest_used_slotid != -1) {
-		INIT_COMPLETION(ses->complete);
+		INIT_COMPLETION(tbl->complete);
+		spin_unlock(&tbl->slot_tbl_lock);
+		wait_for_completion_interruptible(&tbl->complete);
+		goto backchannel;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+backchannel:
+	/* back channel */
+	tbl = &ses->bc_slot_table;
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->highest_used_slotid != -1) {
+		INIT_COMPLETION(tbl->complete);
 		spin_unlock(&tbl->slot_tbl_lock);
-		return wait_for_completion_interruptible(&ses->complete);
+		return wait_for_completion_interruptible(&tbl->complete);
 	}
 	spin_unlock(&tbl->slot_tbl_lock);
 	return 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 295d449..c3127cc 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -211,6 +211,7 @@ struct nfs4_slot_table {
 						 * op for dynamic resizing */
 	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
 						 * the new max_slots */
+	struct completion complete;
 };
 
 static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
@@ -227,7 +228,6 @@ struct nfs4_session {
 	unsigned long			session_state;
 	u32				hash_alg;
 	u32				ssv_len;
-	struct completion		complete;
 
 	/* The fore and back channel */
 	struct nfs4_channel_attrs	fc_attrs;
-- 
1.6.6

