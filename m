Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34807 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbbHTLRc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:32 -0400
Received: by ykdt205 with SMTP id t205so33872295ykd.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:31 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 05/20] nfsd: add a shrinker to the nfsd_file cache
Date: Thu, 20 Aug 2015 07:17:05 -0400
Message-Id: <1440069440-27454-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 63b24419c674..669e62f6f4f6 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -118,6 +118,46 @@ nfsd_file_dispose_list(struct list_head *dispose)
 	}
 }
 
+static enum lru_status
+nfsd_file_lru_cb(struct list_head *item, struct list_lru_one *lru,
+		 spinlock_t *lock, void *arg)
+	__releases(lock)
+	__acquires(lock)
+{
+	struct nfsd_file *nf = list_entry(item, struct nfsd_file, nf_lru);
+	bool unhashed;
+
+	if (atomic_read(&nf->nf_ref) > 1)
+		return LRU_SKIP;
+
+	spin_unlock(lock);
+	spin_lock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	unhashed = nfsd_file_unhash(nf);
+	spin_unlock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	if (unhashed)
+		nfsd_file_put(nf);
+	spin_lock(lock);
+	return unhashed ? LRU_REMOVED_RETRY : LRU_RETRY;
+}
+
+static unsigned long
+nfsd_file_lru_count(struct shrinker *s, struct shrink_control *sc)
+{
+	return list_lru_count(&nfsd_file_lru);
+}
+
+static unsigned long
+nfsd_file_lru_scan(struct shrinker *s, struct shrink_control *sc)
+{
+	return list_lru_shrink_walk(&nfsd_file_lru, sc, nfsd_file_lru_cb, NULL);
+}
+
+static struct shrinker	nfsd_file_shrinker = {
+	.scan_objects = nfsd_file_lru_scan,
+	.count_objects = nfsd_file_lru_count,
+	.seeks = 1,
+};
+
 int
 nfsd_file_cache_init(void)
 {
@@ -140,12 +180,20 @@ nfsd_file_cache_init(void)
 		goto out_err;
 	}
 
+	ret = register_shrinker(&nfsd_file_shrinker);
+	if (ret) {
+		pr_err("nfsd: failed to register nfsd_file_shrinker: %d\n", ret);
+		goto out_lru;
+	}
+
 	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
 		INIT_HLIST_HEAD(&nfsd_file_hashtbl[i].nfb_head);
 		spin_lock_init(&nfsd_file_hashtbl[i].nfb_lock);
 	}
 out:
 	return ret;
+out_lru:
+	list_lru_destroy(&nfsd_file_lru);
 out_err:
 	kfree(nfsd_file_hashtbl);
 	nfsd_file_hashtbl = NULL;
@@ -159,6 +207,7 @@ nfsd_file_cache_shutdown(void)
 	struct nfsd_file	*nf;
 	LIST_HEAD(dispose);
 
+	unregister_shrinker(&nfsd_file_shrinker);
 	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
 		spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
 		while(!hlist_empty(&nfsd_file_hashtbl[i].nfb_head)) {
-- 
2.4.3

