From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 14/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 2
Date: Thu, 17 Jun 2010 10:50:42 -0400
Message-ID: <1276786242-12946-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42207 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932803Ab0FQOug (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:36 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Possibly override nfs_client with data server's.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b88cf2..2782900 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3278,16 +3278,24 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
+	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_client *client = server->nfs_client;
 	
 #ifdef CONFIG_NFS_V4_1
 	if (data->pdata.pnfsflags & PNFS_NO_RPC)
 		return 0;
+
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS commit\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
 #endif /* CONFIG_NFS_V4_1 */
 
-	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
+	nfs4_sequence_done(server, &data->res.seq_res,
 			   task->tk_status);
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+	if (nfs4_async_handle_error(task, server, NULL, client) == -EAGAIN) {
+		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
 	nfs_refresh_inode(inode, data->res.fattr);
-- 
1.6.4.4

