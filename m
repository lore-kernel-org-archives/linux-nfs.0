Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab1CATZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 14:25:54 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH pnfs-submit-wave3 update 3/5] wave3: document that we are relying on nfs_initiate_read not failing
Date: Tue,  1 Mar 2011 14:25:32 -0500
Message-Id: <1299007534-4105-4-git-send-email-andros@netapp.com>
In-Reply-To: <1299007534-4105-3-git-send-email-andros@netapp.com>
References: <1299007534-4105-1-git-send-email-andros@netapp.com>
 <1299007534-4105-2-git-send-email-andros@netapp.com>
 <1299007534-4105-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

With the curent code, rpc_run_task(), and thus nfs_initiate_read(),
can not fail if the task is pre-initialized.  Trond asked that
we document this in case of future code changes with a BUG_ON.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 45b650a..e76c582 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -203,6 +203,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
+	int status;
 
 	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
 		__func__, data->inode->i_ino,
@@ -231,8 +232,9 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
-			  &filelayout_read_call_ops);
+	status = nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
+				   &filelayout_read_call_ops);
+	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
 
-- 
1.6.2.5

