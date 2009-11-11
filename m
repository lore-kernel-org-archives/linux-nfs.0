From: andros@netapp.com
Subject: [PATCH 1/2] nfs41: remove nfs4_recover_session
Date: Wed, 11 Nov 2009 17:47:17 -0500
Message-ID: <1257979638-2444-2-git-send-email-andros@netapp.com>
References: <1257979638-2444-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22486 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbZKLOiS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2009 09:38:18 -0500
In-Reply-To: <1257979638-2444-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_recover_session can put rpciod to sleep. Just use nfs4_schedule_recovery.

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   26 +++-----------------------
 1 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f1afde..44d1c14 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -427,24 +427,6 @@ out:
 	return ret_id;
 }
 
-static int nfs4_recover_session(struct nfs4_session *session)
-{
-	struct nfs_client *clp = session->clp;
-	unsigned int loop;
-	int ret;
-
-	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
-		ret = nfs4_wait_clnt_recover(clp);
-		if (ret != 0)
-			break;
-		if (!test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
-			break;
-		nfs4_schedule_state_manager(clp);
-		ret = -EIO;
-	}
-	return ret;
-}
-
 static int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
@@ -453,7 +435,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 {
 	struct nfs4_slot *slot;
 	struct nfs4_slot_table *tbl;
-	int status = 0;
 	u8 slotid;
 
 	dprintk("--> %s\n", __func__);
@@ -476,11 +457,10 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 
 		/* The slot table is empty; start the reset thread */
 		dprintk("%s Session Reset\n", __func__);
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		nfs4_schedule_state_manager(session->clp);
 		spin_unlock(&tbl->slot_tbl_lock);
-		status = nfs4_recover_session(session);
-		if (status)
-			return status;
-		spin_lock(&tbl->slot_tbl_lock);
+		return -EAGAIN;
 	}
 
 	slotid = nfs4_find_slot(tbl, task);
-- 
1.6.0.6

