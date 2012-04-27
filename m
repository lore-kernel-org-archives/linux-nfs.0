Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002Ab2D0Vpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 10/13] NFSv4.1 send layoutreturn to fence disconnected data server
Date: Fri, 27 Apr 2012 17:53:50 -0400
Message-Id: <1335563633-7191-11-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Let the MDS know that you are redirecting I/O from pNFS to MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 ++
 fs/nfs/pnfs.c           |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a63062d..c6b7c18 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -186,6 +186,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -EPIPE:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
+		if (!filelayout_test_devid_invalid(devid))
+			_pnfs_return_layout(state->inode);
 		filelayout_mark_devid_invalid(devid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 78fd7eb..98a7ec8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -692,6 +692,7 @@ out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
+EXPORT_SYMBOL_GPL(_pnfs_return_layout);
 
 bool pnfs_roc(struct inode *ino)
 {
-- 
1.7.6.4

