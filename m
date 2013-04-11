Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:7381 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935176Ab3DKN2w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Apr 2013 09:28:52 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4 release the sequence id in the return on close case
Date: Thu, 11 Apr 2013 09:28:45 -0400
Message-Id: <1365686925-1112-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ce87287..36df296 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2276,8 +2276,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
 		if (calldata->roc &&
-		    pnfs_roc_drain(inode, &calldata->roc_barrier, task))
+		    pnfs_roc_drain(inode, &calldata->roc_barrier, task)) {
+			nfs_release_seqid(calldata->arg.seqid);
 			goto out_wait;
+		    }
 	}
 
 	nfs_fattr_init(calldata->res.fattr);
-- 
1.7.10.2 (Apple Git-33)

