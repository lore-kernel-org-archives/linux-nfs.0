From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/69] NFSv4: Don't tell server we rebooted when not
 necessary
Date: Tue, 23 Dec 2008 18:02:12 -0500
Message-ID: <20081223230212.13743.41401.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbYLWXXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:44 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsY006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of doing a full setclientid, try doing a RENEW call first.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3cc88a5..a780518 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1059,19 +1059,19 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	struct rpc_cred *cred;
 	int status = -NFS4ERR_EXPIRED;
 
-	/* Are there any open files on this volume? */
+	/* Is the client already known to have an expired lease? */
+	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
+		return 0;
 	cred = nfs4_get_renew_cred(clp);
-	if (cred != NULL) {
-		/* Yes there are: try to renew the old lease */
-		status = nfs4_proc_renew(clp, cred);
-		put_rpccred(cred);
-		nfs4_recovery_handle_error(clp, status);
-		return status;
+	if (cred == NULL) {
+		cred = nfs4_get_setclientid_cred(clp);
+		if (cred == NULL)
+			goto out;
 	}
-
-	/* "reboot" to ensure we clear all state on the server */
-	clp->cl_boot_time = CURRENT_TIME;
-	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+	status = nfs4_proc_renew(clp, cred);
+	put_rpccred(cred);
+out:
+	nfs4_recovery_handle_error(clp, status);
 	return status;
 }
 

