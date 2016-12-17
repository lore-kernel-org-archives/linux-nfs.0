Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34050 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752554AbcLQS1S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:18 -0500
Received: by mail-io0-f196.google.com with SMTP id y124so15270761iof.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] NFSv4: Don't discard the attributes returned by asynchronous DELEGRETURN
Date: Sat, 17 Dec 2016 13:27:05 -0500
Message-Id: <20161217182711.10643-4-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-3-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DELEGRETURN will always carry a reference to the inode except when
the latter is being freed, so let's ensure that we always use that
inode information to ensure close-to-open cache consistency, even
when the DELEGRETURN call is asynchronous.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e0816cb7136..58e3d5f627f2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5702,6 +5702,7 @@ static void nfs4_delegreturn_release(void *calldata)
 		if (data->lr.roc)
 			pnfs_roc_release(&data->lr.arg, &data->lr.res,
 					data->res.lr_ret);
+		nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
 		nfs_iput_and_deactive(inode);
 	}
 	kfree(calldata);
@@ -5790,10 +5791,6 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	if (status != 0)
 		goto out;
 	status = data->rpc_status;
-	if (status == 0)
-		nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
-	else
-		nfs_refresh_inode(inode, &data->fattr);
 out:
 	rpc_put_task(task);
 	return status;
-- 
2.9.3

