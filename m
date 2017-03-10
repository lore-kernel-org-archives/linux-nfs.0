Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:46452 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933493AbdCJVho (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 16:37:44 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS dont retry some error when MDS=DS
Date: Fri, 10 Mar 2017 16:37:15 -0500
Message-ID: <20170310213715.38258-1-kolga@netapp.com>
In-Reply-To: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
References: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we sent an operation to the "DS" and got an error, the code resends
to "MDS" but when they are the same, it gets the same error and goes
into the infinite loop. Example was COMMIT getting EACCES.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 44347f4..772be38 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -207,6 +207,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		/* fall through */
 	default:
 reset:
+		if (mds_client->cl_rpcclient == clp->cl_rpcclient)
+			return task->tk_status;
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
@@ -384,9 +386,10 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
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

