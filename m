Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757705Ab2EXQ05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 12:26:57 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] nfs41: Use BIND_CONN_TO_SESSION for CB_PATH_DOWN*
Date: Thu, 24 May 2012 12:26:37 -0400
Message-Id: <1337876797-17706-2-git-send-email-dros@netapp.com>
In-Reply-To: <1337876797-17706-1-git-send-email-dros@netapp.com>
References: <1337876797-17706-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state manager can handle SEQ4_STATUS_CB_PATH_DOWN* flags with a
BIND_CONN_TO_SESSION instead of destroying the session and creating a new one.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4state.c |   26 +++++++++++++++++++++-----
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ad90bc7..9feff0f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -24,6 +24,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
+	NFS4CLNT_BIND_CONN_TO_SESSION,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7f0fcfc..40558ca 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1639,13 +1639,20 @@ static void nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
 	nfs_expire_all_delegations(clp);
 }
 
-static void nfs41_handle_cb_path_down(struct nfs_client *clp)
+static void nfs41_handle_backchannel_fault(struct nfs_client *clp)
 {
 	nfs_expire_all_delegations(clp);
 	if (test_and_set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) == 0)
 		nfs4_schedule_state_manager(clp);
 }
 
+static void nfs41_handle_cb_path_down(struct nfs_client *clp)
+{
+	if (test_and_set_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
+		&clp->cl_state) == 0)
+		nfs4_schedule_state_manager(clp);
+}
+
 void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 {
 	if (!flags)
@@ -1659,9 +1666,10 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs41_handle_state_revoked(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
-	if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
-			    SEQ4_STATUS_BACKCHANNEL_FAULT |
-			    SEQ4_STATUS_CB_PATH_DOWN_SESSION))
+	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)
+		nfs41_handle_backchannel_fault(clp);
+	else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
+				SEQ4_STATUS_CB_PATH_DOWN_SESSION))
 		nfs41_handle_cb_path_down(clp);
 }
 
@@ -1721,7 +1729,6 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 	nfs4_end_drain_session(clp);
 	return 0;
 }
-
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
@@ -1803,6 +1810,15 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 		}
 
+		/* Send BIND_CONN_TO_SESSION */
+		if (clp->cl_mvops->minor_version == 1 &&
+		    test_and_clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
+				&clp->cl_state) && nfs4_has_session(clp)) {
+			status = nfs4_proc_bind_conn_to_session(clp);
+			if (status < 0)
+				goto out_error;
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
-- 
1.7.4.4

