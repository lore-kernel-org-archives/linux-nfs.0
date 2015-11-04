Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030439AbbKDPUq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 10:20:46 -0500
Subject: [PATCH 4/4] FS-Cache: Handle a write to the page immediately beyond
 the EOF marker
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
        linux-kernel@vger.kernel.org
Date: Wed, 04 Nov 2015 15:20:42 +0000
Message-ID: <20151104152042.2987.95657.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
References: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle a write being requested to the page immediately beyond the EOF
marker on a cache object.  Currently this gets an assertion failure in
CacheFiles because the EOF marker is used there to encode information about
a partial page at the EOF - which could lead to an unknown blank spot in
the file if we extend the file over it.

The problem is actually in fscache where we check the index of the page
being written against store_limit.  store_limit is set to the number of
pages that we're allowed to store by fscache_set_store_limit() - which
means it's one more than the index of the last page we're allowed to store.
The problem is that we permit writing to a page with an index _equal_ to
the store limit - when we should reject that case.

Whilst we're at it, change the triggered assertion in CacheFiles to just
return -ENOBUFS instead.

The assertion failure looks something like this:

CacheFiles: Assertion failed
1000 < 7b1 is false
------------[ cut here ]------------
kernel BUG at fs/cachefiles/rdwr.c:962!
...
RIP: 0010:[<ffffffffa02c9e83>]  [<ffffffffa02c9e83>] cachefiles_write_page+0x273/0x2d0 [cachefiles]

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/rdwr.c |   67 ++++++++++++++++++++++++++++----------------------
 fs/fscache/page.c    |    2 +
 2 files changed, 38 insertions(+), 31 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index e76c2452ac40..7a6b02f72787 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -899,6 +899,15 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 	cache = container_of(object->fscache.cache,
 			     struct cachefiles_cache, cache);
 
+	pos = (loff_t)page->index << PAGE_SHIFT;
+
+	/* We mustn't write more data than we have, so we have to beware of a
+	 * partial page at EOF.
+	 */
+	eof = object->fscache.store_limit_l;
+	if (pos >= eof)
+		goto error;
+
 	/* write the page to the backing filesystem and let it store it in its
 	 * own time */
 	path.mnt = cache->mnt;
@@ -906,40 +915,38 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 	file = dentry_open(&path, O_RDWR | O_LARGEFILE, cache->cache_cred);
 	if (IS_ERR(file)) {
 		ret = PTR_ERR(file);
-	} else {
-		pos = (loff_t) page->index << PAGE_SHIFT;
-
-		/* we mustn't write more data than we have, so we have
-		 * to beware of a partial page at EOF */
-		eof = object->fscache.store_limit_l;
-		len = PAGE_SIZE;
-		if (eof & ~PAGE_MASK) {
-			ASSERTCMP(pos, <, eof);
-			if (eof - pos < PAGE_SIZE) {
-				_debug("cut short %llx to %llx",
-				       pos, eof);
-				len = eof - pos;
-				ASSERTCMP(pos + len, ==, eof);
-			}
-		}
-
-		data = kmap(page);
-		ret = __kernel_write(file, data, len, &pos);
-		kunmap(page);
-		if (ret != len)
-			ret = -EIO;
-		fput(file);
+		goto error_2;
 	}
 
-	if (ret < 0) {
-		if (ret == -EIO)
-			cachefiles_io_error_obj(
-				object, "Write page to backing file failed");
-		ret = -ENOBUFS;
+	len = PAGE_SIZE;
+	if (eof & ~PAGE_MASK) {
+		if (eof - pos < PAGE_SIZE) {
+			_debug("cut short %llx to %llx",
+			       pos, eof);
+			len = eof - pos;
+			ASSERTCMP(pos + len, ==, eof);
+		}
 	}
 
-	_leave(" = %d", ret);
-	return ret;
+	data = kmap(page);
+	ret = __kernel_write(file, data, len, &pos);
+	kunmap(page);
+	fput(file);
+	if (ret != len)
+		goto error_eio;
+
+	_leave(" = 0");
+	return 0;
+
+error_eio:
+	ret = -EIO;
+error_2:
+	if (ret == -EIO)
+		cachefiles_io_error_obj(object,
+					"Write page to backing file failed");
+error:
+	_leave(" = -ENOBUFS [%d]", ret);
+	return -ENOBUFS;
 }
 
 /*
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 483bbc613bf0..ca916af5a7c4 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -816,7 +816,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 		goto superseded;
 	page = results[0];
 	_debug("gang %d [%lx]", n, page->index);
-	if (page->index > op->store_limit) {
+	if (page->index >= op->store_limit) {
 		fscache_stat(&fscache_n_store_pages_over_limit);
 		goto superseded;
 	}

