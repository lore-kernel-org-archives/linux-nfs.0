Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755949Ab2KZURI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:08 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 18/28] NFSv4.1: Support dynamic resizing of the session slot table
Date: Mon, 26 Nov 2012 15:16:35 -0500
Message-Id: <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
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
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the server to control the size of the session slot table
by adjusting the value of sr_target_max_slots in the reply to the
SEQUENCE operation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c         | 12 ++++++++++--
 fs/nfs/nfs4state.c        |  6 +++---
 include/linux/nfs_fs_sb.h |  1 +
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 731a6fd..5641380 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -493,10 +493,17 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid)
 {
+	unsigned int max_slotid, i;
+
 	if (tbl->target_highest_slotid == target_highest_slotid)
 		return;
 	tbl->target_highest_slotid = target_highest_slotid;
 	tbl->generation++;
+
+	max_slotid = min(tbl->max_slots - 1, tbl->target_highest_slotid);
+	for (i = tbl->max_slotid + 1; i <= max_slotid; i++)
+		rpc_wake_up_next(&tbl->slot_tbl_waitq);
+	tbl->max_slotid = max_slotid;
 }
 
 void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
@@ -623,8 +630,8 @@ static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
 		tbl->max_slots);
-	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slots);
-	if (slotid >= tbl->max_slots)
+	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slotid + 1);
+	if (slotid > tbl->max_slotid)
 		goto out;
 	__set_bit(slotid, tbl->used_slots);
 	if (slotid > tbl->highest_used_slotid ||
@@ -5745,6 +5752,7 @@ static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
 	tbl->target_highest_slotid = max_slots - 1;
 	tbl->server_highest_slotid = max_slots - 1;
+	tbl->max_slotid = max_slots - 1;
 	for (i = 0; i < tbl->max_slots; i++)
 		tbl->slots[i].seq_nr = ivalue;
 	spin_unlock(&tbl->slot_tbl_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 842cb8c..1b7fa73 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -254,15 +254,14 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
 	struct nfs4_slot_table *tbl;
-	int max_slots;
+	unsigned int i;
 
 	if (ses == NULL)
 		return;
 	tbl = &ses->fc_slot_table;
 	if (test_and_clear_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
 		spin_lock(&tbl->slot_tbl_lock);
-		max_slots = tbl->max_slots;
-		while (max_slots--) {
+		for (i = 0; i <= tbl->max_slotid; i++) {
 			if (rpc_wake_up_first(&tbl->slot_tbl_waitq,
 						nfs4_set_task_privileged,
 						NULL) == NULL)
@@ -2043,6 +2042,7 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 	old = fc_tbl->slots;
 	fc_tbl->slots = new;
 	fc_tbl->max_slots = fc_tbl->target_highest_slotid + 1;
+	fc_tbl->max_slotid = fc_tbl->target_highest_slotid;
 	clp->cl_session->fc_attrs.max_reqs = fc_tbl->max_slots;
 	spin_unlock(&fc_tbl->slot_tbl_lock);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 646e64b..3071550 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -215,6 +215,7 @@ struct nfs4_slot_table {
 	spinlock_t	slot_tbl_lock;
 	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
 	u32		max_slots;		/* # slots in table */
+	u32		max_slotid;		/* Max allowed slotid value */
 	u32		highest_used_slotid;	/* sent to server on each SEQ.
 						 * op for dynamic resizing */
 	u32		target_highest_slotid;	/* Server max_slot target */
-- 
1.7.11.7

