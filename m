Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752246AbeDDWHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:39 -0400
Subject: [PATCH 08/12] fscache: Add tracepoints
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:37 +0100
Message-ID: <152287965708.14760.1890566472418421211.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some tracepoints to fscache:

 (*) fscache_cookie - Tracks a cookie's usage count.

 (*) fscache_netfs - Logs registration of a network filesystem, including
     the pointer to the cookie allocated.

 (*) fscache_acquire - Logs cookie acquisition.

 (*) fscache_relinquish - Logs cookie relinquishment.

 (*) fscache_enable - Logs enablement of a cookie.

 (*) fscache_disable - Logs disablement of a cookie.

 (*) fscache_osm - Tracks execution of states in the object state machine.

and cachefiles:

 (*) cachefiles_ref - Tracks a cachefiles object's usage count.

 (*) cachefiles_lookup - Logs result of lookup_one_len().

 (*) cachefiles_mkdir - Logs result of vfs_mkdir().

 (*) cachefiles_create - Logs result of vfs_create().

 (*) cachefiles_unlink - Logs calls to vfs_unlink().

 (*) cachefiles_rename - Logs calls to vfs_rename().

 (*) cachefiles_mark_active - Logs an object becoming active.

 (*) cachefiles_wait_active - Logs a wait for an old object to be
     destroyed.

 (*) cachefiles_mark_inactive - Logs an object becoming inactive.

 (*) cachefiles_mark_buried - Logs the burial of an object.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/interface.c         |   18 ++
 fs/cachefiles/internal.h          |    2 
 fs/cachefiles/main.c              |    1 
 fs/cachefiles/namei.c             |   42 ++++-
 fs/fscache/cookie.c               |   46 +++--
 fs/fscache/internal.h             |   16 +-
 fs/fscache/main.c                 |    1 
 fs/fscache/netfs.c                |    3 
 fs/fscache/object.c               |   36 +++-
 include/linux/fscache-cache.h     |   18 ++
 include/trace/events/cachefiles.h |  325 +++++++++++++++++++++++++++++++++++++
 include/trace/events/fscache.h    |  277 ++++++++++++++++++++++++++++++++
 12 files changed, 731 insertions(+), 54 deletions(-)
 create mode 100644 include/trace/events/cachefiles.h
 create mode 100644 include/trace/events/fscache.h

diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index e7f16a77a22a..405ebc3932c2 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -177,10 +177,12 @@ static void cachefiles_lookup_complete(struct fscache_object *_object)
  * increment the usage count on an inode object (may fail if unmounting)
  */
 static
-struct fscache_object *cachefiles_grab_object(struct fscache_object *_object)
+struct fscache_object *cachefiles_grab_object(struct fscache_object *_object,
+					      enum fscache_obj_ref_trace why)
 {
 	struct cachefiles_object *object =
 		container_of(_object, struct cachefiles_object, fscache);
+	int u;
 
 	_enter("{OBJ%x,%d}", _object->debug_id, atomic_read(&object->usage));
 
@@ -188,7 +190,9 @@ struct fscache_object *cachefiles_grab_object(struct fscache_object *_object)
 	ASSERT((atomic_read(&object->usage) & 0xffff0000) != 0x6b6b0000);
 #endif
 
-	atomic_inc(&object->usage);
+	u = atomic_inc_return(&object->usage);
+	trace_cachefiles_ref(object, _object->cookie,
+			     (enum cachefiles_obj_ref_trace)why, u);
 	return &object->fscache;
 }
 
@@ -309,10 +313,12 @@ static void cachefiles_drop_object(struct fscache_object *_object)
 /*
  * dispose of a reference to an object
  */
-static void cachefiles_put_object(struct fscache_object *_object)
+static void cachefiles_put_object(struct fscache_object *_object,
+				  enum fscache_obj_ref_trace why)
 {
 	struct cachefiles_object *object;
 	struct fscache_cache *cache;
+	int u;
 
 	ASSERT(_object);
 
@@ -328,7 +334,11 @@ static void cachefiles_put_object(struct fscache_object *_object)
 	ASSERTIFCMP(object->fscache.parent,
 		    object->fscache.parent->n_children, >, 0);
 
-	if (atomic_dec_and_test(&object->usage)) {
+	u = atomic_dec_return(&object->usage);
+	trace_cachefiles_ref(object, _object->cookie,
+			     (enum cachefiles_obj_ref_trace)why, u);
+	ASSERTCMP(u, !=, -1);
+	if (u == 0) {
 		_debug("- kill object OBJ%x", object->fscache.debug_id);
 
 		ASSERT(!test_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags));
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index bb3a02ca9da4..d2f6f996e65a 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -124,6 +124,8 @@ struct cachefiles_xattr {
 	uint8_t				data[];
 };
 
+#include <trace/events/cachefiles.h>
+
 /*
  * note change of state for daemon
  */
diff --git a/fs/cachefiles/main.c b/fs/cachefiles/main.c
index 711f13d8c2de..f54d3f5b2e40 100644
--- a/fs/cachefiles/main.c
+++ b/fs/cachefiles/main.c
@@ -22,6 +22,7 @@
 #include <linux/statfs.h>
 #include <linux/sysctl.h>
 #include <linux/miscdevice.h>
+#define CREATE_TRACE_POINTS
 #include "internal.h"
 
 unsigned cachefiles_debug;
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 3978b324cbca..5fc214256316 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -120,6 +120,7 @@ static void cachefiles_mark_object_buried(struct cachefiles_cache *cache,
 	}
 
 	write_unlock(&cache->active_lock);
+	trace_cachefiles_mark_buried(NULL, dentry, why);
 	_leave(" [no owner]");
 	return;
 
@@ -130,6 +131,8 @@ static void cachefiles_mark_object_buried(struct cachefiles_cache *cache,
 	       object->fscache.state->name,
 	       dentry);
 
+	trace_cachefiles_mark_buried(object, dentry, why);
+
 	if (fscache_object_is_live(&object->fscache)) {
 		pr_err("\n");
 		pr_err("Error: Can't preemptively bury live object\n");
@@ -158,13 +161,15 @@ static int cachefiles_mark_object_active(struct cachefiles_cache *cache,
 try_again:
 	write_lock(&cache->active_lock);
 
+	dentry = object->dentry;
+	trace_cachefiles_mark_active(object, dentry);
+
 	if (test_and_set_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags)) {
 		pr_err("Error: Object already active\n");
 		cachefiles_printk_object(object, NULL);
 		BUG();
 	}
 
-	dentry = object->dentry;
 	_p = &cache->active_nodes.rb_node;
 	while (*_p) {
 		_parent = *_p;
@@ -191,6 +196,8 @@ static int cachefiles_mark_object_active(struct cachefiles_cache *cache,
 	/* an old object from a previous incarnation is hogging the slot - we
 	 * need to wait for it to be destroyed */
 wait_for_old_object:
+	trace_cachefiles_wait_active(object, dentry, xobject);
+
 	if (fscache_object_is_live(&xobject->fscache)) {
 		pr_err("\n");
 		pr_err("Error: Unexpected object collision\n");
@@ -248,12 +255,12 @@ static int cachefiles_mark_object_active(struct cachefiles_cache *cache,
 
 	ASSERT(!test_bit(CACHEFILES_OBJECT_ACTIVE, &xobject->flags));
 
-	cache->cache.ops->put_object(&xobject->fscache);
+	cache->cache.ops->put_object(&xobject->fscache, cachefiles_obj_put_wait_retry);
 	goto try_again;
 
 requeue:
 	clear_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags);
-	cache->cache.ops->put_object(&xobject->fscache);
+	cache->cache.ops->put_object(&xobject->fscache, cachefiles_obj_put_wait_timeo);
 	_leave(" = -ETIMEDOUT");
 	return -ETIMEDOUT;
 }
@@ -265,6 +272,11 @@ void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
 				     struct cachefiles_object *object,
 				     blkcnt_t i_blocks)
 {
+	struct dentry *dentry = object->dentry;
+	struct inode *inode = d_backing_inode(dentry);
+
+	trace_cachefiles_mark_inactive(object, dentry, inode);
+
 	write_lock(&cache->active_lock);
 	rb_erase(&object->active_node, &cache->active_nodes);
 	clear_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags);
@@ -288,6 +300,7 @@ void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
  * - unlocks the directory mutex
  */
 static int cachefiles_bury_object(struct cachefiles_cache *cache,
+				  struct cachefiles_object *object,
 				  struct dentry *dir,
 				  struct dentry *rep,
 				  bool preemptive,
@@ -312,6 +325,7 @@ static int cachefiles_bury_object(struct cachefiles_cache *cache,
 		if (ret < 0) {
 			cachefiles_io_error(cache, "Unlink security error");
 		} else {
+			trace_cachefiles_unlink(object, rep, why);
 			ret = vfs_unlink(d_inode(dir), rep, NULL);
 
 			if (preemptive)
@@ -413,6 +427,7 @@ static int cachefiles_bury_object(struct cachefiles_cache *cache,
 	if (ret < 0) {
 		cachefiles_io_error(cache, "Rename security error %d", ret);
 	} else {
+		trace_cachefiles_rename(object, rep, grave, why);
 		ret = vfs_rename(d_inode(dir), rep,
 				 d_inode(cache->graveyard), grave, NULL, 0);
 		if (ret != 0 && ret != -ENOMEM)
@@ -458,7 +473,7 @@ int cachefiles_delete_object(struct cachefiles_cache *cache,
 		/* we need to check that our parent is _still_ our parent - it
 		 * may have been renamed */
 		if (dir == object->dentry->d_parent) {
-			ret = cachefiles_bury_object(cache, dir,
+			ret = cachefiles_bury_object(cache, object, dir,
 						     object->dentry, false,
 						     FSCACHE_OBJECT_WAS_RETIRED);
 		} else {
@@ -486,6 +501,7 @@ int cachefiles_walk_to_object(struct cachefiles_object *parent,
 {
 	struct cachefiles_cache *cache;
 	struct dentry *dir, *next = NULL;
+	struct inode *inode;
 	struct path path;
 	unsigned long start;
 	const char *name;
@@ -529,13 +545,17 @@ int cachefiles_walk_to_object(struct cachefiles_object *parent,
 	start = jiffies;
 	next = lookup_one_len(name, dir, nlen);
 	cachefiles_hist(cachefiles_lookup_histogram, start);
-	if (IS_ERR(next))
+	if (IS_ERR(next)) {
+		trace_cachefiles_lookup(object, next, NULL);
 		goto lookup_error;
+	}
 
-	_debug("next -> %p %s", next, d_backing_inode(next) ? "positive" : "negative");
+	inode = d_backing_inode(next);
+	trace_cachefiles_lookup(object, next, inode);
+	_debug("next -> %p %s", next, inode ? "positive" : "negative");
 
 	if (!key)
-		object->new = !d_backing_inode(next);
+		object->new = !inode;
 
 	/* if this element of the path doesn't exist, then the lookup phase
 	 * failed, and we can release any readers in the certain knowledge that
@@ -558,6 +578,8 @@ int cachefiles_walk_to_object(struct cachefiles_object *parent,
 			start = jiffies;
 			ret = vfs_mkdir(d_inode(dir), next, 0);
 			cachefiles_hist(cachefiles_mkdir_histogram, start);
+			if (!key)
+				trace_cachefiles_mkdir(object, next, ret);
 			if (ret < 0)
 				goto create_error;
 
@@ -587,6 +609,7 @@ int cachefiles_walk_to_object(struct cachefiles_object *parent,
 			start = jiffies;
 			ret = vfs_create(d_inode(dir), next, S_IFREG, true);
 			cachefiles_hist(cachefiles_create_histogram, start);
+			trace_cachefiles_create(object, next, ret);
 			if (ret < 0)
 				goto create_error;
 
@@ -629,7 +652,8 @@ int cachefiles_walk_to_object(struct cachefiles_object *parent,
 			 * mutex) */
 			object->dentry = NULL;
 
-			ret = cachefiles_bury_object(cache, dir, next, true,
+			ret = cachefiles_bury_object(cache, object, dir, next,
+						     true,
 						     FSCACHE_OBJECT_IS_STALE);
 			dput(next);
 			next = NULL;
@@ -955,7 +979,7 @@ int cachefiles_cull(struct cachefiles_cache *cache, struct dentry *dir,
 	/*  actually remove the victim (drops the dir mutex) */
 	_debug("bury");
 
-	ret = cachefiles_bury_object(cache, dir, victim, false,
+	ret = cachefiles_bury_object(cache, NULL, dir, victim, false,
 				     FSCACHE_OBJECT_WAS_CULLED);
 	if (ret < 0)
 		goto error;
diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 98d22f495cd8..20bc3341f113 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -101,7 +101,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	 */
 	atomic_set(&cookie->n_active, 1);
 
-	atomic_inc(&parent->usage);
+	fscache_cookie_get(parent, fscache_cookie_get_acquire_parent);
 	atomic_inc(&parent->n_children);
 
 	cookie->def		= def;
@@ -125,6 +125,8 @@ struct fscache_cookie *__fscache_acquire_cookie(
 		break;
 	}
 
+	trace_fscache_acquire(cookie);
+
 	if (enable) {
 		/* if the object is an index then we need do nothing more here
 		 * - we create indices on disk when we need them as an index
@@ -134,7 +136,8 @@ struct fscache_cookie *__fscache_acquire_cookie(
 				set_bit(FSCACHE_COOKIE_ENABLED, &cookie->flags);
 			} else {
 				atomic_dec(&parent->n_children);
-				__fscache_cookie_put(cookie);
+				fscache_cookie_put(cookie,
+						   fscache_cookie_put_acquire_nobufs);
 				fscache_stat(&fscache_n_acquires_nobufs);
 				_leave(" = NULL");
 				return NULL;
@@ -159,6 +162,8 @@ void __fscache_enable_cookie(struct fscache_cookie *cookie,
 {
 	_enter("%p", cookie);
 
+	trace_fscache_enable(cookie);
+
 	wait_on_bit_lock(&cookie->flags, FSCACHE_COOKIE_ENABLEMENT_LOCK,
 			 TASK_UNINTERRUPTIBLE);
 
@@ -318,7 +323,7 @@ static int fscache_alloc_object(struct fscache_cache *cache,
 	 * attached to the cookie */
 	if (fscache_attach_object(cookie, object) < 0) {
 		fscache_stat(&fscache_n_cop_put_object);
-		cache->ops->put_object(object);
+		cache->ops->put_object(object, fscache_obj_put_attach_fail);
 		fscache_stat_d(&fscache_n_cop_put_object);
 	}
 
@@ -338,7 +343,7 @@ static int fscache_alloc_object(struct fscache_cache *cache,
 
 error_put:
 	fscache_stat(&fscache_n_cop_put_object);
-	cache->ops->put_object(object);
+	cache->ops->put_object(object, fscache_obj_put_alloc_fail);
 	fscache_stat_d(&fscache_n_cop_put_object);
 error:
 	_leave(" = %d", ret);
@@ -398,7 +403,7 @@ static int fscache_attach_object(struct fscache_cookie *cookie,
 
 	/* attach to the cookie */
 	object->cookie = cookie;
-	atomic_inc(&cookie->usage);
+	fscache_cookie_get(cookie, fscache_cookie_get_attach_object);
 	hlist_add_head(&object->cookie_link, &cookie->backing_objects);
 
 	fscache_objlist_add(object);
@@ -516,6 +521,8 @@ void __fscache_disable_cookie(struct fscache_cookie *cookie, bool invalidate)
 
 	_enter("%p,%u", cookie, invalidate);
 
+	trace_fscache_disable(cookie);
+
 	ASSERTCMP(atomic_read(&cookie->n_active), >, 0);
 
 	if (atomic_read(&cookie->n_children) != 0) {
@@ -601,6 +608,8 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 	       cookie, cookie->def->name, cookie->netfs_data,
 	       atomic_read(&cookie->n_active), retire);
 
+	trace_fscache_relinquish(cookie, retire);
+
 	/* No further netfs-accessing operations on this cookie permitted */
 	if (test_and_set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags))
 		BUG();
@@ -620,35 +629,38 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 
 	/* Dispose of the netfs's link to the cookie */
 	ASSERTCMP(atomic_read(&cookie->usage), >, 0);
-	fscache_cookie_put(cookie);
+	fscache_cookie_put(cookie, fscache_cookie_put_relinquish);
 
 	_leave("");
 }
 EXPORT_SYMBOL(__fscache_relinquish_cookie);
 
 /*
- * destroy a cookie
+ * Drop a reference to a cookie.
  */
-void __fscache_cookie_put(struct fscache_cookie *cookie)
+void fscache_cookie_put(struct fscache_cookie *cookie,
+			enum fscache_cookie_trace where)
 {
 	struct fscache_cookie *parent;
+	int usage;
 
 	_enter("%p", cookie);
 
-	for (;;) {
-		_debug("FREE COOKIE %p", cookie);
+	do {
+		usage = atomic_dec_return(&cookie->usage);
+		trace_fscache_cookie(cookie, where, usage);
+
+		if (usage > 0)
+			return;
+		BUG_ON(usage < 0);
+
 		parent = cookie->parent;
 		BUG_ON(!hlist_empty(&cookie->backing_objects));
 		kmem_cache_free(fscache_cookie_jar, cookie);
 
-		if (!parent)
-			break;
-
 		cookie = parent;
-		BUG_ON(atomic_read(&cookie->usage) <= 0);
-		if (!atomic_dec_and_test(&cookie->usage))
-			break;
-	}
+		where = fscache_cookie_put_parent;
+	} while (cookie);
 
 	_leave("");
 }
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 0ff4b49a0037..c27e2db3004e 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -29,6 +29,7 @@
 #define pr_fmt(fmt) "FS-Cache: " fmt
 
 #include <linux/fscache-cache.h>
+#include <trace/events/fscache.h>
 #include <linux/sched.h>
 
 #define FSCACHE_MIN_THREADS	4
@@ -49,7 +50,8 @@ extern struct fscache_cache *fscache_select_cache_for_object(
 extern struct kmem_cache *fscache_cookie_jar;
 
 extern void fscache_cookie_init_once(void *);
-extern void __fscache_cookie_put(struct fscache_cookie *);
+extern void fscache_cookie_put(struct fscache_cookie *,
+			       enum fscache_cookie_trace);
 
 /*
  * fsdef.c
@@ -311,14 +313,12 @@ static inline void fscache_raise_event(struct fscache_object *object,
 		fscache_enqueue_object(object);
 }
 
-/*
- * drop a reference to a cookie
- */
-static inline void fscache_cookie_put(struct fscache_cookie *cookie)
+static inline void fscache_cookie_get(struct fscache_cookie *cookie,
+				      enum fscache_cookie_trace where)
 {
-	BUG_ON(atomic_read(&cookie->usage) <= 0);
-	if (atomic_dec_and_test(&cookie->usage))
-		__fscache_cookie_put(cookie);
+	int usage = atomic_inc_return(&cookie->usage);
+
+	trace_fscache_cookie(cookie, where, usage);
 }
 
 /*
diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index 249968dcbf5c..7dce110bf17d 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -16,6 +16,7 @@
 #include <linux/completion.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
+#define CREATE_TRACE_POINTS
 #include "internal.h"
 
 MODULE_DESCRIPTION("FS Cache Manager");
diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index a8aa00be4444..c816600d1dde 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -60,7 +60,7 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 			goto already_registered;
 	}
 
-	atomic_inc(&cookie->parent->usage);
+	fscache_cookie_get(cookie->parent, fscache_cookie_get_register_netfs);
 	atomic_inc(&cookie->parent->n_children);
 
 	netfs->primary_index = cookie;
@@ -68,6 +68,7 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	ret = 0;
 
 	pr_notice("Netfs '%s' registered for caching\n", netfs->name);
+	trace_fscache_netfs(netfs);
 
 already_registered:
 	up_write(&fscache_addremove_sem);
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 7a182c87f378..99afe64352a5 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -138,8 +138,10 @@ static const struct fscache_transition fscache_osm_run_oob[] = {
 	   { 0, NULL }
 };
 
-static int  fscache_get_object(struct fscache_object *);
-static void fscache_put_object(struct fscache_object *);
+static int  fscache_get_object(struct fscache_object *,
+			       enum fscache_obj_ref_trace);
+static void fscache_put_object(struct fscache_object *,
+			       enum fscache_obj_ref_trace);
 static bool fscache_enqueue_dependents(struct fscache_object *, int);
 static void fscache_dequeue_object(struct fscache_object *);
 
@@ -170,6 +172,7 @@ static void fscache_object_sm_dispatcher(struct fscache_object *object)
 	const struct fscache_transition *t;
 	const struct fscache_state *state, *new_state;
 	unsigned long events, event_mask;
+	bool oob;
 	int event = -1;
 
 	ASSERT(object != NULL);
@@ -188,6 +191,7 @@ static void fscache_object_sm_dispatcher(struct fscache_object *object)
 	if (events & object->oob_event_mask) {
 		_debug("{OBJ%x} oob %lx",
 		       object->debug_id, events & object->oob_event_mask);
+		oob = true;
 		for (t = object->oob_table; t->events; t++) {
 			if (events & t->events) {
 				state = t->transit_to;
@@ -199,6 +203,7 @@ static void fscache_object_sm_dispatcher(struct fscache_object *object)
 			}
 		}
 	}
+	oob = false;
 
 	/* Wait states are just transition tables */
 	if (!state->work) {
@@ -207,6 +212,8 @@ static void fscache_object_sm_dispatcher(struct fscache_object *object)
 				if (events & t->events) {
 					new_state = t->transit_to;
 					event = fls(events & t->events) - 1;
+					trace_fscache_osm(object, state,
+							  true, false, event);
 					clear_bit(event, &object->events);
 					_debug("{OBJ%x} ev %d: %s -> %s",
 					       object->debug_id, event,
@@ -226,6 +233,7 @@ static void fscache_object_sm_dispatcher(struct fscache_object *object)
 execute_work_state:
 	_debug("{OBJ%x} exec %s", object->debug_id, state->name);
 
+	trace_fscache_osm(object, state, false, oob, event);
 	new_state = state->work(object, event);
 	event = -1;
 	if (new_state == NO_TRANSIT) {
@@ -279,7 +287,7 @@ static void fscache_object_work_func(struct work_struct *work)
 	start = jiffies;
 	fscache_object_sm_dispatcher(object);
 	fscache_hist(fscache_objs_histogram, start);
-	fscache_put_object(object);
+	fscache_put_object(object, fscache_obj_put_work);
 }
 
 /**
@@ -397,7 +405,7 @@ static const struct fscache_state *fscache_initialise_object(struct fscache_obje
 	fscache_stat(&fscache_n_cop_grab_object);
 	success = false;
 	if (fscache_object_is_live(parent) &&
-	    object->cache->ops->grab_object(object)) {
+	    object->cache->ops->grab_object(object, fscache_obj_get_add_to_deps)) {
 		list_add(&object->dep_link, &parent->dependents);
 		success = true;
 	}
@@ -745,7 +753,7 @@ static const struct fscache_state *fscache_drop_object(struct fscache_object *ob
 	}
 
 	/* this just shifts the object release to the work processor */
-	fscache_put_object(object);
+	fscache_put_object(object, fscache_obj_put_drop_obj);
 	fscache_stat(&fscache_n_object_dead);
 
 	_leave("");
@@ -755,12 +763,13 @@ static const struct fscache_state *fscache_drop_object(struct fscache_object *ob
 /*
  * get a ref on an object
  */
-static int fscache_get_object(struct fscache_object *object)
+static int fscache_get_object(struct fscache_object *object,
+			      enum fscache_obj_ref_trace why)
 {
 	int ret;
 
 	fscache_stat(&fscache_n_cop_grab_object);
-	ret = object->cache->ops->grab_object(object) ? 0 : -EAGAIN;
+	ret = object->cache->ops->grab_object(object, why) ? 0 : -EAGAIN;
 	fscache_stat_d(&fscache_n_cop_grab_object);
 	return ret;
 }
@@ -768,10 +777,11 @@ static int fscache_get_object(struct fscache_object *object)
 /*
  * Discard a ref on an object
  */
-static void fscache_put_object(struct fscache_object *object)
+static void fscache_put_object(struct fscache_object *object,
+			       enum fscache_obj_ref_trace why)
 {
 	fscache_stat(&fscache_n_cop_put_object);
-	object->cache->ops->put_object(object);
+	object->cache->ops->put_object(object, why);
 	fscache_stat_d(&fscache_n_cop_put_object);
 }
 
@@ -786,7 +796,7 @@ void fscache_object_destroy(struct fscache_object *object)
 	fscache_objlist_remove(object);
 
 	/* We can get rid of the cookie now */
-	fscache_cookie_put(object->cookie);
+	fscache_cookie_put(object->cookie, fscache_cookie_put_object);
 	object->cookie = NULL;
 }
 EXPORT_SYMBOL(fscache_object_destroy);
@@ -798,7 +808,7 @@ void fscache_enqueue_object(struct fscache_object *object)
 {
 	_enter("{OBJ%x}", object->debug_id);
 
-	if (fscache_get_object(object) >= 0) {
+	if (fscache_get_object(object, fscache_obj_get_queue) >= 0) {
 		wait_queue_head_t *cong_wq =
 			&get_cpu_var(fscache_object_cong_wait);
 
@@ -806,7 +816,7 @@ void fscache_enqueue_object(struct fscache_object *object)
 			if (fscache_object_congested())
 				wake_up(cong_wq);
 		} else
-			fscache_put_object(object);
+			fscache_put_object(object, fscache_obj_put_queue);
 
 		put_cpu_var(fscache_object_cong_wait);
 	}
@@ -866,7 +876,7 @@ static bool fscache_enqueue_dependents(struct fscache_object *object, int event)
 		list_del_init(&dep->dep_link);
 
 		fscache_raise_event(dep, event);
-		fscache_put_object(dep);
+		fscache_put_object(dep, fscache_obj_put_enq_dep);
 
 		if (!list_empty(&object->dependents) && need_resched()) {
 			ret = false;
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index b19fa8592fc2..fbe102f37074 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -29,6 +29,18 @@ struct fscache_cache_ops;
 struct fscache_object;
 struct fscache_operation;
 
+enum fscache_obj_ref_trace {
+	fscache_obj_get_add_to_deps,
+	fscache_obj_get_queue,
+	fscache_obj_put_alloc_fail,
+	fscache_obj_put_attach_fail,
+	fscache_obj_put_drop_obj,
+	fscache_obj_put_enq_dep,
+	fscache_obj_put_queue,
+	fscache_obj_put_work,
+	fscache_obj_ref__nr_traces
+};
+
 /*
  * cache tag definition
  */
@@ -231,7 +243,8 @@ struct fscache_cache_ops {
 	void (*lookup_complete)(struct fscache_object *object);
 
 	/* increment the usage count on this object (may fail if unmounting) */
-	struct fscache_object *(*grab_object)(struct fscache_object *object);
+	struct fscache_object *(*grab_object)(struct fscache_object *object,
+					      enum fscache_obj_ref_trace why);
 
 	/* pin an object in the cache */
 	int (*pin_object)(struct fscache_object *object);
@@ -254,7 +267,8 @@ struct fscache_cache_ops {
 	void (*drop_object)(struct fscache_object *object);
 
 	/* dispose of a reference to an object */
-	void (*put_object)(struct fscache_object *object);
+	void (*put_object)(struct fscache_object *object,
+			   enum fscache_obj_ref_trace why);
 
 	/* sync a cache */
 	void (*sync_cache)(struct fscache_cache *cache);
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
new file mode 100644
index 000000000000..aa86e7dba511
--- /dev/null
+++ b/include/trace/events/cachefiles.h
@@ -0,0 +1,325 @@
+/* CacheFiles tracepoints
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM cachefiles
+
+#if !defined(_TRACE_CACHEFILES_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_CACHEFILES_H
+
+#include <linux/tracepoint.h>
+
+/*
+ * Define enums for tracing information.
+ */
+#ifndef __CACHEFILES_DECLARE_TRACE_ENUMS_ONCE_ONLY
+#define __CACHEFILES_DECLARE_TRACE_ENUMS_ONCE_ONLY
+
+enum cachefiles_obj_ref_trace {
+	cachefiles_obj_put_wait_retry = fscache_obj_ref__nr_traces,
+	cachefiles_obj_put_wait_timeo,
+	cachefiles_obj_ref__nr_traces
+};
+
+#endif
+
+/*
+ * Define enum -> string mappings for display.
+ */
+#define cachefiles_obj_kill_traces				\
+	EM(FSCACHE_OBJECT_IS_STALE,	"stale")		\
+	EM(FSCACHE_OBJECT_NO_SPACE,	"no_space")		\
+	EM(FSCACHE_OBJECT_WAS_RETIRED,	"was_retired")		\
+	E_(FSCACHE_OBJECT_WAS_CULLED,	"was_culled")
+
+#define cachefiles_obj_ref_traces					\
+	EM(fscache_obj_get_add_to_deps,		"GET add_to_deps")	\
+	EM(fscache_obj_get_queue,		"GET queue")		\
+	EM(fscache_obj_put_alloc_fail,		"PUT alloc_fail")	\
+	EM(fscache_obj_put_attach_fail,		"PUT attach_fail")	\
+	EM(fscache_obj_put_drop_obj,		"PUT drop_obj")		\
+	EM(fscache_obj_put_enq_dep,		"PUT enq_dep")		\
+	EM(fscache_obj_put_queue,		"PUT queue")		\
+	EM(fscache_obj_put_work,		"PUT work")		\
+	EM(cachefiles_obj_put_wait_retry,	"PUT wait_retry")	\
+	E_(cachefiles_obj_put_wait_timeo,	"PUT wait_timeo")
+
+/*
+ * Export enum symbols via userspace.
+ */
+#undef EM
+#undef E_
+#define EM(a, b) TRACE_DEFINE_ENUM(a);
+#define E_(a, b) TRACE_DEFINE_ENUM(a);
+
+cachefiles_obj_kill_traces;
+cachefiles_obj_ref_traces;
+
+/*
+ * Now redefine the EM() and E_() macros to map the enums to the strings that
+ * will be printed in the output.
+ */
+#undef EM
+#undef E_
+#define EM(a, b)	{ a, b },
+#define E_(a, b)	{ a, b }
+
+
+TRACE_EVENT(cachefiles_ref,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct fscache_cookie *cookie,
+		     enum cachefiles_obj_ref_trace why,
+		     int usage),
+
+	    TP_ARGS(obj, cookie, why, usage),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,		obj		)
+		    __field(struct fscache_cookie *,		cookie		)
+		    __field(enum cachefiles_obj_ref_trace,	why		)
+		    __field(int,				usage		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->cookie	= cookie;
+		    __entry->usage	= usage;
+		    __entry->why	= why;
+			   ),
+
+	    TP_printk("c=%p o=%p u=%d %s",
+		      __entry->cookie, __entry->obj, __entry->usage,
+		      __print_symbolic(__entry->why, cachefiles_obj_ref_traces))
+	    );
+
+TRACE_EVENT(cachefiles_lookup,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     struct inode *inode),
+
+	    TP_ARGS(obj, de, inode),
+
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj	)
+		    __field(struct dentry *,		de	)
+		    __field(struct inode *,		inode	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->inode	= inode;
+			   ),
+
+	    TP_printk("o=%p d=%p i=%p",
+		      __entry->obj, __entry->de, __entry->inode)
+	    );
+
+TRACE_EVENT(cachefiles_mkdir,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de, int ret),
+
+	    TP_ARGS(obj, de, ret),
+
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj	)
+		    __field(struct dentry *,		de	)
+		    __field(int,			ret	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->ret	= ret;
+			   ),
+
+	    TP_printk("o=%p d=%p r=%u",
+		      __entry->obj, __entry->de, __entry->ret)
+	    );
+
+TRACE_EVENT(cachefiles_create,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de, int ret),
+
+	    TP_ARGS(obj, de, ret),
+
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj	)
+		    __field(struct dentry *,		de	)
+		    __field(int,			ret	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->ret	= ret;
+			   ),
+
+	    TP_printk("o=%p d=%p r=%u",
+		      __entry->obj, __entry->de, __entry->ret)
+	    );
+
+TRACE_EVENT(cachefiles_unlink,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     enum fscache_why_object_killed why),
+
+	    TP_ARGS(obj, de, why),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+		    __field(enum fscache_why_object_killed, why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->why	= why;
+			   ),
+
+	    TP_printk("o=%p d=%p w=%s",
+		      __entry->obj, __entry->de,
+		      __print_symbolic(__entry->why, cachefiles_obj_kill_traces))
+	    );
+
+TRACE_EVENT(cachefiles_rename,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     struct dentry *to,
+		     enum fscache_why_object_killed why),
+
+	    TP_ARGS(obj, de, to, why),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+		    __field(struct dentry *,		to		)
+		    __field(enum fscache_why_object_killed, why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->to		= to;
+		    __entry->why	= why;
+			   ),
+
+	    TP_printk("o=%p d=%p t=%p w=%s",
+		      __entry->obj, __entry->de, __entry->to,
+		      __print_symbolic(__entry->why, cachefiles_obj_kill_traces))
+	    );
+
+TRACE_EVENT(cachefiles_mark_active,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de),
+
+	    TP_ARGS(obj, de),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+			   ),
+
+	    TP_printk("o=%p d=%p",
+		      __entry->obj, __entry->de)
+	    );
+
+TRACE_EVENT(cachefiles_wait_active,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     struct cachefiles_object *xobj),
+
+	    TP_ARGS(obj, de, xobj),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+		    __field(struct cachefiles_object *,	xobj		)
+		    __field(u16,			flags		)
+		    __field(u16,			fsc_flags	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->xobj	= xobj;
+		    __entry->flags	= xobj->flags;
+		    __entry->fsc_flags	= xobj->fscache.flags;
+			   ),
+
+	    TP_printk("o=%p d=%p wo=%p wf=%x wff=%x",
+		      __entry->obj, __entry->de, __entry->xobj,
+		      __entry->flags, __entry->fsc_flags)
+	    );
+
+TRACE_EVENT(cachefiles_mark_inactive,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     struct inode *inode),
+
+	    TP_ARGS(obj, de, inode),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+		    __field(struct inode *,		inode		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->inode	= inode;
+			   ),
+
+	    TP_printk("o=%p d=%p i=%p",
+		      __entry->obj, __entry->de, __entry->inode)
+	    );
+
+TRACE_EVENT(cachefiles_mark_buried,
+	    TP_PROTO(struct cachefiles_object *obj,
+		     struct dentry *de,
+		     enum fscache_why_object_killed why),
+
+	    TP_ARGS(obj, de, why),
+
+	    /* Note that obj may be NULL */
+	    TP_STRUCT__entry(
+		    __field(struct cachefiles_object *,	obj		)
+		    __field(struct dentry *,		de		)
+		    __field(enum fscache_why_object_killed, why		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj;
+		    __entry->de		= de;
+		    __entry->why	= why;
+			   ),
+
+	    TP_printk("o=%p d=%p w=%s",
+		      __entry->obj, __entry->de,
+		      __print_symbolic(__entry->why, cachefiles_obj_kill_traces))
+	    );
+
+#endif /* _TRACE_CACHEFILES_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/include/trace/events/fscache.h b/include/trace/events/fscache.h
new file mode 100644
index 000000000000..99f5355d6281
--- /dev/null
+++ b/include/trace/events/fscache.h
@@ -0,0 +1,277 @@
+/* FS-Cache tracepoints
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fscache
+
+#if !defined(_TRACE_FSCACHE_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FSCACHE_H
+
+#include <linux/fscache.h>
+#include <linux/tracepoint.h>
+
+/*
+ * Define enums for tracing information.
+ */
+#ifndef __FSCACHE_DECLARE_TRACE_ENUMS_ONCE_ONLY
+#define __FSCACHE_DECLARE_TRACE_ENUMS_ONCE_ONLY
+
+enum fscache_cookie_trace {
+	fscache_cookie_get_acquire_parent,
+	fscache_cookie_get_attach_object,
+	fscache_cookie_get_register_netfs,
+	fscache_cookie_put_acquire_nobufs,
+	fscache_cookie_put_relinquish,
+	fscache_cookie_put_object,
+	fscache_cookie_put_parent,
+};
+
+#endif
+
+/*
+ * Declare tracing information enums and their string mappings for display.
+ */
+#define fscache_cookie_traces						\
+	EM(fscache_cookie_get_acquire_parent,	"GET prn")		\
+	EM(fscache_cookie_get_attach_object,	"GET obj")		\
+	EM(fscache_cookie_get_register_netfs,	"GET net")		\
+	EM(fscache_cookie_put_acquire_nobufs,	"PUT nbf")		\
+	EM(fscache_cookie_put_relinquish,	"PUT rlq")		\
+	EM(fscache_cookie_put_object,		"PUT obj")		\
+	E_(fscache_cookie_put_parent,		"PUT prn")
+
+/*
+ * Export enum symbols via userspace.
+ */
+#undef EM
+#undef E_
+#define EM(a, b) TRACE_DEFINE_ENUM(a);
+#define E_(a, b) TRACE_DEFINE_ENUM(a);
+
+fscache_cookie_traces;
+
+/*
+ * Now redefine the EM() and E_() macros to map the enums to the strings that
+ * will be printed in the output.
+ */
+#undef EM
+#undef E_
+#define EM(a, b)	{ a, b },
+#define E_(a, b)	{ a, b }
+
+
+TRACE_EVENT(fscache_cookie,
+	    TP_PROTO(struct fscache_cookie *cookie,
+		     enum fscache_cookie_trace where,
+		     int usage),
+
+	    TP_ARGS(cookie, where, usage),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_cookie *,	parent		)
+		    __field(enum fscache_cookie_trace,	where		)
+		    __field(int,			usage		)
+		    __field(int,			n_children	)
+		    __field(int,			n_active	)
+		    __field(u8,				flags		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie	= cookie;
+		    __entry->parent	= cookie->parent;
+		    __entry->where	= where;
+		    __entry->usage	= usage;
+		    __entry->n_children	= atomic_read(&cookie->n_children);
+		    __entry->n_active	= atomic_read(&cookie->n_active);
+		    __entry->flags	= cookie->flags;
+			   ),
+
+	    TP_printk("%s c=%p u=%d p=%p Nc=%d Na=%d f=%02x",
+		      __print_symbolic(__entry->where, fscache_cookie_traces),
+		      __entry->cookie, __entry->usage,
+		      __entry->parent, __entry->n_children, __entry->n_active,
+		      __entry->flags)
+	    );
+
+TRACE_EVENT(fscache_netfs,
+	    TP_PROTO(struct fscache_netfs *netfs),
+
+	    TP_ARGS(netfs),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __array(char,			name, 8		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= netfs->primary_index;
+		    strncpy(__entry->name, netfs->name, 8);
+		    __entry->name[7]		= 0;
+			   ),
+
+	    TP_printk("c=%p n=%s",
+		      __entry->cookie, __entry->name)
+	    );
+
+TRACE_EVENT(fscache_acquire,
+	    TP_PROTO(struct fscache_cookie *cookie),
+
+	    TP_ARGS(cookie),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_cookie *,	parent		)
+		    __array(char,			name, 8		)
+		    __field(int,			p_usage		)
+		    __field(int,			p_n_children	)
+		    __field(u8,				p_flags		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= cookie;
+		    __entry->parent		= cookie->parent;
+		    __entry->p_usage		= atomic_read(&cookie->parent->usage);
+		    __entry->p_n_children	= atomic_read(&cookie->parent->n_children);
+		    __entry->p_flags		= cookie->parent->flags;
+		    memcpy(__entry->name, cookie->def->name, 8);
+		    __entry->name[7]		= 0;
+			   ),
+
+	    TP_printk("c=%p p=%p pu=%d pc=%d pf=%02x n=%s",
+		      __entry->cookie, __entry->parent, __entry->p_usage,
+		      __entry->p_n_children, __entry->p_flags, __entry->name)
+	    );
+
+TRACE_EVENT(fscache_relinquish,
+	    TP_PROTO(struct fscache_cookie *cookie, bool retire),
+
+	    TP_ARGS(cookie, retire),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_cookie *,	parent		)
+		    __field(int,			usage		)
+		    __field(int,			n_children	)
+		    __field(int,			n_active	)
+		    __field(u8,				flags		)
+		    __field(bool,			retire		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie	= cookie;
+		    __entry->parent	= cookie->parent;
+		    __entry->usage	= atomic_read(&cookie->usage);
+		    __entry->n_children	= atomic_read(&cookie->n_children);
+		    __entry->n_active	= atomic_read(&cookie->n_active);
+		    __entry->flags	= cookie->flags;
+		    __entry->retire	= retire;
+			   ),
+
+	    TP_printk("c=%p u=%d p=%p Nc=%d Na=%d f=%02x r=%u",
+		      __entry->cookie, __entry->usage,
+		      __entry->parent, __entry->n_children, __entry->n_active,
+		      __entry->flags, __entry->retire)
+	    );
+
+TRACE_EVENT(fscache_enable,
+	    TP_PROTO(struct fscache_cookie *cookie),
+
+	    TP_ARGS(cookie),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(int,			usage		)
+		    __field(int,			n_children	)
+		    __field(int,			n_active	)
+		    __field(u8,				flags		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie	= cookie;
+		    __entry->usage	= atomic_read(&cookie->usage);
+		    __entry->n_children	= atomic_read(&cookie->n_children);
+		    __entry->n_active	= atomic_read(&cookie->n_active);
+		    __entry->flags	= cookie->flags;
+			   ),
+
+	    TP_printk("c=%p u=%d Nc=%d Na=%d f=%02x",
+		      __entry->cookie, __entry->usage,
+		      __entry->n_children, __entry->n_active, __entry->flags)
+	    );
+
+TRACE_EVENT(fscache_disable,
+	    TP_PROTO(struct fscache_cookie *cookie),
+
+	    TP_ARGS(cookie),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(int,			usage		)
+		    __field(int,			n_children	)
+		    __field(int,			n_active	)
+		    __field(u8,				flags		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie	= cookie;
+		    __entry->usage	= atomic_read(&cookie->usage);
+		    __entry->n_children	= atomic_read(&cookie->n_children);
+		    __entry->n_active	= atomic_read(&cookie->n_active);
+		    __entry->flags	= cookie->flags;
+			   ),
+
+	    TP_printk("c=%p u=%d Nc=%d Na=%d f=%02x",
+		      __entry->cookie, __entry->usage,
+		      __entry->n_children, __entry->n_active, __entry->flags)
+	    );
+
+TRACE_EVENT(fscache_osm,
+	    TP_PROTO(struct fscache_object *object,
+		     const struct fscache_state *state,
+		     bool wait, bool oob, s8 event_num),
+
+	    TP_ARGS(object, state, wait, oob, event_num),
+
+	    TP_STRUCT__entry(
+		    __field(struct fscache_cookie *,	cookie		)
+		    __field(struct fscache_object *,	object		)
+		    __array(char,			state, 8	)
+		    __field(bool,			wait		)
+		    __field(bool,			oob		)
+		    __field(s8,				event_num	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->cookie		= object->cookie;
+		    __entry->object		= object;
+		    __entry->wait		= wait;
+		    __entry->oob		= oob;
+		    __entry->event_num		= event_num;
+		    memcpy(__entry->state, state->short_name, 8);
+			   ),
+
+	    TP_printk("c=%p o=%p %s %s%sev=%d",
+		      __entry->cookie,
+		      __entry->object,
+		      __entry->state,
+		      __print_symbolic(__entry->wait,
+				       { true,  "WAIT" },
+				       { false, "WORK" }),
+		      __print_symbolic(__entry->oob,
+				       { true,  " OOB " },
+				       { false, " " }),
+		      __entry->event_num)
+	    );
+
+#endif /* _TRACE_FSCACHE_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>

