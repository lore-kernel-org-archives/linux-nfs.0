Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60626 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755340Ab2KVSmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:35 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/20] NFSv4.1: Allow SEQUENCE to resize the slot table on the fly
Date: Wed, 21 Nov 2012 17:43:17 -0500
Message-Id: <1353537799-60488-19-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-18-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-18-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of an array of slots, use a singly linked list of slots that
can be dynamically appended to or shrunk.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |   4 +-
 fs/nfs/nfs4proc.c       | 174 +++++++++++++++++++++++++++++++-----------------
 fs/nfs/nfs4state.c      |  22 ++----
 include/linux/nfs_xdr.h |   1 +
 4 files changed, 121 insertions(+), 80 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5d4e82b..856bc49 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -258,10 +258,10 @@ extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				  bool sync);
 
-extern struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
-		u32 max_slots, gfp_t gfp_flags);
 extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid);
+extern int nfs4_resize_slot_table(struct nfs4_slot_table *tbl,
+		u32 max_reqs, u32 ivalue);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5641380..adedcfa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -397,6 +397,27 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 #if defined(CONFIG_NFS_V4_1)
 
 /*
+ * nfs4_shrink_slot_table - free retired slots from the slot table
+ */
+static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
+{
+	struct nfs4_slot **p;
+	if (newsize >= tbl->max_slots)
+		return;
+
+	p = &tbl->slots;
+	while (newsize--)
+		p = &(*p)->next;
+	while (*p) {
+		struct nfs4_slot *slot = *p;
+
+		*p = slot->next;
+		kfree(slot);
+		tbl->max_slots--;
+	}
+}
+
+/*
  * nfs4_free_slot - free a slot and efficiently update slot table.
  *
  * freeing a slot is trivially done by clearing its respective bit
@@ -500,7 +521,7 @@ static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
 	tbl->target_highest_slotid = target_highest_slotid;
 	tbl->generation++;
 
-	max_slotid = min(tbl->max_slots - 1, tbl->target_highest_slotid);
+	max_slotid = min(NFS4_MAX_SLOT_TABLE - 1, tbl->target_highest_slotid);
 	for (i = tbl->max_slotid + 1; i <= max_slotid; i++)
 		rpc_wake_up_next(&tbl->slot_tbl_waitq);
 	tbl->max_slotid = max_slotid;
@@ -517,16 +538,12 @@ void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
 static void nfs41_set_server_slotid_locked(struct nfs4_slot_table *tbl,
 		u32 highest_slotid)
 {
-	unsigned int max_slotid, i;
-
 	if (tbl->server_highest_slotid == highest_slotid)
 		return;
 	if (tbl->highest_used_slotid > highest_slotid)
 		return;
-	max_slotid = min(tbl->max_slots - 1, highest_slotid);
-	/* Reset the seq_nr for deallocated slots */
-	for (i = tbl->server_highest_slotid + 1; i <= max_slotid; i++)
-		tbl->slots[i].seq_nr = 1;
+	/* Deallocate slots */
+	nfs4_shrink_slot_table(tbl, highest_slotid + 1);
 	tbl->server_highest_slotid = highest_slotid;
 }
 
@@ -613,6 +630,42 @@ static int nfs4_sequence_done(struct rpc_task *task,
 	return nfs41_sequence_done(task, res);
 }
 
+static struct nfs4_slot *nfs4_new_slot(struct nfs4_slot_table  *tbl,
+		u32 slotid, u32 seq_init, gfp_t gfp_mask)
+{
+	struct nfs4_slot *slot;
+
+	slot = kzalloc(sizeof(*slot), gfp_mask);
+	if (slot) {
+		slot->table = tbl;
+		slot->slot_nr = slotid;
+		slot->seq_nr = seq_init;
+	}
+	return slot;
+}
+
+static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
+		u32 slotid, u32 seq_init, gfp_t gfp_mask)
+{
+	struct nfs4_slot **p, *slot;
+
+	p = &tbl->slots;
+	for (;;) {
+		if (*p == NULL) {
+			*p = nfs4_new_slot(tbl, tbl->max_slots,
+					seq_init, gfp_mask);
+			if (*p == NULL)
+				break;
+			tbl->max_slots++;
+		}
+		slot = *p;
+		if (slot->slot_nr == slotid)
+			return slot;
+		p = &slot->next;
+	}
+	return NULL;
+}
+
 /*
  * nfs4_alloc_slot - efficiently look for a free slot
  *
@@ -629,15 +682,17 @@ static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 
 	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
-		tbl->max_slots);
+		tbl->max_slotid + 1);
 	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slotid + 1);
 	if (slotid > tbl->max_slotid)
 		goto out;
+	ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
+	if (ret == NULL)
+		goto out;
 	__set_bit(slotid, tbl->used_slots);
 	if (slotid > tbl->highest_used_slotid ||
 			tbl->highest_used_slotid == NFS4_NO_SLOT)
 		tbl->highest_used_slotid = slotid;
-	ret = &tbl->slots[slotid];
 	ret->renewal_time = jiffies;
 	ret->generation = tbl->generation;
 
@@ -5719,67 +5774,56 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
-struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
-		u32 max_slots, gfp_t gfp_flags)
+static int nfs4_grow_slot_table(struct nfs4_slot_table *tbl,
+		 u32 max_reqs, u32 ivalue)
 {
-	struct nfs4_slot *tbl;
-	u32 i;
-
-	tbl = kmalloc_array(max_slots, sizeof(*tbl), gfp_flags);
-	if (tbl != NULL) {
-		for (i = 0; i < max_slots; i++) {
-			tbl[i].table = table;
-			tbl[i].slot_nr = i;
-		}
-	}
-	return tbl;
+	if (max_reqs <= tbl->max_slots)
+		return 0;
+	if (nfs4_find_or_create_slot(tbl, max_reqs - 1, ivalue, GFP_NOFS))
+		return 0;
+	return -ENOMEM;
 }
 
-static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
-		struct nfs4_slot *new,
-		u32 max_slots,
+static void nfs4_reset_slot_table(struct nfs4_slot_table *tbl,
+		u32 server_highest_slotid,
 		u32 ivalue)
 {
-	struct nfs4_slot *old = NULL;
-	u32 i;
+	struct nfs4_slot **p;
 
-	spin_lock(&tbl->slot_tbl_lock);
-	if (new) {
-		old = tbl->slots;
-		tbl->slots = new;
-		tbl->max_slots = max_slots;
+	nfs4_shrink_slot_table(tbl, server_highest_slotid + 1);
+	p = &tbl->slots;
+	while (*p) {
+		(*p)->seq_nr = ivalue;
+		p = &(*p)->next;
 	}
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	tbl->target_highest_slotid = max_slots - 1;
-	tbl->server_highest_slotid = max_slots - 1;
-	tbl->max_slotid = max_slots - 1;
-	for (i = 0; i < tbl->max_slots; i++)
-		tbl->slots[i].seq_nr = ivalue;
-	spin_unlock(&tbl->slot_tbl_lock);
-	kfree(old);
+	tbl->target_highest_slotid = server_highest_slotid;
+	tbl->server_highest_slotid = server_highest_slotid;
+	tbl->max_slotid = server_highest_slotid;
 }
 
 /*
  * (re)Initialise a slot table
  */
-static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
-				 u32 ivalue)
+static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,
+		u32 max_reqs, u32 ivalue)
 {
-	struct nfs4_slot *new = NULL;
-	int ret = -ENOMEM;
+	int ret;
 
 	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
 		max_reqs, tbl->max_slots);
 
-	/* Does the newly negotiated max_reqs match the existing slot table? */
-	if (max_reqs != tbl->max_slots) {
-		new = nfs4_alloc_slots(tbl, max_reqs, GFP_NOFS);
-		if (!new)
-			goto out;
-	}
-	ret = 0;
+	if (max_reqs > NFS4_MAX_SLOT_TABLE)
+		max_reqs = NFS4_MAX_SLOT_TABLE;
+
+	ret = nfs4_grow_slot_table(tbl, max_reqs, ivalue);
+	if (ret)
+		goto out;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	nfs4_reset_slot_table(tbl, max_reqs - 1, ivalue);
+	spin_unlock(&tbl->slot_tbl_lock);
 
-	nfs4_add_and_init_slots(tbl, new, max_reqs, ivalue);
 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
 		tbl, tbl->slots, tbl->max_slots);
 out:
@@ -5787,18 +5831,28 @@ out:
 	return ret;
 }
 
+int nfs4_resize_slot_table(struct nfs4_slot_table *tbl,
+		 u32 max_reqs, u32 ivalue)
+{
+	int ret;
+
+	if (max_reqs > NFS4_MAX_SLOT_TABLE)
+		max_reqs = NFS4_MAX_SLOT_TABLE;
+	ret = nfs4_grow_slot_table(tbl, max_reqs, ivalue);
+	if (ret)
+		return ret;
+	spin_lock(&tbl->slot_tbl_lock);
+	nfs4_shrink_slot_table(tbl, max_reqs);
+	tbl->max_slotid = max_reqs - 1;
+	spin_unlock(&tbl->slot_tbl_lock);
+	return 0;
+}
+
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
+	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
+	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
 }
 
 /*
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1b7fa73..c14b2c7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2025,29 +2025,15 @@ out:
 static int nfs4_recall_slot(struct nfs_client *clp)
 {
 	struct nfs4_slot_table *fc_tbl;
-	struct nfs4_slot *new, *old;
-	int i;
+	u32 new_size;
 
 	if (!nfs4_has_session(clp))
 		return 0;
 	nfs4_begin_drain_session(clp);
-	fc_tbl = &clp->cl_session->fc_slot_table;
-	new = nfs4_alloc_slots(fc_tbl, fc_tbl->target_highest_slotid + 1, GFP_NOFS);
-        if (!new)
-		return -ENOMEM;
 
-	spin_lock(&fc_tbl->slot_tbl_lock);
-	for (i = 0; i <= fc_tbl->target_highest_slotid; i++)
-		new[i].seq_nr = fc_tbl->slots[i].seq_nr;
-	old = fc_tbl->slots;
-	fc_tbl->slots = new;
-	fc_tbl->max_slots = fc_tbl->target_highest_slotid + 1;
-	fc_tbl->max_slotid = fc_tbl->target_highest_slotid;
-	clp->cl_session->fc_attrs.max_reqs = fc_tbl->max_slots;
-	spin_unlock(&fc_tbl->slot_tbl_lock);
-
-	kfree(old);
-	return 0;
+	fc_tbl = &clp->cl_session->fc_slot_table;
+	new_size = fc_tbl->server_highest_slotid + 1;
+	return nfs4_resize_slot_table(fc_tbl, new_size, 1);
 }
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ddb08f..44d256f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -188,6 +188,7 @@ struct nfs4_channel_attrs {
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
 	struct nfs4_slot_table	*table;
+	struct nfs4_slot	*next;
 	unsigned long		generation;
 	unsigned long		renewal_time;
 	u32			slot_nr;
-- 
1.7.11.7

