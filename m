Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751100AbdCNHHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:53 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/12] fs, nfs: convert nfs_cache_defer_req.count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:16 +0200
Message-Id: <1489475240-6594-9-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/cache_lib.c | 6 +++---
 fs/nfs/cache_lib.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 6de1570..cf8ccb6 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -66,7 +66,7 @@ int nfs_cache_upcall(struct cache_detail *cd, char *entry_name)
  */
 void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq)
 {
-	if (atomic_dec_and_test(&dreq->count))
+	if (refcount_dec_and_test(&dreq->count))
 		kfree(dreq);
 }
 
@@ -86,7 +86,7 @@ static struct cache_deferred_req *nfs_dns_cache_defer(struct cache_req *req)
 
 	dreq = container_of(req, struct nfs_cache_defer_req, req);
 	dreq->deferred_req.revisit = nfs_dns_cache_revisit;
-	atomic_inc(&dreq->count);
+	refcount_inc(&dreq->count);
 
 	return &dreq->deferred_req;
 }
@@ -98,7 +98,7 @@ struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void)
 	dreq = kzalloc(sizeof(*dreq), GFP_KERNEL);
 	if (dreq) {
 		init_completion(&dreq->completion);
-		atomic_set(&dreq->count, 1);
+		refcount_set(&dreq->count, 1);
 		dreq->req.defer = nfs_dns_cache_defer;
 	}
 	return dreq;
diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
index 4116d2c..02b378c 100644
--- a/fs/nfs/cache_lib.h
+++ b/fs/nfs/cache_lib.h
@@ -15,7 +15,7 @@ struct nfs_cache_defer_req {
 	struct cache_req req;
 	struct cache_deferred_req deferred_req;
 	struct completion completion;
-	atomic_t count;
+	refcount_t count;
 };
 
 extern int nfs_cache_upcall(struct cache_detail *cd, char *entry_name);
-- 
2.7.4

