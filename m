Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752274AbeDDWHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:19 -0400
Subject: [PATCH 05/12] fscache: Pass the correct cancelled indications to
 fscache_op_complete()
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:15 +0100
Message-ID: <152287963567.14760.16595321606457703954.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The last parameter to fscache_op_complete() is a bool indicating whether or
not the operation was cancelled.  A lot of the time the inverse value is
given or no differentiation is made.  Fix this.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/page.c             |   15 +++++++++------
 include/linux/fscache-cache.h |    2 +-
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 961029e04027..adc39c0c62df 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -185,9 +185,11 @@ static void fscache_attr_changed_op(struct fscache_operation *op)
 		fscache_stat_d(&fscache_n_cop_attr_changed);
 		if (ret < 0)
 			fscache_abort_object(object);
+		fscache_op_complete(op, ret < 0);
+	} else {
+		fscache_op_complete(op, true);
 	}
 
-	fscache_op_complete(op, true);
 	_leave("");
 }
 
@@ -780,11 +782,12 @@ static void fscache_write_op(struct fscache_operation *_op)
 	cookie = object->cookie;
 
 	if (!fscache_object_is_active(object)) {
-		/* If we get here, then the on-disk cache object likely longer
-		 * exists, so we should just cancel this write operation.
+		/* If we get here, then the on-disk cache object likely no
+		 * longer exists, so we should just cancel this write
+		 * operation.
 		 */
 		spin_unlock(&object->lock);
-		fscache_op_complete(&op->op, false);
+		fscache_op_complete(&op->op, true);
 		_leave(" [inactive]");
 		return;
 	}
@@ -797,7 +800,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 		 * cancel this write operation.
 		 */
 		spin_unlock(&object->lock);
-		fscache_op_complete(&op->op, false);
+		fscache_op_complete(&op->op, true);
 		_leave(" [cancel] op{f=%lx s=%u} obj{s=%s f=%lx}",
 		       _op->flags, _op->state, object->state->short_name,
 		       object->flags);
@@ -851,7 +854,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 	spin_unlock(&cookie->stores_lock);
 	clear_bit(FSCACHE_OBJECT_PENDING_WRITE, &object->flags);
 	spin_unlock(&object->lock);
-	fscache_op_complete(&op->op, true);
+	fscache_op_complete(&op->op, false);
 	_leave("");
 }
 
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 3b03e29e2f1a..b19fa8592fc2 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -185,7 +185,7 @@ static inline void fscache_retrieval_complete(struct fscache_retrieval *op,
 {
 	atomic_sub(n_pages, &op->n_pages);
 	if (atomic_read(&op->n_pages) <= 0)
-		fscache_op_complete(&op->op, true);
+		fscache_op_complete(&op->op, false);
 }
 
 /**

