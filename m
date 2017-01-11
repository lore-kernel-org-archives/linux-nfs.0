Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:55666 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753264AbdAKSzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:12 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/11] NFS: Check if the slot table is draining from nfs4_setup_sequence()
Date: Wed, 11 Jan 2017 13:54:52 -0500
Message-ID: <20170111185454.9315-10-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 56e8c9e04f4a..aaa87f4eacf2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -630,9 +630,6 @@ static int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
 {
 	struct nfs4_slot *slot;
 
-	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
-		return -EAGAIN;
-
 	slot = nfs4_alloc_slot(tbl);
 	if (IS_ERR(slot)) {
 		if (slot == ERR_PTR(-ENOMEM))
@@ -875,15 +872,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	dprintk("--> %s\n", __func__);
 	tbl = &session->fc_slot_table;
 
-	task->tk_timeout = 0;
-
-	if (test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state) &&
-	    !args->sa_privileged) {
-		/* The state manager will wait until the slot table is empty */
-		dprintk("%s session is draining\n", __func__);
-		return -EAGAIN;
-	}
-
 	slot = nfs4_alloc_slot(tbl);
 	if (IS_ERR(slot)) {
 		/* If out of memory, try again in 1/4 second */
@@ -961,15 +949,22 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 			struct rpc_task *task)
 {
 	struct nfs4_session *session = nfs4_get_session(client);
-	struct nfs4_slot_table *tbl  = session ? &session->fc_slot_table :
-						  client->cl_slot_tbl;
+	struct nfs4_slot_table *tbl  = client->cl_slot_tbl;
 	int ret;
 
 	/* slot already allocated? */
 	if (res->sr_slot != NULL)
 		goto out_start;
 
+	if (session) {
+		tbl = &session->fc_slot_table;
+		task->tk_timeout = 0;
+	}
+
 	spin_lock(&tbl->slot_tbl_lock);
+	/* The state manager will wait until the slot table is empty */
+	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
+		goto out_sleep;
 
 #if defined(CONFIG_NFS_V4_1)
 	if (session)
-- 
2.11.0

