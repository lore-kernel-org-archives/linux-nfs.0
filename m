Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35306 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754584AbdGSWKI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:08 -0400
Received: by mail-it0-f65.google.com with SMTP id v127so855013itd.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 05/20] NFS: Fix a reference and lock leak in nfs_lock_and_join_requests()
Date: Wed, 19 Jul 2017 18:09:40 -0400
Message-Id: <20170719220955.58210-6-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-5-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
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

