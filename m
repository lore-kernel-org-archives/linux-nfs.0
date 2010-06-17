From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 12/19] SQUASHME: pnfs-submit: get rid of pnfs4_write_done
Date: Thu, 17 Jun 2010 10:50:20 -0400
Message-ID: <1276786220-12641-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43296 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932833Ab0FQOuO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:14 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that it's fully merged into nfs4_write_done

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   59 -----------------------------------------------------
 1 files changed, 0 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7b501ec..5c1e680 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3171,64 +3171,6 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 #ifdef CONFIG_NFS_V4_1
 /*
- * rpc_call_done callback for a write to the MDS or to a filelayout Data Server
- */
-static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
-{
-	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
-	struct nfs_client *client = mds_svr->nfs_client;
-
-	/* restore original count after retry? */
-	if (data->pdata.orig_count) {
-		dprintk("%s: restoring original count %u\n", __func__,
-			data->pdata.orig_count);
-		data->args.count = data->pdata.orig_count;
-	}
-
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
-	/* Is this a DS session */
-	if (data->fldata.ds_nfs_client) {
-		dprintk("%s DS write\n", __func__);
-		client = data->fldata.ds_nfs_client;
-	}
-
-	nfs41_sequence_done(&data->res.seq_res);
-
-	/*
-	* Handle async errors for both data servers and MDS communication.
-	*/
-	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
-	   like in nfs4_write_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
-		nfs_restart_rpc(task, client);
-		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
-		return -EAGAIN;
-	}
-
-	/*
-	 * MDS write: renew lease
-	 * DS write: update lastbyte written
-	 */
-	if (task->tk_status > 0) {
-		if (!data->fldata.ds_nfs_client) {
-			nfs_post_op_update_inode_force_wcc(data->inode,
-							data->res.fattr);
-			renew_lease(mds_svr, data->timestamp);
-		} else {
-			pnfs_update_last_write(NFS_I(data->inode),
-					       data->args.offset,
-					       data->res.count);
-			/* Mark for LAYOUTCOMMIT */
-			pnfs_need_layoutcommit(NFS_I(data->inode),
-					       data->args.context);
-		}
-	}
-	return 0;
-}
-
-/*
  * rpc_call_done callback for a commit to the MDS or to a filelayout Data Server
  */
 static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -6058,7 +6000,6 @@ pnfs_v4_clientops_init(void)
 
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
 	p->write_setup		= pnfs4_proc_write_setup;
-	p->write_done		= pnfs4_write_done;
 	p->commit_setup		= pnfs4_proc_commit_setup;
 	p->commit_done		= pnfs4_commit_done;
 }
-- 
1.6.4.4

