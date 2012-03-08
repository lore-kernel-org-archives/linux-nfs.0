Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31504 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757819Ab2CHQEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 11:04:15 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 cleanup DS stateid error handling
Date: Thu,  8 Mar 2012 11:03:53 -0500
Message-Id: <1331222633-2645-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The error handler nfs4_state parameter is never NULL in the pNFS case as
the open_context must carry an nfs_state.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b2d3bb5..768f6f8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -99,16 +99,12 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_BAD_STATEID:
-		if (state != NULL)
-			nfs_remove_bad_delegation(state->inode);
+		nfs_remove_bad_delegation(state->inode);
 	case -NFS4ERR_OPENMODE:
-		if (state == NULL)
-			break;
 		nfs4_schedule_stateid_recovery(mds_server, state);
 		goto wait_on_recovery;
 	case -NFS4ERR_EXPIRED:
-		if (state != NULL)
-			nfs4_schedule_stateid_recovery(mds_server, state);
+		nfs4_schedule_stateid_recovery(mds_server, state);
 		nfs4_schedule_lease_recovery(mds_client);
 		goto wait_on_recovery;
 	/* DS session errors */
@@ -145,7 +141,6 @@ wait_on_recovery:
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
 		rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
 	goto out;
-
 }
 
 /* NFS_PROTO call done callback routines */
-- 
1.7.6.4

