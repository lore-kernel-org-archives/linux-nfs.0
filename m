Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:24235 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463Ab2KVSoq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:44:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/20] NFSv4.1: Ensure that the client tracks the server target_highest_slotid
Date: Wed, 21 Nov 2012 17:43:11 -0500
Message-Id: <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
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
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dynamic slot allocation in NFSv4.1 depends on the client being able to
track the server's target value for the highest slotid in the
slot table.  See the reference in Section 2.10.6.1 of RFC5661.

To avoid ordering problems in the case where 2 SEQUENCE replies contain
conflicting updates to this target value, we also introduce a generation
counter, to track whether or not an RPC containing a SEQUENCE operation
was launched before or after the last update.

Also rename the nfs4_slot_table target_max_slots field to
'target_highest_slotid' to avoid confusion with a slot
table size or number of slots.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c         | 25 +++++++++++++++++++++++++
 fs/nfs/nfs4state.c        |  7 +++----
 fs/nfs/nfs4xdr.c          |  4 ++--
 include/linux/nfs_fs_sb.h |  5 +++--
 include/linux/nfs_xdr.h   |  2 ++
 5 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 14389f2..8333260 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -489,6 +489,28 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	res->sr_slot = NULL;
 }
 
+/* Update the client's idea of target_highest_slotid */
+static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid)
+{
+	if (tbl->target_highest_slotid == target_highest_slotid)
+		return;
+	tbl->target_highest_slotid = target_highest_slotid;
+	tbl->generation++;
+}
+
+static void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot,
+		struct nfs4_sequence_res *res)
+{
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->generation != slot->generation)
+		goto out;
+	nfs41_set_target_slotid_locked(tbl, res->sr_target_highest_slotid);
+out:
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
 static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
@@ -523,6 +545,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		/* Check sequence flags */
 		if (res->sr_status_flags != 0)
 			nfs4_schedule_lease_recovery(clp);
+		nfs41_update_target_slotid(slot->table, slot, res);
 		break;
 	case -NFS4ERR_DELAY:
 		/* The server detected a resend of the RPC call and
@@ -584,6 +607,7 @@ static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 		tbl->highest_used_slotid = slotid;
 	ret = &tbl->slots[slotid];
 	ret->renewal_time = jiffies;
+	ret->generation = tbl->generation;
 
 out:
 	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
@@ -5694,6 +5718,7 @@ static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
 		tbl->max_slots = max_slots;
 	}
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	tbl->target_highest_slotid = max_slots - 1;
 	for (i = 0; i < tbl->max_slots; i++)
 		tbl->slots[i].seq_nr = ivalue;
 	spin_unlock(&tbl->slot_tbl_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9495789..842cb8c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2033,17 +2033,16 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 		return 0;
 	nfs4_begin_drain_session(clp);
 	fc_tbl = &clp->cl_session->fc_slot_table;
-	new = nfs4_alloc_slots(fc_tbl, fc_tbl->target_max_slots, GFP_NOFS);
+	new = nfs4_alloc_slots(fc_tbl, fc_tbl->target_highest_slotid + 1, GFP_NOFS);
         if (!new)
 		return -ENOMEM;
 
 	spin_lock(&fc_tbl->slot_tbl_lock);
-	for (i = 0; i < fc_tbl->target_max_slots; i++)
+	for (i = 0; i <= fc_tbl->target_highest_slotid; i++)
 		new[i].seq_nr = fc_tbl->slots[i].seq_nr;
 	old = fc_tbl->slots;
 	fc_tbl->slots = new;
-	fc_tbl->max_slots = fc_tbl->target_max_slots;
-	fc_tbl->target_max_slots = 0;
+	fc_tbl->max_slots = fc_tbl->target_highest_slotid + 1;
 	clp->cl_session->fc_attrs.max_reqs = fc_tbl->max_slots;
 	spin_unlock(&fc_tbl->slot_tbl_lock);
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 27b0fec..05d34f1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5552,8 +5552,8 @@ static int decode_sequence(struct xdr_stream *xdr,
 	}
 	/* highest slot id - currently not processed */
 	dummy = be32_to_cpup(p++);
-	/* target highest slot id - currently not processed */
-	dummy = be32_to_cpup(p++);
+	/* target highest slot id */
+	res->sr_target_highest_slotid = be32_to_cpup(p++);
 	/* result flags */
 	res->sr_status_flags = be32_to_cpup(p);
 	status = 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b041287..57d4069 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -217,8 +217,9 @@ struct nfs4_slot_table {
 	u32		max_slots;		/* # slots in table */
 	u32		highest_used_slotid;	/* sent to server on each SEQ.
 						 * op for dynamic resizing */
-	u32		target_max_slots;	/* Set by CB_RECALL_SLOT as
-						 * the new max_slots */
+	u32		target_highest_slotid;	/* Server max_slot target */
+	unsigned long	generation;		/* Generation counter for
+						   target_highest_slotid */
 	struct completion complete;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index deb31bb..08c47db 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -188,6 +188,7 @@ struct nfs4_channel_attrs {
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
 	struct nfs4_slot_table	*table;
+	unsigned long		generation;
 	unsigned long		renewal_time;
 	u32			slot_nr;
 	u32		 	seq_nr;
@@ -202,6 +203,7 @@ struct nfs4_sequence_res {
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 	int			sr_status;	/* sequence operation status */
 	u32			sr_status_flags;
+	u32			sr_target_highest_slotid;
 };
 
 struct nfs4_get_lease_time_args {
-- 
1.7.11.7

