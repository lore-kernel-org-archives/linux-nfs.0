From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 54/67] nfs41: add session reset to state manager
Date: Thu,  2 Apr 2009 16:58:24 +0300
Message-ID: <1238680704-15090-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29885 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756990AbZDBN6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:39 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Move the code to reset a session from the session_reclaimer to the
nfs4_state_manager.  Destroy the session, and create a new one. Treat
NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION as a successful
nfs4_proc_destroy_session. Signal nfs4_proc_create_session that this is a
session reset so that the session slot table is re-used.

If the clientid is stale, set both NFS4CLNT_LEASE_EXPIRED and
NFS4CLNT_SESSION_SETUP bits and retry.

Use a switch statement in nfs4_session_recovery_handle_error for future
patche which will add handling for other errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[nfs41: session reset in nfs4_recovery_handle_error]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: reset session on nfs4_do_reclaim session reset error]
    If nfs4_do_reclaim gets a session reset error, nfs4_recovery_handle_error
    will set the NFS4CLNT_SESSION_SETUP bit, and the state manager should
    continue processing to reset the session.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[move nfs4_proc_destroy_session declaration here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4state.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f9195d7..ea59327 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -210,6 +210,7 @@ extern int nfs4_setup_sequence(struct nfs_client *clp,
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *, int reset);
+extern int nfs4_proc_destroy_session(struct nfs4_session *);
 #else /* CONFIG_NFS_v4_1 */
 static inline int nfs4_setup_sequence(struct nfs_client *clp,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index df5b480..8b7f007 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1042,6 +1042,14 @@ static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_EXPIRED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_start_reclaim_nograce(clp);
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_DEADSESSION:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_SEQ_FALSE_RETRY:
+		case -NFS4ERR_SEQ_MISORDERED:
+			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
 	}
 }
 
@@ -1114,6 +1122,36 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 }
 
 #ifdef CONFIG_NFS_V4_1
+static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
+{
+	switch (err) {
+	case -NFS4ERR_STALE_CLIENTID:
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+	}
+}
+
+static int nfs4_reset_session(struct nfs_client *clp)
+{
+	int status;
+
+	status = nfs4_proc_destroy_session(clp->cl_session);
+	if (status && status != -NFS4ERR_BADSESSION &&
+	    status != -NFS4ERR_DEADSESSION) {
+		nfs4_session_recovery_handle_error(clp, status);
+		goto out;
+	}
+
+	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
+	status = nfs4_proc_create_session(clp, 1);
+	if (status)
+		nfs4_session_recovery_handle_error(clp, status);
+		/* fall through*/
+out:
+	/* Wake up the next rpc task even on error */
+	rpc_wake_up_next(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
+	return status;
+}
 
 static int nfs4_initialize_session(struct nfs_client *clp)
 {
@@ -1131,6 +1169,7 @@ static int nfs4_initialize_session(struct nfs_client *clp)
 	return status;
 }
 #else /* CONFIG_NFS_V4_1 */
+static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_initialize_session(struct nfs_client *clp) { return 0; }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1160,10 +1199,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			if (status != 0)
 				continue;
 		}
-		/* Setup the session */
+		/* Initialize or reset the session */
 		if (nfs4_has_session(clp) &&
 		   test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
-			status = nfs4_initialize_session(clp);
+			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
+				status = nfs4_initialize_session(clp);
+			else
+				status = nfs4_reset_session(clp);
 			if (status) {
 				if (status == -NFS4ERR_STALE_CLIENTID)
 					continue;
@@ -1175,6 +1217,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
 			if (status == -NFS4ERR_STALE_CLIENTID)
 				continue;
+			if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
+				continue;
 			nfs4_state_end_reclaim_reboot(clp);
 			continue;
 		}
@@ -1188,6 +1232,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 					continue;
 				if (status == -NFS4ERR_EXPIRED)
 					continue;
+				if (test_bit(NFS4CLNT_SESSION_SETUP,
+								&clp->cl_state))
+					continue;
 				goto out_error;
 			} else
 				nfs4_state_end_reclaim_nograce(clp);
-- 
1.6.2.1

