Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756092Ab2BHVSX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:18:23 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 09/17] CacheFiles: Implement invalidation
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:18:13 +0000
Message-ID: <20120208211813.15607.14339.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement invalidation for CacheFiles.  This is in two parts:

 (1) Provide an invalidation method (which just truncates the backing file).

 (2) Abort attempts to copy anything read from the backing file whilst
     invalidation is in progress.

Question: CacheFiles uses truncation in a couple of places.  It has been using
notify_change() rather than sys_truncate() or something similar.  This means
it bypasses a bunch of checks and suchlike that it possibly should be making
(security, file locking, lease breaking, vfsmount write).  Should it be using
vfs_truncate() as added by a preceding patch or should it use notify_write()
and assume that anyone poking around in the cache files on disk gets
everything they deserve?

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/interface.c |   49 +++++++++++++++++++++++++++++++++++++++++++++
 fs/cachefiles/rdwr.c      |    5 ++++-
 2 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 9bff0f8..7a9d574 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -441,6 +441,54 @@ truncate_failed:
 }
 
 /*
+ * Invalidate an object
+ */
+static void cachefiles_invalidate_object(struct fscache_operation *op)
+{
+	struct cachefiles_object *object;
+	struct cachefiles_cache *cache;
+	const struct cred *saved_cred;
+	struct path path;
+	uint64_t ni_size;
+	int ret;
+
+	object = container_of(op->object, struct cachefiles_object, fscache);
+	cache = container_of(object->fscache.cache,
+			     struct cachefiles_cache, cache);
+
+	op->object->cookie->def->get_attr(op->object->cookie->netfs_data,
+					  &ni_size);
+
+	_enter("{OBJ%x},[%llu]",
+	       op->object->debug_id, (unsigned long long)ni_size);
+
+	if (object->backer) {
+		ASSERT(S_ISREG(object->backer->d_inode->i_mode));
+
+		fscache_set_store_limit(&object->fscache, ni_size);
+
+		path.dentry = object->backer;
+		path.mnt = cache->mnt;
+
+		cachefiles_begin_secure(cache, &saved_cred);
+		ret = vfs_truncate(&path, 0);
+		if (ret == 0)
+			ret = vfs_truncate(&path, ni_size);
+		cachefiles_end_secure(cache, saved_cred);
+
+		if (ret != 0) {
+			fscache_set_store_limit(&object->fscache, 0);
+			if (ret == -EIO)
+				cachefiles_io_error_obj(object,
+							"Invalidate failed");
+		}
+	}
+
+	fscache_op_complete(op);
+	_leave("");
+}
+
+/*
  * dissociate a cache from all the pages it was backing
  */
 static void cachefiles_dissociate_pages(struct fscache_cache *cache)
@@ -455,6 +503,7 @@ const struct fscache_cache_ops cachefiles_cache_ops = {
 	.lookup_complete	= cachefiles_lookup_complete,
 	.grab_object		= cachefiles_grab_object,
 	.update_object		= cachefiles_update_object,
+	.invalidate_object	= cachefiles_invalidate_object,
 	.drop_object		= cachefiles_drop_object,
 	.put_object		= cachefiles_put_object,
 	.sync_cache		= cachefiles_sync_cache,
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 31cda81..f437e97 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -174,7 +174,10 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
 		_debug("- copy {%lu}", monitor->back_page->index);
 
 	recheck:
-		if (PageUptodate(monitor->back_page)) {
+		if (test_bit(FSCACHE_COOKIE_INVALIDATING,
+			     &object->fscache.cookie->flags)) {
+			error = -ESTALE;
+		} else if (PageUptodate(monitor->back_page)) {
 			copy_highpage(monitor->netfs_page, monitor->back_page);
 			fscache_mark_page_cached(monitor->op,
 						 monitor->netfs_page);

