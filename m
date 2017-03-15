Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:55965 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751756AbdCOUEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 16:04:34 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 1/1] PNFS dont retry some error when MDS=DS
Date: Wed, 15 Mar 2017 16:02:15 -0400
Message-ID: <20170315200215.43997-1-kolga@netapp.com>
In-Reply-To: <20170315163224.43632-1-kolga@netapp.com>
References: <20170315163224.43632-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we sent an operation to the "DS" and got an error, the code resends
to "MDS" but when they are the same, it gets the same error and goes
into the infinite loop. Example was COMMIT getting EACCES.

Since some setups like ONTAP where each node in the cluster is MDS and
DS need to check if MDS=DS based on if clientids are the same.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 44347f4..e1d9bea 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -207,6 +207,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		/* fall through */
 	default:
 reset:
+		if (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS &&
+			clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS &&
+			clp->cl_clientid == mds_client->cl_clientid)
+			return task->tk_status;
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
@@ -384,9 +388,10 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
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

