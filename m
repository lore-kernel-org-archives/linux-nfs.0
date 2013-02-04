Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f180.google.com ([209.85.160.180]:32924 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3BDNS2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:28 -0500
Received: by mail-gh0-f180.google.com with SMTP id f13so1525034ghb.11
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:28 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/8] nfsd: register a shrinker for DRC cache entries
Date: Mon,  4 Feb 2013 08:18:06 -0500
Message-Id: <1359983887-28535-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we dynamically allocate them now, allow the system to call us up
to release them if it gets low on memory. Since these entries aren't
replaceable, only free ones that are expired or that are over the cap.
The the seeks value is set to '1' however to indicate that freeing the
these entries is low-cost.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index d7b088b..d16a5d6 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -37,6 +37,13 @@ static inline u32 request_hash(u32 xid)
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 static void	cache_cleaner_func(struct work_struct *unused);
+static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
+					struct shrink_control *sc);
+
+struct shrinker nfsd_reply_cache_shrinker = {
+	.shrink	= nfsd_reply_cache_shrink,
+	.seeks	= 1,
+};
 
 /*
  * locking for the reply cache:
@@ -110,6 +117,7 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
+	register_shrinker(&nfsd_reply_cache_shrinker);
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
 	if (!drc_slab)
@@ -133,6 +141,7 @@ void nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
 
+	unregister_shrinker(&nfsd_reply_cache_shrinker);
 	cancel_delayed_work_sync(&cache_cleaner);
 
 	while (!list_empty(&lru_head)) {
@@ -214,6 +223,20 @@ cache_cleaner_func(struct work_struct *unused)
 	spin_unlock(&cache_lock);
 }
 
+static int
+nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
+{
+	unsigned int num;
+
+	spin_lock(&cache_lock);
+	if (sc->nr_to_scan)
+		prune_cache_entries();
+	num = num_drc_entries;
+	spin_unlock(&cache_lock);
+
+	return num;
+}
+
 /*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
-- 
1.7.11.7

