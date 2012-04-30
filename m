Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41994 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756603Ab2D3WoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 18:44:00 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/2] NFS: Use kmem_cache_zalloc() in nfs_direct_req_alloc
Date: Mon, 30 Apr 2012 18:43:59 -0400
Message-Id: <1335825840-22006-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the initialisation of O_DIRECT requests.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 78d1ead..f17e469 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -149,26 +149,16 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 {
 	struct nfs_direct_req *dreq;
 
-	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_KERNEL);
+	dreq = kmem_cache_zalloc(nfs_direct_cachep, GFP_KERNEL);
 	if (!dreq)
 		return NULL;
 
 	kref_init(&dreq->kref);
 	kref_get(&dreq->kref);
 	init_completion(&dreq->completion);
-	dreq->mds_cinfo.ncommit = 0;
-	atomic_set(&dreq->mds_cinfo.rpcs_out, 0);
 	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
 	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
-	memset(&dreq->ds_cinfo, 0, sizeof(dreq->ds_cinfo));
-	dreq->iocb = NULL;
-	dreq->ctx = NULL;
-	dreq->l_ctx = NULL;
 	spin_lock_init(&dreq->lock);
-	atomic_set(&dreq->io_count, 0);
-	dreq->count = 0;
-	dreq->error = 0;
-	dreq->flags = 0;
 
 	return dreq;
 }
-- 
1.7.7.6

