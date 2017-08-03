Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34589 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbdHCNpu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:50 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so1320709ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/28] NFS: Reduce inode->i_lock contention in nfs_lock_and_join_requests()
Date: Thu,  3 Aug 2017 09:45:07 -0400
Message-Id: <20170803134523.4922-13-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-12-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should no longer need the inode->i_lock, now that we've
straightened out the request locking. The locking schema is now:

1) Lock page head request
2) Lock the page group
3) Lock the subrequests one by one

Note that there is a subtle race with nfs_inode_remove_request() due
to the fact that the latter does not lock the page head, when removing
it from the struct page. Only the last subrequest is locked, hence
we need to re-check that the PagePrivate(page) is still set after
we've locked all the subrequests.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 08c1ce968cce..ff7c90c7ff79 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -372,15 +372,14 @@ nfs_page_group_clear_bits(struct nfs_page *req)
  * @head  - head request of page group, must be holding head lock
  * @req   - request that couldn't lock and needs to wait on the req bit lock
  *
- * NOTE: this must be called holding page_group bit lock and inode spin lock
- *       and BOTH will be released before returning.
+ * NOTE: this must be called holding page_group bit lock
+ *       which will be released before returning.
  *
  * returns 0 on success, < 0 on error.
  */
 static int
 nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
 			  struct nfs_page *req)
-	__releases(&inode->i_lock)
 {
 	struct nfs_page *tmp;
 	int ret;
@@ -395,7 +394,6 @@ nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
 	kref_get(&req->wb_kref);
 
 	nfs_page_group_unlock(head);
-	spin_unlock(&inode->i_lock);
 
 	/* release ref from nfs_page_find_head_request_locked */
 	nfs_unlock_and_release_request(head);
@@ -491,8 +489,9 @@ nfs_lock_and_join_requests(struct page *page)
 	int ret;
 
 try_again:
+	if (!(PagePrivate(page) || PageSwapCache(page)))
+		return NULL;
 	spin_lock(&inode->i_lock);
-
 	/*
 	 * A reference is taken only on the head request which acts as a
 	 * reference to the whole page group - the group will not be destroyed
@@ -514,16 +513,12 @@ nfs_lock_and_join_requests(struct page *page)
 			return ERR_PTR(ret);
 		goto try_again;
 	}
+	spin_unlock(&inode->i_lock);
 
-	/* holding inode lock, so always make a non-blocking call to try the
-	 * page group lock */
-	ret = nfs_page_group_lock(head, true);
+	ret = nfs_page_group_lock(head, false);
 	if (ret < 0) {
-		spin_unlock(&inode->i_lock);
-
-		nfs_page_group_lock_wait(head);
 		nfs_unlock_and_release_request(head);
-		goto try_again;
+		return ERR_PTR(ret);
 	}
 
 	/* lock each request in the page group */
@@ -531,8 +526,10 @@ nfs_lock_and_join_requests(struct page *page)
 	for (subreq = head->wb_this_page; subreq != head;
 			subreq = subreq->wb_this_page) {
 		if (!nfs_lock_request(subreq)) {
-			/* releases page group bit lock and
-			 * inode spin lock and all references */
+			/*
+			 * releases page group bit lock and
+			 * page locks and all references
+			 */
 			ret = nfs_unroll_locks_and_wait(inode, head,
 				subreq);
 
@@ -580,7 +577,9 @@ nfs_lock_and_join_requests(struct page *page)
 	if (test_and_clear_bit(PG_REMOVE, &head->wb_flags)) {
 		set_bit(PG_INODE_REF, &head->wb_flags);
 		kref_get(&head->wb_kref);
+		spin_lock(&inode->i_lock);
 		NFS_I(inode)->nrequests++;
+		spin_unlock(&inode->i_lock);
 	}
 
 	/*
@@ -590,11 +589,14 @@ nfs_lock_and_join_requests(struct page *page)
 
 	nfs_page_group_unlock(head);
 
-	/* drop lock to clean uprequests on destroy list */
-	spin_unlock(&inode->i_lock);
-
 	nfs_destroy_unlinked_subrequests(destroy_list, head, inode);
 
+	/* Did we lose a race with nfs_inode_remove_request()? */
+	if (!(PagePrivate(page) || PageSwapCache(page))) {
+		nfs_unlock_and_release_request(head);
+		return NULL;
+	}
+
 	/* still holds ref on head from nfs_page_find_head_request_locked
 	 * and still has lock on head from lock loop */
 	return head;
@@ -968,7 +970,7 @@ nfs_clear_page_commit(struct page *page)
 		    WB_RECLAIMABLE);
 }
 
-/* Called holding inode (/cinfo) lock */
+/* Called holding the request lock on @req */
 static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
@@ -977,9 +979,11 @@ nfs_clear_request_commit(struct nfs_page *req)
 		struct nfs_commit_info cinfo;
 
 		nfs_init_cinfo_from_inode(&cinfo, inode);
+		spin_lock(&inode->i_lock);
 		if (!pnfs_clear_request_commit(req, &cinfo)) {
 			nfs_request_remove_commit_list(req, &cinfo);
 		}
+		spin_unlock(&inode->i_lock);
 		nfs_clear_page_commit(req->wb_page);
 	}
 }
-- 
2.13.3

