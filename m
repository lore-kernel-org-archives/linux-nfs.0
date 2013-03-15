Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f49.google.com ([209.85.219.49]:53373 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab3CONQf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2013 09:16:35 -0400
Received: by mail-oa0-f49.google.com with SMTP id j6so3307336oag.8
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2013 06:16:35 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix startup order in nfsd_reply_cache_init
Date: Fri, 15 Mar 2013 09:16:29 -0400
Message-Id: <1363353389-11659-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we end up doing "goto out_nomem" in this function, we'll call
nfsd_reply_cache_shutdown. That will attempt to walk the LRU list and
free entries, but that list may not be initialized yet if the server is
starting up for the first time. It's also possible for the shrinker to
kick in before we've initialized the LRU list.

Rearrange the initialization so that the LRU list_head and cache size
are initialized before doing any of the allocations that might fail.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 62c1ee1..f5ad28e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -118,6 +118,10 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
+	INIT_LIST_HEAD(&lru_head);
+	max_drc_entries = nfsd_cache_size_limit();
+	num_drc_entries = 0;
+
 	register_shrinker(&nfsd_reply_cache_shrinker);
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
@@ -128,10 +132,6 @@ int nfsd_reply_cache_init(void)
 	if (!cache_hash)
 		goto out_nomem;
 
-	INIT_LIST_HEAD(&lru_head);
-	max_drc_entries = nfsd_cache_size_limit();
-	num_drc_entries = 0;
-
 	return 0;
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
-- 
1.7.11.7

