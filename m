From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 29/67] nfs41: find slot
Date: Thu,  2 Apr 2009 16:54:23 +0300
Message-ID: <1238680463-14308-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31332 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755323AbZDBNyc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:54:32 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
 fs/nfs/nfs4proc.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4d48bf8..582d61e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -273,6 +273,39 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 
 #if defined(CONFIG_NFS_V4_1)
 
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
 static int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
-- 
1.6.2.1

