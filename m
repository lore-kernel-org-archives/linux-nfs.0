Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59420 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752246AbeDDWHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:48 -0400
Subject: [PATCH 09/12] fscache: Add more tracepoints
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:43 +0100
Message-ID: <152287966385.14760.13508254943115982830.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add more tracepoints to fscache, including:

 (*) fscache_page - Tracks netfs pages known to fscache.

 (*) fscache_check_page - Tracks the netfs querying whether a page is
     pending storage.

 (*) fscache_wake_cookie - Tracks cookies being woken up after a page
     completes/aborts storage in the cache.

 (*) fscache_op - Tracks operations being initialised.

 (*) fscache_wrote_page - Tracks return of the backend write_page op.

 (*) fscache_gang_lookup - Tracks lookup of pages to be stored in the write
     operation.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c            |    3 
 fs/fscache/object.c            |    3 
 fs/fscache/operation.c         |   26 ++++
 fs/fscache/page.c              |   51 +++++++-
 include/linux/fscache-cache.h  |    3 
 include/trace/events/fscache.h |  252 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 330 insertions(+), 8 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 20bc3341f113..ea1f80daaff4 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -691,10 +691,11 @@ int __fscache_check_consistency(struct fscache_cookie *cookie)
 	if (!op)
 		return -ENOMEM;
 
-	fscache_operation_init(op, NULL, NULL, NULL);
+	fscache_operation_init(cookie, op, NULL, NULL, NULL);
 	op->flags = FSCACHE_OP_MYTHREAD |
 		(1 << FSCACHE_OP_WAITING) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
+	trace_fscache_page_op(cookie, NULL, op, fscache_page_op_check_consistency);
 
 	spin_lock(&cookie->lock);
 
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 99afe64352a5..7c0ddb7ae29a 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -982,11 +982,12 @@ static const struct fscache_state *_fscache_invalidate_object(struct fscache_obj
 	if (!op)
 		goto nomem;
 
-	fscache_operation_init(op, object->cache->ops->invalidate_object,
+	fscache_operation_init(cookie, op, object->cache->ops->invalidate_object,
 			       NULL, NULL);
 	op->flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_EXCLUSIVE) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
+	trace_fscache_page_op(cookie, NULL, op, fscache_page_op_invalidate);
 
 	spin_lock(&cookie->lock);
 	if (fscache_submit_exclusive_op(object, op) < 0)
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index de67745e1cd7..7a071e1e952d 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -32,7 +32,8 @@ static void fscache_operation_dummy_cancel(struct fscache_operation *op)
  * Do basic initialisation of an operation.  The caller must still set flags,
  * object and processor if needed.
  */
-void fscache_operation_init(struct fscache_operation *op,
+void fscache_operation_init(struct fscache_cookie *cookie,
+			    struct fscache_operation *op,
 			    fscache_operation_processor_t processor,
 			    fscache_operation_cancel_t cancel,
 			    fscache_operation_release_t release)
@@ -46,6 +47,7 @@ void fscache_operation_init(struct fscache_operation *op,
 	op->release = release;
 	INIT_LIST_HEAD(&op->pend_link);
 	fscache_stat(&fscache_n_op_initialised);
+	trace_fscache_op(cookie, op, fscache_op_init);
 }
 EXPORT_SYMBOL(fscache_operation_init);
 
@@ -59,6 +61,8 @@ EXPORT_SYMBOL(fscache_operation_init);
  */
 void fscache_enqueue_operation(struct fscache_operation *op)
 {
+	struct fscache_cookie *cookie = op->object->cookie;
+	
 	_enter("{OBJ%x OP%x,%u}",
 	       op->object->debug_id, op->debug_id, atomic_read(&op->usage));
 
@@ -71,12 +75,14 @@ void fscache_enqueue_operation(struct fscache_operation *op)
 	fscache_stat(&fscache_n_op_enqueue);
 	switch (op->flags & FSCACHE_OP_TYPE) {
 	case FSCACHE_OP_ASYNC:
+		trace_fscache_op(cookie, op, fscache_op_enqueue_async);
 		_debug("queue async");
 		atomic_inc(&op->usage);
 		if (!queue_work(fscache_op_wq, &op->work))
 			fscache_put_operation(op);
 		break;
 	case FSCACHE_OP_MYTHREAD:
+		trace_fscache_op(cookie, op, fscache_op_enqueue_mythread);
 		_debug("queue for caller's attention");
 		break;
 	default:
@@ -101,6 +107,8 @@ static void fscache_run_op(struct fscache_object *object,
 		wake_up_bit(&op->flags, FSCACHE_OP_WAITING);
 	if (op->processor)
 		fscache_enqueue_operation(op);
+	else
+		trace_fscache_op(object->cookie, op, fscache_op_run);
 	fscache_stat(&fscache_n_op_run);
 }
 
@@ -155,6 +163,8 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 
 	_enter("{OBJ%x OP%x},", object->debug_id, op->debug_id);
 
+	trace_fscache_op(object->cookie, op, fscache_op_submit_ex);
+
 	ASSERTCMP(op->state, ==, FSCACHE_OP_ST_INITIALISED);
 	ASSERTCMP(atomic_read(&op->usage), >, 0);
 
@@ -240,6 +250,8 @@ int fscache_submit_op(struct fscache_object *object,
 	_enter("{OBJ%x OP%x},{%u}",
 	       object->debug_id, op->debug_id, atomic_read(&op->usage));
 
+	trace_fscache_op(object->cookie, op, fscache_op_submit);
+
 	ASSERTCMP(op->state, ==, FSCACHE_OP_ST_INITIALISED);
 	ASSERTCMP(atomic_read(&op->usage), >, 0);
 
@@ -357,6 +369,8 @@ int fscache_cancel_op(struct fscache_operation *op,
 
 	_enter("OBJ%x OP%x}", op->object->debug_id, op->debug_id);
 
+	trace_fscache_op(object->cookie, op, fscache_op_cancel);
+
 	ASSERTCMP(op->state, >=, FSCACHE_OP_ST_PENDING);
 	ASSERTCMP(op->state, !=, FSCACHE_OP_ST_CANCELLED);
 	ASSERTCMP(atomic_read(&op->usage), >, 0);
@@ -419,6 +433,8 @@ void fscache_cancel_all_ops(struct fscache_object *object)
 		fscache_stat(&fscache_n_op_cancelled);
 		list_del_init(&op->pend_link);
 
+		trace_fscache_op(object->cookie, op, fscache_op_cancel_all);
+
 		ASSERTCMP(op->state, ==, FSCACHE_OP_ST_PENDING);
 		op->cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
@@ -454,9 +470,11 @@ void fscache_op_complete(struct fscache_operation *op, bool cancelled)
 	spin_lock(&object->lock);
 
 	if (!cancelled) {
+		trace_fscache_op(object->cookie, op, fscache_op_completed);
 		op->state = FSCACHE_OP_ST_COMPLETE;
 	} else {
 		op->cancel(op);
+		trace_fscache_op(object->cookie, op, fscache_op_cancelled);
 		op->state = FSCACHE_OP_ST_CANCELLED;
 	}
 
@@ -488,6 +506,8 @@ void fscache_put_operation(struct fscache_operation *op)
 	if (!atomic_dec_and_test(&op->usage))
 		return;
 
+	trace_fscache_op(op->object->cookie, op, fscache_op_put);
+
 	_debug("PUT OP");
 	ASSERTIFCMP(op->state != FSCACHE_OP_ST_INITIALISED &&
 		    op->state != FSCACHE_OP_ST_COMPLETE,
@@ -563,6 +583,8 @@ void fscache_operation_gc(struct work_struct *work)
 		spin_unlock(&cache->op_gc_list_lock);
 
 		object = op->object;
+		trace_fscache_op(object->cookie, op, fscache_op_gc);
+
 		spin_lock(&object->lock);
 
 		_debug("GC DEFERRED REL OBJ%x OP%x",
@@ -601,6 +623,8 @@ void fscache_op_work_func(struct work_struct *work)
 	_enter("{OBJ%x OP%x,%d}",
 	       op->object->debug_id, op->debug_id, atomic_read(&op->usage));
 
+	trace_fscache_op(op->object->cookie, op, fscache_op_work);
+
 	ASSERT(op->processor != NULL);
 	start = jiffies;
 	op->processor(op);
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index b9f18bf4227d..810b33aced1c 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -27,6 +27,7 @@ bool __fscache_check_page_write(struct fscache_cookie *cookie, struct page *page
 	rcu_read_lock();
 	val = radix_tree_lookup(&cookie->stores, page->index);
 	rcu_read_unlock();
+	trace_fscache_check_page(cookie, page, val, 0);
 
 	return val != NULL;
 }
@@ -39,6 +40,8 @@ void __fscache_wait_on_page_write(struct fscache_cookie *cookie, struct page *pa
 {
 	wait_queue_head_t *wq = bit_waitqueue(&cookie->flags, 0);
 
+	trace_fscache_page(cookie, page, fscache_page_write_wait);
+
 	wait_event(*wq, !__fscache_check_page_write(cookie, page));
 }
 EXPORT_SYMBOL(__fscache_wait_on_page_write);
@@ -69,6 +72,8 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
 
 	_enter("%p,%p,%x", cookie, page, gfp);
 
+	trace_fscache_page(cookie, page, fscache_page_maybe_release);
+
 try_again:
 	rcu_read_lock();
 	val = radix_tree_lookup(&cookie->stores, page->index);
@@ -101,6 +106,7 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
 	}
 
 	xpage = radix_tree_delete(&cookie->stores, page->index);
+	trace_fscache_page(cookie, page, fscache_page_radix_delete);
 	spin_unlock(&cookie->stores_lock);
 
 	if (xpage) {
@@ -112,6 +118,7 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
 	}
 
 	wake_up_bit(&cookie->flags, 0);
+	trace_fscache_wake_cookie(cookie);
 	if (xpage)
 		put_page(xpage);
 	__fscache_uncache_page(cookie, page);
@@ -144,7 +151,7 @@ static void fscache_end_page_write(struct fscache_object *object,
 				   struct page *page)
 {
 	struct fscache_cookie *cookie;
-	struct page *xpage = NULL;
+	struct page *xpage = NULL, *val;
 
 	spin_lock(&object->lock);
 	cookie = object->cookie;
@@ -154,13 +161,24 @@ static void fscache_end_page_write(struct fscache_object *object,
 		spin_lock(&cookie->stores_lock);
 		radix_tree_tag_clear(&cookie->stores, page->index,
 				     FSCACHE_COOKIE_STORING_TAG);
+		trace_fscache_page(cookie, page, fscache_page_radix_clear_store);
 		if (!radix_tree_tag_get(&cookie->stores, page->index,
 					FSCACHE_COOKIE_PENDING_TAG)) {
 			fscache_stat(&fscache_n_store_radix_deletes);
 			xpage = radix_tree_delete(&cookie->stores, page->index);
+			trace_fscache_page(cookie, page, fscache_page_radix_delete);
+			trace_fscache_page(cookie, page, fscache_page_write_end);
+
+			val = radix_tree_lookup(&cookie->stores, page->index);
+			trace_fscache_check_page(cookie, page, val, 1);
+		} else {
+			trace_fscache_page(cookie, page, fscache_page_write_end_pend);
 		}
 		spin_unlock(&cookie->stores_lock);
 		wake_up_bit(&cookie->flags, 0);
+		trace_fscache_wake_cookie(cookie);
+	} else {
+		trace_fscache_page(cookie, page, fscache_page_write_end_noc);
 	}
 	spin_unlock(&object->lock);
 	if (xpage)
@@ -215,7 +233,8 @@ int __fscache_attr_changed(struct fscache_cookie *cookie)
 		return -ENOMEM;
 	}
 
-	fscache_operation_init(op, fscache_attr_changed_op, NULL, NULL);
+	fscache_operation_init(cookie, op, fscache_attr_changed_op, NULL, NULL);
+	trace_fscache_page_op(cookie, NULL, op, fscache_page_op_attr_changed);
 	op->flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_EXCLUSIVE) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
@@ -299,7 +318,7 @@ static struct fscache_retrieval *fscache_alloc_retrieval(
 		return NULL;
 	}
 
-	fscache_operation_init(&op->op, NULL,
+	fscache_operation_init(cookie, &op->op, NULL,
 			       fscache_do_cancel_retrieval,
 			       fscache_release_retrieval_op);
 	op->op.flags	= FSCACHE_OP_MYTHREAD |
@@ -370,6 +389,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 		fscache_stat(stat_op_waits);
 	if (wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
 			TASK_INTERRUPTIBLE) != 0) {
+		trace_fscache_op(object->cookie, op, fscache_op_signal);
 		ret = fscache_cancel_op(op, false);
 		if (ret == 0)
 			return -ERESTARTSYS;
@@ -391,6 +411,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 	if (unlikely(fscache_object_is_dying(object) ||
 		     fscache_cache_is_broken(object))) {
 		enum fscache_operation_state state = op->state;
+		trace_fscache_op(object->cookie, op, fscache_op_signal);
 		fscache_cancel_op(op, true);
 		if (stat_object_dead)
 			fscache_stat(stat_object_dead);
@@ -445,6 +466,7 @@ int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
 		return -ENOMEM;
 	}
 	atomic_set(&op->n_pages, 1);
+	trace_fscache_page_op(cookie, page, &op->op, fscache_page_op_retr_one);
 
 	spin_lock(&cookie->lock);
 
@@ -573,6 +595,7 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 	if (!op)
 		return -ENOMEM;
 	atomic_set(&op->n_pages, *nr_pages);
+	trace_fscache_page_op(cookie, NULL, &op->op, fscache_page_op_retr_multi);
 
 	spin_lock(&cookie->lock);
 
@@ -684,6 +707,7 @@ int __fscache_alloc_page(struct fscache_cookie *cookie,
 	if (!op)
 		return -ENOMEM;
 	atomic_set(&op->n_pages, 1);
+	trace_fscache_page_op(cookie, page, &op->op, fscache_page_op_alloc_one);
 
 	spin_lock(&cookie->lock);
 
@@ -813,9 +837,11 @@ static void fscache_write_op(struct fscache_operation *_op)
 	fscache_stat(&fscache_n_store_calls);
 
 	/* find a page to store */
+	results[0] = NULL;
 	page = NULL;
 	n = radix_tree_gang_lookup_tag(&cookie->stores, results, 0, 1,
 				       FSCACHE_COOKIE_PENDING_TAG);
+	trace_fscache_gang_lookup(cookie, &op->op, results, n, op->store_limit);
 	if (n != 1)
 		goto superseded;
 	page = results[0];
@@ -825,6 +851,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 			   FSCACHE_COOKIE_STORING_TAG);
 	radix_tree_tag_clear(&cookie->stores, page->index,
 			     FSCACHE_COOKIE_PENDING_TAG);
+	trace_fscache_page(cookie, page, fscache_page_radix_pend2store);
 
 	spin_unlock(&cookie->stores_lock);
 	spin_unlock(&object->lock);
@@ -836,6 +863,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 	fscache_stat(&fscache_n_cop_write_page);
 	ret = object->cache->ops->write_page(op, page);
 	fscache_stat_d(&fscache_n_cop_write_page);
+	trace_fscache_wrote_page(cookie, page, &op->op, ret);
 	fscache_end_page_write(object, page);
 	if (ret < 0) {
 		fscache_abort_object(object);
@@ -849,6 +877,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 
 discard_page:
 	fscache_stat(&fscache_n_store_pages_over_limit);
+	trace_fscache_wrote_page(cookie, page, &op->op, -ENOBUFS);
 	fscache_end_page_write(object, page);
 	goto again;
 
@@ -887,6 +916,8 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 		for (i = n - 1; i >= 0; i--) {
 			page = results[i];
 			radix_tree_delete(&cookie->stores, page->index);
+			trace_fscache_page(cookie, page, fscache_page_radix_delete);
+			trace_fscache_page(cookie, page, fscache_page_inval);
 		}
 
 		spin_unlock(&cookie->stores_lock);
@@ -896,6 +927,7 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 	}
 
 	wake_up_bit(&cookie->flags, 0);
+	trace_fscache_wake_cookie(cookie);
 
 	_leave("");
 }
@@ -954,7 +986,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (!op)
 		goto nomem;
 
-	fscache_operation_init(&op->op, fscache_write_op, NULL,
+	fscache_operation_init(cookie, &op->op, fscache_write_op, NULL,
 			       fscache_release_write_op);
 	op->op.flags = FSCACHE_OP_ASYNC |
 		(1 << FSCACHE_OP_WAITING) |
@@ -964,6 +996,8 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (ret < 0)
 		goto nomem_free;
 
+	trace_fscache_page_op(cookie, page, &op->op, fscache_page_op_write_one);
+
 	ret = -ENOBUFS;
 	spin_lock(&cookie->lock);
 
@@ -975,6 +1009,8 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (test_bit(FSCACHE_IOERROR, &object->cache->flags))
 		goto nobufs;
 
+	trace_fscache_page(cookie, page, fscache_page_write);
+
 	/* add the page to the pending-storage radix tree on the backing
 	 * object */
 	spin_lock(&object->lock);
@@ -990,8 +1026,10 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 		goto nobufs_unlock_obj;
 	}
 
+	trace_fscache_page(cookie, page, fscache_page_radix_insert);
 	radix_tree_tag_set(&cookie->stores, page->index,
 			   FSCACHE_COOKIE_PENDING_TAG);
+	trace_fscache_page(cookie, page, fscache_page_radix_set_pend);
 	get_page(page);
 
 	/* we only want one writer at a time, but we do need to queue new
@@ -1034,6 +1072,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 submit_failed:
 	spin_lock(&cookie->stores_lock);
 	radix_tree_delete(&cookie->stores, page->index);
+	trace_fscache_page(cookie, page, fscache_page_radix_delete);
 	spin_unlock(&cookie->stores_lock);
 	wake_cookie = __fscache_unuse_cookie(cookie);
 	put_page(page);
@@ -1080,6 +1119,8 @@ void __fscache_uncache_page(struct fscache_cookie *cookie, struct page *page)
 	if (!PageFsCache(page))
 		goto done;
 
+	trace_fscache_page(cookie, page, fscache_page_uncache);
+
 	/* get the object */
 	spin_lock(&cookie->lock);
 
@@ -1128,6 +1169,8 @@ void fscache_mark_page_cached(struct fscache_retrieval *op, struct page *page)
 	atomic_inc(&fscache_n_marks);
 #endif
 
+	trace_fscache_page(cookie, page, fscache_page_cached);
+
 	_debug("- mark %p{%lx}", page, page->index);
 	if (TestSetPageFsCache(page)) {
 		static bool once_only;
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index fbe102f37074..3e764fd38d9f 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -135,7 +135,8 @@ extern void fscache_op_work_func(struct work_struct *work);
 extern void fscache_enqueue_operation(struct fscache_operation *);
 extern void fscache_op_complete(struct fscache_operation *, bool);
 extern void fscache_put_operation(struct fscache_operation *);
-extern void fscache_operation_init(struct fscache_operation *,
+extern void fscache_operation_init(struct fscache_cookie *,
+				   struct fscache_operation *,
 				   fscache_operation_processor_t,
 				   fscache_operation_cancel_t,
 				   fscache_operation_release_t);
diff --git a/include/trace/events/fscache.h b/include/trace/events/fscache.h
index 99f5355d6281..82c060fe6635 100644
--- a/include/trace/events/fscache.h
+++ b/include/trace/events/fscache.h
@@ -33,6 +33,53 @@ enum fscache_cookie_trace {
 	fscache_cookie_put_parent,
 };
 
+enum fscache_page_trace {
+	fscache_page_cached,
+	fscache_page_inval,
+	fscache_page_maybe_release,
+	fscache_page_radix_clear_store,
+	fscache_page_radix_delete,
+	fscache_page_radix_insert,
+	fscache_page_radix_pend2store,
+	fscache_page_radix_set_pend,
+	fscache_page_uncache,
+	fscache_page_write,
+	fscache_page_write_end,
+	fscache_page_write_end_pend,
+	fscache_page_write_end_noc,
+	fscache_page_write_wait,
+	fscache_page_trace__nr
+};
+
+enum fscache_op_trace {
+	fscache_op_cancel,
+	fscache_op_cancel_all,
+	fscache_op_cancelled,
+	fscache_op_completed,
+	fscache_op_enqueue_async,
+	fscache_op_enqueue_mythread,
+	fscache_op_gc,
+	fscache_op_init,
+	fscache_op_put,
+	fscache_op_run,
+	fscache_op_signal,
+	fscache_op_submit,
+	fscache_op_submit_ex,
+	fscache_op_work,
+	fscache_op_trace__nr
+};
+
+enum fscache_page_op_trace {
+	fscache_page_op_alloc_one,
+	fscache_page_op_attr_changed,
+	fscache_page_op_check_consistency,
+	fscache_page_op_invalidate,
+	fscache_page_op_retr_multi,
+	fscache_page_op_retr_one,
+	fscache_page_op_write_one,
+	fscache_page_op_trace__nr
+};
+
 #endif
 
 /*
@@ -47,6 +94,47 @@ enum fscache_cookie_trace {
 	EM(fscache_cookie_put_object,		"PUT obj")		\
 	E_(fscache_cookie_put_parent,		"PUT prn")
 
+#define fscache_page_traces						\
+	EM(fscache_page_cached,			"Cached ")		\
+	EM(fscache_page_inval,			"InvalPg")		\
+	EM(fscache_page_maybe_release,		"MayRels")		\
+	EM(fscache_page_uncache,		"Uncache")		\
+	EM(fscache_page_radix_clear_store,	"RxCStr ")		\
+	EM(fscache_page_radix_delete,		"RxDel  ")		\
+	EM(fscache_page_radix_insert,		"RxIns  ")		\
+	EM(fscache_page_radix_pend2store,	"RxP2S  ")		\
+	EM(fscache_page_radix_set_pend,		"RxSPend ")		\
+	EM(fscache_page_write,			"WritePg")		\
+	EM(fscache_page_write_end,		"EndPgWr")		\
+	EM(fscache_page_write_end_pend,		"EndPgWP")		\
+	EM(fscache_page_write_end_noc,		"EndPgNC")		\
+	E_(fscache_page_write_wait,		"WtOnWrt")
+
+#define fscache_op_traces						\
+	EM(fscache_op_cancel,			"Cancel1")		\
+	EM(fscache_op_cancel_all,		"CancelA")		\
+	EM(fscache_op_cancelled,		"Canclld")		\
+	EM(fscache_op_completed,		"Complet")		\
+	EM(fscache_op_enqueue_async,		"EnqAsyn")		\
+	EM(fscache_op_enqueue_mythread,		"EnqMyTh")		\
+	EM(fscache_op_gc,			"GC     ")		\
+	EM(fscache_op_init,			"Init   ")		\
+	EM(fscache_op_put,			"Put    ")		\
+	EM(fscache_op_run,			"Run    ")		\
+	EM(fscache_op_signal,			"Signal ")		\
+	EM(fscache_op_submit,			"Submit ")		\
+	EM(fscache_op_submit_ex,		"SubmitX")		\
+	E_(fscache_op_work,			"Work   ")
+
+#define fscache_page_op_traces						\
+	EM(fscache_page_op_alloc_one,		"Alloc1 ")		\
+	EM(fscache_page_op_attr_changed,	"AttrChg")		\
+	EM(fscache_page_op_check_consistency,	"CheckCn")		\
+	EM(fscache_page_op_invalidate,		"Inval  ")		\
+	EM(fscache_page_op_retr_multi,		"RetrMul")		\
+	EM(fscache_page_op_retr_one,		"Retr1  ")		\
+	E_(fscache_page_op_write_one,		"Write1 ")
+
 /*
  * Export enum symbols via userspace.
  */
@@ -271,6 +359,170 @@ TRACE_EVENT(fscache_osm,
 		      __entry->event_num)
 	    );
 
+TRACE_EVENT(fscache_page,
+	    TP_PROTO(struct fscache_cookie *cookie, struct page *page,
+		     enum fscache_page_trace why),
+
+	    TP_ARGS(cookie, page, why),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(pgoff_t,			page		)
+		    __field(enum fscache_page_trace,	why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->page		= page->index;
+		    __entry->why		= why;
+			   ),
+
+	    TP_printk("c=%p %s pg=%lx",
+		      __entry->cookie,
+		      __print_symbolic(__entry->why, fscache_page_traces),
+		      __entry->page)
+	    );
+
+TRACE_EVENT(fscache_check_page,
+	    TP_PROTO(struct fscache_cookie *cookie, struct page *page,
+		     void *val, int n),
+
+	    TP_ARGS(cookie, page, val, n),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(void *,			page		)
+		    __field(void *,			val		)
+		    __field(int,			n		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->page		= page;
+		    __entry->val		= val;
+		    __entry->n			= n;
+			   ),
+
+	    TP_printk("c=%p pg=%p val=%p n=%d",
+		      __entry->cookie, __entry->page, __entry->val, __entry->n)
+	    );
+
+TRACE_EVENT(fscache_wake_cookie,
+	    TP_PROTO(struct fscache_cookie *cookie),
+
+	    TP_ARGS(cookie),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+			   ),
+
+	    TP_printk("c=%p", __entry->cookie)
+	    );
+
+TRACE_EVENT(fscache_op,
+	    TP_PROTO(struct fscache_cookie *cookie, struct fscache_operation *op,
+		     enum fscache_op_trace why),
+
+	    TP_ARGS(cookie, op, why),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_operation *,	op		)
+		    __field(enum fscache_op_trace,	why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->op			= op;
+		    __entry->why		= why;
+			   ),
+
+	    TP_printk("c=%p op=%p %s",
+		      __entry->cookie, __entry->op,
+		      __print_symbolic(__entry->why, fscache_op_traces))
+	    );
+
+TRACE_EVENT(fscache_page_op,
+	    TP_PROTO(struct fscache_cookie *cookie, struct page *page,
+		     struct fscache_operation *op, enum fscache_page_op_trace what),
+
+	    TP_ARGS(cookie, page, op, what),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(pgoff_t,			page		)
+		    __field(struct fscache_operation *,	op		)
+		    __field(enum fscache_page_op_trace,	what		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->page		= page ? page->index : 0;
+		    __entry->op			= op;
+		    __entry->what		= what;
+			   ),
+
+	    TP_printk("c=%p %s pg=%lx op=%p",
+		      __entry->cookie,
+		      __print_symbolic(__entry->what, fscache_page_op_traces),
+		      __entry->page, __entry->op)
+	    );
+
+TRACE_EVENT(fscache_wrote_page,
+	    TP_PROTO(struct fscache_cookie *cookie, struct page *page,
+		     struct fscache_operation *op, int ret),
+
+	    TP_ARGS(cookie, page, op, ret),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(pgoff_t,			page		)
+		    __field(struct fscache_operation *,	op		)
+		    __field(int,			ret		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->page		= page->index;
+		    __entry->op			= op;
+		    __entry->ret		= ret;
+			   ),
+
+	    TP_printk("c=%p pg=%lx op=%p ret=%d",
+		      __entry->cookie, __entry->page, __entry->op, __entry->ret)
+	    );
+
+TRACE_EVENT(fscache_gang_lookup,
+	    TP_PROTO(struct fscache_cookie *cookie, struct fscache_operation *op,
+		     void **results, int n, pgoff_t store_limit),
+
+	    TP_ARGS(cookie, op, results, n, store_limit),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_operation *,	op		)
+		    __field(pgoff_t,			results0	)
+		    __field(int,			n		)
+		    __field(pgoff_t,			store_limit	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->op			= op;
+		    __entry->results0		= results[0] ? ((struct page *)results[0])->index : (pgoff_t)-1;
+		    __entry->n			= n;
+		    __entry->store_limit	= store_limit;
+			   ),
+
+	    TP_printk("c=%p op=%p r0=%lx n=%d sl=%lx",
+		      __entry->cookie, __entry->op, __entry->results0, __entry->n,
+		      __entry->store_limit)
+	    );
+
 #endif /* _TRACE_FSCACHE_H */
 
 /* This part must be outside protection */

