Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:16810 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751713AbdCOQc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 12:32:29 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/1] PNFS dont retry some error when MDS=DS
Date: Wed, 15 Mar 2017 12:32:24 -0400
Message-ID: <20170315163224.43632-1-kolga@netapp.com>
In-Reply-To: <CAN-5tyEs649mRJkPRd=MyGi9ssVzc8uUH7g+mnKcBV+gSOF07w@mail.gmail.com>
References: <CAN-5tyEs649mRJkPRd=MyGi9ssVzc8uUH7g+mnKcBV+gSOF07w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we sent an operation to the "DS" and got an error, the code resends
to "MDS" but when they are the same, it gets the same error and goes
into the infinite loop. Example was COMMIT getting EACCES.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 44347f4..5276abe 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -207,6 +207,9 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		/* fall through */
 	default:
 reset:
+		if (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS &&
+			clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)
+			return task->tk_status;
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
@@ -384,9 +387,10 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
-	pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
+	if (!err)
+		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
-	return 0;
+	return err;
 }
 
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
-- 
1.8.3.1

