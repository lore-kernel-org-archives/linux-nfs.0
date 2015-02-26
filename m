Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161AbbBZODJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 09:03:09 -0500
Subject: [PATCH 11/13] FS-Cache: Put an aborted initialised op so that it is
 accounted correctly
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:03:03 +0000
Message-ID: <20150226140303.2387.28512.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call fscache_put_operation() or a wrapper on any op that has gone through
fscache_operation_init() so that the accounting shown in /proc is done
correctly, specifically fscache_n_op_release.

fscache_put_operation() therefore now allows an op in the INITIALISED state as
well as in the CANCELLED and COMPLETE states.

Note that this means that an operation can get put that doesn't have its
->object pointer filled in, so anything that depends on the object needs to be
conditional in fscache_put_operation().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/operation.c |   54 +++++++++++++++++++++++++-----------------------
 fs/fscache/page.c      |   14 ++++++------
 2 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index b6bf5f399d70..c76c09730768 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -472,7 +472,8 @@ void fscache_put_operation(struct fscache_operation *op)
 		return;
 
 	_debug("PUT OP");
-	ASSERTIFCMP(op->state != FSCACHE_OP_ST_COMPLETE,
+	ASSERTIFCMP(op->state != FSCACHE_OP_ST_INITIALISED &&
+		    op->state != FSCACHE_OP_ST_COMPLETE,
 		    op->state, ==, FSCACHE_OP_ST_CANCELLED);
 	op->state = FSCACHE_OP_ST_DEAD;
 
@@ -484,35 +485,36 @@ void fscache_put_operation(struct fscache_operation *op)
 	}
 
 	object = op->object;
+	if (likely(object)) {
+		if (test_bit(FSCACHE_OP_DEC_READ_CNT, &op->flags))
+			atomic_dec(&object->n_reads);
+		if (test_bit(FSCACHE_OP_UNUSE_COOKIE, &op->flags))
+			fscache_unuse_cookie(object);
+
+		/* now... we may get called with the object spinlock held, so we
+		 * complete the cleanup here only if we can immediately acquire the
+		 * lock, and defer it otherwise */
+		if (!spin_trylock(&object->lock)) {
+			_debug("defer put");
+			fscache_stat(&fscache_n_op_deferred_release);
+
+			cache = object->cache;
+			spin_lock(&cache->op_gc_list_lock);
+			list_add_tail(&op->pend_link, &cache->op_gc_list);
+			spin_unlock(&cache->op_gc_list_lock);
+			schedule_work(&cache->op_gc);
+			_leave(" [defer]");
+			return;
+		}
 
-	if (test_bit(FSCACHE_OP_DEC_READ_CNT, &op->flags))
-		atomic_dec(&object->n_reads);
-	if (test_bit(FSCACHE_OP_UNUSE_COOKIE, &op->flags))
-		fscache_unuse_cookie(object);
-
-	/* now... we may get called with the object spinlock held, so we
-	 * complete the cleanup here only if we can immediately acquire the
-	 * lock, and defer it otherwise */
-	if (!spin_trylock(&object->lock)) {
-		_debug("defer put");
-		fscache_stat(&fscache_n_op_deferred_release);
+		ASSERTCMP(object->n_ops, >, 0);
+		object->n_ops--;
+		if (object->n_ops == 0)
+			fscache_raise_event(object, FSCACHE_OBJECT_EV_CLEARED);
 
-		cache = object->cache;
-		spin_lock(&cache->op_gc_list_lock);
-		list_add_tail(&op->pend_link, &cache->op_gc_list);
-		spin_unlock(&cache->op_gc_list_lock);
-		schedule_work(&cache->op_gc);
-		_leave(" [defer]");
-		return;
+		spin_unlock(&object->lock);
 	}
 
-	ASSERTCMP(object->n_ops, >, 0);
-	object->n_ops--;
-	if (object->n_ops == 0)
-		fscache_raise_event(object, FSCACHE_OBJECT_EV_CLEARED);
-
-	spin_unlock(&object->lock);
-
 	kfree(op);
 	_leave(" [done]");
 }
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 433cae927eca..7db9752252ef 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -239,7 +239,7 @@ nobufs_dec:
 	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs:
 	spin_unlock(&cookie->lock);
-	kfree(op);
+	fscache_put_operation(op);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
 	fscache_stat(&fscache_n_attr_changed_nobufs);
@@ -505,7 +505,7 @@ nobufs_unlock:
 	spin_unlock(&cookie->lock);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
-	kfree(op);
+	fscache_put_retrieval(op);
 nobufs:
 	fscache_stat(&fscache_n_retrievals_nobufs);
 	_leave(" = -ENOBUFS");
@@ -634,7 +634,7 @@ nobufs_unlock_dec:
 	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs_unlock:
 	spin_unlock(&cookie->lock);
-	kfree(op);
+	fscache_put_retrieval(op);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
 nobufs:
@@ -728,7 +728,7 @@ nobufs_unlock_dec:
 	wake_cookie = __fscache_unuse_cookie(cookie);
 nobufs_unlock:
 	spin_unlock(&cookie->lock);
-	kfree(op);
+	fscache_put_retrieval(op);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
 nobufs:
@@ -1018,7 +1018,7 @@ already_pending:
 	spin_unlock(&object->lock);
 	spin_unlock(&cookie->lock);
 	radix_tree_preload_end();
-	kfree(op);
+	fscache_put_operation(&op->op);
 	fscache_stat(&fscache_n_stores_ok);
 	_leave(" = 0");
 	return 0;
@@ -1038,7 +1038,7 @@ nobufs_unlock_obj:
 nobufs:
 	spin_unlock(&cookie->lock);
 	radix_tree_preload_end();
-	kfree(op);
+	fscache_put_operation(&op->op);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
 	fscache_stat(&fscache_n_stores_nobufs);
@@ -1046,7 +1046,7 @@ nobufs:
 	return -ENOBUFS;
 
 nomem_free:
-	kfree(op);
+	fscache_put_operation(&op->op);
 nomem:
 	fscache_stat(&fscache_n_stores_oom);
 	_leave(" = -ENOMEM");

