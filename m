Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757749Ab2FTTDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:03:50 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/4] NFSv4.1 return the LAYOUT for each file with failed DS connection I/O
Date: Wed, 20 Jun 2012 15:03:31 -0400
Message-Id: <1340219014-5749-2-git-send-email-andros@netapp.com>
In-Reply-To: <1340219014-5749-1-git-send-email-andros@netapp.com>
References: <1340219014-5749-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

First mark the deviceid invalid to prevent any future use. Then fence all
files involved in I/O to a DS with a connection error by sending a
LAYOUTRETURN.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 85b7063..26b96de 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -205,9 +205,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -EPIPE:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		if (!filelayout_test_devid_invalid(devid))
-			_pnfs_return_layout(inode);
 		filelayout_mark_devid_invalid(devid);
+		_pnfs_return_layout(inode);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
 		/* fall through */
-- 
1.7.6.4

