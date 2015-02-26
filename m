Return-Path: linux-kernel-owner@vger.kernel.org
Subject: [PATCH 02/13] FS-Cache: Move fscache_report_unexpected_submission()
 to make it more available
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:09 +0000
Message-ID: <20150226140209.2387.62527.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move fscache_report_unexpected_submission() up within operation.c so that it
can be called from fscache_submit_exclusive_op() too.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/operation.c |   74 ++++++++++++++++++++++++------------------------
 1 file changed, 37 insertions(+), 37 deletions(-)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index e7b87a0e5185..68ead8482617 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -76,6 +76,43 @@ static void fscache_run_op(struct fscache_object *object,
 }
 
 /*
+ * report an unexpected submission
+ */
+static void fscache_report_unexpected_submission(struct fscache_object *object,
+						 struct fscache_operation *op,
+						 const struct fscache_state *ostate)
+{
+	static bool once_only;
+	struct fscache_operation *p;
+	unsigned n;
+
+	if (once_only)
+		return;
+	once_only = true;
+
+	kdebug("unexpected submission OP%x [OBJ%x %s]",
+	       op->debug_id, object->debug_id, object->state->name);
+	kdebug("objstate=%s [%s]", object->state->name, ostate->name);
+	kdebug("objflags=%lx", object->flags);
+	kdebug("objevent=%lx [%lx]", object->events, object->event_mask);
+	kdebug("ops=%u inp=%u exc=%u",
+	       object->n_ops, object->n_in_progress, object->n_exclusive);
+
+	if (!list_empty(&object->pending_ops)) {
+		n = 0;
+		list_for_each_entry(p, &object->pending_ops, pend_link) {
+			ASSERTCMP(p->object, ==, object);
+			kdebug("%p %p", op->processor, op->release);
+			n++;
+		}
+
+		kdebug("n=%u", n);
+	}
+
+	dump_stack();
+}
+
+/*
  * submit an exclusive operation for an object
  * - other ops are excluded from running simultaneously with this one
  * - this gets any extra refs it needs on an op
@@ -139,43 +176,6 @@ int fscache_submit_exclusive_op(struct fscache_object *object,
 }
 
 /*
- * report an unexpected submission
- */
-static void fscache_report_unexpected_submission(struct fscache_object *object,
-						 struct fscache_operation *op,
-						 const struct fscache_state *ostate)
-{
-	static bool once_only;
-	struct fscache_operation *p;
-	unsigned n;
-
-	if (once_only)
-		return;
-	once_only = true;
-
-	kdebug("unexpected submission OP%x [OBJ%x %s]",
-	       op->debug_id, object->debug_id, object->state->name);
-	kdebug("objstate=%s [%s]", object->state->name, ostate->name);
-	kdebug("objflags=%lx", object->flags);
-	kdebug("objevent=%lx [%lx]", object->events, object->event_mask);
-	kdebug("ops=%u inp=%u exc=%u",
-	       object->n_ops, object->n_in_progress, object->n_exclusive);
-
-	if (!list_empty(&object->pending_ops)) {
-		n = 0;
-		list_for_each_entry(p, &object->pending_ops, pend_link) {
-			ASSERTCMP(p->object, ==, object);
-			kdebug("%p %p", op->processor, op->release);
-			n++;
-		}
-
-		kdebug("n=%u", n);
-	}
-
-	dump_stack();
-}
-
-/*
  * submit an operation for an object
  * - objects may be submitted only in the following states:
  *   - during object creation (write ops may be submitted)

