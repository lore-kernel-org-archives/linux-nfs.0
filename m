From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/4] pnfs-submit: Remove pnfs_call_done and friends
Date: Sun, 13 Jun 2010 16:18:41 -0400
Message-ID: <1276460322-13873-4-git-send-email-iisaman@netapp.com>
References: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
 <1276460322-13873-2-git-send-email-iisaman@netapp.com>
 <1276460322-13873-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24319 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675Ab0FMUSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:18:52 -0400
Received: from localhost.localdomain (kellyv2-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DKIkfe012997
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 13:18:49 -0700 (PDT)
In-Reply-To: <1276460322-13873-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Filelayout isn't using it, so rip it all out.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |  109 ---------------------------------------------
 include/linux/nfs4_pnfs.h |    9 ----
 2 files changed, 0 insertions(+), 118 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 89c788d..7795e3e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1398,56 +1398,6 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pnfs_set_pg_test(inode, pgio);
 }
 
-static int
-pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
-{
-	put_lseg(pdata->lseg);
-	pdata->lseg = NULL;
-	pdata->call_ops->rpc_call_done(task, data);
-	if (pdata->pnfs_error == -EAGAIN || task->tk_status == -EAGAIN)
-		return -EAGAIN;
-	/*
-	 * just restore original rpc call ops
-	 * rpc_release will be called later by the rpc scheduling layer.
-	 */
-	task->tk_ops = pdata->call_ops;
-	return 0;
-}
-
-/* Post-write completion function
- * Invoked by all layout drivers when write_pagelist is done.
- */
-static void
-pnfs_write_retry(struct work_struct *work)
-{
-	struct rpc_task *task;
-	struct nfs_write_data *wdata;
-	struct nfs4_pnfs_layout_segment range;
-
-	dprintk("%s enter\n", __func__);
-	task = container_of(work, struct rpc_task, u.tk_work);
-	wdata = container_of(task, struct nfs_write_data, task);
-	range.iomode = IOMODE_RW;
-	range.offset = wdata->args.offset;
-	range.length = wdata->args.count;
-	_pnfs_return_layout(wdata->inode, &range, NULL, RETURN_FILE, true);
-	pnfs_initiate_write(wdata, NFS_CLIENT(wdata->inode),
-			    wdata->pdata.call_ops, wdata->pdata.how);
-}
-
-static void
-pnfs_writeback_done(struct nfs_write_data *data)
-{
-	struct pnfs_call_data *pdata = &data->pdata;
-
-	dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
-
-	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
-		INIT_WORK(&data->task.u.tk_work, pnfs_write_retry);
-		queue_work(nfsiod_workqueue, &data->task.u.tk_work);
-	}
-}
-
 /*
  * Call the appropriate parallel I/O subsystem write function.
  * If no I/O device driver exists, or one does match the returned
@@ -1506,40 +1456,6 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 	return trypnfs;
 }
 
-/* Post-read completion function.  Invoked by all layout drivers when
- * read_pagelist is done
- */
-static void
-pnfs_read_retry(struct work_struct *work)
-{
-	struct rpc_task *task;
-	struct nfs_read_data *rdata;
-	struct nfs4_pnfs_layout_segment range;
-
-	dprintk("%s enter\n", __func__);
-	task = container_of(work, struct rpc_task, u.tk_work);
-	rdata = container_of(task, struct nfs_read_data, task);
-	range.iomode = IOMODE_RW;
-	range.offset = rdata->args.offset;
-	range.length = rdata->args.count;
-	_pnfs_return_layout(rdata->inode, &range, NULL, RETURN_FILE, true);
-	pnfs_initiate_read(rdata, NFS_CLIENT(rdata->inode),
-			   rdata->pdata.call_ops);
-}
-
-static void
-pnfs_read_done(struct nfs_read_data *data)
-{
-	struct pnfs_call_data *pdata = &data->pdata;
-
-	dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
-
-	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
-		INIT_WORK(&data->task.u.tk_work, pnfs_read_retry);
-		queue_work(nfsiod_workqueue, &data->task.u.tk_work);
-	}
-}
-
 /*
  * Call the appropriate parallel I/O subsystem read function.
  * If no I/O device driver exists, or one does match the returned
@@ -1623,28 +1539,6 @@ _pnfs_try_to_commit(struct nfs_write_data *data,
 	return pnfs_commit(data, how);
 }
 
-/* pNFS Commit callback function for all layout drivers */
-static void
-pnfs_commit_done(struct nfs_write_data *data)
-{
-	struct pnfs_call_data *pdata = &data->pdata;
-
-	dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
-
-	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
-		struct nfs4_pnfs_layout_segment range = {
-			.iomode = IOMODE_RW,
-			.offset = data->args.offset,
-			.length = data->args.count,
-		};
-		dprintk("%s: retrying\n", __func__);
-		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
-				    true);
-		pnfs_initiate_commit(data, NFS_CLIENT(data->inode),
-				     pdata->call_ops, pdata->how, 1);
-	}
-}
-
 static enum pnfs_try_status
 pnfs_commit(struct nfs_write_data *data, int sync)
 {
@@ -1796,9 +1690,6 @@ out_free:
  */
 struct pnfs_client_operations pnfs_ops = {
 	.nfs_getdeviceinfo = nfs4_pnfs_getdeviceinfo,
-	.nfs_readlist_complete = pnfs_read_done,
-	.nfs_writelist_complete = pnfs_writeback_done,
-	.nfs_commit_complete = pnfs_commit_done,
 };
 
 EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index a987d06..a88cd69 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -279,15 +279,6 @@ extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
 struct pnfs_client_operations {
 	int (*nfs_getdeviceinfo) (struct nfs_server *,
 				  struct pnfs_device *dev);
-
-	/* Post read callback. */
-	void (*nfs_readlist_complete) (struct nfs_read_data *nfs_data);
-
-	/* Post write callback. */
-	void (*nfs_writelist_complete) (struct nfs_write_data *nfs_data);
-
-	/* Post commit callback. */
-	void (*nfs_commit_complete) (struct nfs_write_data *nfs_data);
 	void (*nfs_return_layout) (struct inode *);
 };
 
-- 
1.6.6.1

