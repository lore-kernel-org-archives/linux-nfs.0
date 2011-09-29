Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab1I2Or0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:47:26 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/13] CacheFiles: Downgrade the requirements passed to the
 allocator
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:46:25 +0100
Message-ID: <20110929144625.5812.70900.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Downgrade the requirements passed to the allocator in the gfp flags parameter.
FS-Cache/CacheFiles can handle OOM conditions simply by aborting the attempt to
store an object or a page in the cache.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/interface.c |    8 ++++----
 fs/cachefiles/internal.h  |    2 ++
 fs/cachefiles/key.c       |    2 +-
 fs/cachefiles/rdwr.c      |   18 ++++++++++--------
 fs/cachefiles/xattr.c     |    2 +-
 fs/fscache/page.c         |    2 +-
 6 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 1064805..075b7a6 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -42,12 +42,12 @@ static struct fscache_object *cachefiles_alloc_object(
 
 	_enter("{%s},%p,", cache->cache.identifier, cookie);
 
-	lookup_data = kmalloc(sizeof(*lookup_data), GFP_KERNEL);
+	lookup_data = kmalloc(sizeof(*lookup_data), cachefiles_gfp);
 	if (!lookup_data)
 		goto nomem_lookup_data;
 
 	/* create a new object record and a temporary leaf image */
-	object = kmem_cache_alloc(cachefiles_object_jar, GFP_KERNEL);
+	object = kmem_cache_alloc(cachefiles_object_jar, cachefiles_gfp);
 	if (!object)
 		goto nomem_object;
 
@@ -64,7 +64,7 @@ static struct fscache_object *cachefiles_alloc_object(
 	 * - stick the length on the front and leave space on the back for the
 	 *   encoder
 	 */
-	buffer = kmalloc((2 + 512) + 3, GFP_KERNEL);
+	buffer = kmalloc((2 + 512) + 3, cachefiles_gfp);
 	if (!buffer)
 		goto nomem_buffer;
 
@@ -220,7 +220,7 @@ static void cachefiles_update_object(struct fscache_object *_object)
 		return;
 	}
 
-	auxdata = kmalloc(2 + 512 + 3, GFP_KERNEL);
+	auxdata = kmalloc(2 + 512 + 3, cachefiles_gfp);
 	if (!auxdata) {
 		_leave(" [nomem]");
 		return;
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index bd6bc1b..4938251 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -23,6 +23,8 @@ extern unsigned cachefiles_debug;
 #define CACHEFILES_DEBUG_KLEAVE	2
 #define CACHEFILES_DEBUG_KDEBUG	4
 
+#define cachefiles_gfp (__GFP_WAIT | __GFP_NORETRY | __GFP_NOMEMALLOC)
+
 /*
  * node records
  */
diff --git a/fs/cachefiles/key.c b/fs/cachefiles/key.c
index 81b8b2b..33b58c6 100644
--- a/fs/cachefiles/key.c
+++ b/fs/cachefiles/key.c
@@ -78,7 +78,7 @@ char *cachefiles_cook_key(const u8 *raw, int keylen, uint8_t type)
 
 	_debug("max: %d", max);
 
-	key = kmalloc(max, GFP_KERNEL);
+	key = kmalloc(max, cachefiles_gfp);
 	if (!key)
 		return NULL;
 
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index e8c3766..96e6940 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -238,7 +238,7 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 	_debug("read back %p{%lu,%d}",
 	       netpage, netpage->index, page_count(netpage));
 
-	monitor = kzalloc(sizeof(*monitor), GFP_KERNEL);
+	monitor = kzalloc(sizeof(*monitor), cachefiles_gfp);
 	if (!monitor)
 		goto nomem;
 
@@ -257,13 +257,14 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 			goto backing_page_already_present;
 
 		if (!newpage) {
-			newpage = page_cache_alloc_cold(bmapping);
+			newpage = __page_cache_alloc(cachefiles_gfp |
+						     __GFP_COLD);
 			if (!newpage)
 				goto nomem_monitor;
 		}
 
 		ret = add_to_page_cache(newpage, bmapping,
-					netpage->index, GFP_KERNEL);
+					netpage->index, cachefiles_gfp);
 		if (ret == 0)
 			goto installed_new_backing_page;
 		if (ret != -EEXIST)
@@ -481,7 +482,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		       netpage, netpage->index, page_count(netpage));
 
 		if (!monitor) {
-			monitor = kzalloc(sizeof(*monitor), GFP_KERNEL);
+			monitor = kzalloc(sizeof(*monitor), cachefiles_gfp);
 			if (!monitor)
 				goto nomem;
 
@@ -496,13 +497,14 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 				goto backing_page_already_present;
 
 			if (!newpage) {
-				newpage = page_cache_alloc_cold(bmapping);
+				newpage = __page_cache_alloc(cachefiles_gfp |
+							     __GFP_COLD);
 				if (!newpage)
 					goto nomem;
 			}
 
 			ret = add_to_page_cache(newpage, bmapping,
-						netpage->index, GFP_KERNEL);
+						netpage->index, cachefiles_gfp);
 			if (ret == 0)
 				goto installed_new_backing_page;
 			if (ret != -EEXIST)
@@ -532,7 +534,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		_debug("- monitor add");
 
 		ret = add_to_page_cache(netpage, op->mapping, netpage->index,
-					GFP_KERNEL);
+					cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
 				page_cache_release(netpage);
@@ -608,7 +610,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		_debug("- uptodate");
 
 		ret = add_to_page_cache(netpage, op->mapping, netpage->index,
-					GFP_KERNEL);
+					cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
 				page_cache_release(netpage);
diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
index e18b183..73b4628 100644
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -174,7 +174,7 @@ int cachefiles_check_object_xattr(struct cachefiles_object *object,
 	ASSERT(dentry);
 	ASSERT(dentry->d_inode);
 
-	auxbuf = kmalloc(sizeof(struct cachefiles_xattr) + 512, GFP_KERNEL);
+	auxbuf = kmalloc(sizeof(struct cachefiles_xattr) + 512, cachefiles_gfp);
 	if (!auxbuf) {
 		_leave(" = -ENOMEM");
 		return -ENOMEM;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 5e793b5..b8b62f4 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -759,7 +759,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 
 	fscache_stat(&fscache_n_stores);
 
-	op = kzalloc(sizeof(*op), GFP_NOIO);
+	op = kzalloc(sizeof(*op), GFP_NOIO | __GFP_NOMEMALLOC | __GFP_NORETRY);
 	if (!op)
 		goto nomem;
 

