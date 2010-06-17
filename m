From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 16/19] SQUASHME: pnfs-submit: get rid of pnfs4_commit_done
Date: Thu, 17 Jun 2010 10:51:04 -0400
Message-ID: <1276786264-13029-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49951 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932803Ab0FQOu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:58 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that it's fully merged into nfs4_commit_done

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   36 ------------------------------------
 1 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 95de256..3d15d34 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3169,41 +3169,6 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
-#ifdef CONFIG_NFS_V4_1
-/*
- * rpc_call_done callback for a commit to the MDS or to a filelayout Data Server
- */
-static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
-{
-	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
-	struct nfs_client *client = mds_svr->nfs_client;
-
-	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
-
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
-	/* Is this a DS session */
-	if (data->fldata.ds_nfs_client) {
-		dprintk("%s DS commit\n", __func__);
-		client = data->fldata.ds_nfs_client;
-	}
-
-	nfs41_sequence_done(&data->res.seq_res);
-
-	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
-		nfs_restart_rpc(task, client);
-		return -EAGAIN;
-	}
-
-	/* Update inode if commit to MDS */
-	if (task->tk_status >= 0 && !data->fldata.ds_nfs_client)
-		nfs_refresh_inode(data->inode, data->res.fattr);
-	dprintk("<-- %s\n", __func__);
-	return 0;
-}
-#endif /* CONFIG_NFS_V4_1 */
-
 static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
 	data->timestamp   = jiffies;
@@ -6015,7 +5980,6 @@ pnfs_v4_clientops_init(void)
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
 	p->write_setup		= pnfs4_proc_write_setup;
 	p->commit_setup		= pnfs4_proc_commit_setup;
-	p->commit_done		= pnfs4_commit_done;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.4.4

