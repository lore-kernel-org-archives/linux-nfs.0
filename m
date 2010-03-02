From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/7] nfsd4: remove unnecessary lease-setting function
Date: Tue,  2 Mar 2010 18:12:50 -0500
Message-ID: <1267571573-11844-5-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is another layer of indirection that doesn't really buy us
anything.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   12 ------------
 fs/nfsd/nfsctl.c    |    2 +-
 2 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eb8d124..4471046 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4115,15 +4115,3 @@ nfs4_recoverydir(void)
 {
 	return user_recovery_dirname;
 }
-
-/*
- * Called when leasetime is changed.
- *
- * nfsd4_lease is protected by nfsd_mutex since it's only really accessed
- * when nfsd is starting
- */
-void
-nfs4_reset_lease(time_t leasetime)
-{
-	nfsd4_lease = leasetime;
-}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f1ee549..7f70704 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1219,7 +1219,7 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 			return rv;
 		if (lease < 10 || lease > 3600)
 			return -EINVAL;
-		nfs4_reset_lease(lease);
+		nfsd4_lease = lease;
 	}
 
 	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n", nfsd4_lease);
-- 
1.6.3.3

