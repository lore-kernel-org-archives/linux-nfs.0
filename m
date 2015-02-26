Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 12/13] FS-Cache: The operation cancellation method needs
 calling in more places
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:03:10 +0000
Message-ID: <20150226140310.2387.44764.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any time an incomplete operation is cancelled, the operation cancellation
function needs to be called to clean up.  This is currently being passed
directly to some of the functions that might want to call it, but not all.

Instead, pass the cancellation method pointer to the fscache_operation_init()
and have that cache it in the operation struct.  Further, plug in a dummy
cancellation handler if the caller declines to set one as this allows us to
call the function unconditionally (the extra overhead isn't worth bothering
about as we don't expect to be calling this typically).

The cancellation method must thence be called everywhere the CANCELLED state
is set.  Note that we call it *before* setting the CANCELLED state such that
the method can use the old state value to guide its operation.

fscache_do_cancel_retrieval() needs moving higher up in the sources so that
the init function can use it now.

Without this, the following oops may be seen:

	FS-Cache: Assertion failed
	FS-Cache: 3 == 0 is false
	------------[ cut here ]------------
	kernel BUG at ../fs/fscache/page.c:261!
	...
	RIP: 0010:[<ffffffffa0089c1b>]  fscache_release_retrieval_op+0x77/0x100
	 [<ffffffffa008853d>] fscache_put_operation+0x114/0x2da
	 [<ffffffffa008b8c2>] __fscache_read_or_alloc_pages+0x358/0x3b3
	 [<ffffffffa00b761f>] __nfs_readpages_from_fscache+0x59/0xbf [nfs]
	 [<ffffffffa00b06c5>] nfs_readpages+0x10c/0x185 [nfs]
	 [<ffffffff81124925>] ? alloc_pages_current+0x119/0x13e
	 [<ffffffff810ee5fd>] ? __page_cache_alloc+0xfb/0x10a
	 [<ffffffff810f87f8>] __do_page_cache_readahead+0x188/0x22c
	 [<ffffffff810f8b3a>] ondemand_readahead+0x29e/0x2af
	 [<ffffffff810f8c92>] page_cache_sync_readahead+0x38/0x3a
	 [<ffffffff810ef337>] generic_file_read_iter+0x1a2/0x55a
	 [<ffffffffa00a9dff>] ? nfs_revalidate_mapping+0xd6/0x288 [nfs]
	 [<ffffffffa00a6a23>] nfs_file_read+0x49/0x70 [nfs]
	 [<ffffffff811363be>] new_sync_read+0x78/0x9c
	 [<ffffffff81137164>] __vfs_read+0x13/0x38
	 [<ffffffff8113721e>] vfs_read+0x95/0x121
	 [<ffffffff811372f6>] SyS_read+0x4c/0x8a
	 [<ffffffff81557a52>] system_call_fastpath+0x12/0x17

The assertion is showing that the remaining number of pages (n_pages) is not 0
when the operation is being released.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c           |    5 ++--
 fs/fscache/internal.h         |    7 ++----
 fs/fscache/object.c           |    3 ++-
 fs/fscache/operation.c        |   31 +++++++++++++++++++++-------
 fs/fscache/page.c             |   46 ++++++++++++++++++++---------------------
 include/linux/fscache-cache.h |    5 ++++
 6 files changed, 57 insertions(+), 40 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 8de22164f5fb..d403c69bee08 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -672,7 +672,7 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 	if (!op)
 		return -ENOMEM;
 
-	fscache_operation_init(op, NULL, NULL);
+	fscache_operation_init(op, NULL, NULL, NULL);
 	op->flags = FSCACHE_OP_MYTHREAD |
 		(1 << FSCACHE_OP_WAITING) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
@@ -696,8 +696,7 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 	/* the work queue now carries its own ref on the object */
 	spin_unlock(&cookie->lock);
 
-	ret = fscache_wait_for_operation_activation(object, op,
-						    NULL, NULL, NULL);
+	ret = fscache_wait_for_operation_activation(object, op, NULL, NULL);
 	if (ret == 0) {
 		/* ask the cache to honour the operation */
 		ret = object->cache->ops->check_consistency(op);
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index a63225116db6..97ec45110957 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -124,9 +124,7 @@ extern int fscache_submit_exclusive_op(struct fscache_object *,
 				       struct fscache_operation *);
 extern int fscache_submit_op(struct fscache_object *,
 			     struct fscache_operation *);
-extern int fscache_cancel_op(struct fscache_operation *,
-			     void (*)(struct fscache_operation *),
-			     bool);
+extern int fscache_cancel_op(struct fscache_operation *, bool);
 extern void fscache_cancel_all_ops(struct fscache_object *);
 extern void fscache_abort_object(struct fscache_object *);
 extern void fscache_start_operations(struct fscache_object *);
@@ -139,8 +137,7 @@ extern int fscache_wait_for_deferred_lookup(struct fscache_cookie *);
 extern int fscache_wait_for_operation_activation(struct fscache_object *,
 						 struct fscache_operation *,
 						 atomic_t *,
-						 atomic_t *,
-						 void (*)(struct fscache_operation *));
+						 atomic_t *);
 extern void fscache_invalidate_writes(struct fscache_cookie *);
 
 /*
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 40049f7505f0..9e792e30f4db 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -961,7 +961,8 @@ static const struct fscache_state *_fscache_invalidate_object(struct fscache_obj
 	if (!op)
 		goto nomem;
 
-	fscache_operation_init(op, object->cache->ops->invalidate_object, NULL);
+	fscache_operation_init(op, object->cache->ops->invalidate_object,
+			       NULL, NULL);
 	op->flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_EXCLUSIVE) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index c76c09730768..57d4abb68656 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -20,6 +20,10 @@
 atomic_t fscache_op_debug_id;
 EXPORT_SYMBOL(fscache_op_debug_id);
 
+static void fscache_operation_dummy_cancel(struct fscache_operation *op)
+{
+}
+
 /**
  * fscache_operation_init - Do basic initialisation of an operation
  * @op: The operation to initialise
@@ -30,6 +34,7 @@ EXPORT_SYMBOL(fscache_op_debug_id);
  */
 void fscache_operation_init(struct fscache_operation *op,
 			    fscache_operation_processor_t processor,
+			    fscache_operation_cancel_t cancel,
 			    fscache_operation_release_t release)
 {
 	INIT_WORK(&op->work, fscache_op_work_func);
@@ -37,6 +42,7 @@ void fscache_operation_init(struct fscache_operation *op,
 	op->state = FSCACHE_OP_ST_INITIALISED;
 	op->debug_id = atomic_inc_return(&fscache_op_debug_id);
 	op->processor = processor;
+	op->cancel = cancel ?: fscache_operation_dummy_cancel;
 	op->release = release;
 	INIT_LIST_HEAD(&op->pend_link);
 	fscache_stat(&fscache_n_op_initialised);
@@ -164,9 +170,11 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 	flags = READ_ONCE(object->flags);
 	if (unlikely(!(flags & BIT(FSCACHE_OBJECT_IS_LIVE)))) {
 		fscache_stat(&fscache_n_op_rejected);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	} else if (unlikely(fscache_cache_is_broken(object))) {
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -EIO;
 	} else if (flags & BIT(FSCACHE_OBJECT_IS_AVAILABLE)) {
@@ -200,10 +208,12 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 		fscache_stat(&fscache_n_op_pend);
 		ret = 0;
 	} else if (flags & BIT(FSCACHE_OBJECT_KILLED_BY_CACHE)) {
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	} else {
 		fscache_report_unexpected_submission(object, op, ostate);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	}
@@ -245,9 +255,11 @@ int fscache_submit_op(struct fscache_object *object,
 	flags = READ_ONCE(object->flags);
 	if (unlikely(!(flags & BIT(FSCACHE_OBJECT_IS_LIVE)))) {
 		fscache_stat(&fscache_n_op_rejected);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	} else if (unlikely(fscache_cache_is_broken(object))) {
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -EIO;
 	} else if (flags & BIT(FSCACHE_OBJECT_IS_AVAILABLE)) {
@@ -276,11 +288,13 @@ int fscache_submit_op(struct fscache_object *object,
 		fscache_stat(&fscache_n_op_pend);
 		ret = 0;
 	} else if (flags & BIT(FSCACHE_OBJECT_KILLED_BY_CACHE)) {
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	} else {
 		fscache_report_unexpected_submission(object, op, ostate);
 		ASSERT(!fscache_object_is_active(object));
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
 	}
@@ -335,7 +349,6 @@ void fscache_start_operations(struct fscache_object *object)
  * cancel an operation that's pending on an object
  */
 int fscache_cancel_op(struct fscache_operation *op,
-		      void (*do_cancel)(struct fscache_operation *),
 		      bool cancel_in_progress_op)
 {
 	struct fscache_object *object = op->object;
@@ -355,9 +368,9 @@ int fscache_cancel_op(struct fscache_operation *op,
 		ASSERT(!list_empty(&op->pend_link));
 		list_del_init(&op->pend_link);
 		put = true;
+
 		fscache_stat(&fscache_n_op_cancelled);
-		if (do_cancel)
-			do_cancel(op);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
 			object->n_exclusive--;
@@ -373,8 +386,7 @@ int fscache_cancel_op(struct fscache_operation *op,
 			fscache_start_operations(object);
 
 		fscache_stat(&fscache_n_op_cancelled);
-		if (do_cancel)
-			do_cancel(op);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
 			object->n_exclusive--;
@@ -408,6 +420,7 @@ void fscache_cancel_all_ops(struct fscache_object *object)
 		list_del_init(&op->pend_link);
 
 		ASSERTCMP(op->state, ==, FSCACHE_OP_ST_PENDING);
+		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 
 		if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
@@ -440,8 +453,12 @@ void fscache_op_complete(struct fscache_operation *op, bool cancelled)
 
 	spin_lock(&object->lock);
 
-	op->state = cancelled ?
-		FSCACHE_OP_ST_CANCELLED : FSCACHE_OP_ST_COMPLETE;
+	if (!cancelled) {
+		op->state = FSCACHE_OP_ST_COMPLETE;
+	} else {
+		op->cancel(op);
+		op->state = FSCACHE_OP_ST_CANCELLED;
+	}
 
 	if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
 		object->n_exclusive--;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 7db9752252ef..d1b23a67c031 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -213,7 +213,7 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 		return -ENOMEM;
 	}
 
-	fscache_operation_init(op, fscache_attr_changed_op, NULL);
+	fscache_operation_init(op, fscache_attr_changed_op, NULL, NULL);
 	op->flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_EXCLUSIVE) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
@@ -249,6 +249,17 @@ nobufs:
 EXPORT_SYMBOL(__fscache_attr_changed);
 
 /*
+ * Handle cancellation of a pending retrieval op
+ */
+static void fscache_do_cancel_retrieval(struct fscache_operation *_op)
+{
+	struct fscache_retrieval *op =
+		container_of(_op, struct fscache_retrieval, op);
+
+	atomic_set(&op->n_pages, 0);
+}
+
+/*
  * release a retrieval op reference
  */
 static void fscache_release_retrieval_op(struct fscache_operation *_op)
@@ -285,7 +296,9 @@ static struct fscache_retrieval *fscache_alloc_retrieval(
 		return NULL;
 	}
 
-	fscache_operation_init(&op->op, NULL, fscache_release_retrieval_op);
+	fscache_operation_init(&op->op, NULL,
+			       fscache_do_cancel_retrieval,
+			       fscache_release_retrieval_op);
 	op->op.flags	= FSCACHE_OP_MYTHREAD |
 		(1UL << FSCACHE_OP_WAITING) |
 		(1UL << FSCACHE_OP_UNUSE_COOKIE);
@@ -330,24 +343,12 @@ int fscache_wait_for_deferred_lookup(struct fscache_cookie *cookie)
 }
 
 /*
- * Handle cancellation of a pending retrieval op
- */
-static void fscache_do_cancel_retrieval(struct fscache_operation *_op)
-{
-	struct fscache_retrieval *op =
-		container_of(_op, struct fscache_retrieval, op);
-
-	atomic_set(&op->n_pages, 0);
-}
-
-/*
  * wait for an object to become active (or dead)
  */
 int fscache_wait_for_operation_activation(struct fscache_object *object,
 					  struct fscache_operation *op,
 					  atomic_t *stat_op_waits,
-					  atomic_t *stat_object_dead,
-					  void (*do_cancel)(struct fscache_operation *))
+					  atomic_t *stat_object_dead)
 {
 	int ret;
 
@@ -359,7 +360,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 		fscache_stat(stat_op_waits);
 	if (wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
 			TASK_INTERRUPTIBLE) != 0) {
-		ret = fscache_cancel_op(op, do_cancel, false);
+		ret = fscache_cancel_op(op, false);
 		if (ret == 0)
 			return -ERESTARTSYS;
 
@@ -380,7 +381,7 @@ check_if_dead:
 	if (unlikely(fscache_object_is_dying(object) ||
 		     fscache_cache_is_broken(object))) {
 		enum fscache_operation_state state = op->state;
-		fscache_cancel_op(op, do_cancel, true);
+		fscache_cancel_op(op, true);
 		if (stat_object_dead)
 			fscache_stat(stat_object_dead);
 		_leave(" = -ENOBUFS [obj dead %d]", state);
@@ -464,8 +465,7 @@ int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
 	ret = fscache_wait_for_operation_activation(
 		object, &op->op,
 		__fscache_stat(&fscache_n_retrieval_op_waits),
-		__fscache_stat(&fscache_n_retrievals_object_dead),
-		fscache_do_cancel_retrieval);
+		__fscache_stat(&fscache_n_retrievals_object_dead));
 	if (ret < 0)
 		goto error;
 
@@ -595,8 +595,7 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 	ret = fscache_wait_for_operation_activation(
 		object, &op->op,
 		__fscache_stat(&fscache_n_retrieval_op_waits),
-		__fscache_stat(&fscache_n_retrievals_object_dead),
-		fscache_do_cancel_retrieval);
+		__fscache_stat(&fscache_n_retrievals_object_dead));
 	if (ret < 0)
 		goto error;
 
@@ -702,8 +701,7 @@ int __fscache_alloc_page(struct fscache_cookie *cookie,
 	ret = fscache_wait_for_operation_activation(
 		object, &op->op,
 		__fscache_stat(&fscache_n_alloc_op_waits),
-		__fscache_stat(&fscache_n_allocs_object_dead),
-		fscache_do_cancel_retrieval);
+		__fscache_stat(&fscache_n_allocs_object_dead));
 	if (ret < 0)
 		goto error;
 
@@ -946,7 +944,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (!op)
 		goto nomem;
 
-	fscache_operation_init(&op->op, fscache_write_op,
+	fscache_operation_init(&op->op, fscache_write_op, NULL,
 			       fscache_release_write_op);
 	op->op.flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_WAITING) |
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 0e26d49972e3..69c6eb10d858 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -74,6 +74,7 @@ extern wait_queue_head_t fscache_cache_cleared_wq;
  */
 typedef void (*fscache_operation_release_t)(struct fscache_operation *op);
 typedef void (*fscache_operation_processor_t)(struct fscache_operation *op);
+typedef void (*fscache_operation_cancel_t)(struct fscache_operation *op);
 
 enum fscache_operation_state {
 	FSCACHE_OP_ST_BLANK,		/* Op is not yet submitted */
@@ -109,6 +110,9 @@ struct fscache_operation {
 	 *   the op in a non-pool thread */
 	fscache_operation_processor_t processor;
 
+	/* Operation cancellation cleanup (optional) */
+	fscache_operation_cancel_t cancel;
+
 	/* operation releaser */
 	fscache_operation_release_t release;
 };
@@ -121,6 +125,7 @@ extern void fscache_op_complete(struct fscache_operation *, bool);
 extern void fscache_put_operation(struct fscache_operation *);
 extern void fscache_operation_init(struct fscache_operation *,
 				   fscache_operation_processor_t,
+				   fscache_operation_cancel_t,
 				   fscache_operation_release_t);
 
 /*

