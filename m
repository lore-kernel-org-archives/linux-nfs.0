Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31695 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759790Ab2FGNVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jun 2012 09:21:31 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: prevent hang if EXCHANGEID returns NFS4ERR_DELAY
Date: Thu,  7 Jun 2012 09:21:30 -0400
Message-Id: <1339075290-1180-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If EXCHANGEID returns NFS4ERR_DELAY, the mount will hang as the
statemanager goes into an infinite loop.  Hiting ctrl-c and trying
to remount will then hit the BUG_ON(clp->cl_cons_state != NFS_CS_READY)
in nfs_found_client().

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4state.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index de13309..0cdfccd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1639,7 +1639,7 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 	dprintk("%s: handled error %d for server %s\n", __func__, status,
 			clp->cl_hostname);
-	return 0;
+	return -EAGAIN;
 }
 
 static int nfs4_establish_lease(struct nfs_client *clp)
@@ -1665,8 +1665,11 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	int status;
 
 	status = nfs4_establish_lease(clp);
-	if (status < 0)
+	if (status < 0) {
+		if (status == -EAGAIN)
+			status = 0;
 		return status;
+	}
 	if (test_and_clear_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state))
 		nfs4_state_start_reclaim_nograce(clp);
 	if (!test_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state))
-- 
1.7.2.1

