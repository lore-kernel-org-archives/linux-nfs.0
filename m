Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34790 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab1KIS7A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:59:00 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 5/7] NFSv4.1: do not drain session on CB_RECALL_SLOT
Date: Wed,  9 Nov 2011 13:58:24 -0500
Message-Id: <1320865106-1791-5-git-send-email-andros@netapp.com>
In-Reply-To: <1320865106-1791-1-git-send-email-andros@netapp.com>
References: <1320865106-1791-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add a reference to the dynamic session slots while they are in use
to allow for reducing the number of active slots without
the need to drain the session.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c  |    6 +++++-
 fs/nfs/nfs4_fs.h        |    1 -
 fs/nfs/nfs4proc.c       |   23 +++++++++++++++++++++--
 fs/nfs/nfs4state.c      |   36 ------------------------------------
 include/linux/nfs_xdr.h |    1 +
 5 files changed, 27 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 77cc96c..baf0847 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -578,8 +578,12 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (args->crsa_target_max_slots == fc_tbl->max_slots)
 		goto out;
 
+        spin_lock(&fc_tbl->slot_tbl_lock);
 	fc_tbl->target_max_slots = args->crsa_target_max_slots;
-	nfs41_handle_recall_slot(cps->clp);
+        fc_tbl->max_slots = fc_tbl->target_max_slots;
+        nfs4_reduce_slots_locked(fc_tbl);
+        cps->clp->cl_session->fc_attrs.max_reqs = fc_tbl->max_slots;
+        spin_unlock(&fc_tbl->slot_tbl_lock);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ff87169..a1f889a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -22,7 +22,6 @@ enum nfs4_client_state {
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
-	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e3a7663..525635f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -359,6 +359,7 @@ static void nfs4_init_slot(struct nfs4_slot *new, u8 slotid, int ivalue)
 	INIT_HLIST_NODE(&new->slot_node);
 	new->slotid = slotid;
 	new->seq_nr = ivalue;
+	atomic_set(&new->ref, 1);
 }
 
 static void nfs4_insert_slot_locked(struct nfs4_slot_table *tbl,
@@ -451,13 +452,29 @@ nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl, u8 slotid)
 	return NULL;
 }
 
+static inline void nfs4_put_slot_locked(struct nfs4_slot *slot)
+{
+	dprintk("--> %s slotid %d ref %d\n", __func__, slot->slotid,
+		atomic_read(&slot->ref));
+	if (atomic_dec_and_test(&slot->ref)) {
+		BUG_ON(!hlist_unhashed(&slot->slot_node));
+		kfree(slot);
+	}
+}
+
+static inline void nfs4_get_slot(struct nfs4_slot *slot)
+{
+	dprintk("--> %s slotid %d ref %d\n", __func__, slot->slotid,
+		atomic_read(&slot->ref));
+	atomic_inc(&slot->ref);
+}
+
 static void nfs4_remove_slot_locked(struct nfs4_slot_table *tbl,
 				    struct nfs4_slot *slot)
 {
-	dprintk("--> %s slotid %d\n", __func__, slot->slotid);
 	hlist_del_init(&slot->slot_node);
 	tbl->allocated_slots--;
-	kfree(slot);
+	nfs4_put_slot_locked(slot);
 }
 
 static void nfs4_free_all_slots(struct nfs4_slot_table *tbl)
@@ -587,6 +604,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slot->slotid);
+	nfs4_put_slot_locked(res->sr_slot);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
@@ -746,6 +764,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		nfs4_dynamic_alloc_slot(tbl, slotid);
 		return -EAGAIN;
 	}
+	nfs4_get_slot(slot);
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8260865..c08fb3b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1479,12 +1479,6 @@ void nfs4_schedule_session_recovery(struct nfs4_session *session)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_session_recovery);
 
-void nfs41_handle_recall_slot(struct nfs_client *clp)
-{
-	set_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
-	nfs4_schedule_state_manager(clp);
-}
-
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
@@ -1559,8 +1553,6 @@ static int nfs4_reset_session(struct nfs_client *clp)
 		goto out;
 	}
 	clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-	/* create_session negotiated new slot table */
-	clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
 
 	 /* Let the state manager reestablish state */
 	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
@@ -1569,28 +1561,9 @@ out:
 	return status;
 }
 
-static int nfs4_recall_slot(struct nfs_client *clp)
-{
-	struct nfs4_slot_table *fc_tbl = &clp->cl_session->fc_slot_table;
-	struct nfs4_channel_attrs *fc_attrs = &clp->cl_session->fc_attrs;
-
-	nfs4_begin_drain_session(clp);
-
-	spin_lock(&fc_tbl->slot_tbl_lock);
-	fc_tbl->max_slots = fc_tbl->target_max_slots;
-	nfs4_reduce_slots_locked(fc_tbl);
-	fc_tbl->target_max_slots = 0;
-	fc_attrs->max_reqs = fc_tbl->max_slots;
-	spin_unlock(&fc_tbl->slot_tbl_lock);
-
-	nfs4_end_drain_session(clp);
-	return 0;
-}
-
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
-static int nfs4_recall_slot(struct nfs_client *clp) { return 0; }
 #endif /* CONFIG_NFS_V4_1 */
 
 /* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
@@ -1699,15 +1672,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs_client_return_marked_delegations(clp);
 			continue;
 		}
-		/* Recall session slots */
-		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
-		   && nfs4_has_session(clp)) {
-			status = nfs4_recall_slot(clp);
-			if (status < 0)
-				goto out_error;
-			continue;
-		}
-
 
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 76b27a4..3bcfbaf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -169,6 +169,7 @@ struct nfs4_channel_attrs {
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
 	struct hlist_node	slot_node;
+	atomic_t		ref;
 	u32		 	seq_nr;
 	u8			slotid;
 };
-- 
1.7.6.4

