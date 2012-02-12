Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab2BLRyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Feb 2012 12:54:12 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 3/3] NFSv4.1 avoid freeing slot when tasks are waiting
Date: Sun, 12 Feb 2012 12:52:56 -0500
Message-Id: <1329069176-8349-4-git-send-email-andros@netapp.com>
In-Reply-To: <1329069176-8349-1-git-send-email-andros@netapp.com>
References: <1329069176-8349-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When a slotid is to freed, check to see if a task is waiting for a slot.
If so, then the slot to be freed is the lowest (the only) slot, and can
therefore be assigned to a waiting task.

This saves a bit lookup in nfs4_free_slot and nfs4_find_slot, and an hist
lookup in nfs4_lookup_slot_locked.

Add a new tk_private field to the rpc_task structure to hold the assigned slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c            |   61 +++++++++++++++++++++++++++++++-----------
 include/linux/sunrpc/sched.h |    1 +
 2 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 11f4e96..17b3d0b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -485,15 +485,33 @@ static void nfs4_free_all_slots(struct nfs4_slot_table *tbl)
  *
  * Must be called while holding tbl->slot_tbl_lock
  */
-static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
+static bool
+nfs4_free_slot(struct nfs4_session *ses, struct nfs4_slot *slot)
 {
-	int slotid = free_slotid;
+	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
+	struct rpc_task *task = NULL;
+	int slotid = slot->slot_id;
+	bool clear_it = true;
 
 	BUG_ON(slotid < 0 || slotid >= NFS4_MAX_SLOT_TABLE);
+
+	if (!rpc_queue_empty(&tbl->slot_tbl_waitq) &&
+		!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
+		/* The slot is the lowest (the only) free slotid.
+		* Try to give it to the next task. */
+		task =  rpc_wake_up_next(&tbl->slot_tbl_waitq);
+		if (task) {
+			rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
+			task->tk_private = slot;
+			clear_it = false;
+			goto highslot;
+		}
+	}
+
 	/* clear used bit in bitmap */
 	__clear_bit(slotid, tbl->used_slots);
 
+highslot:
 	/* update highest_used_slotid when it is freed */
 	if (slotid == tbl->highest_used_slotid) {
 		slotid = find_last_bit(tbl->used_slots, tbl->max_slots);
@@ -503,17 +521,19 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 			tbl->highest_used_slotid = -1;
 	}
 	dprintk("%s: free_slotid %u highest_used_slotid %d\n", __func__,
-		free_slotid, tbl->highest_used_slotid);
+		slot->slot_id, tbl->highest_used_slotid);
+
+	return clear_it;
 }
 
 /*
  * Signal state manager thread if session fore channel is drained
  */
-static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
+static void nfs4_check_drain_fc_complete(struct nfs4_session *ses, bool wakeup)
 {
 	struct rpc_task *task;
 
-	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
+	if (wakeup && !test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
 		task = rpc_wake_up_next(&ses->fc_slot_table.slot_tbl_waitq);
 		if (task)
 			rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
@@ -542,6 +562,7 @@ void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot_table *tbl;
+	bool wakeup;
 
 	tbl = &res->sr_session->fc_slot_table;
 	if (!res->sr_slot) {
@@ -552,8 +573,8 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot->slot_id);
-	nfs4_check_drain_fc_complete(res->sr_session);
+	wakeup = nfs4_free_slot(res->sr_session, res->sr_slot);
+	nfs4_check_drain_fc_complete(res->sr_session, wakeup);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 }
@@ -688,14 +709,21 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		return -EAGAIN;
 	}
 
-	slotid = nfs4_find_slot(tbl);
-	if (slotid == NFS4_MAX_SLOT_TABLE) {
-		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-		spin_unlock(&tbl->slot_tbl_lock);
-		dprintk("<-- %s: no free slots\n", __func__);
-		return -EAGAIN;
+	if (task->tk_private) {
+		/* use slot assigned in nfs4_free_slot */
+		slot = (struct nfs4_slot *)task->tk_private;
+		task->tk_private = NULL;
+		dprintk("%s Using tk_private slot\n", __func__);
+	} else {
+		slotid = nfs4_find_slot(tbl);
+		if (slotid == NFS4_MAX_SLOT_TABLE) {
+			rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+			spin_unlock(&tbl->slot_tbl_lock);
+			dprintk("<-- %s: no free slots\n", __func__);
+			return -EAGAIN;
+		}
+		slot = nfs4_lookup_slot_locked(tbl, slotid);
 	}
-	slot = nfs4_lookup_slot_locked(tbl, slotid);
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
@@ -703,7 +731,8 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	args->sa_slot = slot;
 	args->sa_cache_this = cache_reply;
 
-	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
+	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slot->slot_id,
+		slot->seq_nr);
 
 	res->sr_session = session;
 	res->sr_slot = slot;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index e775689..b4429bcf 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -60,6 +60,7 @@ struct rpc_task {
 	void			(*tk_action)(struct rpc_task *);
 	const struct rpc_call_ops *tk_ops;
 	void *			tk_calldata;
+	void *			tk_private;
 
 	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
 	unsigned long		tk_runstate;	/* Task run status */
-- 
1.7.6.4

