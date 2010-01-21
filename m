From: andros@netapp.com
Subject: [PATCH 2/2] nfs41: clear NFS4CLNT_RECALL_SLOT bit on session reset
Date: Thu, 21 Jan 2010 14:54:13 -0500
Message-ID: <1264103653-7677-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45558 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab0AUTyT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 14:54:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 069dcb3..294827a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1291,17 +1291,17 @@ static int nfs4_reset_session(struct nfs_client *clp)
 
 	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
 	status = nfs4_proc_create_session(clp);
-	if (status)
+	if (status) {
 		status = nfs4_recovery_handle_error(clp, status);
+		goto out;
+	}
+	/* create_session negotiated new slot table */
+	clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
 
-out:
-	/*
-	 * Let the state manager reestablish state
-	 */
-	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
-	    status == 0)
+	 /* Let the state manager reestablish state */
+	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		nfs41_setup_state_renewal(clp);
-
+out:
 	return status;
 }
 
-- 
1.6.6

