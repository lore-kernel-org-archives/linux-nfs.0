Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 07/13] FS-Cache: Permit fscache_cancel_op() to cancel
 in-progress operations too
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:39 +0000
Message-ID: <20150226140239.2387.13014.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, fscache_cancel_op() only cancels pending operations - attempts to
cancel in-progress operations are ignored.  This leads to a problem in
fscache_wait_for_operation_activation() whereby the wait is terminated, but
the object has been killed.

The check at the end of the function now triggers because it's no longer
contingent on the cache having produced an I/O error since the commit that
fixed the logic error in fscache_object_is_dead().

The result of the check is that it tries to cancel the operation - but since
the object may not be pending by this point, the cancellation request may be
ignored - with the result that the the object is just put by the caller and
fscache_put_operation has an assertion failure because the operation isn't in
either the COMPLETE or the CANCELLED states.

To fix this, we permit in-progress ops to be cancelled under some
circumstances.

The bug results in an oops that looks something like this:

	FS-Cache: fscache_wait_for_operation_activation() = -ENOBUFS [obj dead 3]
	FS-Cache:
	FS-Cache: Assertion failed
	FS-Cache: 3 == 5 is false
	------------[ cut here ]------------
	kernel BUG at ../fs/fscache/operation.c:432!
	...
	RIP: 0010:[<ffffffffa0088574>] fscache_put_operation+0xf2/0x2cd
	Call Trace:
	 [<ffffffffa008b92a>] __fscache_read_or_alloc_pages+0x2ec/0x3b3
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

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/internal.h  |    3 ++-
 fs/fscache/operation.c |   20 +++++++++++++++++---
 fs/fscache/page.c      |    4 ++--
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 3063a58b7d3d..87c4544ec912 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -125,7 +125,8 @@ extern int fscache_submit_exclusive_op(struct fscache_object *,
 extern int fscache_submit_op(struct fscache_object *,
 			     struct fscache_operation *);
 extern int fscache_cancel_op(struct fscache_operation *,
-			     void (*)(struct fscache_operation *));
+			     void (*)(struct fscache_operation *),
+			     bool);
 extern void fscache_cancel_all_ops(struct fscache_object *);
 extern void fscache_abort_object(struct fscache_object *);
 extern void fscache_start_operations(struct fscache_object *);
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 18658fffbba1..67594a8d791a 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -312,9 +312,11 @@ void fscache_start_operations(struct fscache_object *object)
  * cancel an operation that's pending on an object
  */
 int fscache_cancel_op(struct fscache_operation *op,
-		      void (*do_cancel)(struct fscache_operation *))
+		      void (*do_cancel)(struct fscache_operation *),
+		      bool cancel_in_progress_op)
 {
 	struct fscache_object *object = op->object;
+	bool put = false;
 	int ret;
 
 	_enter("OBJ%x OP%x}", op->object->debug_id, op->debug_id);
@@ -328,8 +330,19 @@ int fscache_cancel_op(struct fscache_operation *op,
 	ret = -EBUSY;
 	if (op->state == FSCACHE_OP_ST_PENDING) {
 		ASSERT(!list_empty(&op->pend_link));
-		fscache_stat(&fscache_n_op_cancelled);
 		list_del_init(&op->pend_link);
+		put = true;
+		fscache_stat(&fscache_n_op_cancelled);
+		if (do_cancel)
+			do_cancel(op);
+		op->state = FSCACHE_OP_ST_CANCELLED;
+		if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
+			object->n_exclusive--;
+		if (test_and_clear_bit(FSCACHE_OP_WAITING, &op->flags))
+			wake_up_bit(&op->flags, FSCACHE_OP_WAITING);
+		ret = 0;
+	} else if (op->state == FSCACHE_OP_ST_IN_PROGRESS && cancel_in_progress_op) {
+		fscache_stat(&fscache_n_op_cancelled);
 		if (do_cancel)
 			do_cancel(op);
 		op->state = FSCACHE_OP_ST_CANCELLED;
@@ -337,10 +350,11 @@ int fscache_cancel_op(struct fscache_operation *op,
 			object->n_exclusive--;
 		if (test_and_clear_bit(FSCACHE_OP_WAITING, &op->flags))
 			wake_up_bit(&op->flags, FSCACHE_OP_WAITING);
-		fscache_put_operation(op);
 		ret = 0;
 	}
 
+	if (put)
+		fscache_put_operation(op);
 	spin_unlock(&object->lock);
 	_leave(" = %d", ret);
 	return ret;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index d0805e31361c..433cae927eca 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -359,7 +359,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
 		fscache_stat(stat_op_waits);
 	if (wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
 			TASK_INTERRUPTIBLE) != 0) {
-		ret = fscache_cancel_op(op, do_cancel);
+		ret = fscache_cancel_op(op, do_cancel, false);
 		if (ret == 0)
 			return -ERESTARTSYS;
 
@@ -380,7 +380,7 @@ check_if_dead:
 	if (unlikely(fscache_object_is_dying(object) ||
 		     fscache_cache_is_broken(object))) {
 		enum fscache_operation_state state = op->state;
-		fscache_cancel_op(op, do_cancel);
+		fscache_cancel_op(op, do_cancel, true);
 		if (stat_object_dead)
 			fscache_stat(stat_object_dead);
 		_leave(" = -ENOBUFS [obj dead %d]", state);

