Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759826Ab2EVQKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 12:10:21 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] NFSv4.1 fix null state reference in filelayout_async_handle_error
Date: Tue, 22 May 2012 08:09:28 -0400
Message-Id: <1337688569-1515-4-git-send-email-andros@netapp.com>
In-Reply-To: <1337688569-1515-1-git-send-email-andros@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index db6f2a6..cd3d1ce 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -193,8 +193,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		 * layout is destroyed and a new valid layout is obtained.
 		 */
 		set_bit(NFS_LAYOUT_INVALID,
-				&NFS_I(state->inode)->layout->plh_flags);
-		pnfs_destroy_layout(NFS_I(state->inode));
+				&NFS_I(inode)->layout->plh_flags);
+		pnfs_destroy_layout(NFS_I(inode));
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		goto reset;
 	/* RPC connection errors */
@@ -208,7 +208,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		if (!filelayout_test_devid_invalid(devid))
-			_pnfs_return_layout(state->inode);
+			_pnfs_return_layout(inode);
 		filelayout_mark_devid_invalid(devid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
-- 
1.7.7.6

