Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762403Ab3ECAdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 20:33:37 -0400
Subject: [PATCH 4/8] FS-Cache: Uninline fscache_object_init()
To: linux-cachefs@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        hjayasur@redhat.com, jlayton@redhat.com, linux-kernel@vger.kernel.org
Date: Fri, 03 May 2013 01:33:35 +0100
Message-ID: <20130503003335.14952.45228.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130503003316.14952.51791.stgit@warthog.procyon.org.uk>
References: <20130503003316.14952.51791.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uninline fscache_object_init() so as not to expose some of the FS-Cache
internals to the cache backend.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/object.c           |   40 ++++++++++++++++++++++++++++++++++++++--
 include/linux/fscache-cache.h |   38 ++------------------------------------
 2 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 50d41c1..0133699 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -363,7 +363,7 @@ unsupported_event:
 /*
  * execute an object
  */
-void fscache_object_work_func(struct work_struct *work)
+static void fscache_object_work_func(struct work_struct *work)
 {
 	struct fscache_object *object =
 		container_of(work, struct fscache_object, work);
@@ -379,7 +379,43 @@ void fscache_object_work_func(struct work_struct *work)
 	clear_bit(FSCACHE_OBJECT_EV_REQUEUE, &object->events);
 	fscache_put_object(object);
 }
-EXPORT_SYMBOL(fscache_object_work_func);
+
+/**
+ * fscache_object_init - Initialise a cache object description
+ * @object: Object description
+ * @cookie: Cookie object will be attached to
+ * @cache: Cache in which backing object will be found
+ *
+ * Initialise a cache object description to its basic values.
+ *
+ * See Documentation/filesystems/caching/backend-api.txt for a complete
+ * description.
+ */
+void fscache_object_init(struct fscache_object *object,
+			 struct fscache_cookie *cookie,
+			 struct fscache_cache *cache)
+{
+	atomic_inc(&cache->object_count);
+
+	object->state = FSCACHE_OBJECT_INIT;
+	spin_lock_init(&object->lock);
+	INIT_LIST_HEAD(&object->cache_link);
+	INIT_HLIST_NODE(&object->cookie_link);
+	INIT_WORK(&object->work, fscache_object_work_func);
+	INIT_LIST_HEAD(&object->dependents);
+	INIT_LIST_HEAD(&object->dep_link);
+	INIT_LIST_HEAD(&object->pending_ops);
+	object->n_children = 0;
+	object->n_ops = object->n_in_progress = object->n_exclusive = 0;
+	object->events = object->event_mask = 0;
+	object->flags = 0;
+	object->store_limit = 0;
+	object->store_limit_l = 0;
+	object->cache = cache;
+	object->cookie = cookie;
+	object->parent = NULL;
+}
+EXPORT_SYMBOL(fscache_object_init);
 
 /*
  * initialise an object
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 5dfa0aa..9b9c1de 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -426,42 +426,8 @@ extern const char *fscache_object_states[];
 	(test_bit(FSCACHE_IOERROR, &(obj)->cache->flags) &&	\
 	 (obj)->state >= FSCACHE_OBJECT_DYING)
 
-extern void fscache_object_work_func(struct work_struct *work);
-
-/**
- * fscache_object_init - Initialise a cache object description
- * @object: Object description
- *
- * Initialise a cache object description to its basic values.
- *
- * See Documentation/filesystems/caching/backend-api.txt for a complete
- * description.
- */
-static inline
-void fscache_object_init(struct fscache_object *object,
-			 struct fscache_cookie *cookie,
-			 struct fscache_cache *cache)
-{
-	atomic_inc(&cache->object_count);
-
-	object->state = FSCACHE_OBJECT_INIT;
-	spin_lock_init(&object->lock);
-	INIT_LIST_HEAD(&object->cache_link);
-	INIT_HLIST_NODE(&object->cookie_link);
-	INIT_WORK(&object->work, fscache_object_work_func);
-	INIT_LIST_HEAD(&object->dependents);
-	INIT_LIST_HEAD(&object->dep_link);
-	INIT_LIST_HEAD(&object->pending_ops);
-	object->n_children = 0;
-	object->n_ops = object->n_in_progress = object->n_exclusive = 0;
-	object->events = object->event_mask = 0;
-	object->flags = 0;
-	object->store_limit = 0;
-	object->store_limit_l = 0;
-	object->cache = cache;
-	object->cookie = cookie;
-	object->parent = NULL;
-}
+extern void fscache_object_init(struct fscache_object *, struct fscache_cookie *,
+				struct fscache_cache *);
 
 extern void fscache_object_lookup_negative(struct fscache_object *object);
 extern void fscache_obtained_object(struct fscache_object *object);

