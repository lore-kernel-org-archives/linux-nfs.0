Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab2FSXCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 19:02:15 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/2] NFS: Initialise commit_info.rpc_out when !defined(CONFIG_NFS_V4)
Date: Tue, 19 Jun 2012 19:02:09 -0400
Message-Id: <1340146929-21242-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340146929-21242-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1340146929-21242-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e605d69..f729698 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1530,7 +1530,6 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	nfsi->layout = NULL;
-	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 #endif
 }
 
@@ -1545,6 +1544,7 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->commit_info.list);
 	nfsi->npages = 0;
 	nfsi->commit_info.ncommit = 0;
+	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 	atomic_set(&nfsi->silly_count, 1);
 	INIT_HLIST_HEAD(&nfsi->silly_list);
 	init_waitqueue_head(&nfsi->waitqueue);
-- 
1.7.10.2

