Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34553 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdHCNpk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:45:40 -0400
Received: by mail-it0-f68.google.com with SMTP id t78so1320337ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:45:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/28] NFS: Fix a reference and lock leak in nfs_lock_and_join_requests()
Date: Thu,  3 Aug 2017 09:45:00 -0400
Message-Id: <20170803134523.4922-6-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-5-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, this is a situation that should never happen (hence the WARN_ON)
but we should still ensure that we free up the locks and references to
the faulty pages.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bb019096c331..1ca759719429 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -526,8 +526,7 @@ nfs_lock_and_join_requests(struct page *page)
 		} else if (WARN_ON_ONCE(subreq->wb_offset < head->wb_offset ||
 			    ((subreq->wb_offset + subreq->wb_bytes) >
 			     (head->wb_offset + total_bytes)))) {
-			nfs_page_group_unlock(head);
-			spin_unlock(&inode->i_lock);
+			nfs_unroll_locks_and_wait(inode, head, subreq);
 			return ERR_PTR(-EIO);
 		}
 
-- 
2.13.3

