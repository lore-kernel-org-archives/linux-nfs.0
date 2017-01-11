Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46892 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752882AbdAKSzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:11 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/11] NFS: Lock the slot table from a single place during setup sequence
Date: Wed, 11 Jan 2017 13:54:50 -0500
Message-ID: <20170111185454.9315-8-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Rather than implementing this twice for NFS v4.0 and v4.1

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 856d0df8d653..0b409b84b9a2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -630,7 +630,6 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 {
 	struct nfs4_slot *slot;
 
-	spin_lock(&tbl->slot_tbl_lock);
 	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
 		goto out_sleep;
 
@@ -640,13 +639,10 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 			task->tk_timeout = HZ >> 2;
 		goto out_sleep;
 	}
-	spin_unlock(&tbl->slot_tbl_lock);
 
 	slot->privileged = args->sa_privileged ? 1 : 0;
 	args->sa_slot = slot;
 	res->sr_slot = slot;
-
-	rpc_call_start(task);
 	return 0;
 
 out_sleep:
@@ -655,7 +651,6 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 				NULL, RPC_PRIORITY_PRIVILEGED);
 	else
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-	spin_unlock(&tbl->slot_tbl_lock);
 	return -EAGAIN;
 }
 
@@ -890,7 +885,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 
 	task->tk_timeout = 0;
 
-	spin_lock(&tbl->slot_tbl_lock);
 	if (test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state) &&
 	    !args->sa_privileged) {
 		/* The state manager will wait until the slot table is empty */
@@ -906,7 +900,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 		dprintk("<-- %s: no free slots\n", __func__);
 		goto out_sleep;
 	}
-	spin_unlock(&tbl->slot_tbl_lock);
 
 	slot->privileged = args->sa_privileged ? 1 : 0;
 	args->sa_slot = slot;
@@ -923,7 +916,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	 */
 	res->sr_status = 1;
 	trace_nfs4_setup_sequence(session, args);
-	rpc_call_start(task);
 	return 0;
 out_sleep:
 	/* Privileged tasks are queued with top priority */
@@ -932,7 +924,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 				NULL, RPC_PRIORITY_PRIVILEGED);
 	else
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-	spin_unlock(&tbl->slot_tbl_lock);
 	return -EAGAIN;
 }
 
@@ -985,19 +976,27 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 			struct nfs4_sequence_res *res,
 			struct rpc_task *task)
 {
-#if defined(CONFIG_NFS_V4_1)
 	struct nfs4_session *session = nfs4_get_session(client);
-#endif /* CONFIG_NFS_V4_1 */
+	struct nfs4_slot_table *tbl  = session ? &session->fc_slot_table :
+						  client->cl_slot_tbl;
+	int ret;
 
 	/* slot already allocated? */
 	if (res->sr_slot != NULL)
 		goto out_start;
 
+	spin_lock(&tbl->slot_tbl_lock);
+
 #if defined(CONFIG_NFS_V4_1)
 	if (session)
-		return nfs41_setup_sequence(session, args, res, task);
+		ret = nfs41_setup_sequence(session, args, res, task);
+	else
 #endif /* CONFIG_NFS_V4_1 */
-	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
+		ret = nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
+
+	spin_unlock(&tbl->slot_tbl_lock);
+	if (ret < 0)
+		return ret;
 
 out_start:
 	rpc_call_start(task);
-- 
2.11.0

