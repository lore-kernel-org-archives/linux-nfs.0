Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39036 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965048Ab2CVTTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:19:45 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 08/11] NFSv4.1 wake up all tasks on un-connected DS slot table waitq
Date: Thu, 22 Mar 2012 15:19:36 -0400
Message-Id: <1332443979-2302-9-git-send-email-andros@netapp.com>
In-Reply-To: <1332443979-2302-1-git-send-email-andros@netapp.com>
References: <1332443979-2302-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The DS has a connection error (invalid deviceid). Drain the fore channel
slot table waitq.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index faba987..ce8734d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -120,6 +120,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 {
 	struct nfs_server *mds_server = NFS_SERVER(state->inode);
 	struct nfs_client *mds_client = mds_server->nfs_client;
+	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -168,6 +169,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		filelayout_mark_devid_invalid(devid);
+		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
@@ -192,8 +194,6 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
 	int err;
 
-	dprintk("%s DS read\n", __func__);
-
 	err = filelayout_async_handle_error(task, data->args.context->state,
 					  data->ds_clp, devid);
 
-- 
1.7.6.4

