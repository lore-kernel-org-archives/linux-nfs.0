From: andros@netapp.com
Subject: [PATCH 11/11] nfs41: drain session cleanup
Date: Fri,  4 Dec 2009 15:25:46 -0500
Message-ID: <1259958347-9031-12-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
 <1259958347-9031-6-git-send-email-andros@netapp.com>
 <1259958347-9031-7-git-send-email-andros@netapp.com>
 <1259958347-9031-8-git-send-email-andros@netapp.com>
 <1259958347-9031-9-git-send-email-andros@netapp.com>
 <1259958347-9031-10-git-send-email-andros@netapp.com>
 <1259958347-9031-11-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26685 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757290AbZLDU0C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:26:02 -0500
In-Reply-To: <1259958347-9031-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not wake up the next slot_tbl_waitq task in nfs4_free_slot because we
may be draining the slot. Either signal the state manager that the session
is drained (the state manager wakes up tasks) OR wake up the next task.

In nfs41_sequence_done, the slot dereference is only needed in the sequence
operation success case.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b5b5f0..263ac19 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -329,7 +329,6 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 		else
 			tbl->highest_used_slotid = -1;
 	}
-	rpc_wake_up_next(&tbl->slot_tbl_waitq);
 	spin_unlock(&tbl->slot_tbl_lock);
 	dprintk("%s: free_slotid %u highest_used_slotid %d\n", __func__,
 		free_slotid, tbl->highest_used_slotid);
@@ -346,14 +345,13 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
 	}
 	tbl = &clp->cl_session->fc_slot_table;
 	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE) {
-		dprintk("%s: No slot\n", __func__);
 		/* just wake up the next guy waiting since
 		 * we may have not consumed a slot after all */
-		rpc_wake_up_next(&tbl->slot_tbl_waitq);
-		return;
+		dprintk("%s: No slot\n", __func__);
+	} else {
+		nfs4_free_slot(tbl, res->sr_slotid);
+		res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 	}
-	nfs4_free_slot(tbl, res->sr_slotid);
-	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 
 	/* Signal state manager thread if session is drained */
 	if (test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
@@ -363,6 +361,8 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
 			complete(&clp->cl_session->complete);
 		}
 		spin_unlock(&tbl->slot_tbl_lock);
+	} else {
+		rpc_wake_up_next(&tbl->slot_tbl_waitq);
 	}
 }
 
@@ -387,10 +387,10 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
 		goto out;
 
-	tbl = &clp->cl_session->fc_slot_table;
-	slot = tbl->slots + res->sr_slotid;
-
+	/* Check the SEQUENCE operation status */
 	if (res->sr_status == 0) {
+		tbl = &clp->cl_session->fc_slot_table;
+		slot = tbl->slots + res->sr_slotid;
 		/* Update the slot's sequence and clientid lease timer */
 		++slot->seq_nr;
 		timestamp = res->sr_renewal_time;
-- 
1.6.0.6

