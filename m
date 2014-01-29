Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:52400 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaA2Rnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jan 2014 12:43:33 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so2416813iej.17
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 09:43:33 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 2/3] NFSv4.1: Clean up nfs41_sequence_done
Date: Wed, 29 Jan 2014 12:36:21 -0500
Message-Id: <1391016982-10562-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
References: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the test for res->sr_slot == NULL out of the nfs41_sequence_free_slot
helper and into the main function for efficiency.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 493e9cce1f11..42da6af77587 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -559,15 +559,10 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
+	struct nfs4_slot *slot = res->sr_slot;
 	bool send_new_highest_used_slotid = false;
 
-	if (!res->sr_slot) {
-		/* just wake up the next guy waiting since
-		 * we may have not consumed a slot after all */
-		dprintk("%s: No slot\n", __func__);
-		return;
-	}
-	tbl = res->sr_slot->table;
+	tbl = slot->table;
 	session = tbl->session;
 
 	spin_lock(&tbl->slot_tbl_lock);
@@ -577,11 +572,11 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	if (tbl->highest_used_slotid > tbl->target_highest_slotid)
 		send_new_highest_used_slotid = true;
 
-	if (nfs41_wake_and_assign_slot(tbl, res->sr_slot)) {
+	if (nfs41_wake_and_assign_slot(tbl, slot)) {
 		send_new_highest_used_slotid = false;
 		goto out_unlock;
 	}
-	nfs4_free_slot(tbl, res->sr_slot);
+	nfs4_free_slot(tbl, slot);
 
 	if (tbl->highest_used_slotid != NFS4_NO_SLOT)
 		send_new_highest_used_slotid = false;
@@ -595,16 +590,17 @@ out_unlock:
 int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
-	struct nfs4_slot *slot;
+	struct nfs4_slot *slot = res->sr_slot;
 	struct nfs_client *clp;
 	bool interrupted = false;
 	int ret = 1;
 
+	if (slot == NULL)
+		goto out_noaction;
 	/* don't increment the sequence number if the task wasn't sent */
 	if (!RPC_WAS_SENT(task))
 		goto out;
 
-	slot = res->sr_slot;
 	session = slot->table->session;
 
 	if (slot->interrupted) {
@@ -679,6 +675,7 @@ out:
 	/* The session may be reset by one of the error handlers. */
 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
 	nfs41_sequence_free_slot(res);
+out_noaction:
 	return ret;
 retry_nowait:
 	if (rpc_restart_call_prepare(task)) {
-- 
1.8.5.3

