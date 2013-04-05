Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61793 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162690Ab3DEVQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 17:16:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/3] NFSv4: Don't clear the machine cred when client establish returns EACCES
Date: Fri,  5 Apr 2013 17:16:36 -0400
Message-Id: <1365196596-25439-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365196596-25439-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1365196596-25439-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365196596-25439-2-git-send-email-Trond.Myklebust@netapp.com>
 <1365196596-25439-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The expected behaviour is that the client will decide at mount time
whether or not to use a krb5i machine cred, or AUTH_NULL.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4state.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 209df69..c546009 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -154,18 +154,6 @@ struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
-static void nfs4_clear_machine_cred(struct nfs_client *clp)
-{
-	struct rpc_cred *cred;
-
-	spin_lock(&clp->cl_lock);
-	cred = clp->cl_machine_cred;
-	clp->cl_machine_cred = NULL;
-	spin_unlock(&clp->cl_lock);
-	if (cred != NULL)
-		put_rpccred(cred);
-}
-
 static struct rpc_cred *
 nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 {
@@ -1768,10 +1756,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		return -EPERM;
 	case -EACCES:
-		if (clp->cl_machine_cred == NULL)
-			return -EACCES;
-		/* Handle case where the user hasn't set up machine creds */
-		nfs4_clear_machine_cred(clp);
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
 	case -EAGAIN:
-- 
1.8.1.4

