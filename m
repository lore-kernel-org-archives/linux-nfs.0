From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/4] pnfs-submit: Remove checks for non-rpc drivers
Date: Sun, 13 Jun 2010 16:18:40 -0400
Message-ID: <1276460322-13873-3-git-send-email-iisaman@netapp.com>
References: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
 <1276460322-13873-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27832 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab0FMUSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:18:52 -0400
Received: from localhost.localdomain (kellyv2-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DKIkfd012997
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 13:18:48 -0700 (PDT)
In-Reply-To: <1276460322-13873-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Removes PNFS_NO_RPC and pnfs_use_rpc()

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |    1 -
 fs/nfs/nfs4proc.c         |    9 ---------
 fs/nfs/pnfs.c             |   40 +++++-----------------------------------
 fs/nfs/pnfs.h             |   13 -------------
 include/linux/nfs4_pnfs.h |   10 ----------
 include/linux/nfs_xdr.h   |    3 ---
 6 files changed, 5 insertions(+), 71 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 472b613..9a3ea49 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -753,7 +753,6 @@ struct layoutdriver_io_operations filelayout_io_operations = {
 };
 
 struct layoutdriver_policy_operations filelayout_policy_operations = {
-	.flags                 = PNFS_USE_RPC_CODE,
 	.get_stripesize        = filelayout_get_stripesize,
 	.pg_test               = filelayout_pg_test,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 192afc3..c7d68f5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3175,9 +3175,6 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	dprintk("--> %s\n", __func__);
 
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
 	status = task->tk_status >= 0 ? 0 : task->tk_status;
 
 	/* Is this a DS session */
@@ -3225,9 +3222,6 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 		data->args.count = data->pdata.orig_count;
 	}
 
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
 	/* Is this a DS session */
 	if (data->fldata.ds_nfs_client) {
 		dprintk("%s DS write\n", __func__);
@@ -3278,9 +3272,6 @@ static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
-	if (data->pdata.pnfsflags & PNFS_NO_RPC)
-		return 0;
-
 	/* Is this a DS session */
 	if (data->fldata.ds_nfs_client) {
 		dprintk("%s DS commit\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a4d1937..89c788d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1406,24 +1406,16 @@ pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
 	pdata->call_ops->rpc_call_done(task, data);
 	if (pdata->pnfs_error == -EAGAIN || task->tk_status == -EAGAIN)
 		return -EAGAIN;
-	if (pdata->pnfsflags & PNFS_NO_RPC) {
-		pdata->call_ops->rpc_release(data);
-	} else {
-		/*
-		 * just restore original rpc call ops
-		 * rpc_release will be called later by the rpc scheduling layer.
-		 */
-		task->tk_ops = pdata->call_ops;
-	}
+	/*
+	 * just restore original rpc call ops
+	 * rpc_release will be called later by the rpc scheduling layer.
+	 */
+	task->tk_ops = pdata->call_ops;
 	return 0;
 }
 
 /* Post-write completion function
  * Invoked by all layout drivers when write_pagelist is done.
- *
- * NOTE: callers set data->pnfsflags PNFS_NO_RPC
- * so that the NFS cleanup routines perform only the page cache
- * cleanup.
  */
 static void
 pnfs_write_retry(struct work_struct *work)
@@ -1450,18 +1442,6 @@ pnfs_writeback_done(struct nfs_write_data *data)
 
 	dprintk("%s: Begin (status %d)\n", __func__, data->task.tk_status);
 
-	/* update last write offset and need layout commit
-	 * for non-files layout types (files layout calls
-	 * pnfs4_write_done for this)
-	 */
-	if ((pdata->pnfsflags & PNFS_NO_RPC) &&
-	    data->task.tk_status >= 0 && data->res.count > 0) {
-		struct nfs_inode *nfsi = NFS_I(data->inode);
-
-		pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
-		pnfs_need_layoutcommit(nfsi, data->args.context);
-	}
-
 	if (pnfs_call_done(pdata, &data->task, data) == -EAGAIN) {
 		INIT_WORK(&data->task.u.tk_work, pnfs_write_retry);
 		queue_work(nfsiod_workqueue, &data->task.u.tk_work);
@@ -1507,8 +1487,6 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		__func__,
 		how,
 		numpages);
-	if (!pnfs_use_rpc(nfss))
-		wdata->pdata.pnfsflags |= PNFS_NO_RPC;
 	wdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
 							&nfsi->layout,
@@ -1521,7 +1499,6 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 							wdata);
 
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		wdata->pdata.pnfsflags &= ~PNFS_NO_RPC;
 		wdata->pdata.lseg = NULL;
 		put_lseg(lseg);
 	}
@@ -1597,8 +1574,6 @@ pnfs_readpages(struct nfs_read_data *rdata)
 
 	dprintk("%s: Calling layout driver read with %d pages\n",
 		__func__, numpages);
-	if (!pnfs_use_rpc(nfss))
-		rdata->pdata.pnfsflags |= PNFS_NO_RPC;
 	rdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(
 							&nfsi->layout,
@@ -1609,7 +1584,6 @@ pnfs_readpages(struct nfs_read_data *rdata)
 							args->count,
 							rdata);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		rdata->pdata.pnfsflags &= ~PNFS_NO_RPC;
 		rdata->pdata.lseg = NULL;
 		put_lseg(lseg);
 	}
@@ -1688,12 +1662,8 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	 * This will be done by passing the buck to the layout driver.
 	 */
 	data->pdata.lseg = NULL;
-	if (!pnfs_use_rpc(nfss))
-		data->pdata.pnfsflags |= PNFS_NO_RPC;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
 							sync, data);
-	if (trypnfs == PNFS_NOT_ATTEMPTED)
-		data->pdata.pnfsflags &= ~PNFS_NO_RPC;
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 75f6cf1..60bddc1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -195,14 +195,6 @@ static inline int pnfs_get_read_status(struct nfs_read_data *data)
 	return data->pdata.pnfs_error;
 }
 
-static inline int pnfs_use_rpc(struct nfs_server *nfss)
-{
-	if (pnfs_enabled_sb(nfss))
-		return pnfs_ld_use_rpc_code(nfss->pnfs_curr_ld);
-
-	return 1;
-}
-
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
@@ -253,11 +245,6 @@ static inline int pnfs_get_read_status(struct nfs_read_data *data)
 	return 0;
 }
 
-static inline int pnfs_use_rpc(struct nfs_server *nfss)
-{
-	return 1;
-}
-
 static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index f6e97c8..a987d06 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -173,9 +173,6 @@ struct layoutdriver_io_operations {
 };
 
 enum layoutdriver_policy_flags {
-	/* Should the full nfs rpc cleanup code be used after io */
-	PNFS_USE_RPC_CODE		= 1 << 0,
-
 	/* Should the NFS req. gather algorithm cross stripe boundaries? */
 	PNFS_GATHER_ACROSS_STRIPES	= 1 << 1,
 
@@ -193,13 +190,6 @@ struct layoutdriver_policy_operations {
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
-/* Should the full nfs rpc cleanup code be used after io */
-static inline int
-pnfs_ld_use_rpc_code(struct pnfs_layoutdriver_type *ld)
-{
-	return ld->ld_policy_ops->flags & PNFS_USE_RPC_CODE;
-}
-
 /* Should the NFS req. gather algorithm cross stripe boundaries? */
 static inline int
 pnfs_ld_gather_across_stripes(struct pnfs_layoutdriver_type *ld)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 22113a1..aa41a3c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -967,8 +967,6 @@ struct nfs_page;
 #define NFS_PAGEVEC_SIZE	(8U)
 
 #if defined(CONFIG_NFS_V4_1)
-/* pnfsflag values */
-#define PNFS_NO_RPC		0x0001   /* non rpc result callback switch */
 
 /* pnfs-specific data needed for read, write, and commit calls */
 struct pnfs_call_data {
@@ -976,7 +974,6 @@ struct pnfs_call_data {
 	const struct rpc_call_ops *call_ops;
 	u32			orig_count;	/* for retry via MDS */
 	int			pnfs_error;
-	u8			pnfsflags;
 	u8			how;		/* for FLUSH_STABLE */
 };
 
-- 
1.6.6.1

