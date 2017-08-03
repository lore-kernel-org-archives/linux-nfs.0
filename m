Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33219 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdHCNpv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:51 -0400
Received: by mail-it0-f65.google.com with SMTP id m34so1323023iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 13/28] NFS: Further optimise nfs_lock_and_join_requests()
Date: Thu,  3 Aug 2017 09:45:08 -0400
Message-Id: <20170803134523.4922-14-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-13-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When locking the entire group in order to remove subrequests,
the locks are always taken in order, and with the page group
lock being taken after the page head is locked. The intention
is that:

1) The lock on the group head guarantees that requests may not
   be removed from the group (although new entries could be appended
   if we're not holding the group lock).
2) It is safe to drop and retake the page group lock while iterating
   through the list, in particular when waiting for a subrequest lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 45 ++++++++++++++++++---------------------------
 1 file changed, 18 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ff7c90c7ff79..1ee5d89380d9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -377,31 +377,17 @@ nfs_page_group_clear_bits(struct nfs_page *req)
  *
  * returns 0 on success, < 0 on error.
  */
-static int
-nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
+static void
+nfs_unroll_locks(struct inode *inode, struct nfs_page *head,
 			  struct nfs_page *req)
 {
 	struct nfs_page *tmp;
-	int ret;
 
 	/* relinquish all the locks successfully grabbed this run */
 	for (tmp = head->wb_this_page ; tmp != req; tmp = tmp->wb_this_page)
 		nfs_unlock_request(tmp);
 
 	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
-
-	/* grab a ref on the request that will be waited on */
-	kref_get(&req->wb_kref);
-
-	nfs_page_group_unlock(head);
-
-	/* release ref from nfs_page_find_head_request_locked */
-	nfs_unlock_and_release_request(head);
-
-	ret = nfs_wait_on_request(req);
-	nfs_release_request(req);
-
-	return ret;
 }
 
 /*
@@ -525,18 +511,21 @@ nfs_lock_and_join_requests(struct page *page)
 	total_bytes = head->wb_bytes;
 	for (subreq = head->wb_this_page; subreq != head;
 			subreq = subreq->wb_this_page) {
-		if (!nfs_lock_request(subreq)) {
+
+		while (!nfs_lock_request(subreq)) {
 			/*
-			 * releases page group bit lock and
-			 * page locks and all references
+			 * Unlock page to allow nfs_page_group_sync_on_bit()
+			 * to succeed
 			 */
-			ret = nfs_unroll_locks_and_wait(inode, head,
-				subreq);
-
-			if (ret == 0)
-				goto try_again;
-
-			return ERR_PTR(ret);
+			nfs_page_group_unlock(head);
+			ret = nfs_wait_on_request(subreq);
+			if (!ret)
+				ret = nfs_page_group_lock(head, false);
+			if (ret < 0) {
+				nfs_unroll_locks(inode, head, subreq);
+				nfs_unlock_and_release_request(head);
+				return ERR_PTR(ret);
+			}
 		}
 		/*
 		 * Subrequests are always contiguous, non overlapping
@@ -549,7 +538,9 @@ nfs_lock_and_join_requests(struct page *page)
 			    ((subreq->wb_offset + subreq->wb_bytes) >
 			     (head->wb_offset + total_bytes)))) {
 			nfs_unlock_request(subreq);
-			nfs_unroll_locks_and_wait(inode, head, subreq);
+			nfs_unroll_locks(inode, head, subreq);
+			nfs_page_group_unlock(head);
+			nfs_unlock_and_release_request(head);
 			return ERR_PTR(-EIO);
 		}
 	}
-- 
2.13.3

