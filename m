Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52390 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932624Ab1KDOWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 10:22:51 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/3] NFSv4.1: dynamic session slots
Date: Tue, 18 Oct 2011 02:33:05 -0400
Message-Id: <1318919587-2642-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The session fore/backchannel slot tables implementation is changed from a
static array to an hlist hashed on slotid. Slotid's are values 0..N where N
is initially negotiated between the client and server via the CREATE_SESSION
call, and can be dynamically changed by the server during an active session.

The slot table init/reset code called by nfs4_proc_create_session has been
refactored: nfs4_setup_slot_tables calls either nfs4_init_slot_table OR
nfs4_reset_slot_table.

A new struct nfs4_slot_table field, allocated_slots, counts the
number of dynamically allocated_slots and is dec'ed/inc'ed in the
nfs4_remove_slot_locked/nfs4_insert_slot_locked functions.

When there are no allocated slots (mount), nfs4_setup_slot_tables calls
nfs4_init_slot_tbl on both the fc and bc tables which allocates an initial
number of session slots equal to the inital number of dynamic rpc_slots
created upon transport creation (xprt->min_reqs).

Slots are dynamically allocated as needed upto the CREATE_SESSION negotiated
max_reqs value. An upcoming patch set will respond to the NFSv4.1 server's
increase in the max_reqs of the slot table (via SEQUENCE target_highest_slotid)
by dynamically adding slots in this same manner.

For session reset the session is drained (inactive). The (old) session has
allocated fc/bc slot tables which we will reuse.  nfs4_reset_slot_table
only reduces the allocated_slots if the new max_reqs negotiated by the reset
CREATE_SESSION is less than the number of allocated_slots. The resultant slot
table is then re-initialized.

CB_SLOT_RECALL is changed only in that it now shares code with session
reset - it also calls nfs4_reduce_slots_locked.

Slots are referenced while in use so that the slot table size can be
adjusted down without session draining for CB_SLOT_RECALL (an upcoming patch),
and for responding to an NFSv4.1 server's decreasing the number of slots
via SEQUENCE target_highest_slotid.

The backchannel also uses the new dynamic slot allocator, even though we only
currently support a single back channel slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |   25 +++-
 fs/nfs/internal.h         |    2 +
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4proc.c         |  355 +++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4state.c        |   12 +--
 fs/nfs/nfs4xdr.c          |   19 +--
 include/linux/nfs_fs_sb.h |   12 +-
 include/linux/nfs_xdr.h   |    5 +-
 8 files changed, 305 insertions(+), 126 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..98ff5fc 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -342,7 +342,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
 		return htonl(NFS4ERR_BADSLOT);
 
-	slot = tbl->slots + args->csa_slotid;
+	slot = nfs4_lookup_slot_locked(tbl, args->csa_slotid);
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
 
 	/* Normal */
@@ -377,6 +377,22 @@ out_ok:
 	return htonl(NFS4_OK);
 }
 
+static bool test_refer_slot(struct nfs4_slot_table *tbl,
+			    struct referring_call *ref)
+{
+	struct nfs4_slot *slot;
+	bool status = false;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (test_bit(ref->rc_slotid, tbl->used_slots)) {
+		slot = nfs4_lookup_slot_locked(tbl, ref->rc_slotid);
+		if (slot->seq_nr == ref->rc_sequenceid)
+			status = true;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+	return status;
+}
+
 /*
  * For each referring call triple, check the session's slot table for
  * a match.  If the slot is in use and the sequence numbers match, the
@@ -417,12 +433,7 @@ static bool referring_call_exists(struct nfs_client *clp,
 				((u32 *)&rclist->rcl_sessionid.data)[2],
 				((u32 *)&rclist->rcl_sessionid.data)[3],
 				ref->rc_sequenceid, ref->rc_slotid);
-
-			spin_lock(&tbl->slot_tbl_lock);
-			status = (test_bit(ref->rc_slotid, tbl->used_slots) &&
-				  tbl->slots[ref->rc_slotid].seq_nr ==
-					ref->rc_sequenceid);
-			spin_unlock(&tbl->slot_tbl_lock);
+			status = test_refer_slot(tbl, ref);
 			if (status)
 				goto out;
 		}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ab12913..88bd927 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -354,6 +354,8 @@ extern int _nfs4_call_sync_session(struct rpc_clnt *clnt,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
 				   int cache_reply);
+struct nfs4_slot *nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl,
+					  u8 slotid);
 
 /*
  * Determine the device name as a string
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3e93e9a..cbc94f3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -266,6 +266,7 @@ extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
 extern int nfs4_init_session(struct nfs_server *server);
+extern void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..ee04f8f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -349,6 +349,186 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 #if defined(CONFIG_NFS_V4_1)
 
 /*
+ * Session dynamic slot table helper functions
+ */
+
+static inline u32 slot_tbl_hash(const u8 slotid)
+{
+	return (u32)slotid % SLOT_TABLE_SIZE;
+}
+
+static void nfs4_init_slot(struct nfs4_slot *new, u8 slotid, int ivalue)
+{
+	INIT_HLIST_NODE(&new->slot_node);
+	new->slotid = slotid;
+	new->seq_nr = ivalue;
+	atomic_set(&new->ref, 1);
+}
+
+static void nfs4_insert_slot_locked(struct nfs4_slot_table *tbl,
+					   struct nfs4_slot *new)
+{
+	u32 hash = slot_tbl_hash(new->slotid);
+
+	hlist_add_head(&new->slot_node, &tbl->slots[hash]);
+	tbl->allocated_slots++;
+}
+
+/*
+ * Allocate a slot for the next slotid (tbl->allocated_slotid)
+ */
+static int nfs4_alloc_add_slot(struct nfs4_slot_table *tbl,
+			       int ivalue, int slotid,
+			       gfp_t gfp_flags)
+{
+	struct nfs4_slot *new;
+	struct rpc_task *task;
+
+	dprintk("--> %s slotid=%u tbl->allocated_slots=%d\n", __func__,
+		slotid, tbl->allocated_slots);
+	new = kzalloc(sizeof(struct nfs4_slot), gfp_flags);
+	if (!new)
+		return -ENOMEM;
+	/* tbl->allocated_slots holds the next unallocated slotid */
+	nfs4_init_slot(new, slotid, ivalue);
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->allocated_slots != slotid) {
+		spin_unlock(&tbl->slot_tbl_lock);
+		kfree(new);
+		dprintk("%s slotid %u already allocated\n", __func__,
+			slotid);
+		return 0;
+	}
+	nfs4_insert_slot_locked(tbl, new);
+
+	/* Only for dynamic allocation which puts tasks waiting for the
+	 * an allocated slot on the slot_tbl_waitq */
+	task = rpc_wake_up_next(&tbl->slot_tbl_waitq);
+	if (task)
+		dprintk("%s woke up task %5u\n", __func__, task->tk_pid);
+	spin_unlock(&tbl->slot_tbl_lock);
+	return 0;
+}
+
+/*
+ * Allocate the minimal number of slots required by the transport.
+ * Called at session creation.
+ */
+static int nfs4_prealloc_slots(struct nfs4_slot_table *tbl, int num, int ivalue)
+{
+	int i;
+
+	for (i = 0; i < num; i++) {
+		if (nfs4_alloc_add_slot(tbl, ivalue, tbl->allocated_slots,
+		    GFP_NOFS) != 0)
+			return -ENOMEM;
+	}
+	return 0;
+}
+
+/*
+ * Allocate the next slotid. If allocation fails, next request will retry.
+ */
+static void
+nfs4_dynamic_alloc_slot(struct nfs4_slot_table *tbl, u8 slotid)
+{
+
+	/* only allocate the next slotid */
+	if (slotid != tbl->allocated_slots) {
+		dprintk("%s slotid %u already allocated\n", __func__, slotid);
+		return;
+	}
+	nfs4_alloc_add_slot(tbl, 1, slotid, GFP_NOWAIT);
+}
+
+/*
+ * Return the slot associated with the slotid returned by nfs4_find_slot.
+ * If the slot is not found, it has not been allocated: the NULL return
+ * puts the request on the slot table waitq and dynamically allocates a
+ * new slot.
+ */
+struct nfs4_slot *
+nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl, u8 slotid)
+{
+	struct nfs4_slot *sp;
+	struct hlist_node *n;
+	u32 hash = slot_tbl_hash(slotid);
+
+	dprintk("--> %s slotid %u\n", __func__, slotid);
+	hlist_for_each_entry(sp, n, &tbl->slots[hash], slot_node) {
+		if (sp->slotid == slotid)
+			return sp;
+	}
+	return NULL;
+}
+
+static inline void nfs4_put_slot_locked(struct nfs4_slot *slot)
+{
+	if (atomic_dec_and_test(&slot->ref)) {
+		BUG_ON(!hlist_unhashed(&slot->slot_node));
+		kfree(slot);
+	}
+}
+
+static inline void nfs4_get_slot(struct nfs4_slot *slot)
+{
+	atomic_inc(&slot->ref);
+}
+
+static void nfs4_remove_slot_locked(struct nfs4_slot_table *tbl,
+			     struct nfs4_slot *slot)
+{
+	dprintk("--> %s slotid %d\n", __func__, slot->slotid);
+	hlist_del_init(&slot->slot_node);
+	tbl->allocated_slots--;
+	nfs4_put_slot_locked(slot);
+}
+
+static void nfs4_free_all_slots(struct nfs4_slot_table *tbl)
+{
+	struct nfs4_slot *slotp;
+	int i;
+
+	dprintk("--> %s\n", __func__);
+	spin_lock(&tbl->slot_tbl_lock);
+	for (i = 0; i < SLOT_TABLE_SIZE; i++) {
+		while (!hlist_empty(&tbl->slots[i])) {
+			slotp = hlist_entry(tbl->slots[i].first,
+					    struct nfs4_slot, slot_node);
+			nfs4_remove_slot_locked(tbl, slotp);
+		}
+		/* re-initialize hlist_head */
+		tbl->slots[i].first = NULL;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
+/*
+ * Remove num_dec number of contiguous slotids starting from highest
+ * allocated slotid
+ *
+ * Note: set the new tbl->max_slots prior to calling.
+ */
+void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl)
+{
+	struct nfs4_slot *removeme;
+	int i, rm_slotid = tbl->allocated_slots - 1;
+	int num_dec = tbl->allocated_slots - tbl->max_slots;
+
+	dprintk("--> %s num_dec=%d\n", __func__, num_dec);
+
+	/* nothing to do */
+	if (num_dec <= 0)
+		return;
+	for (i = 0; i < num_dec; i++) {
+		removeme = nfs4_lookup_slot_locked(tbl, rm_slotid);
+		BUG_ON(removeme == NULL);
+		nfs4_remove_slot_locked(tbl, removeme);
+		rm_slotid--;
+	}
+}
+
+/*
  * nfs4_free_slot - free a slot and efficiently update slot table.
  *
  * freeing a slot is trivially done by clearing its respective bit
@@ -364,9 +544,8 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
+nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 {
-	int free_slotid = free_slot - tbl->slots;
 	int slotid = free_slotid;
 
 	BUG_ON(slotid < 0 || slotid >= NFS4_MAX_SLOT_TABLE);
@@ -431,7 +610,8 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot);
+	nfs4_free_slot(tbl, res->sr_slot->slotid);
+	nfs4_put_slot_locked(res->sr_slot);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
@@ -472,10 +652,9 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
+		dprintk("%s: slot=%u seq=%d: Operation in progress\n",
 			__func__,
-			res->sr_slot - res->sr_session->fc_slot_table.slots,
-			res->sr_slot->seq_nr);
+			res->sr_slot->slotid, res->sr_slot->seq_nr);
 		goto out_retry;
 	default:
 		/* Just update the slot sequence no. */
@@ -560,7 +739,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		 */
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
-		dprintk("%s Schedule Session Reset\n", __func__);
+		dprintk("%s Schedule Session Draining\n", __func__);
 		return -EAGAIN;
 	}
 
@@ -569,6 +748,8 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("%s enforce FIFO order\n", __func__);
+		dprintk("%s FIFO highest used slotid=%u\n", __func__,
+			tbl->highest_used_slotid);
 		return -EAGAIN;
 	}
 
@@ -579,12 +760,27 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		dprintk("<-- %s: no free slots\n", __func__);
 		return -EAGAIN;
 	}
+	slot = nfs4_lookup_slot_locked(tbl, slotid);
+	if (slot == NULL) {
+		/* keep FIFO order */
+		dprintk("%s task pid %5u sleeping for dynamic slot\n",
+			__func__, task->tk_pid);
+		rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		nfs4_free_slot(tbl, slotid);
+		spin_unlock(&tbl->slot_tbl_lock);
+		nfs4_dynamic_alloc_slot(tbl, slotid);
+		dprintk("<-- %s: allocate slotid %u\n", __func__, slotid);
+		return -EAGAIN;
+	}
+	dprintk("%s task pid %5u got slotid %u\n", __func__, task->tk_pid,
+		slotid);
+	nfs4_get_slot(slot);
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
-	slot = tbl->slots + slotid;
 	args->sa_session = session;
-	args->sa_slotid = slotid;
+	args->sa_slot = slot;
 	args->sa_cache_this = cache_reply;
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
@@ -617,9 +813,9 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slot %td\n",
+	dprintk("--> %s clp %p session %p sr_slot %d\n",
 		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot - session->fc_slot_table.slots : -1);
+			res->sr_slot->slotid : -1);
 
 	ret = nfs41_setup_sequence(session, args, res, cache_reply,
 				   task);
@@ -4997,127 +5193,110 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 }
 
 /*
- * Reset a slot table
+ * Reset a slot table. Session has been drained and reset with new slot table
+ * parameters from create_session.
+ * Keep all allocated slots that fit into new slot table max_reqs parameter.
+ * Set tbl->max_slots to new value.
+ * Adjust tbl->allocated_slots if needed.
+ * Initiaize allocated slots seq_nr to ivalue.
+ * Reset highest_used_slotid to -1.
  */
-static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
+static void nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 new_max_reqs,
 				 int ivalue)
 {
-	struct nfs4_slot *new = NULL;
+	struct nfs4_slot *sp;
+	struct hlist_node *n;
 	int i;
-	int ret = 0;
 
-	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
-		max_reqs, tbl->max_slots);
-
-	/* Does the newly negotiated max_reqs match the existing slot table? */
-	if (max_reqs != tbl->max_slots) {
-		ret = -ENOMEM;
-		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
-			      GFP_NOFS);
-		if (!new)
-			goto out;
-		ret = 0;
-		kfree(tbl->slots);
-	}
 	spin_lock(&tbl->slot_tbl_lock);
-	if (new) {
-		tbl->slots = new;
-		tbl->max_slots = max_reqs;
-	}
-	for (i = 0; i < tbl->max_slots; ++i)
-		tbl->slots[i].seq_nr = ivalue;
-	spin_unlock(&tbl->slot_tbl_lock);
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
-out:
-	dprintk("<-- %s: return %d\n", __func__, ret);
-	return ret;
-}
 
-/*
- * Reset the forechannel and backchannel slot tables
- */
-static int nfs4_reset_slot_tables(struct nfs4_session *session)
-{
-	int status;
+	dprintk("--> %s new_max_reqs %d tbl->allocated_slots %d\n", __func__,
+		new_max_reqs, tbl->allocated_slots);
 
-	status = nfs4_reset_slot_table(&session->fc_slot_table,
-			session->fc_attrs.max_reqs, 1);
-	if (status)
-		return status;
+	tbl->max_slots = new_max_reqs;
+	nfs4_reduce_slots_locked(tbl);
+	tbl->highest_used_slotid = -1;
 
-	status = nfs4_reset_slot_table(&session->bc_slot_table,
-			session->bc_attrs.max_reqs, 0);
-	return status;
+	for (i = 0; i < SLOT_TABLE_SIZE; i++) {
+		hlist_for_each_entry(sp, n, &tbl->slots[i], slot_node)
+			sp->seq_nr = ivalue;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("<-- %s: tbl=%p max_slots=%d tbl->allocated_slots=%d\n",
+		__func__, tbl, tbl->max_slots, tbl->allocated_slots);
+	return;
 }
 
-/* Destroy the slot table */
+/* Destroy the sessions slot tables */
 static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 {
-	if (session->fc_slot_table.slots != NULL) {
-		kfree(session->fc_slot_table.slots);
-		session->fc_slot_table.slots = NULL;
-	}
-	if (session->bc_slot_table.slots != NULL) {
-		kfree(session->bc_slot_table.slots);
-		session->bc_slot_table.slots = NULL;
-	}
-	return;
+	dprintk("--> %s\n", __func__);
+
+	nfs4_free_all_slots(&session->fc_slot_table);
+	nfs4_free_all_slots(&session->bc_slot_table);
 }
 
-/*
- * Initialize slot table
- */
 static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
-		int max_slots, int ivalue)
+		int max_slots, int num_prealloc, int ivalue)
 {
-	struct nfs4_slot *slot;
-	int ret = -ENOMEM;
+	int ret;
 
 	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
 
 	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
 
-	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
-	if (!slot)
+	ret = nfs4_prealloc_slots(tbl, num_prealloc, ivalue);
+	if (ret) {
+		nfs4_free_all_slots(tbl);
 		goto out;
+	}
 	ret = 0;
 
 	spin_lock(&tbl->slot_tbl_lock);
 	tbl->max_slots = max_slots;
-	tbl->slots = slot;
 	tbl->highest_used_slotid = -1;  /* no slot is currently used */
 	spin_unlock(&tbl->slot_tbl_lock);
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
+	dprintk("%s: tbl=%p max_slots=%d, tbl->allocated_slots=%d\n", __func__,
+		tbl, tbl->max_slots, tbl->allocated_slots);
 out:
 	dprintk("<-- %s: return %d\n", __func__, ret);
 	return ret;
 }
 
 /*
- * Initialize the forechannel and backchannel tables
+ * Initialize or reset the forechannel and backchannel tables
+ * Note: kzalloc of nfs4_sessions initiallizes tbl->slots[] hlist heads
  */
-static int nfs4_init_slot_tables(struct nfs4_session *session)
+static int nfs4_setup_slot_tables(struct nfs4_session *session)
 {
 	struct nfs4_slot_table *tbl;
 	int status = 0;
 
+	dprintk("--> %s\n", __func__);
 	tbl = &session->fc_slot_table;
-	if (tbl->slots == NULL) {
+	if (tbl->allocated_slots == 0) {
 		status = nfs4_init_slot_table(tbl,
-				session->fc_attrs.max_reqs, 1);
+				session->fc_attrs.max_reqs,
+				session->clp->cl_rpcclient->cl_xprt->min_reqs,
+				1);
 		if (status)
 			return status;
-	}
+	} else
+		nfs4_reset_slot_table(&session->fc_slot_table,
+				      session->fc_attrs.max_reqs, 1);
 
 	tbl = &session->bc_slot_table;
-	if (tbl->slots == NULL) {
+	if (tbl->allocated_slots == 0) {
 		status = nfs4_init_slot_table(tbl,
-				session->bc_attrs.max_reqs, 0);
+				session->bc_attrs.max_reqs,
+				/* Backchannel max_reqs == 1 */
+				session->bc_attrs.max_reqs,
+				0);
 		if (status)
 			nfs4_destroy_slot_tables(session);
-	}
+	} else
+		nfs4_reset_slot_table(&session->bc_slot_table,
+				      session->bc_attrs.max_reqs, 0);
 
 	return status;
 }
@@ -5306,13 +5485,9 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	if (status)
 		goto out;
 
-	/* Init and reset the fore channel */
-	status = nfs4_init_slot_tables(session);
-	dprintk("slot table initialization returned %d\n", status);
-	if (status)
-		goto out;
-	status = nfs4_reset_slot_tables(session);
-	dprintk("slot table reset returned %d\n", status);
+	/* Setup the fore and back channel slot tables */
+	status = nfs4_setup_slot_tables(session);
+	dprintk("slot table setup returned %d\n", status);
 	if (status)
 		goto out;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..8260865 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1573,26 +1573,16 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 {
 	struct nfs4_slot_table *fc_tbl = &clp->cl_session->fc_slot_table;
 	struct nfs4_channel_attrs *fc_attrs = &clp->cl_session->fc_attrs;
-	struct nfs4_slot *new, *old;
-	int i;
 
 	nfs4_begin_drain_session(clp);
-	new = kmalloc(fc_tbl->target_max_slots * sizeof(struct nfs4_slot),
-		      GFP_NOFS);
-        if (!new)
-		return -ENOMEM;
 
 	spin_lock(&fc_tbl->slot_tbl_lock);
-	for (i = 0; i < fc_tbl->target_max_slots; i++)
-		new[i].seq_nr = fc_tbl->slots[i].seq_nr;
-	old = fc_tbl->slots;
-	fc_tbl->slots = new;
 	fc_tbl->max_slots = fc_tbl->target_max_slots;
+	nfs4_reduce_slots_locked(fc_tbl);
 	fc_tbl->target_max_slots = 0;
 	fc_attrs->max_reqs = fc_tbl->max_slots;
 	spin_unlock(&fc_tbl->slot_tbl_lock);
 
-	kfree(old);
 	nfs4_end_drain_session(clp);
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1dce12f..5a22a9b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1872,7 +1872,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 #if defined(CONFIG_NFS_V4_1)
 	struct nfs4_session *session = args->sa_session;
 	struct nfs4_slot_table *tp;
-	struct nfs4_slot *slot;
 	__be32 *p;
 
 	if (!session)
@@ -1880,9 +1879,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 
 	tp = &session->fc_slot_table;
 
-	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
-	slot = tp->slots + args->sa_slotid;
-
 	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN + 16);
 	*p++ = cpu_to_be32(OP_SEQUENCE);
 
@@ -1896,11 +1892,11 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[1],
 		((u32 *)session->sess_id.data)[2],
 		((u32 *)session->sess_id.data)[3],
-		slot->seq_nr, args->sa_slotid,
+		args->sa_slot->seq_nr, args->sa_slot->slotid,
 		tp->highest_used_slotid, args->sa_cache_this);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
-	*p++ = cpu_to_be32(slot->seq_nr);
-	*p++ = cpu_to_be32(args->sa_slotid);
+	*p++ = cpu_to_be32(args->sa_slot->seq_nr);
+	*p++ = cpu_to_be32(args->sa_slot->slotid);
 	*p++ = cpu_to_be32(tp->highest_used_slotid);
 	*p = cpu_to_be32(args->sa_cache_this);
 	hdr->nops++;
@@ -5361,13 +5357,16 @@ static int decode_sequence(struct xdr_stream *xdr,
 	/* seqid */
 	dummy = be32_to_cpup(p++);
 	if (dummy != res->sr_slot->seq_nr) {
-		dprintk("%s Invalid sequence number\n", __func__);
+		dprintk("%s Invalid sequence number %d for "
+			"[slotid:seq_nr] [%d:%d]\n", __func__,
+			dummy, res->sr_slot->slotid, res->sr_slot->seq_nr);
 		goto out_err;
 	}
 	/* slot id */
 	dummy = be32_to_cpup(p++);
-	if (dummy != res->sr_slot - res->sr_session->fc_slot_table.slots) {
-		dprintk("%s Invalid slot id\n", __func__);
+	if (dummy != res->sr_slot->slotid) {
+		dprintk("%s Invalid slot id %d for [slotid:seq_nr] [%d:%d]\n",
+		__func__, dummy, res->sr_slot->slotid, res->sr_slot->seq_nr);
 		goto out_err;
 	}
 	/* highest slot id - currently not processed */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b5479df..1b393ae 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -193,12 +193,15 @@ struct nfs_server {
 
 /* Sessions */
 #define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
+#define SLOT_TABLE_BITS		4
+#define SLOT_TABLE_SIZE		(1 << SLOT_TABLE_BITS)
 struct nfs4_slot_table {
-	struct nfs4_slot *slots;		/* seqid per slot */
+	struct hlist_head slots[SLOT_TABLE_SIZE];  /* seqid per slot */
 	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
 	spinlock_t	slot_tbl_lock;
 	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
-	int		max_slots;		/* # slots in table */
+	int		allocated_slots;	/* # slots in table */
+	int		max_slots;		/* max # slots in table */
 	int		highest_used_slotid;	/* sent to server on each SEQ.
 						 * op for dynamic resizing */
 	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
@@ -206,11 +209,6 @@ struct nfs4_slot_table {
 	struct completion complete;
 };
 
-static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
-{
-	return sp - tbl->slots;
-}
-
 /*
  * Session related parameters
  */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index abd615d..c7fe490 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -168,12 +168,15 @@ struct nfs4_channel_attrs {
 
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
+	struct hlist_node	slot_node;
+	atomic_t		ref;
 	u32		 	seq_nr;
+	u8			slotid;
 };
 
 struct nfs4_sequence_args {
 	struct nfs4_session	*sa_session;
-	u8			sa_slotid;
+	struct nfs4_slot	*sa_slot;
 	u8			sa_cache_this;
 };
 
-- 
1.7.5.1

