Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39036 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030243Ab2CVTTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:19:45 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 09/11] NFSv4.1 ref count nfs_client across filelayout data server io
Date: Thu, 22 Mar 2012 15:19:37 -0400
Message-Id: <1332443979-2302-10-git-send-email-andros@netapp.com>
In-Reply-To: <1332443979-2302-1-git-send-email-andros@netapp.com>
References: <1332443979-2302-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to put a dis-connected DS client record.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index ce8734d..acf6226 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -88,6 +88,8 @@ void filelayout_reset_write(struct rpc_task *task, struct nfs_write_data *data)
 	dprintk("%s Reset task for i/o through MDS\n", __func__);
 	put_lseg(data->lseg);
 	data->lseg          = NULL;
+	/* balance nfs_get_client in filelayout_write_pagelist */
+	nfs_put_client(data->ds_clp);
 	data->ds_clp        = NULL;
 	data->write_done_cb = nfs4_write_done_cb;
 	data->args.fh       = NFS_FH(data->inode);
@@ -106,6 +108,8 @@ void filelayout_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 	data->lseg         = NULL;
 	/* offsets will differ in the dense stripe case */
 	data->args.offset  = data->mds_offset;
+	/* balance nfs_get_client in filelayout_read_pagelist */
+	nfs_put_client(data->ds_clp);
 	data->ds_clp       = NULL;
 	data->args.fh      = NFS_FH(data->inode);
 	data->read_done_cb = nfs4_read_done_cb;
@@ -273,6 +277,7 @@ static void filelayout_read_release(void *data)
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
 	put_lseg(rdata->lseg);
+	nfs_put_client(rdata->ds_clp);
 	rdata->mds_ops->rpc_release(data);
 }
 
@@ -369,6 +374,7 @@ static void filelayout_write_release(void *data)
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
 	put_lseg(wdata->lseg);
+	nfs_put_client(wdata->ds_clp);
 	wdata->mds_ops->rpc_release(data);
 }
 
@@ -388,6 +394,7 @@ static void filelayout_commit_release(void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
+	nfs_put_client(wdata->ds_clp);
 	nfs_commit_release_pages(wdata);
 	if (atomic_dec_and_test(&NFS_I(wdata->inode)->commits_outstanding))
 		nfs_commit_clear_lock(NFS_I(wdata->inode));
@@ -436,9 +443,11 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
-	dprintk("%s USE DS: %s\n", __func__, ds->ds_remotestr);
+	dprintk("%s USE DS: %s cl_count %d\n", __func__,
+		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
 
 	/* No multipath support. Use first DS */
+	atomic_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
@@ -471,11 +480,12 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
-	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s\n", __func__,
-		data->inode->i_ino, sync, (size_t) data->args.count, offset,
-		ds->ds_remotestr);
+	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s cl_count %d\n",
+		__func__, data->inode->i_ino, sync, (size_t) data->args.count,
+		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
 
 	data->write_done_cb = filelayout_write_done_cb;
+	atomic_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
@@ -951,8 +961,10 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 		filelayout_commit_release(data);
 		return -EAGAIN;
 	}
-	dprintk("%s ino %lu, how %d\n", __func__, data->inode->i_ino, how);
+	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
+		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
 	data->write_done_cb = filelayout_commit_done_cb;
+	atomic_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
-- 
1.7.6.4

