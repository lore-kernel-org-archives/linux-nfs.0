Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:59727 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:42:04 -0500
Received: by mail-ye0-f174.google.com with SMTP id m3so473333yen.33
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:42:02 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 11/16] nfsd: remove the cache_disabled flag
Date: Mon, 28 Jan 2013 14:41:17 -0500
Message-Id: <1359402082-29195-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we dynamically allocate entries, we never disable the cache
on the fly. Remove this flag.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ad96f1d..5a39b82 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -20,7 +20,6 @@
 
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
-static int			cache_disabled = 1;
 static struct kmem_cache	*drc_slab;
 
 /*
@@ -79,7 +78,6 @@ int nfsd_reply_cache_init(void)
 		goto out_nomem;
 
 	INIT_LIST_HEAD(&lru_head);
-	cache_disabled = 0;
 	return 0;
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
@@ -96,8 +94,6 @@ void nfsd_reply_cache_shutdown(void)
 		nfsd_reply_cache_free_locked(rp);
 	}
 
-	cache_disabled = 1;
-
 	kfree (cache_hash);
 	cache_hash = NULL;
 
@@ -181,7 +177,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	int rtn;
 
 	rqstp->rq_cacherep = NULL;
-	if (cache_disabled || type == RC_NOCACHE) {
+	if (type == RC_NOCACHE) {
 		nfsdstats.rcnocache++;
 		return RC_DOIT;
 	}
@@ -303,11 +299,11 @@ found_entry:
 void
 nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 {
-	struct svc_cacherep *rp;
+	struct svc_cacherep *rp = rqstp->rq_cacherep;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
 
-	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
+	if (!rp)
 		return;
 
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
-- 
1.7.11.7

