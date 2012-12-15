Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45198 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab2LOUoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 15:44:32 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4.1: Move the RPC timestamp out of the slot.
Date: Sat, 15 Dec 2012 15:44:25 -0500
Message-Id: <1355604266-21183-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355604266-21183-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1355604266-21183-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Shave a few bytes off the slot table size by moving the RPC timestamp
into the sequence results.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 14 +++++++-------
 fs/nfs/nfs4session.c    |  3 +--
 fs/nfs/nfs4session.h    |  1 -
 include/linux/nfs_xdr.h |  1 +
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9003b8f..afb428e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -419,7 +419,6 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 {
 	struct nfs4_session *session;
 	struct nfs4_slot *slot;
-	unsigned long timestamp;
 	struct nfs_client *clp;
 	int ret = 1;
 
@@ -444,9 +443,8 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 	case 0:
 		/* Update the slot's sequence and clientid lease timer */
 		++slot->seq_nr;
-		timestamp = slot->renewal_time;
 		clp = session->clp;
-		do_renew_lease(clp, timestamp);
+		do_renew_lease(clp, res->sr_timestamp);
 		/* Check sequence flags */
 		if (res->sr_status_flags != 0)
 			nfs4_schedule_lease_recovery(clp);
@@ -473,10 +471,11 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * Could this slot have been previously retired?
 		 * If so, then the server may be expecting seq_nr = 1!
 		 */
-		if (slot->seq_nr == 1)
-			break;
-		slot->seq_nr = 1;
-		goto retry_nowait;
+		if (slot->seq_nr != 1) {
+			slot->seq_nr = 1;
+			goto retry_nowait;
+		}
+		break;
 	case -NFS4ERR_SEQ_FALSE_RETRY:
 		++slot->seq_nr;
 		goto retry_nowait;
@@ -567,6 +566,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 			slot->slot_nr, slot->seq_nr);
 
 	res->sr_slot = slot;
+	res->sr_timestamp = jiffies;
 	res->sr_status_flags = 0;
 	/*
 	 * sr_status is only set in decode_sequence, and so will remain
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 1e6c87c..0e1cc1f 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -143,7 +143,6 @@ struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 	if (slotid > tbl->highest_used_slotid ||
 			tbl->highest_used_slotid == NFS4_NO_SLOT)
 		tbl->highest_used_slotid = slotid;
-	ret->renewal_time = jiffies;
 	ret->generation = tbl->generation;
 
 out:
@@ -228,9 +227,9 @@ static bool nfs41_assign_slot(struct rpc_task *task, void *pslot)
 
 	if (nfs4_session_draining(tbl->session) && !args->sa_privileged)
 		return false;
-	slot->renewal_time = jiffies;
 	slot->generation = tbl->generation;
 	args->sa_slot = slot;
+	res->sr_timestamp = jiffies;
 	res->sr_slot = slot;
 	res->sr_status_flags = 0;
 	res->sr_status = 1;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 04f834c..d17b080 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -19,7 +19,6 @@ struct nfs4_slot {
 	struct nfs4_slot_table	*table;
 	struct nfs4_slot	*next;
 	unsigned long		generation;
-	unsigned long		renewal_time;
 	u32			slot_nr;
 	u32		 	seq_nr;
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a55abd4..29adb12 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -194,6 +194,7 @@ struct nfs4_sequence_args {
 
 struct nfs4_sequence_res {
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
+	unsigned long		sr_timestamp;
 	int			sr_status;	/* sequence operation status */
 	u32			sr_status_flags;
 	u32			sr_highest_slotid;
-- 
1.7.11.7

