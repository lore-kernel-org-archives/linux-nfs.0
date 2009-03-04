From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 35/46] nfs41: nfs41_sequence_free_slot
Date: Wed,  4 Mar 2009 02:00:12 +0200
Message-ID: <1236124812-3940-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17790
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752024AbZCDAA1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:00:27 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

[from nfs41: separate free slot from sequence done]

Don't free the slot until after all rpc_restart_calls have completed.
Session reset will require more work.

As noted by Trond, since we're using rpc_wake_up_next rather than
rpc_wake_up() we must always wake up the next task in the queue
either by going through nfs4_free_slot, or just calling
rpc_wake_up_next if no slot is to be freed.

[nfs41: sequence res use slotid]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
[got rid of nfs4_sequence_res.sr_session, use nfs_client.cl_session instead]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: rpc_wake_up_next if sessions slot was not consumed.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |   14 ++++++++++++++
 fs/nfs/nfs4proc.c |   21 +++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 427baef..f7d55a5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -222,6 +222,20 @@ static inline int nfs4_has_session(const struct nfs_client *clp)
 	return 0;
 }
 
+#ifdef CONFIG_NFS_V4_1
+extern void nfs41_sequence_free_slot(const struct nfs_client *,
+				     struct nfs4_sequence_res *res);
+#endif /* CONFIG_NFS_V4_1 */
+
+static inline void nfs4_sequence_free_slot(const struct nfs_server *server,
+					   struct nfs4_sequence_res *res)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(server->nfs_client))
+		nfs41_sequence_free_slot(server->nfs_client, res);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 898d83b..ca40377 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -317,6 +317,27 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 		free_slotid, tbl->highest_used_slotid);
 }
 
+void nfs41_sequence_free_slot(const struct nfs_client *clp,
+			      struct nfs4_sequence_res *res)
+{
+	struct nfs4_slot_table *tbl;
+
+	if (!nfs4_has_session(clp)) {
+		dprintk("%s: No session\n", __func__);
+		return;
+	}
+	tbl = &clp->cl_session->fc_slot_table;
+	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE) {
+		dprintk("%s: No slot\n", __func__);
+		/* just wake up the next guy waiting since
+		 * we may have not consumed a slot after all */
+		rpc_wake_up_next(&tbl->slot_tbl_waitq);
+		return;
+	}
+	nfs4_free_slot(tbl, res->sr_slotid);
+	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+}
+
 /*
  * nfs4_find_slot - efficiently look for a free slot
  *
-- 
1.6.1.3

