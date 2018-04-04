Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752314AbeDDWIK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:08:10 -0400
Subject: [PATCH 12/12] fscache: Maintain a catalogue of allocated cookies
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:08:06 +0100
Message-ID: <152287968653.14760.6880309852156134426.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maintain a catalogue of allocated cookies so that cookie collisions can be
handled properly.  For the moment, this just involves printing a warning
and returning a NULL cookie to the caller of fscache_acquire_cookie(), but
in future it might make sense to wait for the old cookie to finish being
cleaned up.

This requires the cookie key to be stored attached to the cookie so that we
still have the key available if the netfs relinquishes the cookie.  This is
done by an earlier patch.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Anna Schumaker <anna.schumaker@netapp.com>
Tested-by: Steve Dickson <steved@redhat.com>
---

 fs/fscache/cookie.c            |  294 ++++++++++++++++++++++++++++++++--------
 fs/fscache/internal.h          |    6 +
 fs/fscache/netfs.c             |   36 +----
 include/linux/fscache.h        |    7 +
 include/trace/events/fscache.h |    6 +
 5 files changed, 262 insertions(+), 87 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 8ca9a932d225..62b1f0f46b11 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -21,6 +21,9 @@ struct kmem_cache *fscache_cookie_jar;
 
 static atomic_t fscache_object_debug_id = ATOMIC_INIT(0);
 
+#define fscache_cookie_hash_shift 15
+static struct hlist_bl_head fscache_cookie_hash[1 << fscache_cookie_hash_shift];
+
 static int fscache_acquire_non_index_cookie(struct fscache_cookie *cookie,
 					    loff_t object_size);
 static int fscache_alloc_object(struct fscache_cache *cache,
@@ -28,6 +31,44 @@ static int fscache_alloc_object(struct fscache_cache *cache,
 static int fscache_attach_object(struct fscache_cookie *cookie,
 				 struct fscache_object *object);
 
+static void fscache_print_cookie(struct fscache_cookie *cookie, char prefix)
+{
+	struct hlist_node *object;
+	const u8 *k;
+	unsigned loop;
+
+	pr_err("%c-cookie c=%p [p=%p fl=%lx nc=%u na=%u]\n",
+	       prefix, cookie, cookie->parent, cookie->flags,
+	       atomic_read(&cookie->n_children),
+	       atomic_read(&cookie->n_active));
+	pr_err("%c-cookie d=%p n=%p\n",
+	       prefix, cookie->def, cookie->netfs_data);
+
+	object = READ_ONCE(cookie->backing_objects.first);
+	if (object)
+		pr_err("%c-cookie o=%p\n",
+		       prefix, hlist_entry(object, struct fscache_object, cookie_link));
+
+	pr_err("%c-key=[%u] '", prefix, cookie->key_len);
+	k = (cookie->key_len <= sizeof(cookie->inline_key)) ?
+		cookie->inline_key : cookie->key;
+	for (loop = 0; loop < cookie->key_len; loop++)
+		pr_cont("%02x", k[loop]);
+	pr_cont("'\n");
+}
+
+void fscache_free_cookie(struct fscache_cookie *cookie)
+{
+	if (cookie) {
+		BUG_ON(!hlist_empty(&cookie->backing_objects));
+		if (cookie->aux_len > sizeof(cookie->inline_aux))
+			kfree(cookie->aux);
+		if (cookie->key_len > sizeof(cookie->inline_key))
+			kfree(cookie->key);
+		kmem_cache_free(fscache_cookie_jar, cookie);
+	}
+}
+
 /*
  * initialise an cookie jar slab element prior to any use
  */
@@ -41,6 +82,170 @@ void fscache_cookie_init_once(void *_cookie)
 	INIT_HLIST_HEAD(&cookie->backing_objects);
 }
 
+/*
+ * Set the index key in a cookie.  The cookie struct has space for a 12-byte
+ * key plus length and hash, but if that's not big enough, it's instead a
+ * pointer to a buffer containing 3 bytes of hash, 1 byte of length and then
+ * the key data.
+ */
+static int fscache_set_key(struct fscache_cookie *cookie,
+			   const void *index_key, size_t index_key_len)
+{
+	unsigned long long h;
+	u32 *buf;
+	int i;
+
+	cookie->key_len = index_key_len;
+
+	if (index_key_len > sizeof(cookie->inline_key)) {
+		buf = kzalloc(index_key_len, GFP_KERNEL);
+		if (!buf)
+			return -ENOMEM;
+		cookie->key = buf;
+	} else {
+		buf = (u32 *)cookie->inline_key;
+		buf[0] = 0;
+		buf[1] = 0;
+		buf[2] = 0;
+	}
+
+	memcpy(buf, index_key, index_key_len);
+
+	/* Calculate a hash and combine this with the length in the first word
+	 * or first half word
+	 */
+	h = (unsigned long)cookie->parent;
+	h += index_key_len + cookie->type;
+	for (i = 0; i < (index_key_len + sizeof(u32) - 1) / sizeof(u32); i++)
+		h += buf[i];
+
+	cookie->key_hash = h ^ (h >> 32);
+	return 0;
+}
+
+static long fscache_compare_cookie(const struct fscache_cookie *a,
+				   const struct fscache_cookie *b)
+{
+	const void *ka, *kb;
+
+	if (a->key_hash != b->key_hash)
+		return (long)a->key_hash - (long)b->key_hash;
+	if (a->parent != b->parent)
+		return (long)a->parent - (long)b->parent;
+	if (a->key_len != b->key_len)
+		return (long)a->key_len - (long)b->key_len;
+	if (a->type != b->type)
+		return (long)a->type - (long)b->type;
+
+	if (a->key_len <= sizeof(a->inline_key)) {
+		ka = &a->inline_key;
+		kb = &b->inline_key;
+	} else {
+		ka = a->key;
+		kb = b->key;
+	}
+	return memcmp(ka, kb, a->key_len);
+}
+
+/*
+ * Allocate a cookie.
+ */
+struct fscache_cookie *fscache_alloc_cookie(
+	struct fscache_cookie *parent,
+	const struct fscache_cookie_def *def,
+	const void *index_key, size_t index_key_len,
+	const void *aux_data, size_t aux_data_len,
+	void *netfs_data,
+	loff_t object_size)
+{
+	struct fscache_cookie *cookie;
+
+	/* allocate and initialise a cookie */
+	cookie = kmem_cache_alloc(fscache_cookie_jar, GFP_KERNEL);
+	if (!cookie)
+		return NULL;
+
+	cookie->key_len = index_key_len;
+	cookie->aux_len = aux_data_len;
+
+	if (fscache_set_key(cookie, index_key, index_key_len) < 0)
+		goto nomem;
+
+	if (cookie->aux_len <= sizeof(cookie->inline_aux)) {
+		memcpy(cookie->inline_aux, aux_data, cookie->aux_len);
+	} else {
+		cookie->aux = kmemdup(aux_data, cookie->aux_len, GFP_KERNEL);
+		if (!cookie->aux)
+			goto nomem;
+	}
+
+	atomic_set(&cookie->usage, 1);
+	atomic_set(&cookie->n_children, 0);
+
+	/* We keep the active count elevated until relinquishment to prevent an
+	 * attempt to wake up every time the object operations queue quiesces.
+	 */
+	atomic_set(&cookie->n_active, 1);
+
+	cookie->def		= def;
+	cookie->parent		= parent;
+	cookie->netfs_data	= netfs_data;
+	cookie->flags		= (1 << FSCACHE_COOKIE_NO_DATA_YET);
+	cookie->type		= def->type;
+
+	/* radix tree insertion won't use the preallocation pool unless it's
+	 * told it may not wait */
+	INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
+	return cookie;
+
+nomem:
+	fscache_free_cookie(cookie);
+	return NULL;
+}
+
+/*
+ * Attempt to insert the new cookie into the hash.  If there's a collision, we
+ * return the old cookie if it's not in use and an error otherwise.
+ */
+static struct fscache_cookie *fscache_hash_cookie(struct fscache_cookie *candidate)
+{
+	struct fscache_cookie *cursor;
+	struct hlist_bl_head *h;
+	struct hlist_bl_node *p;
+	unsigned int bucket;
+
+	bucket = candidate->key_hash & (ARRAY_SIZE(fscache_cookie_hash) - 1);
+	h = &fscache_cookie_hash[bucket];
+
+	hlist_bl_lock(h);
+	hlist_bl_for_each_entry(cursor, p, h, hash_link) {
+		if (fscache_compare_cookie(candidate, cursor) == 0)
+			goto collision;
+	}
+
+	__set_bit(FSCACHE_COOKIE_ACQUIRED, &candidate->flags);
+	fscache_cookie_get(candidate->parent, fscache_cookie_get_acquire_parent);
+	atomic_inc(&candidate->parent->n_children);
+	hlist_bl_add_head(&candidate->hash_link, h);
+	hlist_bl_unlock(h);
+	return candidate;
+
+collision:
+	if (test_and_set_bit(FSCACHE_COOKIE_ACQUIRED, &cursor->flags)) {
+		trace_fscache_cookie(cursor, fscache_cookie_collision,
+				     atomic_read(&cursor->usage));
+		pr_err("Duplicate cookie detected\n");
+		fscache_print_cookie(cursor, 'O');
+		fscache_print_cookie(candidate, 'N');
+		hlist_bl_unlock(h);
+		return NULL;
+	}
+
+	fscache_cookie_get(cursor, fscache_cookie_get_reacquire);
+	hlist_bl_unlock(h);
+	return cursor;
+}
+
 /*
  * request a cookie to represent an object (index, datafile, xattr, etc)
  * - parent specifies the parent object
@@ -65,7 +270,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	loff_t object_size,
 	bool enable)
 {
-	struct fscache_cookie *cookie;
+	struct fscache_cookie *candidate, *cookie;
 
 	BUG_ON(!def);
 
@@ -95,53 +300,24 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	BUG_ON(def->type == FSCACHE_COOKIE_TYPE_INDEX &&
 	       parent->type != FSCACHE_COOKIE_TYPE_INDEX);
 
-	/* allocate and initialise a cookie */
-	cookie = kmem_cache_alloc(fscache_cookie_jar, GFP_KERNEL);
-	if (!cookie) {
+	candidate = fscache_alloc_cookie(parent, def,
+					 index_key, index_key_len,
+					 aux_data, aux_data_len,
+					 netfs_data, object_size);
+	if (!candidate) {
 		fscache_stat(&fscache_n_acquires_oom);
 		_leave(" [ENOMEM]");
 		return NULL;
 	}
 
-	cookie->key_len		= index_key_len;
-	cookie->aux_len		= aux_data_len;
-
-	if (cookie->key_len <= sizeof(cookie->inline_key)) {
-		memcpy(cookie->inline_key, index_key, cookie->key_len);
-	} else {
-		cookie->key = kmemdup(index_key, cookie->key_len, GFP_KERNEL);
-		if (!cookie->key)
-			goto nomem;
-	}
-
-	if (cookie->aux_len <= sizeof(cookie->inline_aux)) {
-		memcpy(cookie->inline_aux, aux_data, cookie->aux_len);
-	} else {
-		cookie->aux = kmemdup(aux_data, cookie->aux_len, GFP_KERNEL);
-		if (!cookie->aux)
-			goto nomem;
+	cookie = fscache_hash_cookie(candidate);
+	if (!cookie) {
+		trace_fscache_cookie(candidate, fscache_cookie_discard, 1);
+		goto out;
 	}
 
-	atomic_set(&cookie->usage, 1);
-	atomic_set(&cookie->n_children, 0);
-
-	/* We keep the active count elevated until relinquishment to prevent an
-	 * attempt to wake up every time the object operations queue quiesces.
-	 */
-	atomic_set(&cookie->n_active, 1);
-
-	fscache_cookie_get(parent, fscache_cookie_get_acquire_parent);
-	atomic_inc(&parent->n_children);
-
-	cookie->def		= def;
-	cookie->parent		= parent;
-	cookie->netfs_data	= netfs_data;
-	cookie->flags		= (1 << FSCACHE_COOKIE_NO_DATA_YET);
-	cookie->type		= def->type;
-	
-	/* radix tree insertion won't use the preallocation pool unless it's
-	 * told it may not wait */
-	INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
+	if (cookie == candidate)
+		candidate = NULL;
 
 	switch (cookie->type) {
 	case FSCACHE_COOKIE_TYPE_INDEX:
@@ -178,16 +354,10 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	}
 
 	fscache_stat(&fscache_n_acquires_ok);
-	_leave(" = %p", cookie);
-	return cookie;
 
-nomem:
-	if (cookie->aux_len > sizeof(cookie->inline_aux))
-		kfree(cookie->aux);
-	if (cookie->key_len > sizeof(cookie->inline_key))
-		kfree(cookie->key);
-	kmem_cache_free(fscache_cookie_jar, cookie);
-	return NULL;
+out:
+	fscache_free_cookie(candidate);
+	return cookie;
 }
 EXPORT_SYMBOL(__fscache_acquire_cookie);
 
@@ -678,6 +848,22 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie,
 }
 EXPORT_SYMBOL(__fscache_relinquish_cookie);
 
+/*
+ * Remove a cookie from the hash table.
+ */
+static void fscache_unhash_cookie(struct fscache_cookie *candidate)
+{
+	struct hlist_bl_head *h;
+	unsigned int bucket;
+
+	bucket = candidate->key_hash & (ARRAY_SIZE(fscache_cookie_hash) - 1);
+	h = &fscache_cookie_hash[bucket];
+
+	hlist_bl_lock(h);
+	hlist_bl_del(&candidate->hash_link);
+	hlist_bl_unlock(h);
+}
+
 /*
  * Drop a reference to a cookie.
  */
@@ -698,12 +884,8 @@ void fscache_cookie_put(struct fscache_cookie *cookie,
 		BUG_ON(usage < 0);
 
 		parent = cookie->parent;
-		BUG_ON(!hlist_empty(&cookie->backing_objects));
-		if (cookie->aux_len > sizeof(cookie->inline_aux))
-			kfree(cookie->aux);
-		if (cookie->key_len > sizeof(cookie->inline_key))
-			kfree(cookie->key);
-		kmem_cache_free(fscache_cookie_jar, cookie);
+		fscache_unhash_cookie(cookie);
+		fscache_free_cookie(cookie);
 
 		cookie = parent;
 		where = fscache_cookie_put_parent;
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 5f905a499306..8f8e383ae47c 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -49,7 +49,13 @@ extern struct fscache_cache *fscache_select_cache_for_object(
  */
 extern struct kmem_cache *fscache_cookie_jar;
 
+extern void fscache_free_cookie(struct fscache_cookie *);
 extern void fscache_cookie_init_once(void *);
+extern struct fscache_cookie *fscache_alloc_cookie(struct fscache_cookie *,
+						   const struct fscache_cookie_def *,
+						   const void *, size_t,
+						   const void *, size_t,
+						   void *, loff_t);
 extern void fscache_cookie_put(struct fscache_cookie *,
 			       enum fscache_cookie_trace);
 
diff --git a/fs/fscache/netfs.c b/fs/fscache/netfs.c
index a5998dfab7e7..59031d464bb1 100644
--- a/fs/fscache/netfs.c
+++ b/fs/fscache/netfs.c
@@ -30,40 +30,17 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 	INIT_LIST_HEAD(&netfs->link);
 
 	/* allocate a cookie for the primary index */
-	cookie = kmem_cache_zalloc(fscache_cookie_jar, GFP_KERNEL);
-
+	cookie = fscache_alloc_cookie(&fscache_fsdef_index,
+				      &fscache_fsdef_netfs_def,
+				      netfs->name, strlen(netfs->name),
+				      &netfs->version, sizeof(netfs->version),
+				      netfs, 0);
 	if (!cookie) {
 		_leave(" = -ENOMEM");
 		return -ENOMEM;
 	}
 
-	cookie->key_len = strlen(netfs->name);
-	if (cookie->key_len <= sizeof(cookie->inline_key)) {
-		memcpy(cookie->inline_key, netfs->name, strlen(netfs->name));
-	} else {
-		ret = -ENOMEM;
-		cookie->key = kmemdup(netfs->name, cookie->key_len, GFP_KERNEL);
-		if (!cookie->key)
-			goto nomem;
-	}
-
-	cookie->aux_len = sizeof(netfs->version);
-	memcpy(cookie->inline_aux, &netfs->version, cookie->aux_len);
-
-	/* initialise the primary index cookie */
-	atomic_set(&cookie->usage, 1);
-	atomic_set(&cookie->n_children, 0);
-	atomic_set(&cookie->n_active, 1);
-
-	cookie->def		= &fscache_fsdef_netfs_def;
-	cookie->parent		= &fscache_fsdef_index;
-	cookie->netfs_data	= netfs;
-	cookie->flags		= 1 << FSCACHE_COOKIE_ENABLED;
-	cookie->type		= FSCACHE_COOKIE_TYPE_INDEX;
-
-	spin_lock_init(&cookie->lock);
-	spin_lock_init(&cookie->stores_lock);
-	INIT_HLIST_HEAD(&cookie->backing_objects);
+	cookie->flags = 1 << FSCACHE_COOKIE_ENABLED;
 
 	/* check the netfs type is not already present */
 	down_write(&fscache_addremove_sem);
@@ -87,7 +64,6 @@ int __fscache_register_netfs(struct fscache_netfs *netfs)
 already_registered:
 	up_write(&fscache_addremove_sem);
 
-nomem:
 	if (ret < 0)
 		kmem_cache_free(fscache_cookie_jar, cookie);
 
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index eb38f39cf832..c8c87f298e10 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -22,6 +22,7 @@
 #include <linux/list.h>
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
+#include <linux/list_bl.h>
 
 #if defined(CONFIG_FSCACHE) || defined(CONFIG_FSCACHE_MODULE)
 #define fscache_available() (1)
@@ -143,6 +144,7 @@ struct fscache_cookie {
 	struct hlist_head		backing_objects; /* object(s) backing this file/index */
 	const struct fscache_cookie_def	*def;		/* definition */
 	struct fscache_cookie		*parent;	/* parent of this entry */
+	struct hlist_bl_node		hash_link;	/* Link in hash table */
 	void				*netfs_data;	/* back pointer to netfs */
 	struct radix_tree_root		stores;		/* pages to be stored on this cookie */
 #define FSCACHE_COOKIE_PENDING_TAG	0		/* pages tag: pending write to cache */
@@ -156,11 +158,14 @@ struct fscache_cookie {
 #define FSCACHE_COOKIE_RELINQUISHED	4	/* T if cookie has been relinquished */
 #define FSCACHE_COOKIE_ENABLED		5	/* T if cookie is enabled */
 #define FSCACHE_COOKIE_ENABLEMENT_LOCK	6	/* T if cookie is being en/disabled */
-#define FSCACHE_COOKIE_AUX_UPDATED	7	/* T if the auxiliary data was updated */
+#define FSCACHE_COOKIE_AUX_UPDATED	8	/* T if the auxiliary data was updated */
+#define FSCACHE_COOKIE_ACQUIRED		9	/* T if cookie is in use */
+#define FSCACHE_COOKIE_RELINQUISHING	10	/* T if cookie is being relinquished */
 
 	u8				type;		/* Type of object */
 	u8				key_len;	/* Length of index key */
 	u8				aux_len;	/* Length of auxiliary data */
+	u32				key_hash;	/* Hash of parent, type, key, len */
 	union {
 		void			*key;		/* Index key */
 		u8			inline_key[16];	/* - If the key is short enough */
diff --git a/include/trace/events/fscache.h b/include/trace/events/fscache.h
index 82c060fe6635..6f63177e2fb9 100644
--- a/include/trace/events/fscache.h
+++ b/include/trace/events/fscache.h
@@ -24,8 +24,11 @@
 #define __FSCACHE_DECLARE_TRACE_ENUMS_ONCE_ONLY
 
 enum fscache_cookie_trace {
+	fscache_cookie_collision,
+	fscache_cookie_discard,
 	fscache_cookie_get_acquire_parent,
 	fscache_cookie_get_attach_object,
+	fscache_cookie_get_reacquire,
 	fscache_cookie_get_register_netfs,
 	fscache_cookie_put_acquire_nobufs,
 	fscache_cookie_put_relinquish,
@@ -86,8 +89,11 @@ enum fscache_page_op_trace {
  * Declare tracing information enums and their string mappings for display.
  */
 #define fscache_cookie_traces						\
+	EM(fscache_cookie_collision,		"*COLLISION*")		\
+	EM(fscache_cookie_discard,		"DISCARD")		\
 	EM(fscache_cookie_get_acquire_parent,	"GET prn")		\
 	EM(fscache_cookie_get_attach_object,	"GET obj")		\
+	EM(fscache_cookie_get_reacquire,	"GET raq")		\
 	EM(fscache_cookie_get_register_netfs,	"GET net")		\
 	EM(fscache_cookie_put_acquire_nobufs,	"PUT nbf")		\
 	EM(fscache_cookie_put_relinquish,	"PUT rlq")		\

