Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35642 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbcAYOJ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:56 -0500
Received: by mail-io0-f181.google.com with SMTP id 77so152055023ioc.2
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4.x: Allow multiple callbacks in flight
Date: Mon, 25 Jan 2016 09:09:16 -0500
Message-Id: <1453730956-5325-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hook the callback channel into the same session management machinery
as we use for the forward channel.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.h      |  3 ++-
 fs/nfs/callback_proc.c | 14 +++++++++----
 fs/nfs/callback_xdr.c  | 12 ++++++-----
 fs/nfs/nfs4session.c   | 54 +++++++++++++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4session.h   |  8 ++++++++
 5 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index ff8195bd75ea..5fe1cecbf9f0 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -37,10 +37,11 @@ enum nfs4_callback_opnum {
 	OP_CB_ILLEGAL = 10044,
 };
 
+struct nfs4_slot;
 struct cb_process_state {
 	__be32			drc_status;
 	struct nfs_client	*clp;
-	u32			slotid;
+	struct nfs4_slot	*slot;
 	u32			minorversion;
 	struct net		*net;
 };
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 79c93b3bbfec..efd079d28946 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -367,7 +367,7 @@ validate_seqid(const struct nfs4_slot_table *tbl, const struct nfs4_slot *slot,
 	if (args->csa_sequenceid == slot->seq_nr) {
 		dprintk("%s seqid %u is a replay\n",
 			__func__, args->csa_sequenceid);
-		if (tbl->highest_used_slotid != NFS4_NO_SLOT)
+		if (nfs4_test_locked_slot(tbl, slot->slot_nr))
 			return htonl(NFS4ERR_DELAY);
 		/* Signal process_op to set this error on next op */
 		if (args->csa_cachethis == 0)
@@ -476,12 +476,18 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out_unlock;
 	}
 
+	status = htonl(NFS4ERR_BADSLOT);
+	slot = nfs4_lookup_slot(tbl, args->csa_slotid);
+	if (IS_ERR(slot))
+		goto out_unlock;
 	status = validate_seqid(tbl, slot, args);
 	if (status)
 		goto out_unlock;
-
-	cps->slotid = args->csa_slotid;
-	tbl->highest_used_slotid = args->csa_slotid;
+	if (!nfs4_try_to_lock_slot(tbl, slot)) {
+		status = htonl(NFS4ERR_DELAY);
+		goto out_unlock;
+	}
+	cps->slot = slot;
 
 	memcpy(&res->csr_sessionid, &args->csa_sessionid,
 	       sizeof(res->csr_sessionid));
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 646cdac73488..976c90608e56 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -752,7 +752,8 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS_OK);
 }
 
-static void nfs4_callback_free_slot(struct nfs4_session *session)
+static void nfs4_callback_free_slot(struct nfs4_session *session,
+		struct nfs4_slot *slot)
 {
 	struct nfs4_slot_table *tbl = &session->bc_slot_table;
 
@@ -761,15 +762,17 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
 	 * Let the state manager know callback processing done.
 	 * A single slot, so highest used slotid is either 0 or -1
 	 */
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	nfs4_free_slot(tbl, slot);
 	nfs4_slot_tbl_drain_complete(tbl);
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
 static void nfs4_cb_free_slot(struct cb_process_state *cps)
 {
-	if (cps->slotid != NFS4_NO_SLOT)
-		nfs4_callback_free_slot(cps->clp->cl_session);
+	if (cps->slot) {
+		nfs4_callback_free_slot(cps->clp->cl_session, cps->slot);
+		cps->slot = NULL;
+	}
 }
 
 #else /* CONFIG_NFS_V4_1 */
@@ -893,7 +896,6 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	struct cb_process_state cps = {
 		.drc_status = 0,
 		.clp = NULL,
-		.slotid = NFS4_NO_SLOT,
 		.net = SVC_NET(rqstp),
 	};
 	unsigned int nops = 0;
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index e23366effcfb..332d06e64fa9 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -135,6 +135,43 @@ static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
 	return ERR_PTR(-ENOMEM);
 }
 
+static void nfs4_lock_slot(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot)
+{
+	u32 slotid = slot->slot_nr;
+
+	__set_bit(slotid, tbl->used_slots);
+	if (slotid > tbl->highest_used_slotid ||
+	    tbl->highest_used_slotid == NFS4_NO_SLOT)
+		tbl->highest_used_slotid = slotid;
+	slot->generation = tbl->generation;
+}
+
+/*
+ * nfs4_try_to_lock_slot - Given a slot try to allocate it
+ *
+ * Note: must be called with the slot_tbl_lock held.
+ */
+bool nfs4_try_to_lock_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
+{
+	if (nfs4_test_locked_slot(tbl, slot->slot_nr))
+		return false;
+	nfs4_lock_slot(tbl, slot);
+	return true;
+}
+
+/*
+ * nfs4_lookup_slot - Find a slot but don't allocate it
+ *
+ * Note: must be called with the slot_tbl_lock held.
+ */
+struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid)
+{
+	if (slotid <= tbl->max_slotid)
+		return nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
+	return ERR_PTR(-E2BIG);
+}
+
 /*
  * nfs4_alloc_slot - efficiently look for a free slot
  *
@@ -153,18 +190,11 @@ struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
 		tbl->max_slotid + 1);
 	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slotid + 1);
-	if (slotid > tbl->max_slotid)
-		goto out;
-	ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
-	if (IS_ERR(ret))
-		goto out;
-	__set_bit(slotid, tbl->used_slots);
-	if (slotid > tbl->highest_used_slotid ||
-			tbl->highest_used_slotid == NFS4_NO_SLOT)
-		tbl->highest_used_slotid = slotid;
-	ret->generation = tbl->generation;
-
-out:
+	if (slotid <= tbl->max_slotid) {
+		ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
+		if (!IS_ERR(ret))
+			nfs4_lock_slot(tbl, ret);
+	}
 	dprintk("<-- %s used_slots=%04lx highest_used=%u slotid=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
 		!IS_ERR(ret) ? ret->slot_nr : NFS4_NO_SLOT);
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index e3ea2c5324d6..9d4d1af237a3 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -77,6 +77,8 @@ extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 		unsigned int max_reqs, const char *queue);
 extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
+extern struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid);
+extern bool nfs4_try_to_lock_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
 bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
@@ -125,6 +127,12 @@ static inline void nfs4_copy_sessionid(struct nfs4_sessionid *dst,
 	memcpy(dst->data, src->data, NFS4_MAX_SESSIONID_LEN);
 }
 
+static inline bool nfs4_test_locked_slot(const struct nfs4_slot_table *tbl,
+		u32 slotid)
+{
+	return test_bit(slotid, tbl->used_slots) != 0;
+}
+
 #ifdef CONFIG_CRC32
 /*
  * nfs_session_id_hash - calculate the crc32 hash for the session id
-- 
2.5.0

