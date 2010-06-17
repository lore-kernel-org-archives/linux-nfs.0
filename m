From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-submit: delete unused nfs_validate_delegation_stateid
Date: Thu, 17 Jun 2010 10:59:20 -0400
Message-ID: <1276786760-14237-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44375 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755793Ab0FQO7P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:59:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 4f0e74b..2437e3d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -67,15 +67,6 @@ out:
 	return res->status;
 }
 
-static int (*nfs_validate_delegation_stateid(struct nfs_client *clp))(struct nfs_delegation *, const nfs4_stateid *)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_minorversion > 0)
-		return nfs41_validate_delegation_stateid;
-#endif
-	return nfs4_validate_delegation_stateid;
-}
-
 __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 {
 	struct nfs_client *clp;
-- 
1.6.4.4

