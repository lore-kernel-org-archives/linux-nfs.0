Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760520Ab0JGNLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 09:11:00 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97DAgWB017616
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 06:10:46 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pnfs_submit: simplify nfs4_callback_layoutrecall
Date: Wed,  6 Oct 2010 16:35:16 -0400
Message-Id: <1286397317-17881-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The code in the two branches was identical, so remove the if statement.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |   29 ++++++++++-------------------
 1 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa0ca0c..5a996b5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -370,25 +370,16 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 		/* the callback must come from the MDS personality */
 		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
 			goto loop;
-		if (args->cbl_recall_type == RETURN_FILE) {
-			inode = nfs_layoutrecall_find_inode(clp, args);
-			if (inode != NULL) {
-				status = pnfs_async_return_layout(clp, inode,
-								  args);
-				if (status)
-					res = cpu_to_be32(NFS4ERR_DELAY);
-				iput(inode);
-			}
-		} else { /* _ALL or _FSID */
-			/* we need the inode to get the nfs_server struct */
-			inode = nfs_layoutrecall_find_inode(clp, args);
-			if (!inode)
-				goto loop;
-			status = pnfs_async_return_layout(clp, inode, args);
-			if (status)
-				res = cpu_to_be32(NFS4ERR_DELAY);
-			iput(inode);
-		}
+		/* In the _ALL or _FSID case, we need the inode to get
+		 * the nfs_server struct.
+		 */
+		inode = nfs_layoutrecall_find_inode(clp, args);
+		if (!inode)
+			goto loop;
+		status = pnfs_async_return_layout(clp, inode, args);
+		if (status)
+			res = cpu_to_be32(NFS4ERR_DELAY);
+		iput(inode);
 loop:
 		clp = nfs_find_client_next(prev);
 		nfs_put_client(prev);
-- 
1.7.2.1

