Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21799 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab2BQSFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 13:05:47 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFSv4.1: Fix a NFSv4.1 session initialisation regression
Date: Fri, 17 Feb 2012 13:05:22 -0500
Message-Id: <1329501923-3999-2-git-send-email-andros@netapp.com>
In-Reply-To: <1329501923-3999-1-git-send-email-andros@netapp.com>
References: <1329501923-3999-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Commit aacd553 (NFSv4.1: cleanup init and reset of session slot tables)
introduces a regression in the session initialisation code. New tables
now find their sequence ids initialised to 0, rather than the mandated
value of 1 (see RFC5661).

Fix the problem by merging nfs4_reset_slot_table() and nfs4_init_slot_table().
Since the tbl->max_slots is initialised to 0, the test in
nfs4_reset_slot_table for max_reqs != tbl->max_slots will automatically
pass for an empty table.

Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |  111 +++++++++++++++++++++--------------------------------
 1 files changed, 44 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87c584d..8bf4181 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5071,37 +5071,53 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
+static struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
+{
+	return kcalloc(max_slots, sizeof(struct nfs4_slot), gfp_flags);
+}
+
+static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *new,
+		u32 max_slots,
+		u32 ivalue)
+{
+	struct nfs4_slot *old = NULL;
+	u32 i;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (new) {
+		old = tbl->slots;
+		tbl->slots = new;
+		tbl->max_slots = max_slots;
+	}
+	tbl->highest_used_slotid = NFS4_NO_SLOT; /* no slot is currently used */
+	for (i = 0; i < tbl->max_slots; i++)
+		tbl->slots[i].seq_nr = ivalue;
+	spin_unlock(&tbl->slot_tbl_lock);
+	kfree(old);
+}
+
 /*
- * Reset a slot table
+ * (re)Initialise a slot table
  */
-static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
-				 int ivalue)
+static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
+				u32 ivalue)
 {
 	struct nfs4_slot *new = NULL;
-	int i;
-	int ret = 0;
+	int ret = -ENOMEM;
 
 	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
 		max_reqs, tbl->max_slots);
 
 	/* Does the newly negotiated max_reqs match the existing slot table? */
 	if (max_reqs != tbl->max_slots) {
-		ret = -ENOMEM;
-		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
-			      GFP_NOFS);
+		new = nfs4_alloc_slots(max_reqs, GFP_NOFS);
 		if (!new)
 			goto out;
-		ret = 0;
-		kfree(tbl->slots);
-	}
-	spin_lock(&tbl->slot_tbl_lock);
-	if (new) {
-		tbl->slots = new;
-		tbl->max_slots = max_reqs;
 	}
-	for (i = 0; i < tbl->max_slots; ++i)
-		tbl->slots[i].seq_nr = ivalue;
-	spin_unlock(&tbl->slot_tbl_lock);
+	ret = 0;
+
+	nfs4_add_and_init_slots(tbl, new, max_reqs, ivalue);
 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
 		tbl, tbl->slots, tbl->max_slots);
 out:
@@ -5124,36 +5140,6 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 }
 
 /*
- * Initialize slot table
- */
-static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
-		int max_slots, int ivalue)
-{
-	struct nfs4_slot *slot;
-	int ret = -ENOMEM;
-
-	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
-
-	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
-
-	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
-	if (!slot)
-		goto out;
-	ret = 0;
-
-	spin_lock(&tbl->slot_tbl_lock);
-	tbl->max_slots = max_slots;
-	tbl->slots = slot;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;  /* no slot is currently used */
-	spin_unlock(&tbl->slot_tbl_lock);
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
-out:
-	dprintk("<-- %s: return %d\n", __func__, ret);
-	return ret;
-}
-
-/*
  * Initialize or reset the forechannel and backchannel tables
  */
 static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
@@ -5164,25 +5150,16 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	dprintk("--> %s\n", __func__);
 	/* Fore channel */
 	tbl = &ses->fc_slot_table;
-	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
-		if (status) /* -ENOMEM */
-			return status;
-	} else {
-		status = nfs4_reset_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
-		if (status)
-			return status;
-	}
+	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
+	if (status) /* -ENOMEM */
+		return status;
 	/* Back channel */
 	tbl = &ses->bc_slot_table;
-	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
-		if (status)
-			/* Fore and back channel share a connection so get
-			 * both slot tables or neither */
-			nfs4_destroy_slot_tables(ses);
-	} else
-		status = nfs4_reset_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
+	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
+	if (status && tbl->slots == NULL)
+		/* Fore and back channel share a connection so get
+		* both slot tables or neither */
+		nfs4_destroy_slot_tables(ses);
 	return status;
 }
 
@@ -5196,13 +5173,13 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 		return NULL;
 
 	tbl = &session->fc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	tbl->highest_used_slotid = NFS4_NO_SLOT; /* signal slot table drained */
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
 	init_completion(&tbl->complete);
 
 	tbl = &session->bc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	tbl->highest_used_slotid = NFS4_NO_SLOT; /* signal slot table drained */
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
 	init_completion(&tbl->complete);
-- 
1.7.6.4

