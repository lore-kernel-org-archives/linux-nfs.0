Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:63323 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753434AbdAKSzN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:13 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/11] NFS: Merge the remaining setup_sequence functions
Date: Wed, 11 Jan 2017 13:54:53 -0500
Message-ID: <20170111185454.9315-11-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This creates a single place for all the work to happen, using the
presence of a session to determine if extra values need to be set.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 87 +++++++++++++------------------------------------------
 1 file changed, 20 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aaa87f4eacf2..31edcf07ac93 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -623,26 +623,6 @@ static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
 	args->sa_privileged = 1;
 }
 
-static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
-				struct nfs4_sequence_args *args,
-				struct nfs4_sequence_res *res,
-				struct rpc_task *task)
-{
-	struct nfs4_slot *slot;
-
-	slot = nfs4_alloc_slot(tbl);
-	if (IS_ERR(slot)) {
-		if (slot == ERR_PTR(-ENOMEM))
-			task->tk_timeout = HZ >> 2;
-		return -EAGAIN;
-	}
-
-	slot->privileged = args->sa_privileged ? 1 : 0;
-	args->sa_slot = slot;
-	res->sr_slot = slot;
-	return 0;
-}
-
 static void nfs40_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot *slot = res->sr_slot;
@@ -861,44 +841,6 @@ int nfs4_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 }
 EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
-static int nfs41_setup_sequence(struct nfs4_session *session,
-				struct nfs4_sequence_args *args,
-				struct nfs4_sequence_res *res,
-				struct rpc_task *task)
-{
-	struct nfs4_slot *slot;
-	struct nfs4_slot_table *tbl;
-
-	dprintk("--> %s\n", __func__);
-	tbl = &session->fc_slot_table;
-
-	slot = nfs4_alloc_slot(tbl);
-	if (IS_ERR(slot)) {
-		/* If out of memory, try again in 1/4 second */
-		if (slot == ERR_PTR(-ENOMEM))
-			task->tk_timeout = HZ >> 2;
-		dprintk("<-- %s: no free slots\n", __func__);
-		return -EAGAIN;
-	}
-
-	slot->privileged = args->sa_privileged ? 1 : 0;
-	args->sa_slot = slot;
-
-	dprintk("<-- %s slotid=%u seqid=%u\n", __func__,
-			slot->slot_nr, slot->seq_nr);
-
-	res->sr_slot = slot;
-	res->sr_timestamp = jiffies;
-	res->sr_status_flags = 0;
-	/*
-	 * sr_status is only set in decode_sequence, and so will remain
-	 * set to 1 if an rpc level failure occurs.
-	 */
-	res->sr_status = 1;
-	trace_nfs4_setup_sequence(session, args);
-	return 0;
-}
-
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
@@ -950,7 +892,7 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 {
 	struct nfs4_session *session = nfs4_get_session(client);
 	struct nfs4_slot_table *tbl  = client->cl_slot_tbl;
-	int ret;
+	struct nfs4_slot *slot;
 
 	/* slot already allocated? */
 	if (res->sr_slot != NULL)
@@ -966,17 +908,28 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
 		goto out_sleep;
 
-#if defined(CONFIG_NFS_V4_1)
-	if (session)
-		ret = nfs41_setup_sequence(session, args, res, task);
-	else
-#endif /* CONFIG_NFS_V4_1 */
-		ret = nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
-
-	if (ret == -EAGAIN)
+	slot = nfs4_alloc_slot(tbl);
+	if (IS_ERR(slot)) {
+		/* Try again in 1/4 second */
+		if (slot == ERR_PTR(-ENOMEM))
+			task->tk_timeout = HZ >> 2;
 		goto out_sleep;
+	}
 	spin_unlock(&tbl->slot_tbl_lock);
 
+	slot->privileged = args->sa_privileged ? 1 : 0;
+	args->sa_slot = slot;
+
+	res->sr_slot = slot;
+	if (session) {
+		res->sr_timestamp = jiffies;
+		res->sr_status_flags = 0;
+		res->sr_status = 1;
+#ifdef CONFIG_NFS_V4_1
+		trace_nfs4_setup_sequence(session, args);
+#endif /* CONFIG_NFS_V4_1 */
+	}
+
 out_start:
 	rpc_call_start(task);
 	return 0;
-- 
2.11.0

