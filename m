Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36420 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbbGKMwA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 08:52:00 -0400
Message-ID: <55A11163.9080506@gmail.com>
Date: Sat, 11 Jul 2015 20:51:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 09/10 v7] sunrpc: Support get_ref/put_ref for reference change
 in cache_head
References: <55A11010.6050005@gmail.com>
In-Reply-To: <55A11010.6050005@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add get_ref/put_ref functions in cache_head for processing
reference change (increase/decrease)

v7, new one

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h | 15 +++++++++++++--
 net/sunrpc/cache.c           |  2 ++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 5a4b921..77bc623 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -52,6 +52,9 @@ struct cache_head {
 					 * was sent, else this is when update was received
 					 */
 	struct kref	ref;
+	void		(*get_ref)(struct cache_head *);
+	void		(*put_ref)(struct cache_head *);
+
 	unsigned long	flags;
 };
 #define	CACHE_VALID	0	/* Entry contains valid data */
@@ -187,7 +190,11 @@ extern void cache_clean_deferred(void *owner);
 
 static inline struct cache_head  *cache_get(struct cache_head *h)
 {
-	kref_get(&h->ref);
+	if (h->get_ref) {
+		h->get_ref(h);
+	} else
+		kref_get(&h->ref);
+
 	return h;
 }
 
@@ -197,7 +204,11 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 	if (atomic_read(&h->ref.refcount) <= 2 &&
 	    h->expiry_time < cd->nextcheck)
 		cd->nextcheck = h->expiry_time;
-	kref_put(&h->ref, cd->cache_put);
+
+	if (h->put_ref) {
+		h->put_ref(h);
+	} else
+		kref_put(&h->ref, cd->cache_put);
 }
 
 static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8a27483..1ca88b0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -49,6 +49,8 @@ static void cache_init(struct cache_head *h)
 	kref_init(&h->ref);
 	h->expiry_time = now + CACHE_NEW_EXPIRY;
 	h->last_refresh = now;
+	h->get_ref = NULL;
+	h->put_ref = NULL;
 }
 
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
-- 
2.4.3

