Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032043Ab2COSk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:40:58 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 03/11] NFSv4.1 cleanup filelayout invalid layout handling
Date: Thu, 15 Mar 2012 14:40:42 -0400
Message-Id: <1331836850-5195-4-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The invalid layout bits are should only be used to block LAYOUTGETs.

Do not invalidate a layout on deviceid invalidation.
Do not invalidate a layout on un-handled READ, WRITE, COMMIT errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   26 ++++++--------------------
 1 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e1c0670..b0b775c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -187,10 +187,8 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset) {
-			pnfs_set_lo_fail(data->lseg);
+		if (reset)
 			filelayout_reset_read(task, data);
-		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -267,10 +265,8 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset) {
-			pnfs_set_lo_fail(data->lseg);
+		if (reset)
 			filelayout_reset_write(task, data);
-		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -299,10 +295,9 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
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
@@ -393,12 +388,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
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
@@ -432,11 +423,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
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
 		data->inode->i_ino, sync, (size_t) data->args.count, offset,
 		ds->ds_remotestr);
@@ -890,8 +878,6 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		prepare_to_resend_writes(data);
 		data->mds_ops->rpc_release(data);
 		return -EAGAIN;
-- 
1.7.6.4

