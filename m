Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757368Ab2DTSgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:48 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 10/28] NFS: remove unnecessary casts of void pointers in nfs4filelayout.c
Date: Fri, 20 Apr 2012 14:35:52 -0400
Message-Id: <1334946970-27470-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index adbadcb..31afd81 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -191,7 +191,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
  */
 static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
-	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+	struct nfs_read_data *rdata = data;
 
 	rdata->read_done_cb = filelayout_read_done_cb;
 
@@ -205,7 +205,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 
 static void filelayout_read_call_done(struct rpc_task *task, void *data)
 {
-	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+	struct nfs_read_data *rdata = data;
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
@@ -215,14 +215,14 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 
 static void filelayout_read_count_stats(struct rpc_task *task, void *data)
 {
-	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+	struct nfs_read_data *rdata = data;
 
 	rpc_count_iostats(task, NFS_SERVER(rdata->inode)->client->cl_metrics);
 }
 
 static void filelayout_read_release(void *data)
 {
-	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+	struct nfs_read_data *rdata = data;
 
 	put_lseg(rdata->lseg);
 	rdata->mds_ops->rpc_release(data);
@@ -282,7 +282,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
-	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+	struct nfs_write_data *wdata = data;
 
 	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 				&wdata->args.seq_args, &wdata->res.seq_res,
@@ -294,7 +294,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 
 static void filelayout_write_call_done(struct rpc_task *task, void *data)
 {
-	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+	struct nfs_write_data *wdata = data;
 
 	/* Note this may cause RPC to be resent */
 	wdata->mds_ops->rpc_call_done(task, data);
@@ -302,14 +302,14 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 
 static void filelayout_write_count_stats(struct rpc_task *task, void *data)
 {
-	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+	struct nfs_write_data *wdata = data;
 
 	rpc_count_iostats(task, NFS_SERVER(wdata->inode)->client->cl_metrics);
 }
 
 static void filelayout_write_release(void *data)
 {
-	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+	struct nfs_write_data *wdata = data;
 
 	put_lseg(wdata->lseg);
 	wdata->mds_ops->rpc_release(data);
-- 
1.7.2.1

