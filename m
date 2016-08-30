Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758156AbcH3Ls0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 07:48:26 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Olaf Hering <olaf@aepfle.de>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH] nfsd: more robust allocation failure handling in nfsd_reply_cache_init
Date: Tue, 30 Aug 2016 07:48:23 -0400
Message-Id: <1472557703-5985-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we try to allocate the cache as a single, large chunk, which
can fail if no big chunks of memory are available. We _do_ try to size
it according to the amount of memory in the box, but if the server is
started well after boot time, then the allocation can fail due to memory
fragmentation.

Try to handle this more gracefully by cutting the max_drc_entries in
half and then retrying if the allocation fails. Only give up if the
failed allocation is smaller than a page.

Reported-by: Olaf Hering <olaf@aepfle.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

While this would be good to get in, I don't see any particular urgency
here. This seems like it'd be reasonable for v4.9.

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 54cde9a5864e..b8aaa7a71412 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -155,14 +155,12 @@ nfsd_reply_cache_free(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
-	unsigned int hashsize;
+	unsigned int hashsize, target_hashsize;
 	unsigned int i;
 	int status = 0;
 
 	max_drc_entries = nfsd_cache_size_limit();
 	atomic_set(&num_drc_entries, 0);
-	hashsize = nfsd_hashsize(max_drc_entries);
-	maskbits = ilog2(hashsize);
 
 	status = register_shrinker(&nfsd_reply_cache_shrinker);
 	if (status)
@@ -173,9 +171,30 @@ int nfsd_reply_cache_init(void)
 	if (!drc_slab)
 		goto out_nomem;
 
-	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
+	/*
+	 * Attempt to allocate the hashtable, and progressively shrink the
+	 * size as the allocations fail. If the allocation size ends up being
+	 * smaller than a page however, then just give up.
+	 */
+	target_hashsize = nfsd_hashsize(max_drc_entries);
+	hashsize = target_hashsize;
+	do {
+		maskbits = ilog2(hashsize);
+		drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl),
+					GFP_KERNEL|__GFP_NOWARN);
+		if (drc_hashtbl)
+			break;
+		max_drc_entries /= 2;
+		hashsize = nfsd_hashsize(max_drc_entries);
+	} while ((hashsize * sizeof(*drc_hashtbl)) >= PAGE_SIZE);
+
 	if (!drc_hashtbl)
 		goto out_nomem;
+
+	if (hashsize != target_hashsize)
+		pr_warn("NFSD: had to shrink reply cache hashtable (wanted %u, got %u)\n",
+			target_hashsize, hashsize);
+
 	for (i = 0; i < hashsize; i++) {
 		INIT_LIST_HEAD(&drc_hashtbl[i].lru_head);
 		spin_lock_init(&drc_hashtbl[i].cache_lock);
-- 
2.7.4

