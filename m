Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33880 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbHEVNt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:49 -0400
Received: by ykax123 with SMTP id x123so46811560yka.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:49 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/18] nfsd: add a ->flush routine to svc_export_cache
Date: Wed,  5 Aug 2015 17:13:26 -0400
Message-Id: <1438809216-4846-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...to purge the nfsd_file table. This should help ensure that
filesystems are unmountable very soon after unexporting them.

Note that we take the nfsd_mutex in this code to ensure that we can't
race with a concurrent shutdown of nfsd that might destroy the cache.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/export.c    | 14 ++++++++++++++
 fs/nfsd/filecache.c | 39 +++++++++++++++++++++++++--------------
 fs/nfsd/filecache.h |  1 +
 3 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a59747..be80ff370072 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -21,6 +21,7 @@
 #include "nfsfh.h"
 #include "netns.h"
 #include "pnfs.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
@@ -231,6 +232,18 @@ static struct cache_head *expkey_alloc(void)
 		return NULL;
 }
 
+static void
+expkey_flush(void)
+{
+	/*
+	 * Take the nfsd_mutex here to ensure that the file cache is not
+	 * destroyed while we're in the middle of flushing.
+	 */
+	mutex_lock(&nfsd_mutex);
+	nfsd_file_cache_purge();
+	mutex_unlock(&nfsd_mutex);
+}
+
 static struct cache_detail svc_expkey_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPKEY_HASHMAX,
@@ -243,6 +256,7 @@ static struct cache_detail svc_expkey_cache_template = {
 	.init		= expkey_init,
 	.update       	= expkey_update,
 	.alloc		= expkey_alloc,
+	.flush		= expkey_flush,
 };
 
 static int
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 5278b8d9e79a..a3782cf7b352 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -124,6 +124,30 @@ nfsd_file_dispose_list(struct list_head *dispose)
 	}
 }
 
+void
+nfsd_file_cache_purge(void)
+{
+	unsigned int		i;
+	struct nfsd_file	*nf;
+	LIST_HEAD(dispose);
+
+	if (!atomic_read(&nfsd_file_count))
+		return;
+
+	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
+		spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
+		while(!hlist_empty(&nfsd_file_hashtbl[i].nfb_head)) {
+			nf = hlist_entry(nfsd_file_hashtbl[i].nfb_head.first,
+					 struct nfsd_file, nf_node);
+			nfsd_file_unhash(nf);
+			/* put the hash reference */
+			nfsd_file_put_locked(nf, &dispose);
+		}
+		spin_unlock(&nfsd_file_hashtbl[i].nfb_lock);
+		nfsd_file_dispose_list(&dispose);
+	}
+}
+
 static void
 nfsd_file_cache_prune(void)
 {
@@ -200,23 +224,10 @@ out_nomem:
 void
 nfsd_file_cache_shutdown(void)
 {
-	unsigned int		i;
-	struct nfsd_file	*nf;
 	LIST_HEAD(dispose);
 
 	cancel_delayed_work_sync(&nfsd_file_cache_clean_work);
-	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
-		spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
-		while(!hlist_empty(&nfsd_file_hashtbl[i].nfb_head)) {
-			nf = hlist_entry(nfsd_file_hashtbl[i].nfb_head.first,
-					 struct nfsd_file, nf_node);
-			nfsd_file_unhash(nf);
-			/* put the hash reference */
-			nfsd_file_put_locked(nf, &dispose);
-		}
-		spin_unlock(&nfsd_file_hashtbl[i].nfb_lock);
-		nfsd_file_dispose_list(&dispose);
-	}
+	nfsd_file_cache_purge();
 	kfree(nfsd_file_hashtbl);
 	nfsd_file_hashtbl = NULL;
 }
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index adf7e78b8e43..98976f71caa8 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -39,6 +39,7 @@ struct nfsd_file {
 };
 
 int nfsd_file_cache_init(void);
+void nfsd_file_cache_purge(void);
 void nfsd_file_cache_shutdown(void);
 void nfsd_file_put(struct nfsd_file *nf);
 __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
-- 
2.4.3

