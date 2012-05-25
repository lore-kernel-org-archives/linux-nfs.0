Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726Ab2EYWDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 18:03:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/8] NFSv4: Clean up the error handling for nfs4_reclaim_lease
Date: Fri, 25 May 2012 18:03:16 -0400
Message-Id: <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to consolidate the error handling for nfs4_reclaim_lease into
a single function instead of doing a bit here, and a bit there...

Also ensure that NFS4CLNT_PURGE_STATE handles errors correctly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |   99 ++++++++++++++++++++++++++-------------------------
 1 files changed, 50 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 03fa802..758b9a8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1574,26 +1574,57 @@ out:
 	return nfs4_recovery_handle_error(clp, status);
 }
 
+/* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
+ * on EXCHANGE_ID for v4.1
+ */
+static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
+{
+	switch (status) {
+	case -NFS4ERR_CLID_INUSE:
+	case -NFS4ERR_STALE_CLIENTID:
+		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		break;
+	case -EACCES:
+		if (clp->cl_machine_cred == NULL)
+			return -EACCES;
+		/* Handle case where the user hasn't set up machine creds */
+		nfs4_clear_machine_cred(clp);
+	case -NFS4ERR_DELAY:
+	case -ETIMEDOUT:
+	case -EAGAIN:
+		ssleep(1);
+		break;
+
+	case -NFS4ERR_MINOR_VERS_MISMATCH:
+		if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
+			nfs_mark_client_ready(clp, -EPROTONOSUPPORT);
+		return -EPROTONOSUPPORT;
+	case -EKEYEXPIRED:
+		nfs4_warn_keyexpired(clp->cl_hostname);
+	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
+				 * in nfs4_exchange_id */
+	default:
+		return status;
+	}
+	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+	return 0;
+}
+
 static int nfs4_reclaim_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
 	const struct nfs4_state_recovery_ops *ops =
 		clp->cl_mvops->reboot_recovery_ops;
-	int status = -ENOENT;
+	int status;
 
 	cred = ops->get_clid_cred(clp);
-	if (cred != NULL) {
-		status = ops->establish_clid(clp, cred);
-		put_rpccred(cred);
-		/* Handle case where the user hasn't set up machine creds */
-		if (status == -EACCES && cred == clp->cl_machine_cred) {
-			nfs4_clear_machine_cred(clp);
-			status = -EAGAIN;
-		}
-		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
-			status = -EPROTONOSUPPORT;
-	}
-	return status;
+	if (cred == NULL)
+		return -ENOENT;
+	status = ops->establish_clid(clp, cred);
+	put_rpccred(cred);
+	if (status != 0)
+		return nfs4_handle_reclaim_lease_error(clp, status);
+	return 0;
 }
 
 #ifdef CONFIG_NFS_V4_1
@@ -1751,32 +1782,6 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-/* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
- * on EXCHANGE_ID for v4.1
- */
-static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
-{
-	switch (status) {
-	case -NFS4ERR_CLID_INUSE:
-	case -NFS4ERR_STALE_CLIENTID:
-		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-		break;
-	case -NFS4ERR_DELAY:
-	case -ETIMEDOUT:
-	case -EAGAIN:
-		ssleep(1);
-		break;
-
-	case -EKEYEXPIRED:
-		nfs4_warn_keyexpired(clp->cl_hostname);
-	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
-				 * in nfs4_exchange_id */
-	default:
-		return;
-	}
-	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-}
-
 static void nfs4_state_manager(struct nfs_client *clp)
 {
 	int status = 0;
@@ -1784,7 +1789,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	/* Ensure exclusive access to NFSv4 state */
 	do {
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
-			nfs4_reclaim_lease(clp);
+			status = nfs4_reclaim_lease(clp);
+			if (status < 0)
+				goto out_error;
 			clear_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 		}
@@ -1792,16 +1799,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);
-			if (status) {
-				nfs4_set_lease_expired(clp, status);
-				if (test_bit(NFS4CLNT_LEASE_EXPIRED,
-							&clp->cl_state))
-					continue;
-				if (clp->cl_cons_state ==
-							NFS_CS_SESSION_INITING)
-					nfs_mark_client_ready(clp, status);
+			if (status < 0)
 				goto out_error;
-			}
+			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
+				continue;
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 
 			if (test_and_clear_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH,
-- 
1.7.7.6

