Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183Ab2JBAmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 20:42:38 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] NFSv4.0 reclaim reboot state when re-establishing clientid
Date: Mon,  1 Oct 2012 20:42:32 -0400
Message-Id: <1349138552-2533-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We should reclaim reboot state when the clientid is stale.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5c42866..45c25b6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1679,8 +1679,8 @@ out:
 	return nfs4_recovery_handle_error(clp, status);
 }
 
-/* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
- * on EXCHANGE_ID for v4.1
+/* Set NFS4CLNT_LEASE_EXPIRED and reclaim reboot state for all v4.0 errors
+ * and for recoverable errors on EXCHANGE_ID for v4.1
  */
 static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 {
@@ -1690,8 +1690,12 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 			return -ESERVERFAULT;
 		/* Lease confirmation error: retry after purging the lease */
 		ssleep(1);
+		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		break;
 	case -NFS4ERR_STALE_CLIENTID:
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		nfs4_state_clear_reclaim_reboot(clp);
+		nfs4_state_start_reclaim_reboot(clp);
 		break;
 	case -NFS4ERR_CLID_INUSE:
 		pr_err("NFS: Server %s reports our clientid is in use\n",
-- 
1.7.7.6

