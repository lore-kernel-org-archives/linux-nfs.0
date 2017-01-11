Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:47054 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754062AbdAKSzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:25 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/11] NFS: Handle setup sequence task rescheduling in a single place
Date: Wed, 11 Jan 2017 13:54:51 -0500
Message-ID: <20170111185454.9315-9-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 37 +++++++++++++++----------------------
 1 file changed, 15 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0b409b84b9a2..56e8c9e04f4a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -631,27 +631,19 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 	struct nfs4_slot *slot;
 
 	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
-		goto out_sleep;
+		return -EAGAIN;
 
 	slot = nfs4_alloc_slot(tbl);
 	if (IS_ERR(slot)) {
 		if (slot == ERR_PTR(-ENOMEM))
 			task->tk_timeout = HZ >> 2;
-		goto out_sleep;
+		return -EAGAIN;
 	}
 
 	slot->privileged = args->sa_privileged ? 1 : 0;
 	args->sa_slot = slot;
 	res->sr_slot = slot;
 	return 0;
-
-out_sleep:
-	if (args->sa_privileged)
-		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
-				NULL, RPC_PRIORITY_PRIVILEGED);
-	else
-		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-	return -EAGAIN;
 }
 
 static void nfs40_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -889,7 +881,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	    !args->sa_privileged) {
 		/* The state manager will wait until the slot table is empty */
 		dprintk("%s session is draining\n", __func__);
-		goto out_sleep;
+		return -EAGAIN;
 	}
 
 	slot = nfs4_alloc_slot(tbl);
@@ -898,7 +890,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 		if (slot == ERR_PTR(-ENOMEM))
 			task->tk_timeout = HZ >> 2;
 		dprintk("<-- %s: no free slots\n", __func__);
-		goto out_sleep;
+		return -EAGAIN;
 	}
 
 	slot->privileged = args->sa_privileged ? 1 : 0;
@@ -917,14 +909,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	res->sr_status = 1;
 	trace_nfs4_setup_sequence(session, args);
 	return 0;
-out_sleep:
-	/* Privileged tasks are queued with top priority */
-	if (args->sa_privileged)
-		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
-				NULL, RPC_PRIORITY_PRIVILEGED);
-	else
-		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-	return -EAGAIN;
 }
 
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
@@ -994,13 +978,22 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 #endif /* CONFIG_NFS_V4_1 */
 		ret = nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
 
+	if (ret == -EAGAIN)
+		goto out_sleep;
 	spin_unlock(&tbl->slot_tbl_lock);
-	if (ret < 0)
-		return ret;
 
 out_start:
 	rpc_call_start(task);
 	return 0;
+
+out_sleep:
+	if (args->sa_privileged)
+		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
+				NULL, RPC_PRIORITY_PRIVILEGED);
+	else
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+	spin_unlock(&tbl->slot_tbl_lock);
+	return -EAGAIN;
 }
 EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
 
-- 
2.11.0

