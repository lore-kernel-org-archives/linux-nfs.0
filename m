From: andros@netapp.com
Subject: [PATCH 02/11] nfs41: rename cl_state session SETUP bit to RESET
Date: Fri,  4 Dec 2009 15:25:37 -0500
Message-ID: <1259958347-9031-3-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757228AbZLDUZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:53 -0500
In-Reply-To: <1259958347-9031-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The bit is no longer used for session setup, only for session reset.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h  |    2 +-
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |    8 ++++----
 fs/nfs/nfs4state.c |    8 ++++----
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e21b1bb..ebcd379 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -183,7 +183,7 @@ static inline void nfs4_restart_rpc(struct rpc_task *task,
 {
 #ifdef CONFIG_NFS_V4_1
 	if (nfs4_has_session(clp) &&
-	    test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
+	    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)) {
 		rpc_restart_call_prepare(task);
 		return;
 	}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 99d507d..e9ecd6b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,7 +44,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
-	NFS4CLNT_SESSION_SETUP,
+	NFS4CLNT_SESSION_RESET,
 };
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5c24b4b..1e13d53 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -270,7 +270,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 		case -NFS4ERR_SEQ_MISORDERED:
 			dprintk("%s ERROR: %d Reset session\n", __func__,
 				errorcode);
-			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 			exception->retry = 1;
 			/* FALLTHROUGH */
 #endif /* !defined(CONFIG_NFS_V4_1) */
@@ -439,7 +439,7 @@ static int nfs4_recover_session(struct nfs4_session *session)
 		ret = nfs4_wait_clnt_recover(clp);
 		if (ret != 0)
 			break;
-		if (!test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
+		if (!test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
 			break;
 		nfs4_schedule_state_manager(clp);
 		ret = -EIO;
@@ -468,7 +468,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	if (test_bit(NFS4CLNT_SESSION_SETUP, &session->clp->cl_state)) {
+	if (test_bit(NFS4CLNT_SESSION_RESET, &session->clp->cl_state)) {
 		if (tbl->highest_used_slotid != -1) {
 			rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 			spin_unlock(&tbl->slot_tbl_lock);
@@ -3350,7 +3350,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_SEQ_MISORDERED:
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
-			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8f1eb06..4168fa6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1085,7 +1085,7 @@ static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 		case -NFS4ERR_SEQ_FALSE_RETRY:
 		case -NFS4ERR_SEQ_MISORDERED:
-			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 	}
 }
 
@@ -1246,7 +1246,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				continue;
 		}
 		/* Initialize or reset the session */
-		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
+		if (test_and_clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
 			status = nfs4_reset_session(clp);
 			if (status) {
@@ -1261,7 +1261,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				nfs4_reboot_recovery_ops[clp->cl_minorversion]);
 			if (status == -NFS4ERR_STALE_CLIENTID)
 				continue;
-			if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
+			if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
 				continue;
 			nfs4_state_end_reclaim_reboot(clp);
 			continue;
@@ -1277,7 +1277,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 					continue;
 				if (status == -NFS4ERR_EXPIRED)
 					continue;
-				if (test_bit(NFS4CLNT_SESSION_SETUP,
+				if (test_bit(NFS4CLNT_SESSION_RESET,
 								&clp->cl_state))
 					continue;
 				goto out_error;
-- 
1.6.0.6

