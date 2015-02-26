Return-Path: linux-kernel-owner@vger.kernel.org
Subject: [PATCH 03/13] FS-Cache: When submitting an op,
 cancel it if the target object is dying
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:15 +0000
Message-ID: <20150226140215.2387.57638.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When submitting an operation, prefer to cancel the operation immediately
rather than queuing it for later processing if the object is marked as dying
(ie. the object state machine has reached the KILL_OBJECT state).

Whilst we're at it, change the series of related test_bit() calls into a
READ_ONCE() and bitwise-AND operators to reduce the number of load
instructions (test_bit() has a volatile address).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/operation.c        |   47 ++++++++++++++++++++++++++---------------
 include/linux/fscache-cache.h |    9 ++++++--
 2 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 68ead8482617..dec6defe3be3 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -120,6 +120,8 @@ static void fscache_report_unexpected_submission(struct fscache_object *object,
 int fscache_submit_exclusive_op(struct fscache_object *object,
 				struct fscache_operation *op)
 {
+	const struct fscache_state *ostate;
+	unsigned long flags;
 	int ret;
 
 	_enter("{OBJ%x OP%x},", object->debug_id, op->debug_id);
@@ -132,8 +134,19 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 	ASSERTCMP(object->n_ops, >=, object->n_exclusive);
 	ASSERT(list_empty(&op->pend_link));
 
+	ostate = object->state;
+	smp_rmb();
+
 	op->state = FSCACHE_OP_ST_PENDING;
-	if (fscache_object_is_active(object)) {
+	flags = READ_ONCE(object->flags);
+	if (unlikely(!(flags & BIT(FSCACHE_OBJECT_IS_LIVE)))) {
+		fscache_stat(&fscache_n_op_rejected);
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		ret = -ENOBUFS;
+	} else if (unlikely(fscache_cache_is_broken(object))) {
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		ret = -EIO;
+	} else if (flags & BIT(FSCACHE_OBJECT_IS_AVAILABLE)) {
 		op->object = object;
 		object->n_ops++;
 		object->n_exclusive++;	/* reads and writes must wait */
@@ -155,7 +168,7 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 		/* need to issue a new write op after this */
 		clear_bit(FSCACHE_OBJECT_PENDING_WRITE, &object->flags);
 		ret = 0;
-	} else if (test_bit(FSCACHE_OBJECT_IS_LOOKED_UP, &object->flags)) {
+	} else if (flags & BIT(FSCACHE_OBJECT_IS_LOOKED_UP)) {
 		op->object = object;
 		object->n_ops++;
 		object->n_exclusive++;	/* reads and writes must wait */
@@ -164,11 +177,9 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 		fscache_stat(&fscache_n_op_pend);
 		ret = 0;
 	} else {
-		/* If we're in any other state, there must have been an I/O
-		 * error of some nature.
-		 */
-		ASSERT(test_bit(FSCACHE_IOERROR, &object->cache->flags));
-		ret = -EIO;
+		fscache_report_unexpected_submission(object, op, ostate);
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		ret = -ENOBUFS;
 	}
 
 	spin_unlock(&object->lock);
@@ -187,6 +198,7 @@ int fscache_submit_op(struct fscache_object *object,
 		      struct fscache_operation *op)
 {
 	const struct fscache_state *ostate;
+	unsigned long flags;
 	int ret;
 
 	_enter("{OBJ%x OP%x},{%u}",
@@ -204,7 +216,15 @@ int fscache_submit_op(struct fscache_object *object,
 	smp_rmb();
 
 	op->state = FSCACHE_OP_ST_PENDING;
-	if (fscache_object_is_active(object)) {
+	flags = READ_ONCE(object->flags);
+	if (unlikely(!(flags & BIT(FSCACHE_OBJECT_IS_LIVE)))) {
+		fscache_stat(&fscache_n_op_rejected);
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		ret = -ENOBUFS;
+	} else if (unlikely(fscache_cache_is_broken(object))) {
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		ret = -EIO;
+	} else if (flags & BIT(FSCACHE_OBJECT_IS_AVAILABLE)) {
 		op->object = object;
 		object->n_ops++;
 
@@ -222,25 +242,18 @@ int fscache_submit_op(struct fscache_object *object,
 			fscache_run_op(object, op);
 		}
 		ret = 0;
-	} else if (test_bit(FSCACHE_OBJECT_IS_LOOKED_UP, &object->flags)) {
+	} else if (flags & BIT(FSCACHE_OBJECT_IS_LOOKED_UP)) {
 		op->object = object;
 		object->n_ops++;
 		atomic_inc(&op->usage);
 		list_add_tail(&op->pend_link, &object->pending_ops);
 		fscache_stat(&fscache_n_op_pend);
 		ret = 0;
-	} else if (fscache_object_is_dying(object)) {
-		fscache_stat(&fscache_n_op_rejected);
-		op->state = FSCACHE_OP_ST_CANCELLED;
-		ret = -ENOBUFS;
-	} else if (!test_bit(FSCACHE_IOERROR, &object->cache->flags)) {
+	} else {
 		fscache_report_unexpected_submission(object, op, ostate);
 		ASSERT(!fscache_object_is_active(object));
 		op->state = FSCACHE_OP_ST_CANCELLED;
 		ret = -ENOBUFS;
-	} else {
-		op->state = FSCACHE_OP_ST_CANCELLED;
-		ret = -ENOBUFS;
 	}
 
 	spin_unlock(&object->lock);
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index c9dafdaf3347..2e83a141e465 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -411,17 +411,22 @@ static inline bool fscache_object_is_available(struct fscache_object *object)
 	return test_bit(FSCACHE_OBJECT_IS_AVAILABLE, &object->flags);
 }
 
+static inline bool fscache_cache_is_broken(struct fscache_object *object)
+{
+	return test_bit(FSCACHE_IOERROR, &object->cache->flags);
+}
+
 static inline bool fscache_object_is_active(struct fscache_object *object)
 {
 	return fscache_object_is_available(object) &&
 		fscache_object_is_live(object) &&
-		!test_bit(FSCACHE_IOERROR, &object->cache->flags);
+		!fscache_cache_is_broken(object);
 }
 
 static inline bool fscache_object_is_dead(struct fscache_object *object)
 {
 	return fscache_object_is_dying(object) &&
-		test_bit(FSCACHE_IOERROR, &object->cache->flags);
+		fscache_cache_is_broken(object);
 }
 
 /**

