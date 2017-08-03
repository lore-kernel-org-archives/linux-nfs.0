Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36550 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdHCNp4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:56 -0400
Received: by mail-it0-f67.google.com with SMTP id r9so1313437ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 17/28] NFS: Remove unused parameter from nfs_page_group_lock()
Date: Thu,  3 Aug 2017 09:45:12 -0400
Message-Id: <20170803134523.4922-18-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-17-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_page_group_lock() is now always called with the 'nonblock'
parameter set to 'false'.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        | 31 +++++++++++--------------------
 fs/nfs/write.c           |  6 +++---
 include/linux/nfs_page.h |  2 +-
 3 files changed, 15 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ced7974622dd..af6731dd4324 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -134,19 +134,14 @@ EXPORT_SYMBOL_GPL(nfs_async_iocounter_wait);
 /*
  * nfs_page_group_lock - lock the head of the page group
  * @req - request in group that is to be locked
- * @nonblock - if true don't block waiting for lock
  *
- * this lock must be held if modifying the page group list
+ * this lock must be held when traversing or modifying the page
+ * group list
  *
- * return 0 on success, < 0 on error: -EDELAY if nonblocking or the
- * result from wait_on_bit_lock
- *
- * NOTE: calling with nonblock=false should always have set the
- *       lock bit (see fs/buffer.c and other uses of wait_on_bit_lock
- *       with TASK_UNINTERRUPTIBLE), so there is no need to check the result.
+ * return 0 on success, < 0 on error
  */
 int
-nfs_page_group_lock(struct nfs_page *req, bool nonblock)
+nfs_page_group_lock(struct nfs_page *req)
 {
 	struct nfs_page *head = req->wb_head;
 
@@ -155,14 +150,10 @@ nfs_page_group_lock(struct nfs_page *req, bool nonblock)
 	if (!test_and_set_bit(PG_HEADLOCK, &head->wb_flags))
 		return 0;
 
-	if (!nonblock) {
-		set_bit(PG_CONTENDED1, &head->wb_flags);
-		smp_mb__after_atomic();
-		return wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
+	set_bit(PG_CONTENDED1, &head->wb_flags);
+	smp_mb__after_atomic();
+	return wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
 				TASK_UNINTERRUPTIBLE);
-	}
-
-	return -EAGAIN;
 }
 
 /*
@@ -225,7 +216,7 @@ bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
 {
 	bool ret;
 
-	nfs_page_group_lock(req, false);
+	nfs_page_group_lock(req);
 	ret = nfs_page_group_sync_on_bit_locked(req, bit);
 	nfs_page_group_unlock(req);
 
@@ -1016,7 +1007,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	unsigned int bytes_left = 0;
 	unsigned int offset, pgbase;
 
-	nfs_page_group_lock(req, false);
+	nfs_page_group_lock(req);
 
 	subreq = req;
 	bytes_left = subreq->wb_bytes;
@@ -1038,7 +1029,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			if (mirror->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-			nfs_page_group_lock(req, false);
+			nfs_page_group_lock(req);
 			continue;
 		}
 
@@ -1135,7 +1126,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 
 	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 		if (midx) {
-			nfs_page_group_lock(req, false);
+			nfs_page_group_lock(req);
 
 			/* find the last request */
 			for (lastreq = req->wb_head;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 20d44ea328b6..0f418d825185 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -271,7 +271,7 @@ static bool nfs_page_group_covers_page(struct nfs_page *req)
 	unsigned int pos = 0;
 	unsigned int len = nfs_page_length(req->wb_page);
 
-	nfs_page_group_lock(req, false);
+	nfs_page_group_lock(req);
 
 	do {
 		tmp = nfs_page_group_search_locked(req->wb_head, pos);
@@ -480,7 +480,7 @@ nfs_lock_and_join_requests(struct page *page)
 	}
 	spin_unlock(&inode->i_lock);
 
-	ret = nfs_page_group_lock(head, false);
+	ret = nfs_page_group_lock(head);
 	if (ret < 0) {
 		nfs_unlock_and_release_request(head);
 		return ERR_PTR(ret);
@@ -501,7 +501,7 @@ nfs_lock_and_join_requests(struct page *page)
 			nfs_page_group_unlock(head);
 			ret = nfs_wait_on_request(subreq);
 			if (!ret)
-				ret = nfs_page_group_lock(head, false);
+				ret = nfs_page_group_lock(head);
 			if (ret < 0) {
 				nfs_unroll_locks(inode, head, subreq);
 				nfs_release_request(subreq);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index de1d24cedaa2..2f4fdafb6746 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -139,7 +139,7 @@ extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern	void nfs_unlock_and_release_request(struct nfs_page *);
-extern int nfs_page_group_lock(struct nfs_page *, bool);
+extern int nfs_page_group_lock(struct nfs_page *);
 extern void nfs_page_group_unlock(struct nfs_page *);
 extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned int);
 extern bool nfs_async_iocounter_wait(struct rpc_task *, struct nfs_lock_context *);
-- 
2.13.3

