Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33067 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756028AbcH1WZE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:04 -0400
Received: by mail-it0-f67.google.com with SMTP id d65so5046815ith.0
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.1: Fix Oopsable condition in server callback races
Date: Sun, 28 Aug 2016 18:21:01 -0400
Message-Id: <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The slot table hasn't been an array since v3.7. Ensure that we
use nfs4_lookup_slot() to access the slot correctly.

Fixes: 87dda67e7386 ("NFSv4.1: Allow SEQUENCE to resize the slot table...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v3.8+
---
 fs/nfs/callback_proc.c |  5 +----
 fs/nfs/nfs4session.c   | 33 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs4session.h   |  1 +
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c92a75e066a6..a4cf6d2c14a4 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -454,11 +454,8 @@ static bool referring_call_exists(struct nfs_client *clp,
 				((u32 *)&rclist->rcl_sessionid.data)[3],
 				ref->rc_sequenceid, ref->rc_slotid);
 
-			spin_lock(&tbl->slot_tbl_lock);
-			status = (test_bit(ref->rc_slotid, tbl->used_slots) &&
-				  tbl->slots[ref->rc_slotid].seq_nr ==
+			status = nfs4_slot_seqid_in_use(tbl, ref->rc_slotid,
 					ref->rc_sequenceid);
-			spin_unlock(&tbl->slot_tbl_lock);
 			if (status)
 				goto out;
 		}
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 332d06e64fa9..c1f4c208f38a 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -172,6 +172,39 @@ struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid)
 	return ERR_PTR(-E2BIG);
 }
 
+static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
+		u32 *seq_nr)
+	__must_hold(&tbl->slot_tbl_lock)
+{
+	struct nfs4_slot *slot;
+
+	slot = nfs4_lookup_slot(tbl, slotid);
+	if (IS_ERR(slot))
+		return PTR_ERR(slot);
+	*seq_nr = slot->seq_nr;
+	return 0;
+}
+
+/*
+ * nfs4_slot_seqid_in_use - test if a slot sequence id is still in use
+ *
+ * Given a slot table, slot id and sequence number, determine if the
+ * RPC call in question is still in flight. This function is mainly
+ * intended for use by the callback channel.
+ */
+bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl, u32 slotid, u32 seq_nr)
+{
+	u32 cur_seq;
+	bool ret = false;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (nfs4_slot_get_seqid(tbl, slotid, &cur_seq) == 0 &&
+	    cur_seq == seq_nr && test_bit(slotid, tbl->used_slots))
+		ret = true;
+	spin_unlock(&tbl->slot_tbl_lock);
+	return ret;
+}
+
 /*
  * nfs4_alloc_slot - efficiently look for a free slot
  *
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 5b51298d1d03..33cace62b50b 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -78,6 +78,7 @@ extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid);
+extern bool nfs4_slot_seqid_in_use(struct nfs4_slot_table  *tbl, u32 slotid, u32 seq_nr);
 extern bool nfs4_try_to_lock_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
-- 
2.7.4

