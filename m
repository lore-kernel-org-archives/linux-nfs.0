Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36442 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbHSE40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 00:56:26 -0400
Received: by pawq9 with SMTP id q9so51645776paw.3
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 21:56:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFSv4.1/pnfs: Play safe w.r.t. close() races when return-on-close is set
Date: Tue, 18 Aug 2015 23:56:20 -0500
Message-Id: <1439960180-19450-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1439960180-19450-1-git-send-email-trond.myklebust@primarydata.com>
References: <1439960180-19450-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have an OPEN_DOWNGRADE and CLOSE race with one another, we want
to ensure that the layout is forgotten by the client, so that we
start afresh with a new layoutget.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bda7837dfe6b..9e9f7816cf24 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2661,7 +2661,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			res_stateid = &calldata->res.stateid;
-			if (calldata->arg.fmode == 0 && calldata->roc)
+			if (calldata->roc)
 				pnfs_roc_set_barrier(state->inode,
 						     calldata->roc_barrier);
 			renew_lease(server, calldata->timestamp);
@@ -2735,11 +2735,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_no_action;
 	}
 
-	if (calldata->arg.fmode == 0) {
+	if (calldata->arg.fmode == 0)
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
-		if (calldata->roc)
-			pnfs_roc_get_barrier(inode, &calldata->roc_barrier);
-	}
+	if (calldata->roc)
+		pnfs_roc_get_barrier(inode, &calldata->roc_barrier);
+
 	calldata->arg.share_access =
 		nfs4_map_atomic_open_share(NFS_SERVER(inode),
 				calldata->arg.fmode, 0);
-- 
2.4.3

