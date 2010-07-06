From: andros@netapp.com
Subject: [PATCH 4/5] SQUASHME pnfs-submit: set layoutcommit status after async error handler
Date: Tue,  6 Jul 2010 17:17:01 -0400
Message-ID: <1278451022-2889-5-git-send-email-andros@netapp.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
 <1278451022-2889-2-git-send-email-andros@netapp.com>
 <1278451022-2889-3-git-send-email-andros@netapp.com>
 <1278451022-2889-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab0GFURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:14 -0400
In-Reply-To: <1278451022-2889-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6283996..36de1b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5549,14 +5549,14 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
 		(struct pnfs_layoutcommit_data *)calldata;
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
-	data->status = task->tk_status;
-
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
 
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
+
+	data->status = task->tk_status;
 }
 
 static void pnfs_layoutcommit_release(void *lcdata)
-- 
1.6.6

