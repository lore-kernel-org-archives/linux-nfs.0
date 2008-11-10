From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 21/85] nfs41: find slot
Date: Mon, 10 Nov 2008 22:21:31 +0200
Message-ID: <1226348491-7885-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60769 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbYKJUVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:21:39 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
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
---
 fs/nfs/nfs4proc.c            |   88 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4_session.h |    5 ++
 2 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 08e7129..4ded3a5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -207,6 +207,94 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 	spin_unlock(&clp->cl_lock);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+/*
+ * idx2bmp - return pointer to bitmap word holding index "idx".
+ *
+ * inputs:
+ * @base	points to bitmap.
+ * @idx		slot index.
+ *
+ * output:
+ * @bit		optional, *bit set to bit index of "idx" in the returned
+ *		bitmap word.
+ */
+static inline unsigned long *idx2bmp(unsigned long *base, int idx, int *bit)
+{
+	base += idx / BITS_PER_LONG;
+	if (bit)
+		*bit = idx & (BITS_PER_LONG - 1);
+	return base;
+}
+
+/*
+ * bmp2idx - return absolute index of bmp:bit in bitmap.
+ *
+ * inputs:
+ * @base	points to bitmap.
+ * @bmp		points to bitmap word.
+ * @bit		bit index in bitmap word.
+ */
+static inline int bmp2idx(unsigned long *base, unsigned long *bmp,
+			  int bit)
+{
+	return ((bmp - base) * BITS_PER_LONG) + bit;
+}
+
+/*
+ * nfs4_find_slot - efficiently look for a free slot
+ *
+ * nfs4_find_slot uses the ffz cpu-optimized function to look for an unset
+ * bit in each word in the bitmap.
+ * Scan starts at lowest_free_slotid, which is a hint for the free slot,
+ * as all lower-numbered slots are known to be used.
+ * If found, we mark the slot as used, update the highest_used_slotid,
+ * and respectively set up the sequence operation args.
+ * The lowest_free_slotid is always set to the successive slotid.
+ * A pointer to the slot's seqid is returned if found, or NULL otherwise.
+ */
+static struct nfs4_slot *
+nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
+{
+	int bit, slotid;
+	struct nfs4_slot *slot = NULL;
+	unsigned long *used, u;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	slotid = tbl->lowest_free_slotid;
+	while (slotid < tbl->max_slots) {
+		used = idx2bmp(tbl->used_slots, slotid, NULL);
+		u = *used;
+		if (u == ~0UL) {
+			/* all slots marked used in this word */
+			slotid += BITS_PER_LONG;
+			continue;
+		}
+		/* find first slot marked free in word */
+		bit = ffz(u);
+		slotid = bmp2idx(tbl->used_slots, used, bit);
+		/* mark slot used.  note that we don't do that if
+		 * slotid >= tbl->max_slots so not to confuse
+		 * highest_used_slotid algorithm */
+		if (slotid < tbl->max_slots) {
+			*used |= (1 << bit);
+			if (slotid > tbl->highest_used_slotid)
+				tbl->highest_used_slotid = slotid;
+			slot = tbl->slots + slotid;
+			slotid++;	/* for updating lowest_free_slot */
+		}
+		break;
+	}
+	tbl->lowest_free_slotid = slotid;
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("<-- %s slot %p slotid %d\n", __func__,
+		slot, slot ? slot_idx(tbl, slot) : -1);
+	return slot;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
diff --git a/include/linux/nfs4_session.h b/include/linux/nfs4_session.h
index d534269..2960ba9 100644
--- a/include/linux/nfs4_session.h
+++ b/include/linux/nfs4_session.h
@@ -33,6 +33,11 @@ struct nfs4_slot_table {
 						 * op for dynamic resizing */
 };
 
+static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
+{
+	return sp - tbl->slots;
+}
+
 struct nfs4_channel {
 	struct nfs4_channel_attrs 	chan_attrs;
 	struct rpc_clnt 		*rpc_client;
-- 
1.6.0.2

