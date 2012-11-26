Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64150 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755933Ab2KZURD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:03 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/28] NFSv4.1: Simplify slot allocation
Date: Mon, 26 Nov 2012 15:16:28 -0500
Message-Id: <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up the NFSv4.1 slot allocation by replacing nfs_find_slot() with
a function nfs_alloc_slot() that returns a pointer to the nfs4_slot
instead of an offset into the slot table.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7c2b037..59cef54 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -557,20 +557,18 @@ static int nfs4_sequence_done(struct rpc_task *task,
 }
 
 /*
- * nfs4_find_slot - efficiently look for a free slot
+ * nfs4_alloc_slot - efficiently look for a free slot
  *
- * nfs4_find_slot looks for an unset bit in the used_slots bitmap.
+ * nfs4_alloc_slot looks for an unset bit in the used_slots bitmap.
  * If found, we mark the slot as used, update the highest_used_slotid,
  * and respectively set up the sequence operation args.
- * The slot number is returned if found, or NFS4_NO_SLOT otherwise.
  *
  * Note: must be called with under the slot_tbl_lock.
  */
-static u32
-nfs4_find_slot(struct nfs4_slot_table *tbl)
+static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 {
+	struct nfs4_slot *ret = NULL;
 	u32 slotid;
-	u32 ret_id = NFS4_NO_SLOT;
 
 	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
@@ -582,11 +580,14 @@ nfs4_find_slot(struct nfs4_slot_table *tbl)
 	if (slotid > tbl->highest_used_slotid ||
 			tbl->highest_used_slotid == NFS4_NO_SLOT)
 		tbl->highest_used_slotid = slotid;
-	ret_id = slotid;
+	ret = &tbl->slots[slotid];
+	ret->renewal_time = jiffies;
+
 out:
 	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
-		__func__, tbl->used_slots[0], tbl->highest_used_slotid, ret_id);
-	return ret_id;
+		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
+		ret ? ret->slot_nr : -1);
+	return ret;
 }
 
 static void nfs41_init_sequence(struct nfs4_sequence_args *args,
@@ -606,7 +607,6 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 {
 	struct nfs4_slot *slot;
 	struct nfs4_slot_table *tbl;
-	u32 slotid;
 
 	dprintk("--> %s\n", __func__);
 	/* slot already allocated? */
@@ -633,8 +633,8 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 		return -EAGAIN;
 	}
 
-	slotid = nfs4_find_slot(tbl);
-	if (slotid == NFS4_NO_SLOT) {
+	slot = nfs4_alloc_slot(tbl);
+	if (slot == NULL) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("<-- %s: no free slots\n", __func__);
@@ -643,12 +643,11 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
-	slot = tbl->slots + slotid;
-	slot->renewal_time = jiffies;
 
 	args->sa_slot = slot;
 
-	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
+	dprintk("<-- %s slotid=%d seqid=%d\n", __func__,
+			slot->slot_nr, slot->seq_nr);
 
 	res->sr_slot = slot;
 	res->sr_status_flags = 0;
-- 
1.7.11.7

