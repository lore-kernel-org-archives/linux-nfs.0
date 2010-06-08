From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 02/24] Revert "pnfs: Enable O_DIRECT write path."
Date: Tue,  8 Jun 2010 00:18:59 -0400
Message-ID: <1275970761-31806-3-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0FHETp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:45 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOPr014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:26 -0700 (PDT)
In-Reply-To: <1275970761-31806-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 2faf680af973895bdfe19f2254b59dc1a153dd82.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   41 +----------------------------------------
 1 files changed, 1 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 02e5918..1148214 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -505,7 +505,6 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
-	enum pnfs_try_status trypnfs;
 
 	dreq->count = 0;
 	get_dreq(dreq);
@@ -529,11 +528,6 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		 * Reuse data->task; data->args should not have changed
 		 * since the original request was sent.
 		 */
-		trypnfs = pnfs_try_to_write_data(data, &nfs_write_direct_ops,
-						 NFS_FILE_SYNC);
-		if (trypnfs == PNFS_ATTEMPTED)
-			continue;
-
 		nfs_direct_write_execute(data, &task_setup_data, &msg);
 	}
 
@@ -616,7 +610,6 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
-	enum pnfs_try_status trypnfs;
 
 	data->inode = dreq->inode;
 	data->cred = msg.rpc_cred;
@@ -630,11 +623,6 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.verf = &data->verf;
 	nfs_fattr_init(&data->fattr);
 
-	trypnfs = pnfs_try_to_commit(data, &nfs_commit_direct_ops,
-				     RPC_TASK_ASYNC);
-	if (trypnfs == PNFS_ATTEMPTED)
-		return;
-
 	nfs_direct_commit_execute(dreq, data, &task_setup_data, &msg);
 }
 
@@ -683,9 +671,6 @@ static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 
-	dprintk("%s: verf: %d stable %d\n", __func__,
-		data->res.verf->committed, data->args.stable);
-
 	if (nfs_writeback_done(task, data) != 0)
 		return;
 }
@@ -799,17 +784,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
-	size_t pnfs_stripe_rem = count;
-	enum pnfs_try_status trypnfs;
-
-	/* pnfs_stripe_rem will be set to the remaining bytes in
-	 * the first stripe_unit (which for standard nfs is count)
-	 */
-	pnfs_direct_init_io(inode, ctx, count, pos, 1,
-			    &wsize, &pnfs_stripe_rem);
-
-	dprintk("%s: pos %llu count %Zu wsize %Zu\n",
-		__func__, pos, count, wsize);
 
 	do {
 		struct nfs_write_data *data;
@@ -818,12 +792,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		pgbase = user_addr & ~PAGE_MASK;
 		bytes = min(wsize,count);
 
-#if defined(CONFIG_NFS_V4_1)
-		if (pnfs_enabled_sb(NFS_SERVER(inode))) {
-			bytes = min(bytes, pnfs_stripe_rem);
-			pnfs_stripe_rem = wsize;
-		}
-#endif /* CONFIG_NFS_V4_1 */
 		result = -ENOMEM;
 		data = nfs_writedata_alloc(nfs_page_array_len(pgbase, bytes));
 		if (unlikely(!data))
@@ -867,15 +835,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.verf = &data->verf;
 		nfs_fattr_init(&data->fattr);
 
-		trypnfs = pnfs_try_to_write_data(data, &nfs_write_direct_ops,
-						 sync);
-		if (trypnfs == PNFS_ATTEMPTED) {
-			result = pnfs_get_write_status(data);
-			if (result)
-				break;
-		} else if (nfs_direct_write_execute(data, &task_setup_data, &msg)) {
+		if (nfs_direct_write_execute(data, &task_setup_data, &msg))
 			break;
-		}
 
 		started += bytes;
 		user_addr += bytes;
-- 
1.6.6.1

