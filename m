Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756200Ab1I2OsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:48:14 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 08/13] FS-Cache: Make cookie relinquishment wait for
 outstanding reads
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:47:13 +0100
Message-ID: <20110929144713.5812.74883.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
index ae155f1..c593d57 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -301,6 +301,7 @@ struct fscache_cookie {
 #define FSCACHE_COOKIE_PENDING_FILL	3	/* T if pending initial fill on object */
 #define FSCACHE_COOKIE_FILLING		4	/* T if filling object incrementally */
 #define FSCACHE_COOKIE_UNAVAILABLE	5	/* T if cookie is unavailable (error, etc) */
+#define FSCACHE_COOKIE_WAITING_ON_READS	6	/* T if cookie is waiting on reads */
 };
 
 extern struct fscache_cookie fscache_fsdef_index;

