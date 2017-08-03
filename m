Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35228 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdHCNpx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:53 -0400
Received: by mail-it0-f66.google.com with SMTP id v127so1319435itd.2
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 15/28] NFS: Remove nfs_page_group_clear_bits()
Date: Thu,  3 Aug 2017 09:45:10 -0400
Message-Id: <20170803134523.4922-16-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-15-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At this point, we only expect ever to potentially see PG_REMOVE and
PG_TEARDOWN being set on the subrequests.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 29 +++--------------------------
 1 file changed, 3 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ffb9934607ef..20d44ea328b6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -347,22 +347,6 @@ static void nfs_end_page_writeback(struct nfs_page *req)
 		clear_bdi_congested(inode_to_bdi(inode), BLK_RW_ASYNC);
 }
 
-
-/* nfs_page_group_clear_bits
- *   @req - an nfs request
- * clears all page group related bits from @req
- */
-static void
-nfs_page_group_clear_bits(struct nfs_page *req)
-{
-	clear_bit(PG_TEARDOWN, &req->wb_flags);
-	clear_bit(PG_UNLOCKPAGE, &req->wb_flags);
-	clear_bit(PG_UPTODATE, &req->wb_flags);
-	clear_bit(PG_WB_END, &req->wb_flags);
-	clear_bit(PG_REMOVE, &req->wb_flags);
-}
-
-
 /*
  * nfs_unroll_locks_and_wait -  unlock all newly locked reqs and wait on @req
  *
@@ -417,13 +401,12 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 		/* make sure old group is not used */
 		subreq->wb_this_page = subreq;
 
+		clear_bit(PG_REMOVE, &subreq->wb_flags);
+
 		/* Note: races with nfs_page_group_destroy() */
 		if (!kref_read(&subreq->wb_kref)) {
-			bool freeme = test_bit(PG_TEARDOWN, &subreq->wb_flags);
-
-			nfs_page_group_clear_bits(subreq);
 			/* Check if we raced with nfs_page_group_destroy() */
-			if (freeme)
+			if (test_and_clear_bit(PG_TEARDOWN, &subreq->wb_flags))
 				nfs_free_request(subreq);
 			continue;
 		}
@@ -437,7 +420,6 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 			spin_unlock(&inode->i_lock);
 		}
 
-		nfs_page_group_clear_bits(subreq);
 		/* subreq is now totally disconnected from page group or any
 		 * write / commit lists. last chance to wake any waiters */
 		nfs_unlock_and_release_request(subreq);
@@ -573,11 +555,6 @@ nfs_lock_and_join_requests(struct page *page)
 		spin_unlock(&inode->i_lock);
 	}
 
-	/*
-	 * prepare head request to be added to new pgio descriptor
-	 */
-	nfs_page_group_clear_bits(head);
-
 	nfs_page_group_unlock(head);
 
 	nfs_destroy_unlinked_subrequests(destroy_list, head, inode);
-- 
2.13.3

