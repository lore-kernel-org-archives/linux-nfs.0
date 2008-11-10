From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 40/85] nfs41: schedule async session reset
Date: Mon, 10 Nov 2008 22:25:14 +0200
Message-ID: <1226348714-8559-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48829 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbYKJUZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:25:20 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Define a new session reset state which is set upon a sequence operation error
in both the sync and async error handlers.

Place all new requests and all but the last outstanding rpc on the
slot_tbl_waitq. Spawn the recovery thread when the last slot is free.
Call nfs4_proc_destroy_session, reinitialize the session, call
nfs4_proc_create_session, clear the session reset state, and wake up the next
task on the slot_tbl_waitq.

Return the nfs4_proc_destroy_session status to the session reclaimer and
check for NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION. Other destroy session
errors should be handled in nfs4_proc_destroy_session where the call can
be retried with adjusted arguments.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs41_session_recovery.c        |   51 +++++++++++++++++++++--
 fs/nfs/nfs4_fs.h                       |    2 +-
 fs/nfs/nfs4proc.c                      |   69 +++++++++++++++++++++++++++++--
 include/linux/nfs41_session_recovery.h |   30 ++++++++++++++
 4 files changed, 141 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs41_session_recovery.c b/fs/nfs/nfs41_session_recovery.c
index 39ad45f..a54572b 100644
--- a/fs/nfs/nfs41_session_recovery.c
+++ b/fs/nfs/nfs41_session_recovery.c
@@ -48,6 +48,17 @@ static int nfs41_start_session_recovery(struct nfs4_session *session)
 	return ret;
 }
 
+/*
+ * Session reset
+ */
+
+int nfs41_wait_session_reset(struct nfs4_session *session)
+{
+	might_sleep();
+	return wait_on_bit(&session->session_state, NFS41_SESSION_RESET,
+			   nfs4_wait_bit_killable, TASK_KILLABLE);
+}
+
 struct reclaimer_arg {
 	struct nfs4_session *session;
 };
@@ -74,17 +85,49 @@ static int nfs41_wait_session_recover_sync(struct nfs4_session *session)
 
 static int session_reclaimer(void *arg)
 {
-	int ret;
+	int ret, reset;
 	struct reclaimer_arg *rec = (struct reclaimer_arg *)arg;
 
-	dprintk("--> %s\n", __func__);
+	dprintk("--> %s session %p\n", __func__, rec->session);
 	allow_signal(SIGKILL);
 
-	ret = nfs4_proc_create_session(rec->session);
+	reset = nfs41_test_session_reset(rec->session);
+	if (reset) {
+		dprintk("%s Session Reset\n", __func__);
+		/* Reset is called only when all slots are clear.
+		 *
+		 * Bail on the reset if destroy session op fails or if
+		 * the session ref_count is not 1
+		 *
+		 * Of course since we are resetting the session,
+		 * it's OK if the session is already destroyed
+		 * on the server.
+		 */
+		ret = nfs4_proc_destroy_session(rec->session);
+		switch (ret) {
+		case 0:
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_DEADSESSION:
+			break;
+		default:
+			goto out_error;
+		}
+		memset(rec->session->sess_id, 0, sizeof(nfs41_sessionid));
+	}
+	ret = nfs4_proc_create_session(rec->session, reset);
 	if (ret)
 		goto out_error;
 
 out:
+	if (reset) {
+		struct nfs4_slot_table *tbl;
+
+		tbl = &rec->session->fore_channel.slot_table;
+		/* Need to clear reset bit and wake up the next rpc task
+		 * even on error */
+		nfs41_clear_session_reset(rec->session);
+		rpc_wake_up_next(&tbl->slot_tbl_waitq);
+	}
 	nfs41_end_session_recovery(rec->session);
 	kfree(rec);
 	module_put_and_exit(0);
@@ -96,8 +139,6 @@ out_error:
 
 	switch (ret) {
 	case -NFS4ERR_STALE_CLIENTID:
-	case -NFS4ERR_STALE_STATEID:
-	case -NFS4ERR_EXPIRED:
 		set_bit(NFS4CLNT_LEASE_EXPIRED, &rec->session->clp->cl_state);
 		break;
 	}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d0aac94..8cdc3c4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -196,7 +196,7 @@ extern int nfs4_setup_sequence(struct nfs_client *clp,
 extern void nfs4_put_session(struct nfs4_session **session);
 extern void nfs4_get_session(struct nfs_client *clp);
 extern struct nfs4_session *nfs4_alloc_session(void);
-extern int nfs4_proc_create_session(struct nfs4_session *);
+extern int nfs4_proc_create_session(struct nfs4_session *, int reset);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
 #else /* CONFIG_NFS_v4_1 */
 static inline int nfs4_setup_sequence(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ede017c..41f4f74 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -386,13 +386,32 @@ static void nfs41_sequence_done(struct nfs_client *clp,
  * A pointer to the slot's seqid is returned if found, or NULL otherwise.
  */
 static struct nfs4_slot *
-nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
+nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task,
+	       struct nfs4_session *session)
 {
 	int bit, slotid;
 	struct nfs4_slot *slot = NULL;
 	unsigned long *used, u;
 
 	spin_lock(&tbl->slot_tbl_lock);
+	if (nfs41_test_session_reset(session)) {
+		dprintk("%s Session Reset\n", __func__);
+		if (tbl->highest_used_slotid == -1) {
+			int ret;
+
+			/* The slot table is empty; start the reset thread */
+			dprintk("%s Slot Table Empty\n", __func__);
+			spin_unlock(&tbl->slot_tbl_lock);
+			ret = nfs41_recover_session_sync(session);
+			if (ret)
+				return slot;
+			nfs41_wait_session_reset(session);
+			spin_lock(&tbl->slot_tbl_lock);
+		} else {
+			/* Wait on the slot_tbl_waitq */
+			goto out;
+		}
+	}
 	slotid = tbl->lowest_free_slotid;
 	while (slotid < tbl->max_slots) {
 		used = idx2bmp(tbl->used_slots, slotid, NULL);
@@ -418,6 +437,7 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
 		break;
 	}
 	tbl->lowest_free_slotid = slotid;
+out:
 	spin_unlock(&tbl->slot_tbl_lock);
 	dprintk("<-- %s slot %p slotid %d\n", __func__,
 		slot, slot ? slot_idx(tbl, slot) : -1);
@@ -435,7 +455,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 
 	dprintk("--> %s\n", __func__);
 	tbl = &session->fore_channel.slot_table;
-	slot = nfs4_find_slot(tbl, task);
+	slot = nfs4_find_slot(tbl, task, session);
 
 	if (!slot) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
@@ -4326,6 +4346,38 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp,
 	return status;
 }
 
+/* Reset a slot table */
+static int nfs4_reset_slot_table(struct nfs4_channel *channel)
+{
+	struct nfs4_slot_table *tbl = &channel->slot_table;
+	int i, max_slots = channel->chan_attrs.max_reqs;
+	int old_max_slots = channel->slot_table.max_slots;
+	int ret = 0;
+
+	dprintk("--> %s: max_reqs=%u, tbl %p\n", __func__,
+		channel->chan_attrs.max_reqs, tbl);
+
+	/* Until we have dynamic slot table adjustment, insist
+	 * upon the same slot table size */
+	if (max_slots != old_max_slots) {
+		dprintk("%s reset slot table does't match old\n",
+			__func__);
+		ret = -EINVAL; /*XXX NFS4ERR_REQ_TOO_BIG ? */
+		goto out;
+	}
+	spin_lock(&tbl->slot_tbl_lock);
+	for (i = 0; i < max_slots; ++i)
+		tbl->slots[i].seq_nr = 1;
+	tbl->lowest_free_slotid = 0;
+	tbl->highest_used_slotid = -1;
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
+		tbl, tbl->slots, tbl->max_slots);
+out:
+	dprintk("<-- %s: return %d\n", __func__, ret);
+	return ret;
+}
+
 /*
  * Initialize slot table
  *
@@ -4554,7 +4606,7 @@ static int _nfs4_proc_create_session(struct nfs4_session *session)
  * It is the responsibility of the caller to verify the session is
  * expired before calling this routine.
  */
-int nfs4_proc_create_session(struct nfs4_session *session)
+int nfs4_proc_create_session(struct nfs4_session *session, int reset)
 {
 	int status;
 	u32 *ptr;
@@ -4569,8 +4621,11 @@ int nfs4_proc_create_session(struct nfs4_session *session)
 
 	session->clnt = clp->cl_rpcclient;
 
-	/* Init the fore channel */
-	status = nfs4_init_slot_table(&session->fore_channel);
+	/* Init or reset the fore channel */
+	if (reset)
+		status = nfs4_reset_slot_table(&session->fore_channel);
+	else
+		status = nfs4_init_slot_table(&session->fore_channel);
 	dprintk("fore channel initialization returned %d\n", status);
 	if (status)
 		goto out;
@@ -4579,6 +4634,10 @@ int nfs4_proc_create_session(struct nfs4_session *session)
 	ptr = (int *)session->sess_id;
 	dprintk("sessionid is: %u:%u:%u:%u\n", ptr[0], ptr[1], ptr[2], ptr[3]);
 
+	if (reset)
+		/* Lease time is aleady set */
+		goto out;
+
 	/* Get the lease time */
 	status = nfs4_proc_get_lease_time(clp, session, &fsinfo);
 	if (status == 0) {
diff --git a/include/linux/nfs41_session_recovery.h b/include/linux/nfs41_session_recovery.h
index 2d91e80..a0f61b3 100644
--- a/include/linux/nfs41_session_recovery.h
+++ b/include/linux/nfs41_session_recovery.h
@@ -13,10 +13,17 @@
 
 /*
  * Session state bits
+ *
+ * State machine.
+ * NFS41_SESSION_ALLOC bit set: session is ready for create_session call.
+ * NFS41_SESSION_RECOVER bit set: session is being reset/recovered
+ * NFS41_SESSION_ALLOC bit unset: valid session in use.
+ * NFS41_SESSION_RESET bit set: session is being reset.
  */
 enum nfs41_session_state {
 	NFS41_SESSION_ALLOC = 0,
 	NFS41_SESSION_RECOVER,
+	NFS41_SESSION_RESET,
 };
 
 /*
@@ -32,6 +39,29 @@ static inline int nfs41_test_session_alloc(struct nfs4_session *session)
 	return test_bit(NFS41_SESSION_ALLOC, &session->session_state);
 }
 
+/*
+ * Set, test, and clear the session reset state
+ */
+static inline int nfs41_set_session_reset(struct nfs4_session *session)
+{
+	return test_and_set_bit(NFS41_SESSION_RESET, &session->session_state);
+}
+
+static inline int nfs41_test_session_reset(struct nfs4_session *session)
+{
+	return test_bit(NFS41_SESSION_RESET, &session->session_state);
+}
+
+static inline void nfs41_clear_session_reset(struct nfs4_session *session)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NFS41_SESSION_RESET,
+			   &session->session_state);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&session->session_state, NFS41_SESSION_RESET);
+}
+
+int nfs41_wait_session_reset(struct nfs4_session *session);
 int nfs41_set_session_valid(struct nfs4_session *);
 int nfs41_recover_session(struct nfs4_session *);
 int nfs41_recover_session_sync(struct nfs4_session *);
-- 
1.6.0.2

