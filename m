Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760122Ab2FARVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 13:21:16 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFSv4.1 fence all layouts with file layout data server connection errors
Date: Fri,  1 Jun 2012 13:19:38 -0400
Message-Id: <1338571178-2096-3-git-send-email-andros@netapp.com>
In-Reply-To: <1338571178-2096-1-git-send-email-andros@netapp.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Clear the inode LAYOUTCOMMIT flag as we will resend writes through the MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e134029..96a75d1 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -205,8 +205,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -EPIPE:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		if (!filelayout_test_devid_invalid(devid))
-			_pnfs_return_layout(inode);
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
+		_pnfs_return_layout(inode);
 		filelayout_mark_devid_invalid(devid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
-- 
1.7.6.4

