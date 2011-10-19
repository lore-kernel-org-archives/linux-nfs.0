Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439Ab1JSUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] NFS: Get rid of the nfs_rdata_mempool
Date: Wed, 19 Oct 2011 13:50:18 -0700
Message-Id: <1319057418-9851-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-6-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-7-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need a mempool in order to guarantee reliable NFS read performance.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index fd58e90..8b48ec6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -35,16 +35,13 @@ static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
-static mempool_t *nfs_rdata_mempool;
-
-#define MIN_POOL_READ	(32)
 
 struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 {
-	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_KERNEL);
+	struct nfs_read_data *p;
 
+	p = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
 	if (p) {
-		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
 		p->npages = pagecount;
 		if (pagecount <= ARRAY_SIZE(p->page_array))
@@ -52,7 +49,7 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 		else {
 			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
 			if (!p->pagevec) {
-				mempool_free(p, nfs_rdata_mempool);
+				kmem_cache_free(nfs_rdata_cachep, p);
 				p = NULL;
 			}
 		}
@@ -64,7 +61,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
 {
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
-	mempool_free(p, nfs_rdata_mempool);
+	kmem_cache_free(nfs_rdata_cachep, p);
 }
 
 void nfs_readdata_release(struct nfs_read_data *rdata)
@@ -716,16 +713,10 @@ int __init nfs_init_readpagecache(void)
 	if (nfs_rdata_cachep == NULL)
 		return -ENOMEM;
 
-	nfs_rdata_mempool = mempool_create_slab_pool(MIN_POOL_READ,
-						     nfs_rdata_cachep);
-	if (nfs_rdata_mempool == NULL)
-		return -ENOMEM;
-
 	return 0;
 }
 
 void nfs_destroy_readpagecache(void)
 {
-	mempool_destroy(nfs_rdata_mempool);
 	kmem_cache_destroy(nfs_rdata_cachep);
 }
-- 
1.7.6.4

