Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f173.google.com ([209.85.161.173]:49797 "EHLO
	mail-gg0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934977Ab3BNVpW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 16:45:22 -0500
Received: by mail-gg0-f173.google.com with SMTP id b6so5599ggm.32
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2013 13:45:21 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: fix comments on nfsd_cache_lookup
Date: Thu, 14 Feb 2013 16:45:13 -0500
Message-Id: <1360878315-21578-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
References: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 40db57e..2f9c2d2 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -302,8 +302,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 
 /*
  * Try to find an entry matching the current call in the cache. When none
- * is found, we grab the oldest unlocked entry off the LRU list.
- * Note that no operation within the loop may sleep.
+ * is found, we try to grab the oldest expired entry off the LRU list. If
+ * a suitable one isn't there, then drop the cache_lock and allocate a
+ * new one, then search again in case one got inserted while this thread
+ * didn't hold the lock.
  */
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp)
@@ -344,6 +346,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		}
 	}
 
+	/* Drop the lock and allocate a new entry */
 	spin_unlock(&cache_lock);
 	rp = nfsd_reply_cache_alloc();
 	if (!rp) {
-- 
1.7.11.7

