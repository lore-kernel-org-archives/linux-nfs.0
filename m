Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35311 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbdGSWKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:10 -0400
Received: by mail-it0-f65.google.com with SMTP id v127so855065itd.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 07/20] NFS: Don't check request offset and size without holding a lock
Date: Wed, 19 Jul 2017 18:09:42 -0400
Message-Id: <20170719220955.58210-8-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-7-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Request offsets and sizes are not guaranteed to be stable unless you
are holding the request locked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c940e615f5dc..84b6818e5278 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -523,6 +523,17 @@ nfs_lock_and_join_requests(struct page *page)
 	total_bytes = head->wb_bytes;
 	for (subreq = head->wb_this_page; subreq != head;
 			subreq = subreq->wb_this_page) {
+		if (!nfs_lock_request(subreq)) {
+			/* releases page group bit lock and
+			 * inode spin lock and all references */
+			ret = nfs_unroll_locks_and_wait(inode, head,
+				subreq);
+
+			if (ret == 0)
+				goto try_again;
+
+			return ERR_PTR(ret);
+		}
 		/*
 		 * Subrequests are always contiguous, non overlapping
 		 * and in order - but may be repeated (mirrored writes).
@@ -533,21 +544,10 @@ nfs_lock_and_join_requests(struct page *page)
 		} else if (WARN_ON_ONCE(subreq->wb_offset < head->wb_offset ||
 			    ((subreq->wb_offset + subreq->wb_bytes) >
 			     (head->wb_offset + total_bytes)))) {
+			nfs_unlock_request(subreq);
 			nfs_unroll_locks_and_wait(inode, head, subreq);
 			return ERR_PTR(-EIO);
 		}
-
-		if (!nfs_lock_request(subreq)) {
-			/* releases page group bit lock and
-			 * inode spin lock and all references */
-			ret = nfs_unroll_locks_and_wait(inode, head,
-				subreq);
-
-			if (ret == 0)
-				goto try_again;
-
-			return ERR_PTR(ret);
-		}
 	}
 
 	/* Now that all requests are locked, make sure they aren't on any list.
-- 
2.13.3

