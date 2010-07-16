From: andros@netapp.com
Subject: [PATCH 1/1] SQUASHME pnfs-submit pnfs operations use new nfs4_sequence_done
Date: Fri, 16 Jul 2010 11:56:37 -0400
Message-ID: <1279295797-4113-2-git-send-email-andros@netapp.com>
References: <1279295797-4113-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965898Ab0GPP5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 11:57:13 -0400
In-Reply-To: <1279295797-4113-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5779a1..17b0c31 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5448,7 +5448,7 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s\n", __func__);
 
-	nfs4_sequence_done(server, &lgp->res.seq_res, task->tk_status);
+	nfs4_sequence_done(task, &lgp->res.seq_res);
 
 	if (RPC_ASSASSINATED(task))
 		return;
@@ -5558,7 +5558,7 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
 		(struct pnfs_layoutcommit_data *)calldata;
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
-	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+	nfs4_sequence_done(task, &data->res.seq_res);
 	if (RPC_ASSASSINATED(task))
 		return;
 
@@ -5666,7 +5666,7 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s\n", __func__);
 
-	nfs4_sequence_done(server, &lrp->res.seq_res, task->tk_status);
+	nfs4_sequence_done(task, &lrp->res.seq_res);
 	if (RPC_ASSASSINATED(task))
 		return;
 
-- 
1.6.6

