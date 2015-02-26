Return-Path: linux-kernel-owner@vger.kernel.org
Subject: [PATCH 13/13] FS-Cache: Retain the netfs context in the retrieval
 op earlier
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:03:17 +0000
Message-ID: <20150226140317.2387.19517.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the retrieval operation may be disposed of by fscache_put_operation()
before we actually set the context, the retrieval-specific cleanup operation
can produce a NULL-pointer dereference when it tries to unconditionally clean
up the netfs context.

Given that it is expected that we'll get at least as far as the place where we
currently set the context pointer and it is unlikely we'll go through the
error handling paths prior to that point, retain the context right from the
point that the retrieval op is allocated.

Concomitant to this, we need to retain the cookie pointer in the retrieval op
also so that we can call the netfs to release its context in the release
method.

In addition, we might now get into fscache_release_retrieval_op() with the op
only initialised.  To this end, set the operation to DEAD only after the
release method has been called and skip the n_pages test upon cleanup if the
op is still in the INITIALISED state.

Without these changes, the following oops might be seen:

	BUG: unable to handle kernel NULL pointer dereference at 00000000000000b8
	...
	RIP: 0010:[<ffffffffa0089c98>] fscache_release_retrieval_op+0xae/0x100
	...
	Call Trace:
	 [<ffffffffa0088560>] fscache_put_operation+0x117/0x2e0
	 [<ffffffffa008b8f5>] __fscache_read_or_alloc_pages+0x351/0x3ac
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

 fs/fscache/operation.c        |    2 +-
 fs/fscache/page.c             |   20 ++++++++++----------
 include/linux/fscache-cache.h |    1 +
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 57d4abb68656..de67745e1cd7 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -492,7 +492,6 @@ void fscache_put_operation(struct fscache_operation *op)
 	ASSERTIFCMP(op->state != FSCACHE_OP_ST_INITIALISED &&
 		    op->state != FSCACHE_OP_ST_COMPLETE,
 		    op->state, ==, FSCACHE_OP_ST_CANCELLED);
-	op->state = FSCACHE_OP_ST_DEAD;
 
 	fscache_stat(&fscache_n_op_release);
 
@@ -500,6 +499,7 @@ void fscache_put_operation(struct fscache_operation *op)
 		op->release(op);
 		op->release = NULL;
 	}
+	op->state = FSCACHE_OP_ST_DEAD;
 
 	object = op->object;
 	if (likely(object)) {
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index d1b23a67c031..483bbc613bf0 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -269,11 +269,12 @@ static void fscache_release_retrieval_op(struct fscache_operation *_op)
 
 	_enter("{OP%x}", op->op.debug_id);
 
-	ASSERTCMP(atomic_read(&op->n_pages), ==, 0);
+	ASSERTIFCMP(op->op.state != FSCACHE_OP_ST_INITIALISED,
+		    atomic_read(&op->n_pages), ==, 0);
 
 	fscache_hist(fscache_retrieval_histogram, op->start_time);
 	if (op->context)
-		fscache_put_context(op->op.object->cookie, op->context);
+		fscache_put_context(op->cookie, op->context);
 
 	_leave("");
 }
@@ -302,11 +303,18 @@ static struct fscache_retrieval *fscache_alloc_retrieval(
 	op->op.flags	= FSCACHE_OP_MYTHREAD |
 		(1UL << FSCACHE_OP_WAITING) |
 		(1UL << FSCACHE_OP_UNUSE_COOKIE);
+	op->cookie	= cookie;
 	op->mapping	= mapping;
 	op->end_io_func	= end_io_func;
 	op->context	= context;
 	op->start_time	= jiffies;
 	INIT_LIST_HEAD(&op->to_do);
+
+	/* Pin the netfs read context in case we need to do the actual netfs
+	 * read because we've encountered a cache read failure.
+	 */
+	if (context)
+		fscache_get_context(op->cookie, context);
 	return op;
 }
 
@@ -456,10 +464,6 @@ int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
 
 	fscache_stat(&fscache_n_retrieval_ops);
 
-	/* pin the netfs read context in case we need to do the actual netfs
-	 * read because we've encountered a cache read failure */
-	fscache_get_context(object->cookie, op->context);
-
 	/* we wait for the operation to become active, and then process it
 	 * *here*, in this thread, and not in the thread pool */
 	ret = fscache_wait_for_operation_activation(
@@ -586,10 +590,6 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 
 	fscache_stat(&fscache_n_retrieval_ops);
 
-	/* pin the netfs read context in case we need to do the actual netfs
-	 * read because we've encountered a cache read failure */
-	fscache_get_context(object->cookie, op->context);
-
 	/* we wait for the operation to become active, and then process it
 	 * *here*, in this thread, and not in the thread pool */
 	ret = fscache_wait_for_operation_activation(
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 69c6eb10d858..604e1526cd00 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -133,6 +133,7 @@ extern void fscache_operation_init(struct fscache_operation *,
  */
 struct fscache_retrieval {
 	struct fscache_operation op;
+	struct fscache_cookie	*cookie;	/* The netfs cookie */
 	struct address_space	*mapping;	/* netfs pages */
 	fscache_rw_complete_t	end_io_func;	/* function to call on I/O completion */
 	void			*context;	/* netfs read context (pinned) */

