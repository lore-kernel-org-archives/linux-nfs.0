From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 10/11] svcrdma: Create a kmem cache for the WR contexts
Date: Wed,  2 Jul 2008 21:27:42 -0500
Message-ID: <1215052063-7330-11-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-7-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-8-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-9-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-10-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48842 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-10-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a kmem cache to hold WR contexts. Next we will convert
the WR context get and put services to use this kmem cache.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 527acfd..8710117 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -69,8 +69,9 @@ atomic_t rdma_stat_rq_prod;
 atomic_t rdma_stat_sq_poll;
 atomic_t rdma_stat_sq_prod;
 
-/* Temporary NFS request map cache */
+/* Temporary NFS request map and context caches */
 struct kmem_cache *svc_rdma_map_cachep;
+struct kmem_cache *svc_rdma_ctxt_cachep;
 
 /*
  * This function implements reading and resetting an atomic_t stat
@@ -246,6 +247,7 @@ void svc_rdma_cleanup(void)
 	}
 	svc_unreg_xprt_class(&svc_rdma_class);
 	kmem_cache_destroy(svc_rdma_map_cachep);
+	kmem_cache_destroy(svc_rdma_ctxt_cachep);
 }
 
 int svc_rdma_init(void)
@@ -268,14 +270,27 @@ int svc_rdma_init(void)
 						NULL);
 	if (!svc_rdma_map_cachep) {
 		printk(KERN_INFO "Could not allocate map cache.\n");
-		goto err;
+		goto err0;
+	}
+
+	/* Create the temporary context cache */
+	svc_rdma_ctxt_cachep =
+		kmem_cache_create("svc_rdma_ctxt_cache",
+				  sizeof(struct svc_rdma_op_ctxt),
+				  0,
+				  SLAB_HWCACHE_ALIGN,
+				  NULL);
+	if (!svc_rdma_ctxt_cachep) {
+		printk(KERN_INFO "Could not allocate WR ctxt cache.\n");
+		goto err1;
 	}
 
 	/* Register RDMA with the SVC transport switch */
 	svc_reg_xprt_class(&svc_rdma_class);
 	return 0;
-
- err:
+ err1:
+	kmem_cache_destroy(svc_rdma_map_cachep);
+ err0:
 	unregister_sysctl_table(svcrdma_table_header);
 	return -ENOMEM;
 }
