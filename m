Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757802Ab1BKSAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:43 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 02/17] SQUASHME fix filelayout_set_lo_fail logic
Date: Thu, 10 Feb 2011 20:52:35 -0500
Message-Id: <1297389170-26702-3-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-2-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Just use lseg iomode.

squash into pnfs-submit wave3 filelayout read done

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 777d78b..05fcc6a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -99,12 +99,12 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 
 /* For data server errors we don't recover from */
 static void
-filelayout_set_lo_fail(struct pnfs_layout_segment *lseg, fmode_t mode)
+filelayout_set_lo_fail(struct pnfs_layout_segment *lseg)
 {
-	if (mode & FMODE_WRITE) {
+	if (lseg->pls_range.iomode == IOMODE_RW) {
 		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
 		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-	} else if (mode & FMODE_READ) {
+	} else {
 		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 	}
@@ -143,9 +143,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		task->tk_status = 0;
 		return -EAGAIN;
 	default:
-		dprintk("%s DS error %d\n", __func__, task->tk_status);
-		/* Layout marked as failed by pnfs_check_io_status.
-		 * Retry I/O through the MDS */
+		dprintk("%s DS error. Retry through MDS %d\n", __func__,
+			task->tk_status);
 		*reset = 1;
 		task->tk_status = 0;
 		return -EAGAIN;
@@ -168,8 +167,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
 			nfs4_reset_read(task, data);
-			filelayout_set_lo_fail(data->lseg,
-					data->args.context->state->state);
+			filelayout_set_lo_fail(data->lseg);
 			clp = NFS_SERVER(data->inode)->nfs_client;
 		}
 		nfs_restart_rpc(task, clp);
-- 
1.6.6

