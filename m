Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:60233 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbcAFQvv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2016 11:51:51 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id D25932802D5
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jan 2016 17:51:49 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id BF94A4475
	for <linux-nfs@vger.kernel.org>; Wed,  6 Jan 2016 17:51:49 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs: set RPC_TASK_TIMEOUT on rpc task to separate TIMEOUT from IO errors
Date: Wed,  6 Jan 2016 17:51:30 +0100
Message-Id: <1452099090-31729-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1452099090-31729-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1452099090-31729-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

to help debug nfs problems

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/read.c  | 2 +-
 fs/nfs/write.c | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0a5e33f..0fae3f3 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -191,7 +191,7 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
 	struct inode *inode = hdr->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
 
-	task_setup_data->flags |= swap_flags;
+	task_setup_data->flags |= swap_flags | RPC_TASK_TIMEOUT;
 	rpc_ops->read_setup(hdr, msg);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b93164..05c9963 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1296,6 +1296,7 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
 	int priority = flush_task_priority(how);
 
 	task_setup_data->priority = priority;
+	task_setup_data->flags |= RPC_TASK_TIMEOUT;
 	rpc_ops->write_setup(hdr, msg);
 
 	nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
@@ -1578,7 +1579,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | flags,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT | flags,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
-- 
2.5.0

