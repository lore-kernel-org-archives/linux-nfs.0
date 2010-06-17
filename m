From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/19] SQUASHME: pnfs-submit: get rid of pnfs4_read_done
Date: Thu, 17 Jun 2010 10:49:26 -0400
Message-ID: <1276786166-12421-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21541 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756240Ab0FQOtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:49:20 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that its funcitonality if fully merged into nfs4_read_done

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   43 -------------------------------------------
 1 files changed, 0 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e8b0f33..6a0ab6c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3171,48 +3171,6 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 #ifdef CONFIG_NFS_V4_1
 /*
- * rpc_call_done callback for a read to the MDS or to a filelayout Data Server
- */
-static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
-{
-	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
-	struct nfs_client *client = mds_svr->nfs_client;
-
-	dprintk("--> %s\n", __func__);
-
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
-	/* Is this a DS session */
-	if (data->fldata.ds_nfs_client) {
-		dprintk("%s DS read\n", __func__);
-		client = data->fldata.ds_nfs_client;
-	}
-
-	nfs41_sequence_done(&data->res.seq_res);
-
-	/*
-	 * Handle async errors for both data servers and MDS communication.
-	 */
-
-	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
-	   like in nfs4_read_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
-		nfs_restart_rpc(task, client);
-		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
-		return -EAGAIN;
-	}
-
-	/* Only renew lease if this was a read call to MDS */
-	if (task->tk_status > 0 && !data->fldata.ds_nfs_client)
-		renew_lease(mds_svr, data->timestamp);
-
-	dprintk("<-- %s\n", __func__);
-
-	return 0;
-}
-
-/*
  * rpc_call_done callback for a write to the MDS or to a filelayout Data Server
  */
 static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -6063,7 +6021,6 @@ pnfs_v4_clientops_init(void)
 	struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
 
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
-	p->read_done		= pnfs4_read_done;
 	p->write_setup		= pnfs4_proc_write_setup;
 	p->write_done		= pnfs4_write_done;
 	p->commit_setup		= pnfs4_proc_commit_setup;
-- 
1.6.4.4

