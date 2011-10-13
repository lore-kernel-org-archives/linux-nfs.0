Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17125 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182Ab1JMVOi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Oct 2011 17:14:38 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFSv4.1: rename nfs4_free_slot and nfs4_find_slot
Date: Thu, 13 Oct 2011 17:14:30 -0400
Message-Id: <1318540470-15181-3-git-send-email-andros@netapp.com>
In-Reply-To: <1318540470-15181-1-git-send-email-andros@netapp.com>
References: <1318540470-15181-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

These functions deal in slotid's, not slots.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7438632..ad9e1e0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -427,7 +427,7 @@ nfs4_dynamic_alloc_slot(struct nfs4_slot_table *tbl, u8 slotid)
 }
 
 /*
- * Return the slot associated with the slotid returned by nfs4_find_slot
+ * Return the slot associated with the slotid returned by nfs4_find_slotid
  * which returns only slotids between 0 and tbl->max_slots.
  * If the slot is not found, it has not been allocated: the NULL return
  * puts the request on the slot table waitq and dynamically allocates a
@@ -517,9 +517,9 @@ void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl)
 }
 
 /*
- * nfs4_free_slot - free a slot and efficiently update slot table.
+ * nfs4_free_slotid - free a slotid and efficiently update slot table.
  *
- * freeing a slot is trivially done by clearing its respective bit
+ * freeing a slotid is trivially done by clearing its respective bit
  * in the bitmap.
  * If the freed slotid equals highest_used_slotid we want to update it
  * so that the server would be able to size down the slot table if needed,
@@ -532,7 +532,7 @@ void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl)
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
+nfs4_free_slotid(struct nfs4_slot_table *tbl, u8 free_slotid)
 {
 	int slotid = free_slotid;
 
@@ -598,7 +598,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot->slotid);
+	nfs4_free_slotid(tbl, res->sr_slot->slotid);
 	nfs4_put_slot_locked(res->sr_slot);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
@@ -669,17 +669,17 @@ static int nfs4_sequence_done(struct rpc_task *task,
 }
 
 /*
- * nfs4_find_slot - efficiently look for a free slot
+ * nfs4_find_slotid - efficiently look for a free slotid
  *
- * nfs4_find_slot looks for an unset bit in the used_slots bitmap.
- * If found, we mark the slot as used, update the highest_used_slotid,
+ * nfs4_find_slotid looks for an unset bit in the used_slots bitmap.
+ * If found, we mark the slotid as used, update the highest_used_slotid,
  * and respectively set up the sequence operation args.
- * The slot number is returned if found, or NFS4_MAX_SLOT_TABLE otherwise.
+ * The slotid is returned if found, or NFS4_MAX_SLOT_TABLE otherwise.
  *
  * Note: must be called with under the slot_tbl_lock.
  */
 static u8
-nfs4_find_slot(struct nfs4_slot_table *tbl)
+nfs4_find_slotid(struct nfs4_slot_table *tbl)
 {
 	int slotid;
 	u8 ret_id = NFS4_MAX_SLOT_TABLE;
@@ -739,7 +739,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		return -EAGAIN;
 	}
 
-	slotid = nfs4_find_slot(tbl);
+	slotid = nfs4_find_slotid(tbl);
 	if (slotid == NFS4_MAX_SLOT_TABLE) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
@@ -749,7 +749,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	slot = nfs4_lookup_slot_locked(tbl, slotid);
 	if (slot == NULL) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-		nfs4_free_slot(tbl, slotid);
+		nfs4_free_slotid(tbl, slotid);
 		spin_unlock(&tbl->slot_tbl_lock);
 		nfs4_dynamic_alloc_slot(tbl, slotid);
 		dprintk("<-- %s: allocate slotid %u\n", __func__, slotid);
-- 
1.7.4.4

