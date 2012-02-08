Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757349Ab2BHVRL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:17:11 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 02/17] CacheFiles: Downgrade the requirements passed to the
 allocator
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:17:01 +0000
Message-ID: <20120208211701.15607.85808.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index 67bef6d..9bff0f8 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -41,12 +41,12 @@ static struct fscache_object *cachefiles_alloc_object(
 
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
 
@@ -63,7 +63,7 @@ static struct fscache_object *cachefiles_alloc_object(
 	 * - stick the length on the front and leave space on the back for the
 	 *   encoder
 	 */
-	buffer = kmalloc((2 + 512) + 3, GFP_KERNEL);
+	buffer = kmalloc((2 + 512) + 3, cachefiles_gfp);
 	if (!buffer)
 		goto nomem_buffer;
 
@@ -219,7 +219,7 @@ static void cachefiles_update_object(struct fscache_object *_object)
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
index 0186fc1..26a6f52 100644
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
index d7c663c..248a12e 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -759,7 +759,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 
 	fscache_stat(&fscache_n_stores);
 
-	op = kzalloc(sizeof(*op), GFP_NOIO);
+	op = kzalloc(sizeof(*op), GFP_NOIO | __GFP_NOMEMALLOC | __GFP_NORETRY);
 	if (!op)
 		goto nomem;
 

