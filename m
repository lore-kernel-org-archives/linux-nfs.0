Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f51.google.com ([209.85.213.51]:52879 "EHLO
	mail-yw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756331Ab2FYUrZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 16:47:25 -0400
Received: by yhnn12 with SMTP id n12so3812388yhn.10
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2012 13:47:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Handle authentication errors correctly during lease
 reclaim
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Jun 2012 16:47:21 -0400
Message-ID: <20120625204637.1637.14358.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 2a6ee6aa "NFSv4: Clean up the error handling for
nfs4_reclaim_lease" May 25, 2012 appears to have changed the error
value returned by nfs4_reclaim_lease() if rpc.gssd fails to create
a machine credential (either due to a local error or a problem on
the server).

In this case, nfs4_proc_setclientid() returns -EACCES.  Before
2a6ee6aa, nfs4_reclaim_lease() converted this to -EAGAIN.  Now it
returns zero.  The state manager assumes all is well, nfs_client
initialization then proceeds in process context until it oopses while
trying to set up the mount's nfs_server.

Revert nfs4_handle_reclaim_lease_error() to return a non-zero value
in this case.  -EAGAIN was the error returned before 2a6ee6aa.

That prevents the oops, but mount(2) now reports "Resource
unavailable."  Revert the test of cl_machine_cred against NULL so we
report the correct error code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4state.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 706d9ea..1813cee 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1598,7 +1598,8 @@ out:
 /* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
  * on EXCHANGE_ID for v4.1
  */
-static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
+static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status,
+					   struct rpc_cred *cred)
 {
 	switch (status) {
 	case -NFS4ERR_SEQ_MISORDERED:
@@ -1611,10 +1612,11 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		break;
 	case -EACCES:
-		if (clp->cl_machine_cred == NULL)
+		if (clp->cl_machine_cred == cred)
 			return -EACCES;
 		/* Handle case where the user hasn't set up machine creds */
 		nfs4_clear_machine_cred(clp);
+		return -EAGAIN;
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
 	case -EAGAIN:
@@ -1655,7 +1657,7 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	status = ops->establish_clid(clp, cred);
 	put_rpccred(cred);
 	if (status != 0)
-		return nfs4_handle_reclaim_lease_error(clp, status);
+		return nfs4_handle_reclaim_lease_error(clp, status, cred);
 	return 0;
 }
 
@@ -1778,7 +1780,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 	if (status) {
 		dprintk("%s: session reset failed with status %d for server %s!\n",
 			__func__, status, clp->cl_hostname);
-		status = nfs4_handle_reclaim_lease_error(clp, status);
+		status = nfs4_handle_reclaim_lease_error(clp, status, cred);
 		goto out;
 	}
 	nfs41_finish_session_reset(clp);

