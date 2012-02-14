Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49337 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581Ab2BNVsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 16:48:55 -0500
Received: by bkcjm19 with SMTP id jm19so424695bkc.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Feb 2012 13:48:54 -0800 (PST)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: trond.myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Wed, 15 Feb 2012 01:48:28 +0400
Message-Id: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uninitialized seq_nr causes sending first SESSION request
with sa_sequenceid = 0.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f0c849c..711a812 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5067,6 +5067,7 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
 		int max_slots, int ivalue)
 {
 	struct nfs4_slot *slot;
+	int i;
 	int ret = -ENOMEM;
 
 	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
@@ -5082,6 +5083,8 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
 	tbl->max_slots = max_slots;
 	tbl->slots = slot;
 	tbl->highest_used_slotid = -1;  /* no slot is currently used */
+	for (i = 0; i < tbl->max_slots; ++i)
+		tbl->slots[i].seq_nr = ivalue;
 	spin_unlock(&tbl->slot_tbl_lock);
 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
 		tbl, tbl->slots, tbl->max_slots);
-- 
1.7.5.4

