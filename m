From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 32/67] nfs41: nfs41_sequence_free_slot
Date: Thu,  2 Apr 2009 16:54:53 +0300
Message-ID: <1238680493-14402-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1226 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758342AbZDBNzL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:11 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |   14 ++++++++++++++
 fs/nfs/nfs4proc.c |   21 +++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8d67c28..12f4c5e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -230,6 +230,20 @@ static inline int nfs4_has_session(const struct nfs_client *clp)
 	return 0;
 }
 
+#ifdef CONFIG_NFS_V4_1
+extern void nfs41_sequence_free_slot(const struct nfs_client *,
+				     struct nfs4_sequence_res *res);
+#endif /* CONFIG_NFS_V4_1 */
+
+static inline void nfs4_sequence_free_slot(const struct nfs_client *clp,
+					   struct nfs4_sequence_res *res)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp))
+		nfs41_sequence_free_slot(clp, res);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b17c75e..5e49696 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -309,6 +309,27 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
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
1.6.2.1

