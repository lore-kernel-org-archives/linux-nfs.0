Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757788Ab2FTTDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:03:50 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/4] NFSv4.1 don't send LAYOUTCOMMIT if data resent through MDS
Date: Wed, 20 Jun 2012 15:03:32 -0400
Message-Id: <1340219014-5749-3-git-send-email-andros@netapp.com>
In-Reply-To: <1340219014-5749-1-git-send-email-andros@netapp.com>
References: <1340219014-5749-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 26b96de..53f94d9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -206,6 +206,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		filelayout_mark_devid_invalid(devid);
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
 		_pnfs_return_layout(inode);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
-- 
1.7.6.4

