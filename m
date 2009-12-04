From: andros@netapp.com
Subject: [PATCH 12/12] nfs41: only state manager sets NFS4CLNT_SESSION_SETUP
Date: Fri,  4 Dec 2009 15:25:47 -0500
Message-ID: <1259958347-9031-13-git-send-email-andros@netapp.com>
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
 <1259958347-9031-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757140AbZLDU0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:26:03 -0500
In-Reply-To: <1259958347-9031-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replace sync and async handlers setting of the NFS4CLNT_SESSION_SETUP bit with
setting NFS4CLNT_CHECK_LEASE, and let the state manager decide to reset the session.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c  |    6 +++---
 fs/nfs/nfs4state.c |   10 +++++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57316ca..3936da3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -270,7 +270,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 		case -NFS4ERR_SEQ_MISORDERED:
 			dprintk("%s ERROR: %d Reset session\n", __func__,
 				errorcode);
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+			nfs4_schedule_state_recovery(clp);
 			exception->retry = 1;
 			break;
 #endif /* !defined(CONFIG_NFS_V4_1) */
@@ -459,7 +459,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	if (test_bit(NFS4CLNT_SESSION_RESET, &session->clp->cl_state)) {
+	if (test_bit(NFS4CLNT_SESSION_DRAINING, &session->clp->cl_state)) {
 		/*
 		 * The state manager will wait until the slot table is empty.
 		 * Schedule the reset thread
@@ -3355,7 +3355,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_SEQ_MISORDERED:
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+			nfs4_schedule_state_recovery(clp);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 31b4f74..9b26231 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1064,7 +1064,7 @@ static void nfs4_state_end_reclaim_nograce(struct nfs_client *clp)
 	clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
 }
 
-static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
+static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 {
 	switch (error) {
 		case -NFS4ERR_CB_PATH_DOWN:
@@ -1087,7 +1087,10 @@ static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_SEQ_FALSE_RETRY:
 		case -NFS4ERR_SEQ_MISORDERED:
 			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+			/* Zero session reset errors */
+			return 0;
 	}
+	return error;
 }
 
 static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
@@ -1107,6 +1110,7 @@ restart:
 		if (status < 0) {
 			set_bit(ops->owner_flag_bit, &sp->so_flags);
 			nfs4_put_state_owner(sp);
+			/* Do not zero session reset errors */
 			nfs4_recovery_handle_error(clp, status);
 			return status;
 		}
@@ -1138,7 +1142,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	status = ops->renew_lease(clp, cred);
 	put_rpccred(cred);
 out:
-	nfs4_recovery_handle_error(clp, status);
+	status = nfs4_recovery_handle_error(clp, status);
 	return status;
 }
 
@@ -1185,7 +1189,6 @@ static int nfs4_reset_session(struct nfs_client *clp)
 		set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
 		spin_unlock(&tbl->slot_tbl_lock);
 		status = wait_for_completion_interruptible(&ses->complete);
-		clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
 		if (status) /* -ERESTARTSYS */
 			goto out;
 	} else {
@@ -1206,6 +1209,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 		/* fall through*/
 out:
 	/* Wake up the next rpc task even on error */
+	clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
 	rpc_wake_up_next(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
 	return status;
 }
-- 
1.6.0.6

