From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 1/5] nfs41: Mark stateids in need of reclaim if state manager gets stale clientid
Date: Mon,  7 Dec 2009 00:21:47 -0800
Message-ID: <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759055AbZLGI1o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:44 -0500
In-Reply-To: <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state manager was not marking the stateids as needing to be reclaimed
after reestablishing the clientid.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4state.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d3c9c9e..d741ec6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1256,14 +1256,6 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs_expire_all_delegations(clp);
 }
 
-static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
-{
-	switch (err) {
-	case -NFS4ERR_STALE_CLIENTID:
-		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-	}
-}
-
 static int nfs4_reset_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
@@ -1276,14 +1268,14 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	status = nfs4_proc_destroy_session(clp->cl_session);
 	if (status && status != -NFS4ERR_BADSESSION &&
 	    status != -NFS4ERR_DEADSESSION) {
-		nfs4_session_recovery_handle_error(clp, status);
+		nfs4_recovery_handle_error(clp, status);
 		goto out;
 	}
 
 	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
 	status = nfs4_proc_create_session(clp);
 	if (status)
-		nfs4_session_recovery_handle_error(clp, status);
+		nfs4_recovery_handle_error(clp, status);
 out:
 	/*
 	 * Let the state manager reestablish state
-- 
1.5.4.3

