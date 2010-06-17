From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 10/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 3
Date: Thu, 17 Jun 2010 10:49:58 -0400
Message-ID: <1276786198-12555-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3767 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760185Ab0FQOtw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:49:52 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Possibly override data server nfs_client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fd2b588..60898f6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3271,6 +3271,8 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_client *client = server->nfs_client;
 
 #ifdef CONFIG_NFS_V4_1
 	/* restore original count after retry? */
@@ -3282,17 +3284,23 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 
 	if (data->pdata.pnfsflags & PNFS_NO_RPC)
 		return 0;
+
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS write\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
 #endif /* CONFIG_NFS_V4_1 */
 
-	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
+	nfs4_sequence_done(server, &data->res.seq_res,
 			   task->tk_status);
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+	if (nfs4_async_handle_error(task, server, data->args.context->state, client) == -EAGAIN) {
+		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
 	if (task->tk_status >= 0) {
-		renew_lease(NFS_SERVER(inode), data->timestamp);
+		renew_lease(server, data->timestamp);
 		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
 	}
 	return 0;
-- 
1.6.4.4

