Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40493 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705Ab3AOII5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 03:08:57 -0500
Subject: [PATCH 3/4] SUNRPC: remove "cache_request" argument in
	sunrpc_cache_pipe_upcall() function
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 15 Jan 2013 11:09:41 +0300
Message-ID: <20130115080941.2996.98012.stgit@localhost.localdomain>
In-Reply-To: <20130115080402.2996.74320.stgit@localhost.localdomain>
References: <20130115080402.2996.74320.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Passing this pointer is redundant since it's stored on cache_detail structure,
which is also passed to sunrpc_cache_pipe_upcall () function.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/dns_resolve.c         |    2 +-
 include/linux/sunrpc/cache.h |    6 +-----
 net/sunrpc/cache.c           |   10 +++-------
 3 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 90edbd0..f5c4c35 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -142,7 +142,7 @@ static int nfs_dns_upcall(struct cache_detail *cd,
 
 	ret = nfs_cache_upcall(cd, key->hostname);
 	if (ret)
-		ret = sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
+		ret = sunrpc_cache_pipe_upcall(cd, ch);
 	return ret;
 }
 
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 249e73a..ea927ea 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -158,11 +158,7 @@ sunrpc_cache_update(struct cache_detail *detail,
 		    struct cache_head *new, struct cache_head *old, int hash);
 
 extern int
-sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
-		void (*cache_request)(struct cache_detail *,
-				      struct cache_head *,
-				      char **,
-				      int *));
+sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h);
 
 
 extern void cache_clean_deferred(void *owner);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ee6b5dd..901fdca 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -198,7 +198,7 @@ static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 {
 	if (!cd->cache_request)
 		return -EINVAL;
-	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
+	return sunrpc_cache_pipe_upcall(cd, h);
 }
 
 static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
@@ -1140,11 +1140,7 @@ static bool cache_listeners_exist(struct cache_detail *detail)
  *
  * Each request is at most one page long.
  */
-int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
-		void (*cache_request)(struct cache_detail *,
-				      struct cache_head *,
-				      char **,
-				      int *))
+int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 {
 
 	char *buf;
@@ -1169,7 +1165,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 
 	bp = buf; len = PAGE_SIZE;
 
-	cache_request(detail, h, &bp, &len);
+	detail->cache_request(detail, h, &bp, &len);
 
 	if (len < 0) {
 		kfree(buf);

