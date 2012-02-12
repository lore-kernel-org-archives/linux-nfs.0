Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab2BLRyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Feb 2012 12:54:12 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 2/3] NFSv4.1 prepare for dynamic session slots
Date: Sun, 12 Feb 2012 12:52:55 -0500
Message-Id: <1329069176-8349-3-git-send-email-andros@netapp.com>
In-Reply-To: <1329069176-8349-1-git-send-email-andros@netapp.com>
References: <1329069176-8349-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The session fore/backchannel slot tables implementation is changed from a
static array to an hlist hashed on slotid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |   27 ++++-
 fs/nfs/nfs4_fs.h          |    3 +
 fs/nfs/nfs4proc.c         |  230 ++++++++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4state.c        |   18 +---
 fs/nfs/nfs4xdr.c          |   20 ++--
 include/linux/nfs_fs_sb.h |    9 +-
 include/linux/nfs_xdr.h   |    4 +-
 7 files changed, 220 insertions(+), 91 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 54cea8a..5f9a02d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -342,7 +342,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	if (args->csa_slotid >= NFS41_BC_MAX_CALLBACKS)
 		return htonl(NFS4ERR_BADSLOT);
 
-	slot = tbl->slots + args->csa_slotid;
+	slot = nfs4_lookup_slot_locked(tbl, args->csa_slotid);
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
 
 	/* Normal */
@@ -377,6 +377,25 @@ out_ok:
 	return htonl(NFS4_OK);
 }
 
+static bool
+test_slot_referring(struct nfs4_slot_table *tbl, struct referring_call *ref)
+{
+	struct nfs4_slot *slot;
+	bool status = false;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (ref->rc_slotid >= tbl->max_slots)
+		goto out;
+	if (test_bit(ref->rc_slotid, tbl->used_slots)) {
+		slot = nfs4_lookup_slot_locked(tbl, ref->rc_slotid);
+		if (slot->seq_nr == ref->rc_sequenceid)
+			status = true;
+	}
+out:
+	spin_unlock(&tbl->slot_tbl_lock);
+	return status;
+}
+
 /*
  * For each referring call triple, check the session's slot table for
  * a match.  If the slot is in use and the sequence numbers match, the
@@ -418,11 +437,7 @@ static bool referring_call_exists(struct nfs_client *clp,
 				((u32 *)&rclist->rcl_sessionid.data)[3],
 				ref->rc_sequenceid, ref->rc_slotid);
 
-			spin_lock(&tbl->slot_tbl_lock);
-			status = (test_bit(ref->rc_slotid, tbl->used_slots) &&
-				  tbl->slots[ref->rc_slotid].seq_nr ==
-					ref->rc_sequenceid);
-			spin_unlock(&tbl->slot_tbl_lock);
+			status = test_slot_referring(tbl, ref);
 			if (status)
 				goto out;
 		}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4d7d0ae..8bc93cf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -244,6 +244,9 @@ extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
 extern int nfs4_init_session(struct nfs_server *server);
+extern void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl, int num);
+extern struct nfs4_slot *nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl,
+						u8 slotid);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18b095a..11f4e96 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -350,6 +350,127 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 #if defined(CONFIG_NFS_V4_1)
 
 /*
+ * Slot table hlist functions
+ */
+
+static inline u32 slot_tbl_hash(u8 slotid)
+{
+	return (u32)slotid % SLOT_HASH_TBL_SZ;
+}
+
+/*
+ * Allocate the slot the requested slotid.
+ * Called outside of the slot_tbl_lock. If the slot is already allocated,
+ * return success.
+ */
+static int
+nfs4_alloc_insert_slot(struct nfs4_slot_table *tbl, int ivalue, int slotid,
+		    gfp_t gfp_flags)
+{
+	struct nfs4_slot *new;
+	u32 hash = slot_tbl_hash(slotid);
+
+	dprintk("--> %s slotid=%u\n", __func__, slotid);
+
+	new = kzalloc(sizeof(struct nfs4_slot), gfp_flags);
+	if (!new)
+		return -ENOMEM;
+	INIT_HLIST_NODE(&new->node);
+	new->slot_id = slotid;
+	new->seq_nr = ivalue;
+	spin_lock(&tbl->slot_tbl_lock);
+	hlist_add_head(&new->node, &tbl->slots[hash]);
+	tbl->max_slots++;
+	spin_unlock(&tbl->slot_tbl_lock);
+	return 0;
+}
+
+/*
+ * Allocate the negotiated number of slots and place them in the hlist.
+ * Called at session initialization, or session reset (with session
+ * drained).
+ *
+ * @start - the slotid where allocation starts.
+ * @num   - the number of slots to allocate.
+ *
+ */
+static int nfs4_alloc_slots(struct nfs4_slot_table *tbl, int ivalue,
+			    int start, int num, gfp_t gfp_flags)
+{
+int i, ret = 0;
+
+	for (i = start; i < start + num; i++) {
+		ret = nfs4_alloc_insert_slot(tbl, ivalue, i, gfp_flags);
+		if (ret)
+			break;
+	}
+	return ret;
+}
+
+static void
+nfs4_remove_slot_locked(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
+{
+	dprintk("--> %s slotid %d\n", __func__, slot->slot_id);
+	hlist_del_init(&slot->node);
+	tbl->max_slots--;
+	kfree(slot);
+}
+
+/*
+ * Return the slot associated with the slotid.
+ * Caller ensures slotid is < tbl->max_slots.
+ */
+struct nfs4_slot *
+nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl, u8 slotid)
+{
+	struct nfs4_slot *sp = NULL;
+	struct hlist_node *n;
+	u32 hash = slot_tbl_hash(slotid);
+
+	hlist_for_each_entry(sp, n, &tbl->slots[hash], node) {
+		if (sp->slot_id == slotid)
+			return sp;
+	}
+	printk(KERN_ERR "NFSv41 session slot table corruption\n");
+	BUG();
+	return NULL;
+}
+
+/*
+ * Remove num contiguous slotids starting from max_slots
+ * Caller ensures num < tbl->max_slots
+ */
+void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl, int num)
+{
+	struct nfs4_slot *removeme;
+	int rmid;
+	u32 lastid = tbl->max_slots - num;
+
+	for (rmid = tbl->max_slots - 1 ; rmid >= lastid; rmid--) {
+		removeme = nfs4_lookup_slot_locked(tbl, rmid);
+		nfs4_remove_slot_locked(tbl, removeme);
+	}
+}
+
+static void nfs4_free_all_slots(struct nfs4_slot_table *tbl)
+{
+	struct nfs4_slot *sp;
+	int i;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	for (i = 0; i < SLOT_HASH_TBL_SZ; i++) {
+		while (!hlist_empty(&tbl->slots[i])) {
+			sp = hlist_entry(tbl->slots[i].first,
+						struct nfs4_slot, node);
+			nfs4_remove_slot_locked(tbl, sp);
+		}
+		/* re-initialize hlist_head */
+		tbl->slots[i].first = NULL;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
+/*
  * nfs4_free_slot - free a slot and efficiently update slot table.
  *
  * freeing a slot is trivially done by clearing its respective bit
@@ -431,7 +552,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot - tbl->slots);
+	nfs4_free_slot(tbl, res->sr_slot->slot_id);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
@@ -472,10 +593,8 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
-			__func__,
-			res->sr_slot - res->sr_session->fc_slot_table.slots,
-			res->sr_slot->seq_nr);
+		dprintk("%s: slotid=%u seq=%d: Operation in progress\n",
+			__func__, res->sr_slot->slot_id, res->sr_slot->seq_nr);
 		goto out_retry;
 	default:
 		/* Just update the slot sequence no. */
@@ -576,12 +695,12 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		dprintk("<-- %s: no free slots\n", __func__);
 		return -EAGAIN;
 	}
+	slot = nfs4_lookup_slot_locked(tbl, slotid);
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
-	slot = tbl->slots + slotid;
 	args->sa_session = session;
-	args->sa_slotid = slotid;
+	args->sa_slot = slot;
 	args->sa_cache_this = cache_reply;
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
@@ -614,9 +733,9 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slot %td\n",
+	dprintk("--> %s clp %p session %p sr_slot %d\n",
 		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot - session->fc_slot_table.slots : -1);
+			res->sr_slot->slot_id : -1);
 
 	ret = nfs41_setup_sequence(session, args, res, cache_reply,
 				   task);
@@ -5009,55 +5128,52 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 }
 
 /*
- * Reset a slot table
+ * Reset a slot table while the session is drained.
  */
-static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
-				 int ivalue)
-{
-	struct nfs4_slot *new = NULL;
-	int i;
-	int ret = 0;
-
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
+static int
+nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 new_max_reqs, int ivalue)
+{
+	struct nfs4_slot *sp;
+	struct hlist_node *np;
+	int i, ret;
+
+	dprintk("--> %s: new max_slots=%u, tbl->max_slots %d\n", __func__,
+		new_max_reqs, tbl->max_slots);
+
+	if (new_max_reqs > tbl->max_slots) {
+		/* the new tbl->max_slots is set by nfs4_alloc_insert_slots */
+		ret = nfs4_alloc_slots(tbl, ivalue, tbl->max_slots,
+					new_max_reqs, GFP_NOWAIT);
+		if (ret) {
+			/* OK to operate with less than the reset negotiated
+			 * number of slots. */
+			printk(KERN_WARNING "NFS: Unable to allocate %d "
+					"session slots\n",
+					new_max_reqs - tbl->max_slots);
+		}
 	}
 	spin_lock(&tbl->slot_tbl_lock);
-	if (new) {
-		tbl->slots = new;
-		tbl->max_slots = max_reqs;
+	if (new_max_reqs < tbl->max_slots)
+		/* the new tbl->max_slots is set by nfs4_reduce_slots_locked */
+		nfs4_reduce_slots_locked(tbl, tbl->max_slots - new_max_reqs);
+	for (i = 0; i < SLOT_HASH_TBL_SZ; i++) {
+		hlist_for_each_entry(sp, np, &tbl->slots[i], node)
+			sp->seq_nr = ivalue;
 	}
-	for (i = 0; i < tbl->max_slots; ++i)
-		tbl->slots[i].seq_nr = ivalue;
+	tbl->highest_used_slotid = -1;
 	spin_unlock(&tbl->slot_tbl_lock);
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
-out:
-	dprintk("<-- %s: return %d\n", __func__, ret);
-	return ret;
+
+	dprintk("<-- %s\n", __func__);
+	return 0;
 }
 
 /* Destroy the slot table */
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
 
 /*
@@ -5066,25 +5182,27 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 static int nfs4_set_slot_table(struct nfs4_slot_table *tbl,
 		int max_slots, int ivalue)
 {
-	struct nfs4_slot *slot;
-	int ret = -ENOMEM;
+	int ret;
 
 	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
 
 	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
 
-	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
-	if (!slot)
+	/* tbl->max_slots set by nfs4_alloc_insert_slot */
+	ret = nfs4_alloc_slots(tbl, ivalue, 0, max_slots, GFP_NOFS);
+	if (ret) {
+		nfs4_free_all_slots(tbl);
+		printk(KERN_WARNING "NFS: Unable to allocate %d "
+			"session slots\n", max_slots);
 		goto out;
+	}
 	ret = 0;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	tbl->max_slots = max_slots;
-	tbl->slots = slot;
 	tbl->highest_used_slotid = -1;  /* no slot is currently used */
 	spin_unlock(&tbl->slot_tbl_lock);
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
+
+	dprintk("%s: tbl=%p  max_slots=%d\n", __func__, tbl, tbl->max_slots);
 out:
 	dprintk("<-- %s: return %d\n", __func__, ret);
 	return ret;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4539203..408e142 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1646,26 +1646,18 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 {
 	struct nfs4_slot_table *fc_tbl = &clp->cl_session->fc_slot_table;
 	struct nfs4_channel_attrs *fc_attrs = &clp->cl_session->fc_attrs;
-	struct nfs4_slot *new, *old;
-	int i;
+	int num;
 
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
-	fc_tbl->max_slots = fc_tbl->target_max_slots;
-	fc_tbl->target_max_slots = 0;
+	/* num will be positive - checked in nfs4_callback_recallslot */
+	num = fc_tbl->max_slots - fc_tbl->target_max_slots;
+	/* fc_tbl->max_slots set by nfs4_remove_slot_locked */
+	nfs4_reduce_slots_locked(fc_tbl, num);
 	fc_attrs->max_reqs = fc_tbl->max_slots;
 	spin_unlock(&fc_tbl->slot_tbl_lock);
 
-	kfree(old);
 	nfs4_end_drain_session(clp);
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 33bd8d0..43eb416 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1872,7 +1872,6 @@ static void encode_sequence(struct xdr_stream *xdr,
 #if defined(CONFIG_NFS_V4_1)
 	struct nfs4_session *session = args->sa_session;
 	struct nfs4_slot_table *tp;
-	struct nfs4_slot *slot;
 	__be32 *p;
 
 	if (!session)
@@ -1880,8 +1879,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 
 	tp = &session->fc_slot_table;
 
-	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
-	slot = tp->slots + args->sa_slotid;
+	WARN_ON(args->sa_slot->slot_id == NFS4_MAX_SLOT_TABLE);
 
 	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN + 16);
 	*p++ = cpu_to_be32(OP_SEQUENCE);
@@ -1896,11 +1894,11 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[1],
 		((u32 *)session->sess_id.data)[2],
 		((u32 *)session->sess_id.data)[3],
-		slot->seq_nr, args->sa_slotid,
+		args->sa_slot->seq_nr, args->sa_slot->slot_id,
 		tp->highest_used_slotid, args->sa_cache_this);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
-	*p++ = cpu_to_be32(slot->seq_nr);
-	*p++ = cpu_to_be32(args->sa_slotid);
+	*p++ = cpu_to_be32(args->sa_slot->seq_nr);
+	*p++ = cpu_to_be32(args->sa_slot->slot_id);
 	*p++ = cpu_to_be32(tp->highest_used_slotid);
 	*p = cpu_to_be32(args->sa_cache_this);
 	hdr->nops++;
@@ -5385,13 +5383,17 @@ static int decode_sequence(struct xdr_stream *xdr,
 	/* seqid */
 	dummy = be32_to_cpup(p++);
 	if (dummy != res->sr_slot->seq_nr) {
-		dprintk("%s Invalid sequence number\n", __func__);
+		dprintk("%s Invalid seq num %u for [slotid:seq_nr] [%u:%u]\n",
+			__func__, dummy, res->sr_slot->slot_id,
+			res->sr_slot->seq_nr);
 		goto out_err;
 	}
 	/* slot id */
 	dummy = be32_to_cpup(p++);
-	if (dummy != res->sr_slot - res->sr_session->fc_slot_table.slots) {
-		dprintk("%s Invalid slot id\n", __func__);
+	if (dummy != res->sr_slot->slot_id) {
+		dprintk("%s Invalid slot id %u for [slotid:seq_nr] [%u:%u]\n",
+			__func__, dummy, res->sr_slot->slot_id,
+			res->sr_slot->seq_nr);
 		goto out_err;
 	}
 	/* highest slot id - currently not processed */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ba4d765..a091dc1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -194,8 +194,10 @@ struct nfs_server {
 
 /* Sessions */
 #define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
+#define SLOT_HASH_TBL_BITS                5
+#define SLOT_HASH_TBL_SZ                (1 << SLOT_HASH_TBL_BITS)
 struct nfs4_slot_table {
-	struct nfs4_slot *slots;		/* seqid per slot */
+	struct hlist_head slots[SLOT_HASH_TBL_SZ];
 	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
 	spinlock_t	slot_tbl_lock;
 	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
@@ -207,11 +209,6 @@ struct nfs4_slot_table {
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
index d6ba9a1..5126b65 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -177,12 +177,14 @@ struct nfs4_channel_attrs {
 
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
+	struct hlist_node	node;
 	u32		 	seq_nr;
+	u8			slot_id;
 };
 
 struct nfs4_sequence_args {
 	struct nfs4_session	*sa_session;
-	u8			sa_slotid;
+	struct nfs4_slot	*sa_slot;
 	u8			sa_cache_this;
 };
 
-- 
1.7.6.4

