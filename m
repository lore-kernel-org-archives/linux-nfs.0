Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab1LAVme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 16:42:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Don't error if we handled it in nfs4_recovery_handle_error
Date: Thu,  1 Dec 2011 16:42:22 -0500
Message-Id: <1322775743-14870-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we handled an error condition, then nfs4_recovery_handle_error should
return '0' so that the state recovery thread can continue.
Also ensure that nfs4_check_lease() continues to abort if we haven't got
any credentials by having it return ENOKEY (which is not handled).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..1da95e3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1350,12 +1350,14 @@ static void nfs4_warn_keyexpired(const char *s)
 static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 {
 	switch (error) {
+		case 0:
+			break;
 		case -NFS4ERR_CB_PATH_DOWN:
 			nfs_handle_cb_pathdown(clp);
-			return 0;
+			break;
 		case -NFS4ERR_NO_GRACE:
 			nfs4_state_end_reclaim_reboot(clp);
-			return 0;
+			break;
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
@@ -1375,13 +1377,15 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_SEQ_MISORDERED:
 			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 			/* Zero session reset errors */
-			return 0;
+			break;
 		case -EKEYEXPIRED:
 			/* Nothing we can do */
 			nfs4_warn_keyexpired(clp->cl_hostname);
-			return 0;
+			break;
+		default:
+			return error;
 	}
-	return error;
+	return 0;
 }
 
 static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
@@ -1428,7 +1432,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	struct rpc_cred *cred;
 	const struct nfs4_state_maintenance_ops *ops =
 		clp->cl_mvops->state_renewal_ops;
-	int status = -NFS4ERR_EXPIRED;
+	int status;
 
 	/* Is the client already known to have an expired lease? */
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
@@ -1438,6 +1442,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	spin_unlock(&clp->cl_lock);
 	if (cred == NULL) {
 		cred = nfs4_get_setclientid_cred(clp);
+		status = -ENOKEY;
 		if (cred == NULL)
 			goto out;
 	}
@@ -1662,10 +1667,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
 			status = nfs4_check_lease(clp);
+			if (status < 0)
+				goto out_error;
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 				continue;
-			if (status < 0 && status != -NFS4ERR_CB_PATH_DOWN)
-				goto out_error;
 		}
 
 		/* Initialize or reset the session */
-- 
1.7.7.3

