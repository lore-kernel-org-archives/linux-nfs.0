Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45198 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066Ab2LOUod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 15:44:33 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1: Deal effectively with interrupted RPC calls.
Date: Sat, 15 Dec 2012 15:44:26 -0500
Message-Id: <1355604266-21183-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355604266-21183-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1355604266-21183-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355604266-21183-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an RPC call is interrupted, assume that the server hasn't processed
the RPC call so that the next time we use the slot, we know that if we
get a NFS4ERR_SEQ_MISORDERED or NFS4ERR_SEQ_FALSE_RETRY, we just have
to bump the sequence number.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c    | 32 +++++++++++++++++++++++---------
 fs/nfs/nfs4session.c |  1 +
 fs/nfs/nfs4session.h |  1 +
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index afb428e..493f0f4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -420,17 +420,9 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 	struct nfs4_session *session;
 	struct nfs4_slot *slot;
 	struct nfs_client *clp;
+	bool interrupted = false;
 	int ret = 1;
 
-	/*
-	 * sr_status remains 1 if an RPC level error occurred. The server
-	 * may or may not have processed the sequence operation..
-	 * Proceed as if the server received and processed the sequence
-	 * operation.
-	 */
-	if (res->sr_status == 1)
-		res->sr_status = NFS_OK;
-
 	/* don't increment the sequence number if the task wasn't sent */
 	if (!RPC_WAS_SENT(task))
 		goto out;
@@ -438,6 +430,11 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 	slot = res->sr_slot;
 	session = slot->table->session;
 
+	if (slot->interrupted) {
+		slot->interrupted = 0;
+		interrupted = true;
+	}
+
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
 	case 0:
@@ -450,6 +447,15 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 			nfs4_schedule_lease_recovery(clp);
 		nfs41_update_target_slotid(slot->table, slot, res);
 		break;
+	case 1:
+		/*
+		 * sr_status remains 1 if an RPC level error occurred.
+		 * The server may or may not have processed the sequence
+		 * operation..
+		 * Mark the slot as having hosted an interrupted RPC call.
+		 */
+		slot->interrupted = 1;
+		goto out;
 	case -NFS4ERR_DELAY:
 		/* The server detected a resend of the RPC call and
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
@@ -468,6 +474,14 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		goto retry_nowait;
 	case -NFS4ERR_SEQ_MISORDERED:
 		/*
+		 * Was the last operation on this sequence interrupted?
+		 * If so, retry after bumping the sequence number.
+		 */
+		if (interrupted) {
+			++slot->seq_nr;
+			goto retry_nowait;
+		}
+		/*
 		 * Could this slot have been previously retired?
 		 * If so, then the server may be expecting seq_nr = 1!
 		 */
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 0e1cc1f..ebda5f4 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -172,6 +172,7 @@ static void nfs4_reset_slot_table(struct nfs4_slot_table *tbl,
 	p = &tbl->slots;
 	while (*p) {
 		(*p)->seq_nr = ivalue;
+		(*p)->interrupted = 0;
 		p = &(*p)->next;
 	}
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index d17b080..6f3cb39 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -21,6 +21,7 @@ struct nfs4_slot {
 	unsigned long		generation;
 	u32			slot_nr;
 	u32		 	seq_nr;
+	unsigned int		interrupted : 1;
 };
 
 /* Sessions */
-- 
1.7.11.7

