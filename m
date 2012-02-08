Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756936Ab2BHVRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:17:41 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/17] FS-Cache: Make cookie relinquishment wait for
 outstanding reads
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:17:31 +0000
Message-ID: <20120208211731.15607.87865.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make fscache_relinquish_cookie() log a warning and wait if there are any
outstanding reads left on the cookie it was given.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c           |   18 ++++++++++++++----
 fs/fscache/operation.c        |   10 ++++++++--
 include/linux/fscache-cache.h |    1 +
 3 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 0666996..66be9ec 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -442,22 +442,32 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, int retire)
 
 	event = retire ? FSCACHE_OBJECT_EV_RETIRE : FSCACHE_OBJECT_EV_RELEASE;
 
+try_again:
 	spin_lock(&cookie->lock);
 
 	/* break links with all the active objects */
 	while (!hlist_empty(&cookie->backing_objects)) {
+		int n_reads;
 		object = hlist_entry(cookie->backing_objects.first,
 				     struct fscache_object,
 				     cookie_link);
 
 		_debug("RELEASE OBJ%x", object->debug_id);
 
-		if (atomic_read(&object->n_reads)) {
+		set_bit(FSCACHE_COOKIE_WAITING_ON_READS, &cookie->flags);
+		n_reads = atomic_read(&object->n_reads);
+		if (n_reads) {
+			int n_ops = object->n_ops;
+			int n_in_progress = object->n_in_progress;
 			spin_unlock(&cookie->lock);
 			printk(KERN_ERR "FS-Cache:"
-			       " Cookie '%s' still has %d outstanding reads\n",
-			       cookie->def->name, atomic_read(&object->n_reads));
-			BUG();
+			       " Cookie '%s' still has %d outstanding reads (%d,%d)\n",
+			       cookie->def->name,
+			       n_reads, n_ops, n_in_progress);
+			wait_on_bit(&cookie->flags, FSCACHE_COOKIE_WAITING_ON_READS,
+				    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
+			printk("Wait finished\n");
+			goto try_again;
 		}
 
 		/* detach each cache object from the object cookie */
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 30afdfa..c857ab8 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -340,8 +340,14 @@ void fscache_put_operation(struct fscache_operation *op)
 
 	object = op->object;
 
-	if (test_bit(FSCACHE_OP_DEC_READ_CNT, &op->flags))
-		atomic_dec(&object->n_reads);
+	if (test_bit(FSCACHE_OP_DEC_READ_CNT, &op->flags)) {
+		if (atomic_dec_and_test(&object->n_reads)) {
+			clear_bit(FSCACHE_COOKIE_WAITING_ON_READS,
+				  &object->cookie->flags);
+			wake_up_bit(&object->cookie->flags,
+				    FSCACHE_COOKIE_WAITING_ON_READS);
+		}
+	}
 
 	/* now... we may get called with the object spinlock held, so we
 	 * complete the cleanup here only if we can immediately acquire the
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 9879183..e3d6d93 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -301,6 +301,7 @@ struct fscache_cookie {
 #define FSCACHE_COOKIE_PENDING_FILL	3	/* T if pending initial fill on object */
 #define FSCACHE_COOKIE_FILLING		4	/* T if filling object incrementally */
 #define FSCACHE_COOKIE_UNAVAILABLE	5	/* T if cookie is unavailable (error, etc) */
+#define FSCACHE_COOKIE_WAITING_ON_READS	6	/* T if cookie is waiting on reads */
 };
 
 extern struct fscache_cookie fscache_fsdef_index;

