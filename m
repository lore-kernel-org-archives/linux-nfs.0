Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32994 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753904AbdGSWKI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:08 -0400
Received: by mail-it0-f65.google.com with SMTP id t6so860436itb.0
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 06/20] NFS: Fix an ABBA issue in nfs_lock_and_join_requests()
Date: Wed, 19 Jul 2017 18:09:41 -0400
Message-Id: <20170719220955.58210-7-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-6-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All other callers of nfs_page_group_lock() appear to already hold the
page lock on the head page, so doing it in the opposite order here
is inefficient, although not deadlock prone since we roll back all
locks on contention.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ca759719429..c940e615f5dc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -383,7 +383,7 @@ nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
 	int ret;
 
 	/* relinquish all the locks successfully grabbed this run */
-	for (tmp = head ; tmp != req; tmp = tmp->wb_this_page)
+	for (tmp = head->wb_this_page ; tmp != req; tmp = tmp->wb_this_page)
 		nfs_unlock_request(tmp);
 
 	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
@@ -395,7 +395,7 @@ nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
 	spin_unlock(&inode->i_lock);
 
 	/* release ref from nfs_page_find_head_request_locked */
-	nfs_release_request(head);
+	nfs_unlock_and_release_request(head);
 
 	ret = nfs_wait_on_request(req);
 	nfs_release_request(req);
@@ -484,10 +484,6 @@ nfs_lock_and_join_requests(struct page *page)
 	int ret;
 
 try_again:
-	total_bytes = 0;
-
-	WARN_ON_ONCE(destroy_list);
-
 	spin_lock(&inode->i_lock);
 
 	/*
@@ -502,6 +498,16 @@ nfs_lock_and_join_requests(struct page *page)
 		return NULL;
 	}
 
+	/* lock the page head first in order to avoid an ABBA inefficiency */
+	if (!nfs_lock_request(head)) {
+		spin_unlock(&inode->i_lock);
+		ret = nfs_wait_on_request(head);
+		nfs_release_request(head);
+		if (ret < 0)
+			return ERR_PTR(ret);
+		goto try_again;
+	}
+
 	/* holding inode lock, so always make a non-blocking call to try the
 	 * page group lock */
 	ret = nfs_page_group_lock(head, true);
@@ -509,13 +515,14 @@ nfs_lock_and_join_requests(struct page *page)
 		spin_unlock(&inode->i_lock);
 
 		nfs_page_group_lock_wait(head);
-		nfs_release_request(head);
+		nfs_unlock_and_release_request(head);
 		goto try_again;
 	}
 
 	/* lock each request in the page group */
-	subreq = head;
-	do {
+	total_bytes = head->wb_bytes;
+	for (subreq = head->wb_this_page; subreq != head;
+			subreq = subreq->wb_this_page) {
 		/*
 		 * Subrequests are always contiguous, non overlapping
 		 * and in order - but may be repeated (mirrored writes).
@@ -541,9 +548,7 @@ nfs_lock_and_join_requests(struct page *page)
 
 			return ERR_PTR(ret);
 		}
-
-		subreq = subreq->wb_this_page;
-	} while (subreq != head);
+	}
 
 	/* Now that all requests are locked, make sure they aren't on any list.
 	 * Commit list removal accounting is done after locks are dropped */
-- 
2.13.3

