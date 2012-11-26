Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755938Ab2KZURF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:05 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/28] NFSv4.1: Reset the sequence number for slots that have been deallocated
Date: Mon, 26 Nov 2012 15:16:31 -0500
Message-Id: <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the server tells us that it is dynamically resizing the session
replay cache, we should reset the sequence number for those slots
that have been deallocated.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c         | 18 ++++++++++++++++++
 fs/nfs/nfs4xdr.c          |  4 ++--
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  1 +
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8333260..fc58ad8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -499,6 +499,22 @@ static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
 	tbl->generation++;
 }
 
+static void nfs41_set_server_slotid_locked(struct nfs4_slot_table *tbl,
+		u32 highest_slotid)
+{
+	unsigned int max_slotid, i;
+
+	if (tbl->server_highest_slotid == highest_slotid)
+		return;
+	if (tbl->highest_used_slotid > highest_slotid)
+		return;
+	max_slotid = min(tbl->max_slots - 1, highest_slotid);
+	/* Reset the seq_nr for deallocated slots */
+	for (i = tbl->server_highest_slotid + 1; i <= max_slotid; i++)
+		tbl->slots[i].seq_nr = 1;
+	tbl->server_highest_slotid = highest_slotid;
+}
+
 static void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 		struct nfs4_slot *slot,
 		struct nfs4_sequence_res *res)
@@ -506,6 +522,7 @@ static void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 	spin_lock(&tbl->slot_tbl_lock);
 	if (tbl->generation != slot->generation)
 		goto out;
+	nfs41_set_server_slotid_locked(tbl, res->sr_highest_slotid);
 	nfs41_set_target_slotid_locked(tbl, res->sr_target_highest_slotid);
 out:
 	spin_unlock(&tbl->slot_tbl_lock);
@@ -5719,6 +5736,7 @@ static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
 	}
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
 	tbl->target_highest_slotid = max_slots - 1;
+	tbl->server_highest_slotid = max_slots - 1;
 	for (i = 0; i < tbl->max_slots; i++)
 		tbl->slots[i].seq_nr = ivalue;
 	spin_unlock(&tbl->slot_tbl_lock);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 05d34f1..a67040f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5550,8 +5550,8 @@ static int decode_sequence(struct xdr_stream *xdr,
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
-	/* highest slot id - currently not processed */
-	dummy = be32_to_cpup(p++);
+	/* highest slot id */
+	res->sr_highest_slotid = be32_to_cpup(p++);
 	/* target highest slot id */
 	res->sr_target_highest_slotid = be32_to_cpup(p++);
 	/* result flags */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 57d4069..646e64b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -218,6 +218,7 @@ struct nfs4_slot_table {
 	u32		highest_used_slotid;	/* sent to server on each SEQ.
 						 * op for dynamic resizing */
 	u32		target_highest_slotid;	/* Server max_slot target */
+	u32		server_highest_slotid;	/* Server highest slotid */
 	unsigned long	generation;		/* Generation counter for
 						   target_highest_slotid */
 	struct completion complete;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 08c47db..3ddb08f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -203,6 +203,7 @@ struct nfs4_sequence_res {
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 	int			sr_status;	/* sequence operation status */
 	u32			sr_status_flags;
+	u32			sr_highest_slotid;
 	u32			sr_target_highest_slotid;
 };
 
-- 
1.7.11.7

