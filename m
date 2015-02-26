Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 08/13] FS-Cache: Out of line fscache_operation_init()
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:45 +0000
Message-ID: <20150226140245.2387.34670.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Out of line fscache_operation_init() so that it can access internal FS-Cache
features, such as stats, in a later commit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/operation.c        |   22 ++++++++++++++++++++++
 include/linux/fscache-cache.h |   24 +++---------------------
 2 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 67594a8d791a..61a6e78b85fa 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -21,6 +21,28 @@ atomic_t fscache_op_debug_id;
 EXPORT_SYMBOL(fscache_op_debug_id);
 
 /**
+ * fscache_operation_init - Do basic initialisation of an operation
+ * @op: The operation to initialise
+ * @release: The release function to assign
+ *
+ * Do basic initialisation of an operation.  The caller must still set flags,
+ * object and processor if needed.
+ */
+void fscache_operation_init(struct fscache_operation *op,
+			    fscache_operation_processor_t processor,
+			    fscache_operation_release_t release)
+{
+	INIT_WORK(&op->work, fscache_op_work_func);
+	atomic_set(&op->usage, 1);
+	op->state = FSCACHE_OP_ST_INITIALISED;
+	op->debug_id = atomic_inc_return(&fscache_op_debug_id);
+	op->processor = processor;
+	op->release = release;
+	INIT_LIST_HEAD(&op->pend_link);
+}
+EXPORT_SYMBOL(fscache_operation_init);
+
+/**
  * fscache_enqueue_operation - Enqueue an operation for processing
  * @op: The operation to enqueue
  *
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index ca3d550da11e..0e26d49972e3 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -119,27 +119,9 @@ extern void fscache_op_work_func(struct work_struct *work);
 extern void fscache_enqueue_operation(struct fscache_operation *);
 extern void fscache_op_complete(struct fscache_operation *, bool);
 extern void fscache_put_operation(struct fscache_operation *);
-
-/**
- * fscache_operation_init - Do basic initialisation of an operation
- * @op: The operation to initialise
- * @release: The release function to assign
- *
- * Do basic initialisation of an operation.  The caller must still set flags,
- * object and processor if needed.
- */
-static inline void fscache_operation_init(struct fscache_operation *op,
-					fscache_operation_processor_t processor,
-					fscache_operation_release_t release)
-{
-	INIT_WORK(&op->work, fscache_op_work_func);
-	atomic_set(&op->usage, 1);
-	op->state = FSCACHE_OP_ST_INITIALISED;
-	op->debug_id = atomic_inc_return(&fscache_op_debug_id);
-	op->processor = processor;
-	op->release = release;
-	INIT_LIST_HEAD(&op->pend_link);
-}
+extern void fscache_operation_init(struct fscache_operation *,
+				   fscache_operation_processor_t,
+				   fscache_operation_release_t);
 
 /*
  * data read operation

