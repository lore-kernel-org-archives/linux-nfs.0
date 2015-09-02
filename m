Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36831 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbbIBWez (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 18:34:55 -0400
Received: by pacwi10 with SMTP id wi10so24669468pac.3
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2015 15:34:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1/flexfiles: Mark the layout for return in ff_layout_io_track_ds_error()
Date: Wed,  2 Sep 2015 15:34:52 -0700
Message-Id: <1441233293-10911-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I/O cannot complete due to a fatal error on the DS, ensure that we
invalidate the corresponding layout segment and return it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ee8e7013454f..3f073a7de870 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1148,6 +1148,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				       mirror, offset, length, status, opnum,
 				       GFP_NOIO);
+	pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode, lseg);
 	dprintk("%s: err %d op %d status %u\n", __func__, err, opnum, status);
 }
 
@@ -1156,7 +1157,6 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 static int ff_layout_read_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
-	struct inode *inode;
 	int err;
 
 	trace_nfs4_pnfs_read(hdr, task->tk_status);
@@ -1176,8 +1176,6 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 		pnfs_read_resend_pnfs(hdr);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
-		inode = hdr->lseg->pls_layout->plh_inode;
-		pnfs_error_mark_layout_for_return(inode, hdr->lseg);
 		ff_layout_reset_read(hdr);
 		return task->tk_status;
 	case -EAGAIN:
@@ -1330,7 +1328,6 @@ static void ff_layout_read_count_stats(struct rpc_task *task, void *data)
 static int ff_layout_write_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
-	struct inode *inode;
 	int err;
 
 	trace_nfs4_pnfs_write(hdr, task->tk_status);
@@ -1346,8 +1343,6 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
 	case -NFS4ERR_RESET_TO_MDS:
-		inode = hdr->lseg->pls_layout->plh_inode;
-		pnfs_error_mark_layout_for_return(inode, hdr->lseg);
 		if (err == -NFS4ERR_RESET_TO_PNFS) {
 			pnfs_set_retry_layoutget(hdr->lseg->pls_layout);
 			ff_layout_reset_write(hdr, true);
@@ -1376,7 +1371,6 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 static int ff_layout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_commit_data *data)
 {
-	struct inode *inode;
 	int err;
 
 	trace_nfs4_pnfs_commit_ds(data, task->tk_status);
@@ -1391,8 +1385,6 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
 	case -NFS4ERR_RESET_TO_MDS:
-		inode = data->lseg->pls_layout->plh_inode;
-		pnfs_error_mark_layout_for_return(inode, data->lseg);
 		if (err == -NFS4ERR_RESET_TO_PNFS)
 			pnfs_set_retry_layoutget(data->lseg->pls_layout);
 		else
-- 
2.4.3

