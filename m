Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33191 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdHCNpq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:46 -0400
Received: by mail-io0-f193.google.com with SMTP id q64so1310629ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/28] NFS: Fix the inode request accounting when pages have subrequests
Date: Thu,  3 Aug 2017 09:45:04 -0400
Message-Id: <20170803134523.4922-10-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-9-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both nfs_destroy_unlinked_subrequests() and nfs_lock_and_join_requests()
manipulate the inode flags adjusting the NFS_I(inode)->nrequests.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bb38c881fc48..ee981353d4aa 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -418,7 +418,8 @@ nfs_unroll_locks_and_wait(struct inode *inode, struct nfs_page *head,
  */
 static void
 nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
-				 struct nfs_page *old_head)
+				 struct nfs_page *old_head,
+				 struct inode *inode)
 {
 	while (destroy_list) {
 		struct nfs_page *subreq = destroy_list;
@@ -443,9 +444,12 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 			nfs_page_group_clear_bits(subreq);
 
 			/* release the PG_INODE_REF reference */
-			if (test_and_clear_bit(PG_INODE_REF, &subreq->wb_flags))
+			if (test_and_clear_bit(PG_INODE_REF, &subreq->wb_flags)) {
 				nfs_release_request(subreq);
-			else
+				spin_lock(&inode->i_lock);
+				NFS_I(inode)->nrequests--;
+				spin_unlock(&inode->i_lock);
+			} else
 				WARN_ON_ONCE(1);
 		} else {
 			WARN_ON_ONCE(test_bit(PG_CLEAN, &subreq->wb_flags));
@@ -572,25 +576,24 @@ nfs_lock_and_join_requests(struct page *page)
 		head->wb_bytes = total_bytes;
 	}
 
+	/* Postpone destruction of this request */
+	if (test_and_clear_bit(PG_REMOVE, &head->wb_flags)) {
+		set_bit(PG_INODE_REF, &head->wb_flags);
+		kref_get(&head->wb_kref);
+		NFS_I(inode)->nrequests++;
+	}
+
 	/*
 	 * prepare head request to be added to new pgio descriptor
 	 */
 	nfs_page_group_clear_bits(head);
 
-	/*
-	 * some part of the group was still on the inode list - otherwise
-	 * the group wouldn't be involved in async write.
-	 * grab a reference for the head request, iff it needs one.
-	 */
-	if (!test_and_set_bit(PG_INODE_REF, &head->wb_flags))
-		kref_get(&head->wb_kref);
-
 	nfs_page_group_unlock(head);
 
 	/* drop lock to clean uprequests on destroy list */
 	spin_unlock(&inode->i_lock);
 
-	nfs_destroy_unlinked_subrequests(destroy_list, head);
+	nfs_destroy_unlinked_subrequests(destroy_list, head, inode);
 
 	/* still holds ref on head from nfs_page_find_head_request_locked
 	 * and still has lock on head from lock loop */
-- 
2.13.3

