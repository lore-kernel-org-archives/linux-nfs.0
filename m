Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33222 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751899AbdHCNpw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:52 -0400
Received: by mail-it0-f67.google.com with SMTP id m34so1323046iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/28] NFS: Fix nfs_page_group_destroy() and nfs_lock_and_join_requests() race cases
Date: Thu,  3 Aug 2017 09:45:09 -0400
Message-Id: <20170803134523.4922-15-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-14-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since nfs_page_group_destroy() does not take any locks on the requests
to be freed, we need to ensure that we don't inadvertently free the
request in nfs_destroy_unlinked_subrequests() while the last reference
is being released elsewhere.

Do this by:

1) Taking a reference to the request unless it is already being freed
2) Checking (under the page group lock) if PG_TEARDOWN is already set before
   freeing an unreferenced request in nfs_destroy_unlinked_subrequests()

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 58 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ee5d89380d9..ffb9934607ef 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -384,10 +384,11 @@ nfs_unroll_locks(struct inode *inode, struct nfs_page *head,
 	struct nfs_page *tmp;
 
 	/* relinquish all the locks successfully grabbed this run */
-	for (tmp = head->wb_this_page ; tmp != req; tmp = tmp->wb_this_page)
-		nfs_unlock_request(tmp);
-
-	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
+	for (tmp = head->wb_this_page ; tmp != req; tmp = tmp->wb_this_page) {
+		if (!kref_read(&tmp->wb_kref))
+			continue;
+		nfs_unlock_and_release_request(tmp);
+	}
 }
 
 /*
@@ -414,36 +415,32 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 		WARN_ON_ONCE(old_head != subreq->wb_head);
 
 		/* make sure old group is not used */
-		subreq->wb_head = subreq;
 		subreq->wb_this_page = subreq;
 
-		/* subreq is now totally disconnected from page group or any
-		 * write / commit lists. last chance to wake any waiters */
-		nfs_unlock_request(subreq);
-
-		if (!test_bit(PG_TEARDOWN, &subreq->wb_flags)) {
-			/* release ref on old head request */
-			nfs_release_request(old_head);
+		/* Note: races with nfs_page_group_destroy() */
+		if (!kref_read(&subreq->wb_kref)) {
+			bool freeme = test_bit(PG_TEARDOWN, &subreq->wb_flags);
 
 			nfs_page_group_clear_bits(subreq);
+			/* Check if we raced with nfs_page_group_destroy() */
+			if (freeme)
+				nfs_free_request(subreq);
+			continue;
+		}
 
-			/* release the PG_INODE_REF reference */
-			if (test_and_clear_bit(PG_INODE_REF, &subreq->wb_flags)) {
-				nfs_release_request(subreq);
-				spin_lock(&inode->i_lock);
-				NFS_I(inode)->nrequests--;
-				spin_unlock(&inode->i_lock);
-			} else
-				WARN_ON_ONCE(1);
-		} else {
-			WARN_ON_ONCE(test_bit(PG_CLEAN, &subreq->wb_flags));
-			/* zombie requests have already released the last
-			 * reference and were waiting on the rest of the
-			 * group to complete. Since it's no longer part of a
-			 * group, simply free the request */
-			nfs_page_group_clear_bits(subreq);
-			nfs_free_request(subreq);
+		subreq->wb_head = subreq;
+
+		if (test_and_clear_bit(PG_INODE_REF, &subreq->wb_flags)) {
+			nfs_release_request(subreq);
+			spin_lock(&inode->i_lock);
+			NFS_I(inode)->nrequests--;
+			spin_unlock(&inode->i_lock);
 		}
+
+		nfs_page_group_clear_bits(subreq);
+		/* subreq is now totally disconnected from page group or any
+		 * write / commit lists. last chance to wake any waiters */
+		nfs_unlock_and_release_request(subreq);
 	}
 }
 
@@ -512,6 +509,8 @@ nfs_lock_and_join_requests(struct page *page)
 	for (subreq = head->wb_this_page; subreq != head;
 			subreq = subreq->wb_this_page) {
 
+		if (!kref_get_unless_zero(&subreq->wb_kref))
+			continue;
 		while (!nfs_lock_request(subreq)) {
 			/*
 			 * Unlock page to allow nfs_page_group_sync_on_bit()
@@ -523,6 +522,7 @@ nfs_lock_and_join_requests(struct page *page)
 				ret = nfs_page_group_lock(head, false);
 			if (ret < 0) {
 				nfs_unroll_locks(inode, head, subreq);
+				nfs_release_request(subreq);
 				nfs_unlock_and_release_request(head);
 				return ERR_PTR(ret);
 			}
@@ -537,8 +537,8 @@ nfs_lock_and_join_requests(struct page *page)
 		} else if (WARN_ON_ONCE(subreq->wb_offset < head->wb_offset ||
 			    ((subreq->wb_offset + subreq->wb_bytes) >
 			     (head->wb_offset + total_bytes)))) {
-			nfs_unlock_request(subreq);
 			nfs_unroll_locks(inode, head, subreq);
+			nfs_unlock_and_release_request(subreq);
 			nfs_page_group_unlock(head);
 			nfs_unlock_and_release_request(head);
 			return ERR_PTR(-EIO);
-- 
2.13.3

