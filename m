Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35563 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbdGSWKC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:02 -0400
Received: by mail-io0-f196.google.com with SMTP id f1so817162ioj.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 01/20] NFS: Simplify page writeback
Date: Wed, 19 Jul 2017 18:09:36 -0400
Message-Id: <20170719220955.58210-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-1-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't expect the page header lock to ever be held across I/O, so
it should always be safe to wait for it, even if we're doing nonblocking
writebacks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 30 ++++++++++--------------------
 1 file changed, 10 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b1af5dee5e0a..1d447e37f472 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -366,7 +366,6 @@ nfs_page_group_clear_bits(struct nfs_page *req)
  * @inode - inode associated with request page group, must be holding inode lock
  * @head  - head request of page group, must be holding head lock
  * @req   - request that couldn't lock and needs to wait on the req bit lock
- * @nonblock - if true, don't actually wait
  *
  * NOTE: this must be called holding page_group bit lock and inode spin lock
  *       and BOTH will be released before returning.
@@ -375,7 +374,7 @@ nfs_page_group_clear_bits(struct nfs_page *req)
  */
 static int
 nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
-			  struct nfs_page *req, bool nonblock)
+			  struct nfs_page *req)
 	__releases(&inode->i_lock)
 {
 	struct nfs_page *tmp;
@@ -396,10 +395,7 @@ nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
 	/* release ref from nfs_page_find_head_request_locked */
 	nfs_release_request(head);
 
-	if (!nonblock)
-		ret = nfs_wait_on_request(req);
-	else
-		ret = -EAGAIN;
+	ret = nfs_wait_on_request(req);
 	nfs_release_request(req);
 
 	return ret;
@@ -464,7 +460,6 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
  *                              operations for this page.
  *
  * @page - the page used to lookup the "page group" of nfs_page structures
- * @nonblock - if true, don't block waiting for request locks
  *
  * This function joins all sub requests to the head request by first
  * locking all requests in the group, cancelling any pending operations
@@ -478,7 +473,7 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
  * error was encountered.
  */
 static struct nfs_page *
-nfs_lock_and_join_requests(struct page *page, bool nonblock)
+nfs_lock_and_join_requests(struct page *page)
 {
 	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *head, *subreq;
@@ -511,14 +506,9 @@ nfs_lock_and_join_requests(struct page *page, bool nonblock)
 	if (ret < 0) {
 		spin_unlock(&inode->i_lock);
 
-		if (!nonblock && ret == -EAGAIN) {
-			nfs_page_group_lock_wait(head);
-			nfs_release_request(head);
-			goto try_again;
-		}
-
+		nfs_page_group_lock_wait(head);
 		nfs_release_request(head);
-		return ERR_PTR(ret);
+		goto try_again;
 	}
 
 	/* lock each request in the page group */
@@ -543,7 +533,7 @@ nfs_lock_and_join_requests(struct page *page, bool nonblock)
 			/* releases page group bit lock and
 			 * inode spin lock and all references */
 			ret = nfs_unroll_locks_and_wait(inode, head,
-				subreq, nonblock);
+				subreq);
 
 			if (ret == 0)
 				goto try_again;
@@ -624,12 +614,12 @@ nfs_error_is_fatal_on_server(int err)
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page, bool nonblock)
+				struct page *page)
 {
 	struct nfs_page *req;
 	int ret = 0;
 
-	req = nfs_lock_and_join_requests(page, nonblock);
+	req = nfs_lock_and_join_requests(page);
 	if (!req)
 		goto out;
 	ret = PTR_ERR(req);
@@ -672,7 +662,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
 	int ret;
 
 	nfs_pageio_cond_complete(pgio, page_index(page));
-	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
+	ret = nfs_page_async_flush(pgio, page);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
 		ret = 0;
@@ -2015,7 +2005,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 
 	/* blocking call to cancel all requests and join to a single (head)
 	 * request */
-	req = nfs_lock_and_join_requests(page, false);
+	req = nfs_lock_and_join_requests(page);
 
 	if (IS_ERR(req)) {
 		ret = PTR_ERR(req);
-- 
2.13.3

