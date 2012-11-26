Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875Ab2KZURG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:06 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 15/28] NFSv4.1: Fix nfs4_callback_recallslot to work with dynamic slot allocation
Date: Mon, 26 Nov 2012 15:16:32 -0500
Message-Id: <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
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
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the NFSv4.1 CB_RECALL_SLOT callback updates the slot table
target max slotid safely.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c | 2 +-
 fs/nfs/nfs4_fs.h       | 2 ++
 fs/nfs/nfs4proc.c      | 8 ++++++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0be08b9..15b9879 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -576,7 +576,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (args->crsa_target_max_slots == fc_tbl->max_slots)
 		goto out;
 
-	fc_tbl->target_max_slots = args->crsa_target_max_slots;
+	nfs41_set_target_slotid(fc_tbl, args->crsa_target_max_slots);
 	nfs41_handle_recall_slot(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 42c5869..5d4e82b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -260,6 +260,8 @@ extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 
 extern struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
 		u32 max_slots, gfp_t gfp_flags);
+extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fc58ad8..731a6fd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -499,6 +499,14 @@ static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
 	tbl->generation++;
 }
 
+void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid)
+{
+	spin_lock(&tbl->slot_tbl_lock);
+	nfs41_set_target_slotid_locked(tbl, target_highest_slotid);
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
 static void nfs41_set_server_slotid_locked(struct nfs4_slot_table *tbl,
 		u32 highest_slotid)
 {
-- 
1.7.11.7

