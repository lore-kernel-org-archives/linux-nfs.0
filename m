Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59533 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab2KVSmt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:49 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/20] NFSv4.1: Clean up nfs4_free_slot
Date: Wed, 21 Nov 2012 17:43:10 -0500
Message-Id: <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the argument to take the pointer to the slot, instead of
just the slotid.

We know that the new value of highest_used_slot must be less than
the current value. No need to scan the whole table.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59cef54..14389f2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -412,16 +412,18 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, u32 slotid)
+nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 {
+	u32 slotid = slot->slot_nr;
+
 	/* clear used bit in bitmap */
 	__clear_bit(slotid, tbl->used_slots);
 
 	/* update highest_used_slotid when it is freed */
 	if (slotid == tbl->highest_used_slotid) {
-		slotid = find_last_bit(tbl->used_slots, tbl->max_slots);
-		if (slotid < tbl->max_slots)
-			tbl->highest_used_slotid = slotid;
+		u32 new_max = find_last_bit(tbl->used_slots, slotid);
+		if (new_max < slotid)
+			tbl->highest_used_slotid = new_max;
 		else
 			tbl->highest_used_slotid = NFS4_NO_SLOT;
 	}
@@ -481,7 +483,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot - tbl->slots);
+	nfs4_free_slot(tbl, res->sr_slot);
 	nfs4_check_drain_fc_complete(session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
-- 
1.7.11.7

