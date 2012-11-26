Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875Ab2KZUQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:59 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/28] NFSv4.1: Shrink struct nfs4_sequence_res by moving sr_renewal_time
Date: Mon, 26 Nov 2012 15:16:24 -0500
Message-Id: <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Store the renewal time inside the session slot instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 15 +++++++++------
 include/linux/nfs_xdr.h |  2 +-
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e5cc5a..14b3974 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -486,6 +486,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 
 static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
+	struct nfs4_slot *slot;
 	unsigned long timestamp;
 	struct nfs_client *clp;
 
@@ -502,12 +503,14 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 	if (!RPC_WAS_SENT(task))
 		goto out;
 
+	slot = res->sr_slot;
+
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
 	case 0:
 		/* Update the slot's sequence and clientid lease timer */
-		++res->sr_slot->seq_nr;
-		timestamp = res->sr_renewal_time;
+		++slot->seq_nr;
+		timestamp = slot->renewal_time;
 		clp = res->sr_session->clp;
 		do_renew_lease(clp, timestamp);
 		/* Check sequence flags */
@@ -521,12 +524,12 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 */
 		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
 			__func__,
-			res->sr_slot - res->sr_session->fc_slot_table.slots,
-			res->sr_slot->seq_nr);
+			slot - res->sr_session->fc_slot_table.slots,
+			slot->seq_nr);
 		goto out_retry;
 	default:
 		/* Just update the slot sequence no. */
-		++res->sr_slot->seq_nr;
+		++slot->seq_nr;
 	}
 out:
 	/* The session may be reset by one of the error handlers. */
@@ -637,6 +640,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
 	slot = tbl->slots + slotid;
+	slot->renewal_time = jiffies;
 	args->sa_session = session;
 	args->sa_slotid = slotid;
 
@@ -644,7 +648,6 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	res->sr_session = session;
 	res->sr_slot = slot;
-	res->sr_renewal_time = jiffies;
 	res->sr_status_flags = 0;
 	/*
 	 * sr_status is only set in decode_sequence, and so will remain
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a73ea89..9cb1c63 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -187,6 +187,7 @@ struct nfs4_channel_attrs {
 
 /* nfs41 sessions slot seqid */
 struct nfs4_slot {
+	unsigned long		renewal_time;
 	u32		 	seq_nr;
 };
 
@@ -200,7 +201,6 @@ struct nfs4_sequence_res {
 	struct nfs4_session	*sr_session;
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 	int			sr_status;	/* sequence operation status */
-	unsigned long		sr_renewal_time;
 	u32			sr_status_flags;
 };
 
-- 
1.7.11.7

