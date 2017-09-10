Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34278 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751296AbdIJVwr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Sep 2017 17:52:47 -0400
Received: by mail-io0-f196.google.com with SMTP id g32so766417ioj.1
        for <linux-nfs@vger.kernel.org>; Sun, 10 Sep 2017 14:52:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Don't hold the group lock when calling nfs_release_request()
Date: Sun, 10 Sep 2017 17:52:41 -0400
Message-Id: <20170910215242.4212-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That can deadlock if this is the last reference since
nfs_page_group_destroy() calls nfs_page_group_sync_on_bit().
Note that even if the page was removed from the subpage list,
the req->wb_head could still be pointing to the old head.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 121218d4e5ed..36d34a4c86bd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -532,9 +532,9 @@ nfs_lock_and_join_requests(struct page *page)
 		} else if (WARN_ON_ONCE(subreq->wb_offset < head->wb_offset ||
 			    ((subreq->wb_offset + subreq->wb_bytes) >
 			     (head->wb_offset + total_bytes)))) {
+			nfs_page_group_unlock(head);
 			nfs_unroll_locks(inode, head, subreq);
 			nfs_unlock_and_release_request(subreq);
-			nfs_page_group_unlock(head);
 			nfs_unlock_and_release_request(head);
 			return ERR_PTR(-EIO);
 		}
-- 
2.13.5

