Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15938 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078Ab2JPQbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:08 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 12/25] SUNRPC: remove BUG_ON() calls from cache_read()
Date: Tue, 16 Oct 2012 12:30:30 -0400
Message-Id: <1350405043-39316-12-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() in two parts of cache_read().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/cache.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2a68bb3..d051451 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -775,11 +775,11 @@ static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
 	if (rp->q.list.next == &cd->queue) {
 		spin_unlock(&queue_lock);
 		mutex_unlock(&inode->i_mutex);
-		BUG_ON(rp->offset);
+		WARN_ON_ONCE(rp->offset);
 		return 0;
 	}
 	rq = container_of(rp->q.list.next, struct cache_request, q.list);
-	BUG_ON(rq->q.reader);
+	WARN_ON_ONCE(rq->q.reader);
 	if (rp->offset == 0)
 		rq->readers++;
 	spin_unlock(&queue_lock);
-- 
1.7.9.6 (Apple Git-31.1)

