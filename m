From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFSv4.1: Various fixes to the sequence flag error handling
Date: Sat, 20 Feb 2010 18:25:39 -0800
Message-ID: <1266719139.3507.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38743 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756961Ab0BUCZm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Feb 2010 21:25:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Ensure that we change the EXCHANGE_ID verifier (i.e. clp->cl_boot_time)
when we want to reset all state. This is mainly needed when the server
tells us that it is revoking our open or lock stateids.

Handle revoking of recallable state by expiring the delegations.

Handle callback path issues by expiring the delegations and then resetting
the session.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |   57 +++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 45 insertions(+), 12 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c1e2733..97a3b60 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1249,26 +1249,59 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 }
 
 #ifdef CONFIG_NFS_V4_1
+static void nfs4_reset_all_state(struct nfs_client *clp)
+{
+	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
+		clp->cl_boot_time = CURRENT_TIME;
+		nfs4_state_start_reclaim_nograce(clp);
+		nfs4_schedule_state_recovery(clp);
+	}
+}
+
+static void nfs41_handle_server_reboot(struct nfs_client *clp)
+{
+	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
+		nfs4_state_start_reclaim_reboot(clp);
+		nfs4_schedule_state_recovery(clp);
+	}
+}
+
+static void nfs41_handle_state_revoked(struct nfs_client *clp)
+{
+	/* Temporary */
+	nfs4_reset_all_state(clp);
+}
+
+static void nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
+{
+	/* This will need to handle layouts too */
+	nfs_expire_all_delegations(clp);
+}
+
+static void nfs41_handle_cb_path_down(struct nfs_client *clp)
+{
+	nfs_expire_all_delegations(clp);
+	if (test_and_set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
+		nfs4_schedule_state_recovery(clp);
+}
+
 void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 {
 	if (!flags)
 		return;
-	else if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED) {
-		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-		nfs4_state_start_reclaim_reboot(clp);
-		nfs4_schedule_state_recovery(clp);
-	} else if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
+	else if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
+		nfs41_handle_server_reboot(clp);
+	else if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
 			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
 			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
-			    SEQ4_STATUS_RECALLABLE_STATE_REVOKED |
-			    SEQ4_STATUS_LEASE_MOVED)) {
-		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-		nfs4_state_start_reclaim_nograce(clp);
-		nfs4_schedule_state_recovery(clp);
-	} else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
+			    SEQ4_STATUS_LEASE_MOVED))
+		nfs41_handle_state_revoked(clp);
+	else if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
+		nfs41_handle_recallable_state_revoked(clp);
+	else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
 			    SEQ4_STATUS_BACKCHANNEL_FAULT |
 			    SEQ4_STATUS_CB_PATH_DOWN_SESSION))
-		nfs_expire_all_delegations(clp);
+		nfs41_handle_cb_path_down(clp);
 }
 
 static int nfs4_reset_session(struct nfs_client *clp)

