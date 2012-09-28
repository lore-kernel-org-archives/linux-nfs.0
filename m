Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57175 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031878Ab2I1VFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Sep 2012 17:05:21 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.0 reclaim reboot state when re-establishing clientid
Date: Fri, 28 Sep 2012 17:05:09 -0400
Message-Id: <1348866309-2049-2-git-send-email-andros@netapp.com>
In-Reply-To: <1348866309-2049-1-git-send-email-andros@netapp.com>
References: <1348866309-2049-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We should always reclaim state when the lease and therefore the clientid
is expired.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a5331ec..134323a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1600,8 +1600,8 @@ out:
 	return nfs4_recovery_handle_error(clp, status);
 }
 
-/* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
- * on EXCHANGE_ID for v4.1
+/* Set NFS4CLNT_LEASE_EXPIRED and reclaim reboot state for all v4.0 errors
+ * and for recoverable errors on EXCHANGE_ID for v4.1
  */
 static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 {
@@ -1647,6 +1647,8 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		return status;
 	}
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+	nfs4_state_clear_reclaim_reboot(clp);
+	nfs4_state_start_reclaim_reboot(clp);
 	dprintk("%s: handled error %d for server %s\n", __func__, status,
 			clp->cl_hostname);
 	return 0;
-- 
1.7.7.6

