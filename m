Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f169.google.com ([209.85.160.169]:53129 "EHLO
	mail-gh0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3BDNSV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:21 -0500
Received: by mail-gh0-f169.google.com with SMTP id r18so1513690ghr.14
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:20 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/8] nfsd: remove the cache_disabled flag
Date: Mon,  4 Feb 2013 08:18:03 -0500
Message-Id: <1359983887-28535-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the change to dynamically allocate entries, the cache is never
disabled on the fly. Remove this flag.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index d213e6e..69d29d4 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -21,7 +21,6 @@
 
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
-static int			cache_disabled = 1;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
 static unsigned int		max_drc_entries;
@@ -113,7 +112,6 @@ int nfsd_reply_cache_init(void)
 	INIT_LIST_HEAD(&lru_head);
 	max_drc_entries = nfsd_cache_size_limit();
 	num_drc_entries = 0;
-	cache_disabled = 0;
 	return 0;
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
@@ -130,8 +128,6 @@ void nfsd_reply_cache_shutdown(void)
 		nfsd_reply_cache_free_locked(rp);
 	}
 
-	cache_disabled = 1;
-
 	kfree (cache_hash);
 	cache_hash = NULL;
 
@@ -215,7 +211,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	int rtn;
 
 	rqstp->rq_cacherep = NULL;
-	if (cache_disabled || type == RC_NOCACHE) {
+	if (type == RC_NOCACHE) {
 		nfsdstats.rcnocache++;
 		return RC_DOIT;
 	}
@@ -345,11 +341,11 @@ found_entry:
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

