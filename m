Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab3ITPJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Sep 2013 11:09:15 -0400
Subject: [PATCH 1/3] FS-Cache: Add use/unuse/wake cookie wrappers
To: Trond.Myklebust@netapp.com, steved@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Date: Fri, 20 Sep 2013 16:09:10 +0100
Message-ID: <20130920150910.16220.19460.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
References: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add wrapper functions for dealing with cookie->n_active:

 (*) __fscache_use_cookie() to increment it.

 (*) __fscache_unuse_cookie() to decrement and test against zero.

 (*) __fscache_wake_unused_cookie() to wake up anyone waiting for it to reach
     zero.

The second and third are split so that the third can be done after cookie->lock
has been released in case the waiter wakes up whilst we're still holding it and
tries to get it.

We will need to wake-on-zero once the cookie disablement patch is applied
because it will then be possible to see n_active become zero without the cookie
being relinquished.

Also move the cookie usement out of fscache_attr_changed_op() and into
fscache_attr_changed() and the operation struct so that cookie disablement
will be able to track it.

Whilst we're at it, only increment n_active if we're about to do
fscache_submit_op() so that we don't have to deal with undoing it if anything
earlier fails.  Possibly this should be moved into fscache_submit_op() which
could look at FSCACHE_OP_UNUSE_COOKIE.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c           |    7 +++++--
 fs/fscache/page.c             |   42 ++++++++++++++++++++++++++++++-----------
 include/linux/fscache-cache.h |   19 +++++++++++++++++--
 3 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index b2a86e3..d851aa5 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -568,6 +568,7 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 {
 	struct fscache_operation *op;
 	struct fscache_object *object;
+	bool wake_cookie = false;
 	int ret;
 
 	_enter("%p,", cookie);
@@ -600,7 +601,7 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 
 	op->debug_id = atomic_inc_return(&fscache_op_debug_id);
 
-	atomic_inc(&cookie->n_active);
+	__fscache_use_cookie(cookie);
 	if (fscache_submit_op(object, op) < 0)
 		goto submit_failed;
 
@@ -622,9 +623,11 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 	return ret;
 
 submit_failed:
-	atomic_dec(&cookie->n_active);
+	wake_cookie = __fscache_unuse_cookie(cookie);
 inconsistent:
 	spin_unlock(&cookie->lock);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 	kfree(op);
 	_leave(" = -ESTALE");
 	return -ESTALE;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 73899c1..0fe42a6 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -163,12 +163,10 @@ static void fscache_attr_changed_op(struct fscache_operation *op)
 
 	fscache_stat(&fscache_n_attr_changed_calls);
 
-	if (fscache_object_is_active(object) &&
-	    fscache_use_cookie(object)) {
+	if (fscache_object_is_active(object)) {
 		fscache_stat(&fscache_n_cop_attr_changed);
 		ret = object->cache->ops->attr_changed(object);
 		fscache_stat_d(&fscache_n_cop_attr_changed);
-		fscache_unuse_cookie(object);
 		if (ret < 0)
 			fscache_abort_object(object);
 	}
@@ -184,6 +182,7 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 {
 	struct fscache_operation *op;
 	struct fscache_object *object;
+	bool wake_cookie;
 
 	_enter("%p", cookie);
 
@@ -199,7 +198,9 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 	}
 
 	fscache_operation_init(op, fscache_attr_changed_op, NULL);
-	op->flags = FSCACHE_OP_ASYNC | (1 << FSCACHE_OP_EXCLUSIVE);
+	op->flags = FSCACHE_OP_ASYNC |
+		(1 << FSCACHE_OP_EXCLUSIVE) |
+		(1 << FSCACHE_OP_UNUSE_COOKIE);
 
 	spin_lock(&cookie->lock);
 
@@ -208,6 +209,7 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 	object = hlist_entry(cookie->backing_objects.first,
 			     struct fscache_object, cookie_link);
 
+	__fscache_use_cookie(cookie);
 	if (fscache_submit_exclusive_op(object, op) < 0)
 		goto nobufs;
 	spin_unlock(&cookie->lock);
@@ -217,8 +219,11 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 	return 0;
 
 nobufs:
+	wake_cookie = __fscache_unuse_cookie(cookie);
 	spin_unlock(&cookie->lock);
 	kfree(op);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 	fscache_stat(&fscache_n_attr_changed_nobufs);
 	_leave(" = %d", -ENOBUFS);
 	return -ENOBUFS;
@@ -263,7 +268,6 @@ static struct fscache_retrieval *fscache_alloc_retrieval(
 	}
 
 	fscache_operation_init(&op->op, NULL, fscache_release_retrieval_op);
-	atomic_inc(&cookie->n_active);
 	op->op.flags	= FSCACHE_OP_MYTHREAD |
 		(1UL << FSCACHE_OP_WAITING) |
 		(1UL << FSCACHE_OP_UNUSE_COOKIE);
@@ -384,6 +388,7 @@ int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
 {
 	struct fscache_retrieval *op;
 	struct fscache_object *object;
+	bool wake_cookie = false;
 	int ret;
 
 	_enter("%p,%p,,,", cookie, page);
@@ -421,6 +426,7 @@ int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
 
 	ASSERT(test_bit(FSCACHE_OBJECT_IS_LOOKED_UP, &object->flags));
 
+	__fscache_use_cookie(cookie);
 	atomic_inc(&object->n_reads);
 	__set_bit(FSCACHE_OP_DEC_READ_CNT, &op->op.flags);
 
@@ -475,9 +481,11 @@ error:
 
 nobufs_unlock_dec:
 	atomic_dec(&object->n_reads);
+	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs_unlock:
 	spin_unlock(&cookie->lock);
-	atomic_dec(&cookie->n_active);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 	kfree(op);
 nobufs:
 	fscache_stat(&fscache_n_retrievals_nobufs);
@@ -514,6 +522,7 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 {
 	struct fscache_retrieval *op;
 	struct fscache_object *object;
+	bool wake_cookie = false;
 	int ret;
 
 	_enter("%p,,%d,,,", cookie, *nr_pages);
@@ -547,6 +556,7 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 	object = hlist_entry(cookie->backing_objects.first,
 			     struct fscache_object, cookie_link);
 
+	__fscache_use_cookie(cookie);
 	atomic_inc(&object->n_reads);
 	__set_bit(FSCACHE_OP_DEC_READ_CNT, &op->op.flags);
 
@@ -601,10 +611,12 @@ error:
 
 nobufs_unlock_dec:
 	atomic_dec(&object->n_reads);
+	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs_unlock:
 	spin_unlock(&cookie->lock);
-	atomic_dec(&cookie->n_active);
 	kfree(op);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 nobufs:
 	fscache_stat(&fscache_n_retrievals_nobufs);
 	_leave(" = -ENOBUFS");
@@ -626,6 +638,7 @@ int __fscache_alloc_page(struct fscache_cookie *cookie,
 {
 	struct fscache_retrieval *op;
 	struct fscache_object *object;
+	bool wake_cookie = false;
 	int ret;
 
 	_enter("%p,%p,,,", cookie, page);
@@ -658,8 +671,9 @@ int __fscache_alloc_page(struct fscache_cookie *cookie,
 	object = hlist_entry(cookie->backing_objects.first,
 			     struct fscache_object, cookie_link);
 
+	__fscache_use_cookie(cookie);
 	if (fscache_submit_op(object, &op->op) < 0)
-		goto nobufs_unlock;
+		goto nobufs_unlock_dec;
 	spin_unlock(&cookie->lock);
 
 	fscache_stat(&fscache_n_alloc_ops);
@@ -689,10 +703,13 @@ error:
 	_leave(" = %d", ret);
 	return ret;
 
+nobufs_unlock_dec:
+	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs_unlock:
 	spin_unlock(&cookie->lock);
-	atomic_dec(&cookie->n_active);
 	kfree(op);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 nobufs:
 	fscache_stat(&fscache_n_allocs_nobufs);
 	_leave(" = -ENOBUFS");
@@ -889,6 +906,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 {
 	struct fscache_storage *op;
 	struct fscache_object *object;
+	bool wake_cookie = false;
 	int ret;
 
 	_enter("%p,%x,", cookie, (u32) page->flags);
@@ -957,7 +975,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	op->op.debug_id	= atomic_inc_return(&fscache_op_debug_id);
 	op->store_limit = object->store_limit;
 
-	atomic_inc(&cookie->n_active);
+	__fscache_use_cookie(cookie);
 	if (fscache_submit_op(object, &op->op) < 0)
 		goto submit_failed;
 
@@ -984,10 +1002,10 @@ already_pending:
 	return 0;
 
 submit_failed:
-	atomic_dec(&cookie->n_active);
 	spin_lock(&cookie->stores_lock);
 	radix_tree_delete(&cookie->stores, page->index);
 	spin_unlock(&cookie->stores_lock);
+	wake_cookie = __fscache_unuse_cookie(cookie);
 	page_cache_release(page);
 	ret = -ENOBUFS;
 	goto nobufs;
@@ -999,6 +1017,8 @@ nobufs:
 	spin_unlock(&cookie->lock);
 	radix_tree_preload_end();
 	kfree(op);
+	if (wake_cookie)
+		__fscache_wake_unused_cookie(cookie);
 	fscache_stat(&fscache_n_stores_nobufs);
 	_leave(" = -ENOBUFS");
 	return -ENOBUFS;
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 7823e9e..96a2b66 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -511,6 +511,11 @@ static inline void fscache_end_io(struct fscache_retrieval *op,
 	op->end_io_func(page, op->context, error);
 }
 
+static inline void __fscache_use_cookie(struct fscache_cookie *cookie)
+{
+	atomic_inc(&cookie->n_active);
+}
+
 /**
  * fscache_use_cookie - Request usage of cookie attached to an object
  * @object: Object description
@@ -524,6 +529,16 @@ static inline bool fscache_use_cookie(struct fscache_object *object)
 	return atomic_inc_not_zero(&cookie->n_active) != 0;
 }
 
+static inline bool __fscache_unuse_cookie(struct fscache_cookie *cookie)
+{
+	return atomic_dec_and_test(&cookie->n_active);
+}
+
+static inline void __fscache_wake_unused_cookie(struct fscache_cookie *cookie)
+{
+	wake_up_atomic_t(&cookie->n_active);
+}
+
 /**
  * fscache_unuse_cookie - Cease usage of cookie attached to an object
  * @object: Object description
@@ -534,8 +549,8 @@ static inline bool fscache_use_cookie(struct fscache_object *object)
 static inline void fscache_unuse_cookie(struct fscache_object *object)
 {
 	struct fscache_cookie *cookie = object->cookie;
-	if (atomic_dec_and_test(&cookie->n_active))
-		wake_up_atomic_t(&cookie->n_active);
+	if (__fscache_unuse_cookie(cookie))
+		__fscache_wake_unused_cookie(cookie);
 }
 
 /*

