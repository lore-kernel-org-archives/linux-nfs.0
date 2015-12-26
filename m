Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34625 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697AbbLZXVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:47 -0500
Received: by mail-io0-f182.google.com with SMTP id e126so280362415ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/14] pNFS/flexfiles: Don't mark the entire layout as failed, when returning it
Date: Sat, 26 Dec 2015 18:20:57 -0500
Message-Id: <1451172060-28238-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In pNFS/flexfiles, we want to return the layout without necessarily marking
it as having completely failed. We therefore move the call to
pnfs_layout_io_set_failed() out of pnfs_error_mark_layout_for_return(),
and then ensura that pNFS/files layout calls it separately.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 1 +
 fs/nfs/pnfs.c                  | 3 ---
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index ae07b0f56659..bb1f4e7a3270 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -202,6 +202,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
 		pnfs_error_mark_layout_for_return(inode, lseg);
+		pnfs_set_lo_fail(lseg);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6b42362cdbb0..113c3b327e24 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1763,7 +1763,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
-	int iomode = pnfs_iomode_to_fail_bit(lseg->pls_range.iomode);
 	struct pnfs_layout_range range = {
 		.iomode = lseg->pls_range.iomode,
 		.offset = 0,
@@ -1772,8 +1771,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	LIST_HEAD(free_me);
 
 	spin_lock(&inode->i_lock);
-	/* set failure bit so that pnfs path will be retried later */
-	pnfs_layout_set_fail_bit(lo, iomode);
 	if (lo->plh_return_iomode == 0)
 		lo->plh_return_iomode = range.iomode;
 	else if (lo->plh_return_iomode != range.iomode)
-- 
2.5.0

