From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 10/46] nfs41: find slot
Date: Wed,  4 Mar 2009 01:53:29 +0200
Message-ID: <1236124409-3246-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17447
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754156AbZCCXxl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:53:41 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Find a free slot using bitmap-based allocation.
Use the optimized ffz function to find a zero bit
in the bitmap that indicates a free slot, starting
the search from the 'lowest_free_slotid' position.

If found, mark the slot as used in the bitmap, get
the slot's slotid and seqid, and update max_slotid
to be used by the SEQUENCE operation.

Also, update lowest_free_slotid for next search.

If no free slot was found the caller has to wait
for a free slot (outside the scope of this function)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: find slot return slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[use find_first_zero_bit for nfs4_find_slot as per review comment 21/85.]
[use NFS4_MAX_SLOT_TABLE rather than NFS4_NO_SLOT]
[nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c12cf91..9bc6bb7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -279,6 +279,43 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 	spin_unlock(&clp->cl_lock);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+/*
+ * nfs4_find_slot - efficiently look for a free slot
+ *
+ * nfs4_find_slot looks for an unset bit in the used_slots bitmap.
+ * If found, we mark the slot as used, update the highest_used_slotid,
+ * and respectively set up the sequence operation args.
+ * The slot number is returned if found, or NFS4_MAX_SLOT_TABLE otherwise.
+ */
+static u8
+nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
+{
+	int slotid;
+	u8 ret_id = NFS4_MAX_SLOT_TABLE;
+	BUILD_BUG_ON((u8)NFS4_MAX_SLOT_TABLE != (int)NFS4_MAX_SLOT_TABLE);
+
+	spin_lock(&tbl->slot_tbl_lock);
+	dprintk("--> %s used_slots=%04lx highest_used=%d max_slots=%d\n",
+		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
+		tbl->max_slots);
+	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slots);
+	if (slotid >= tbl->max_slots)
+		goto out;
+	__set_bit(slotid, tbl->used_slots);
+	if (slotid > tbl->highest_used_slotid)
+		tbl->highest_used_slotid = slotid;
+	ret_id = slotid;
+out:
+	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
+		__func__, tbl->used_slots[0], tbl->highest_used_slotid, ret_id);
+	spin_unlock(&tbl->slot_tbl_lock);
+	return ret_id;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.6.1.3

