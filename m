Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13796 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952Ab1KIS7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:59:02 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 6/7] NFSv4.1: rename nfs4_free_slot and nfs4_find_slot
Date: Wed,  9 Nov 2011 13:58:25 -0500
Message-Id: <1320865106-1791-6-git-send-email-andros@netapp.com>
In-Reply-To: <1320865106-1791-1-git-send-email-andros@netapp.com>
References: <1320865106-1791-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

These functions deal in slotid's, not slots.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 525635f..9ec3a13 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -519,9 +519,9 @@ void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl)
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
@@ -534,7 +534,7 @@ void nfs4_reduce_slots_locked(struct nfs4_slot_table *tbl)
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
+nfs4_free_slotid(struct nfs4_slot_table *tbl, u8 free_slotid)
 {
 	int slotid = free_slotid;
 
@@ -603,7 +603,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot->slotid);
+	nfs4_free_slotid(tbl, res->sr_slot->slotid);
 	nfs4_put_slot_locked(res->sr_slot);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
@@ -674,17 +674,17 @@ static int nfs4_sequence_done(struct rpc_task *task,
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
@@ -744,7 +744,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		return -EAGAIN;
 	}
 
-	slotid = nfs4_find_slot(tbl);
+	slotid = nfs4_find_slotid(tbl);
 	if (slotid == NFS4_MAX_SLOT_TABLE) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
@@ -756,7 +756,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		/* keep FIFO order */
 		rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-		nfs4_free_slot(tbl, slotid);
+		nfs4_free_slotid(tbl, slotid);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("%s task pid %5u sleeping for dynamic slot %d\n",
 			__func__, task->tk_pid, slotid);
-- 
1.7.6.4

