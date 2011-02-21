Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47247 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab1BUWbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:31:13 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 9/9] pnfs: improve nfs4_layoutget_done debug printouts
Date: Mon, 21 Feb 2011 14:31:08 -0800
Message-Id: <1298327468-9612-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 10d46c4..785c460 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5446,7 +5446,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 
-	dprintk("--> %s\n", __func__);
+	dprintk("--> %s: tk_status=%d\n", __func__, task->tk_status);
 
 	if (!nfs4_sequence_done(task, &lgp->res.seq_res)) {
 		/* layout code relies on fact that in this case
@@ -5467,6 +5467,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
 			struct inode *ino = lgp->args.inode;
 
+			dprintk("<-- %s retrying\n", __func__);
 			spin_lock(&ino->i_lock);
 			atomic_dec(&NFS_I(ino)->layout->plh_outstanding);
 			spin_unlock(&ino->i_lock);
-- 
1.7.3.4

