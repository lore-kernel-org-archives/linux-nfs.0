From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 22/85] nfs41: free slot
Date: Mon, 10 Nov 2008 22:21:42 +0200
Message-ID: <1226348502-7918-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48749 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYKJUVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:21:49 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
---
 fs/nfs/nfs4proc.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4ded3a5..d26f61d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -243,6 +243,60 @@ static inline int bmp2idx(unsigned long *base, unsigned long *bmp,
 }
 
 /*
+ * nfs4_find_slot - free a slot and efficiently update slot table.
+ *
+ * freeing a slot is trivially done by clearing its respective bit
+ * in the bitmap.
+ * The lowest_free_slotid is updated if the freed slotid is lower than that.
+ * If the freed slotid equals highest_used_slotid we want to update it
+ * so that the server would be able to size down the slot table if needed,
+ * otherwise we know that the highest_used_slotid is still in use.
+ * When updating highest_used_slotid there may be "holes" in the bitmap
+ * so we need to scan down from highest_used_slotid to 0 looking for the now
+ * highest slotid in use.
+ * We use the fls cpu-optimized function to look for the last set bit in each
+ * word in the bitmap.
+ * If none found, highest_used_slotid is set to -1.
+ */
+static void
+nfs41_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
+{
+	int slotid = slot_idx(tbl, slot);
+	unsigned long *used, u;
+	int bit;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	/* clear used bit in bitmap */
+	used = idx2bmp(tbl->used_slots, slotid, &bit);
+	*used &= ~(1 << bit);
+
+	if (slotid < tbl->lowest_free_slotid)
+		tbl->lowest_free_slotid = slotid;
+
+	/* update highest_used_slotid when it is freed */
+	if (slotid == tbl->highest_used_slotid) {
+		tbl->highest_used_slotid = -1;
+		slotid--;
+		/* scan down for the highest used slotid */
+		while (slotid >= 0) {
+			used = idx2bmp(tbl->used_slots, slotid, NULL);
+			u = *used;
+			if (!u) {
+				/* all slots marked free in this word */
+				slotid -= BITS_PER_LONG;
+				continue;
+			}
+			bit = __fls(u);
+			tbl->highest_used_slotid = bmp2idx(tbl->used_slots,
+							   used, bit);
+			break;
+		}
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+	rpc_wake_up_next(&tbl->slot_tbl_waitq);
+}
+
+/*
  * nfs4_find_slot - efficiently look for a free slot
  *
  * nfs4_find_slot uses the ffz cpu-optimized function to look for an unset
-- 
1.6.0.2

