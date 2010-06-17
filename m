From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 05/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 2
Date: Thu, 17 Jun 2010 10:49:04 -0400
Message-ID: <1276786144-12248-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29086 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760144Ab0FQOs6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:48:58 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Possibly override nfs_client with ds_nfs_client

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a6bebbf..77b7182 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3141,18 +3141,25 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_client *client = server->nfs_client;
 
 	dprintk("--> %s\n", __func__);
 
 #ifdef CONFIG_NFS_V4_1
 	if (data->pdata.pnfsflags & PNFS_NO_RPC)
 		return 0;
+
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS read\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
 #endif /* CONFIG_NFS_V4_1 */
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
-	if (nfs4_async_handle_error(task, server, data->args.context->state, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, server->nfs_client);
+	if (nfs4_async_handle_error(task, server, data->args.context->state, client) == -EAGAIN) {
+		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
 
-- 
1.6.4.4

