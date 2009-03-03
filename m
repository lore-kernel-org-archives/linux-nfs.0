From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 11/46] nfs41: free slot
Date: Wed,  4 Mar 2009 01:53:39 +0200
Message-ID: <1236124419-3271-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17449
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755344AbZCCXxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:53:51 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Free a slot in the slot table.

Mark the slot as free in the bitmap-based allocation table
by clearing a bit corresponding to the slotid.

Update lowest_free_slotid if freed slotid is lower than that.
Update highest_used_slotid.  In the case the freed slotid
equals the highest_used_slotid, scan downwards for the next
highest used slotid using the optimized fls* functions.

Finally, wake up thread waiting on slot_tbl_waitq for a free slot
to become available.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: free slot use slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use find_first_zero_bit for nfs4_find_slot]
    While at it, obliterate lowest_free_slotid and fix-up related comments.
    As per review comment 21/85.
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use __clear_bit for nfs4_free_slot]
    While at it, fix-up function comment.
    Part of review comment 22/85.
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use find_last_bit in nfs4_free_slot to determine highest used slot.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
    Otherwise there's a race (we've hit) with nfs4_free_slot where
    nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
    nfs4_free_slots happen concurrently and call rpc_wake_up_next
    where there's nobody to wake up yet, context goes back to
    nfs41_setup_sequence which goes to sleep when the slot table
    is actually empty now and there's no-one to wake it up anymore.
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bc6bb7..fed6cfb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -282,6 +282,42 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 #if defined(CONFIG_NFS_V4_1)
 
 /*
+ * nfs4_free_slot - free a slot and efficiently update slot table.
+ *
+ * freeing a slot is trivially done by clearing its respective bit
+ * in the bitmap.
+ * If the freed slotid equals highest_used_slotid we want to update it
+ * so that the server would be able to size down the slot table if needed,
+ * otherwise we know that the highest_used_slotid is still in use.
+ * When updating highest_used_slotid there may be "holes" in the bitmap
+ * so we need to scan down from highest_used_slotid to 0 looking for the now
+ * highest slotid in use.
+ * If none found, highest_used_slotid is set to -1.
+ */
+static void
+nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
+{
+	int slotid = free_slotid;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	/* clear used bit in bitmap */
+	__clear_bit(slotid, tbl->used_slots);
+
+	/* update highest_used_slotid when it is freed */
+	if (slotid == tbl->highest_used_slotid) {
+		slotid = find_last_bit(tbl->used_slots, tbl->max_slots);
+		if (slotid >= 0 && slotid < tbl->max_slots)
+			tbl->highest_used_slotid = slotid;
+		else
+			tbl->highest_used_slotid = -1;
+	}
+	rpc_wake_up_next(&tbl->slot_tbl_waitq);
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("%s: free_slotid %u highest_used_slotid %d\n", __func__,
+		free_slotid, tbl->highest_used_slotid);
+}
+
+/*
  * nfs4_find_slot - efficiently look for a free slot
  *
  * nfs4_find_slot looks for an unset bit in the used_slots bitmap.
-- 
1.6.1.3

