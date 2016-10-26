Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755132AbcJZL0m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Oct 2016 07:26:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: olaf@aepfle.de, torvalds@linux-foundation.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfsd: more robust allocation failure handling in nfsd_reply_cache_init
Date: Wed, 26 Oct 2016 07:26:40 -0400
Message-Id: <1477481200-4730-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we try to allocate the cache as a single, large chunk, which
can fail if no big chunks of memory are available. We _do_ try to size
it according to the amount of memory in the box, but if the server is
started well after boot time, then the allocation can fail due to memory
fragmentation.

Fall back to doing a vzalloc if the kcalloc fails, and switch the
shutdown code to do a kvfree to handle freeing correctly.

Reported-by: Olaf Hering <olaf@aepfle.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 54cde9a5864e..d6b97b424ad1 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/highmem.h>
 #include <linux/log2.h>
@@ -174,8 +175,12 @@ int nfsd_reply_cache_init(void)
 		goto out_nomem;
 
 	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
-	if (!drc_hashtbl)
-		goto out_nomem;
+	if (!drc_hashtbl) {
+		drc_hashtbl = vzalloc(hashsize * sizeof(*drc_hashtbl));
+		if (!drc_hashtbl)
+			goto out_nomem;
+	}
+
 	for (i = 0; i < hashsize; i++) {
 		INIT_LIST_HEAD(&drc_hashtbl[i].lru_head);
 		spin_lock_init(&drc_hashtbl[i].cache_lock);
@@ -204,7 +209,7 @@ void nfsd_reply_cache_shutdown(void)
 		}
 	}
 
-	kfree (drc_hashtbl);
+	kvfree(drc_hashtbl);
 	drc_hashtbl = NULL;
 	drc_hashsize = 0;
 
-- 
2.7.4

