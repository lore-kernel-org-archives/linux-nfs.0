Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962Ab2D0VpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:12 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 03/13] NFSv4.1 cleanup filelayout invalid layout handling
Date: Fri, 27 Apr 2012 17:53:43 -0400
Message-Id: <1335563633-7191-4-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The invalid layout bits are should only be used to block LAYOUTGETs.

Do not invalidate a layout on deviceid invalidation.
Do not invalidate a layout on un-handled READ, WRITE, COMMIT errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   28 ++++++----------------------
 1 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index eebec9a..b9edc88 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -148,7 +148,6 @@ wait_on_recovery:
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
-	struct nfs_pgio_header *hdr = data->header;
 	int reset = 0;
 
 	dprintk("%s DS read\n", __func__);
@@ -157,10 +156,8 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset) {
-			pnfs_set_lo_fail(hdr->lseg);
+		if (reset)
 			nfs4_reset_read(task, data);
-		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -233,17 +230,14 @@ static void filelayout_read_release(void *data)
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
-	struct nfs_pgio_header *hdr = data->header;
 	int reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset) {
-			pnfs_set_lo_fail(hdr->lseg);
+		if (reset)
 			nfs4_reset_write(task, data);
-		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -272,10 +266,9 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset) {
+		if (reset)
 			prepare_to_resend_writes(data);
-			pnfs_set_lo_fail(data->lseg);
-		} else
+		else
 			rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -393,12 +386,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
-	if (!ds) {
-		/* Either layout fh index faulty, or ds connect failed */
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
-	}
 	dprintk("%s USE DS: %s\n", __func__, ds->ds_remotestr);
 
 	/* No multipath support. Use first DS */
@@ -433,11 +422,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	j = nfs4_fl_calc_j_index(lseg, offset);
 	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
-	if (!ds) {
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
-	}
 	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s\n", __func__,
 		hdr->inode->i_ino, sync, (size_t) data->args.count, offset,
 		ds->ds_remotestr);
@@ -969,8 +955,6 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		prepare_to_resend_writes(data);
 		filelayout_commit_release(data);
 		return -EAGAIN;
-- 
1.7.6.4

