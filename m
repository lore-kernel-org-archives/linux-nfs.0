Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:55666 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbdAKSzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:10 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/11] NFS: Move slot-already-allocated check into nfs_setup_sequence()
Date: Wed, 11 Jan 2017 13:54:49 -0500
Message-ID: <20170111185454.9315-7-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This puts the check in a single place, rather than needing to implement
it twice for v4.0 and v4.1.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 132d73435b8f..856d0df8d653 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -630,10 +630,6 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 {
 	struct nfs4_slot *slot;
 
-	/* slot already allocated? */
-	if (res->sr_slot != NULL)
-		goto out_start;
-
 	spin_lock(&tbl->slot_tbl_lock);
 	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
 		goto out_sleep;
@@ -650,7 +646,6 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 	args->sa_slot = slot;
 	res->sr_slot = slot;
 
-out_start:
 	rpc_call_start(task);
 	return 0;
 
@@ -891,10 +886,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	struct nfs4_slot_table *tbl;
 
 	dprintk("--> %s\n", __func__);
-	/* slot already allocated? */
-	if (res->sr_slot != NULL)
-		goto out_success;
-
 	tbl = &session->fc_slot_table;
 
 	task->tk_timeout = 0;
@@ -932,7 +923,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	 */
 	res->sr_status = 1;
 	trace_nfs4_setup_sequence(session, args);
-out_success:
 	rpc_call_start(task);
 	return 0;
 out_sleep:
@@ -997,12 +987,21 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 {
 #if defined(CONFIG_NFS_V4_1)
 	struct nfs4_session *session = nfs4_get_session(client);
+#endif /* CONFIG_NFS_V4_1 */
 
+	/* slot already allocated? */
+	if (res->sr_slot != NULL)
+		goto out_start;
+
+#if defined(CONFIG_NFS_V4_1)
 	if (session)
 		return nfs41_setup_sequence(session, args, res, task);
 #endif /* CONFIG_NFS_V4_1 */
 	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
 
+out_start:
+	rpc_call_start(task);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
 
-- 
2.11.0

