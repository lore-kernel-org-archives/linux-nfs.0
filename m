From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 17 - Initialial caching infrastructure for RPC authentication caches
Date: Fri, 11 Oct 2002 15:27:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKg-0003b0-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLC-0003fv-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:03 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:42 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

This patch provides a "virtual class" for defining caches
that make user-space information available in the kernel
It is intended for RPC services or clients that need user-space
support for authentication.

As yet, support for userspace interaction isn't included as I want
that to be able to have separate review.


 ----------- Diffstat output ------------
 ./Documentation/rpc-cache.txt  |   82 ++++++++++++
 ./include/linux/sunrpc/cache.h |  243 ++++++++++++++++++++++++++++++++++++
 ./include/linux/sunrpc/debug.h |    1 
 ./net/sunrpc/Makefile          |    2 
 ./net/sunrpc/cache.c           |  276 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 603 insertions(+), 1 deletion(-)

--- ./include/linux/sunrpc/debug.h	2002/10/11 00:41:49	1.1
+++ ./include/linux/sunrpc/debug.h	2002/10/11 00:41:59	1.2
@@ -35,6 +35,7 @@
 #define RPCDBG_SVCSOCK		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
+#define RPCDBG_CACHE		0x0800
 #define RPCDBG_ALL		0x7fff
 
 #ifdef __KERNEL__
--- ./include/linux/sunrpc/cache.h	2002/10/11 00:41:49	1.1
+++ ./include/linux/sunrpc/cache.h	2002/10/11 00:41:59	1.2
@@ -0,0 +1,243 @@
+/*
+ * include/linux/sunrpc/cache.h
+ *
+ * Generic code for various authentication-related caches
+ * used by sunrpc clients and servers.
+ *
+ * Copyright (C) 2002 Neil Brown <neilb@cse.unsw.edu.au>
+ *
+ * Released under terms in GPL version 2.  See COPYING.
+ *
+ */
+
+#ifndef _LINUX_SUNRPC_CACHE_H_
+#define _LINUX_SUNRPC_CACHE_H_
+
+#include <linux/slab.h>
+#include <asm/atomic.h>
+
+/*
+ * Each cache requires:
+ *  - A 'struct cache_detail' which contains information specific to the cache
+ *    for common code to use.
+ *  - An item structure that must contain a "struct cache_head"
+ *  - A lookup function defined using DefineCacheLookup
+ *  - A 'put' function that can release a cache item. It will only
+ *    be called after cache_put has succeed, so there are guarantee
+ *    to be no references.
+ *  - A function to calculate a hash of an item's key.
+ *
+ * as well as assorted code fragments (e.g. compare keys) and numbers
+ * (e.g. hash size, goal_age, etc).
+ *
+ * Each cache must be registered so that it can be cleaned regularly.
+ * When the cache is unregistered, it is flushed completely.
+ *
+ * Entries have a ref count and a 'hashed' flag which counts the existance
+ * in the hash table.
+ * We only expire entries when refcount is zero.
+ * Existance in the cache is not measured in refcount but rather in
+ * CACHE_HASHED flag.
+ */
+
+/* Every cache item has a common header that is used
+ * for expiring and refreshing entries.
+ * 
+ */
+struct cache_head {
+	struct cache_head * next;
+	time_t		expiry_time;	/* After time time, don't use the data */
+	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall 
+					 * was sent, else this is when update was received
+					 */
+	atomic_t 	refcnt;
+	unsigned long	flags;
+};
+#define	CACHE_VALID	0	/* Entry contains valid data */
+#define	CACHE_NEGATIVE	1	/* Negative entry - there is no match for the key */
+#define	CACHE_PENDING	2	/* An upcall has been sent but no reply received yet*/
+#define	CACHE_HASHED	3	/* Entry is in a hash table */
+
+#define	CACHE_NEW_EXPIRY 120	/* keep new things pending confirmation for 120 seconds */
+
+struct cache_detail {
+	int			hash_size;
+	struct cache_head **	hash_table;
+	rwlock_t		hash_lock;
+
+	atomic_t		inuse; /* active user-space update or lookup */
+
+	char			*name;
+	void			(*cache_put)(struct cache_head *,
+					     struct cache_detail*);
+
+	/* request and update functions for interaction with userspace
+	 * will go here
+	 */
+
+	/* fields below this comment are for internal use
+	 * and should not be touched by cache owners
+	 */
+	time_t			flush_time;		/* flush all cache items with last_refresh
+							 * earlier than this */
+	struct list_head	others;
+	time_t			nextcheck;
+	int			entries;
+};
+
+
+/*
+ * just like a template in C++, this macro does cache lookup
+ * for us.
+ * The function is passed some sort of HANDLE from which a cache_detail
+ * structure can be determined (via SETUP, DETAIL), a template
+ * cache entry (type RTN*), and a "set" flag.  Using the HASHFN and the 
+ * TEST, the function will try to find a matching cache entry in the cache.
+ * If "set" == 0 :
+ *    If an entry is found, it is returned
+ *    If no entry is found, a new non-VALID entry is created.
+ * If "set" == 1 :
+ *    If no entry is found a new one is inserted with data from "template"
+ *    If a non-CACHE_VALID entry is found, it is updated from template using UPDATE
+ *    If a CACHE_VALID entry is found, a new entry is swapped in with data
+ *       from "template"
+ * If set == 2, we UPDATE, but don't swap. i.e. update in place
+ *
+ * If the passed handle has the CACHE_NEGATIVE flag set, then UPDATE is not
+ * run but insteead CACHE_NEGATIVE is set in any new item.
+
+ *  In any case, the new entry is returned with a reference count.
+ *
+ *    
+ * RTN is a struct type for a cache entry
+ * MEMBER is the member of the cache which is cache_head, which must be first
+ * FNAME is the name for the function	
+ * ARGS are arguments to function and must contain RTN *item, int set.  May
+ *   also contain something to be usedby SETUP or DETAIL to find cache_detail.
+ * SETUP  locates the cache detail and makes it available as...
+ * DETAIL identifies the cache detail, possibly set up by SETUP
+ * HASHFN returns a hash value of the cache entry "item"
+ * TEST  tests if "tmp" matches "item"
+ * INIT copies key information from "item" to "new"
+ * UPDATE copies content information from "item" to "tmp"
+ */
+#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE)	\
+RTN *FNAME ARGS										\
+{											\
+	RTN *tmp, *new=NULL;								\
+	struct cache_head **hp, **head;							\
+	SETUP;										\
+ retry:											\
+	head = &(DETAIL)->hash_table[HASHFN];						\
+	if (set||new) write_lock(&(DETAIL)->hash_lock);					\
+	else read_lock(&(DETAIL)->hash_lock);						\
+	for(hp=head; *hp != NULL; hp = &tmp->MEMBER.next) {				\
+		tmp = container_of(*hp, RTN, MEMBER);					\
+		if (TEST) { /* found a match */						\
+											\
+			atomic_inc(&tmp->MEMBER.refcnt);				\
+			if (set) {							\
+				if (set!= 2 && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
+				{ /* need to swap in new */				\
+					RTN *t2;					\
+					if (!new) break;				\
+											\
+					new->MEMBER.next = tmp->MEMBER.next;		\
+					*head = &new->MEMBER;				\
+					tmp->MEMBER.next = NULL;			\
+					set_bit(CACHE_HASHED, &new->MEMBER.flags);	\
+					clear_bit(CACHE_HASHED, &tmp->MEMBER.flags);	\
+					t2 = tmp; tmp = new; new = t2;			\
+				}							\
+				if (test_bit(CACHE_NEGATIVE,  &item->MEMBER.flags))	\
+					 set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
+				else {UPDATE;}						\
+			}								\
+			if (set||new) write_unlock(&(DETAIL)->hash_lock);		\
+			else read_unlock(&(DETAIL)->hash_lock);				\
+			if (set)							\
+				cache_fresh(DETAIL, &tmp->MEMBER, item->MEMBER.expiry_time); \
+			if (new) (DETAIL)->cache_put(&new->MEMBER, DETAIL);		\
+			return tmp;							\
+		}									\
+	}										\
+	/* Didn't find anything */							\
+	if (new) {									\
+		new->MEMBER.next = *head;						\
+		*head = &new->MEMBER;							\
+		(DETAIL)->entries ++;							\
+		set_bit(CACHE_HASHED, &new->MEMBER.flags);				\
+		if (set) {								\
+			tmp = new;							\
+			if (test_bit(CACHE_NEGATIVE, &item->MEMBER.flags))		\
+				set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);		\
+			else {UPDATE;}							\
+		}									\
+	}										\
+	if (set||new) write_unlock(&(DETAIL)->hash_lock);				\
+	else read_unlock(&(DETAIL)->hash_lock);						\
+	if (new && set)									\
+		cache_fresh(DETAIL, &new->MEMBER, item->MEMBER.expiry_time);		\
+	if (new)				       					\
+		return new;								\
+	new = kmalloc(sizeof(*new), GFP_KERNEL);					\
+	if (new) {									\
+		cache_init(&new->MEMBER);						\
+		atomic_inc(&new->MEMBER.refcnt);					\
+		INIT;									\
+		tmp = new;								\
+		goto retry;								\
+	}										\
+	return NULL;									\
+}
+
+#define DefineSimpleCacheLookup(STRUCT)	\
+	DefineCacheLookup(struct STRUCT, h, STRUCT##_lookup, (struct STRUCT *item, int set), /*no setup */,	\
+			  & STRUCT##_cache, STRUCT##_hash(item), STRUCT##_match(item, tmp),\
+			  STRUCT##_init(new, item), STRUCT##_update(tmp, item))
+
+#define cache_for_each(pos, detail, index, member) 						\
+	for (({read_lock(&(detail)->hash_lock); index = (detail)->hash_size;}) ;		\
+	     ({if (index==0)read_unlock(&(detail)->hash_lock); index--;});			\
+		)										\
+		for (pos = container_of((detail)->hash_table[index], typeof(*pos), member);	\
+		     &pos->member;								\
+		     pos = container_of(pos->member.next, typeof(*pos), member))
+
+	     
+
+static inline struct cache_head  *cache_get(struct cache_head *h)
+{
+	atomic_inc(&h->refcnt);
+	return h;
+}
+
+
+static int inline cache_put(struct cache_head *h, struct cache_detail *cd)
+{
+	atomic_dec(&h->refcnt);
+	if (!atomic_read(&h->refcnt) &&
+	    h->expiry_time < cd->nextcheck)
+		cd->nextcheck = h->expiry_time;
+	if (!test_bit(CACHE_HASHED, &h->flags) &&
+	    !atomic_read(&h->refcnt))
+		return 1;
+
+	return 0;
+}
+
+extern void cache_init(struct cache_head *h);
+extern void cache_fresh(struct cache_detail *detail,
+			struct cache_head *head, time_t expiry);
+extern int cache_check(struct cache_detail *detail,
+		       struct cache_head *h);
+extern int cache_clean(void);
+extern void cache_flush(void);
+extern void cache_purge(struct cache_detail *detail);
+#define NEVER (0x7FFFFFFF)
+extern void cache_register(struct cache_detail *cd);
+extern int cache_unregister(struct cache_detail *cd);
+extern struct cache_detail *cache_find(char *name);
+extern void cache_drop(struct cache_detail *detail);
+
+#endif /*  _LINUX_SUNRPC_CACHE_H_ */
--- ./net/sunrpc/Makefile	2002/10/11 00:41:49	1.1
+++ ./net/sunrpc/Makefile	2002/10/11 00:42:00	1.2
@@ -10,7 +10,7 @@ sunrpc-y := clnt.o xprt.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o \
 	    pmap_clnt.o timer.o xdr.o \
-	    sunrpc_syms.o
+	    sunrpc_syms.o cache.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
 sunrpc-objs := $(sunrpc-y)
--- ./net/sunrpc/cache.c	2002/10/11 00:41:49	1.1
+++ ./net/sunrpc/cache.c	2002/10/11 00:42:00	1.2
@@ -0,0 +1,276 @@
+/*
+ * net/sunrpc/cache.c
+ *
+ * Generic code for various authentication-related caches
+ * used by sunrpc clients and servers.
+ *
+ * Copyright (C) 2002 Neil Brown <neilb@cse.unsw.edu.au>
+ *
+ * Released under terms in GPL version 2.  See COPYING.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/slab.h>
+#include <linux/signal.h>
+#include <linux/sched.h>
+#include <linux/kmod.h>
+#include <linux/list.h>
+#include <asm/uaccess.h>
+#include <linux/sunrpc/types.h>
+#include <linux/sunrpc/cache.h>
+
+#define	 RPCDBG_FACILITY RPCDBG_CACHE
+
+void cache_init(struct cache_head *h)
+{
+	time_t now = CURRENT_TIME;
+	h->next = NULL;
+	h->flags = 0;
+	atomic_set(&h->refcnt, 0);
+	h->expiry_time = now + CACHE_NEW_EXPIRY;
+	h->last_refresh = now;
+}
+
+
+/*
+ * This is the generic cache management routine for all
+ * the authentication caches.
+ * It checks the currency of a cache item and will (later)
+ * initiate an upcall to fill it if needed.
+ *
+ *
+ * Returns 0 if the cache_head can be used, or cache_puts it and returns
+ * -EAGAIN if upcall is pending,
+ * -ENOENT if cache entry was negative
+ */
+int cache_check(struct cache_detail *detail, struct cache_head *h)
+{
+	int rv;
+
+	/* First decide return status as best we can */
+	if (!test_bit(CACHE_VALID, &h->flags) ||
+	    h->expiry_time < CURRENT_TIME)
+		rv = -EAGAIN;
+	else if (detail->flush_time > h->last_refresh)
+		rv = -EAGAIN;
+	else {
+		/* entry is valid */
+		if (test_bit(CACHE_NEGATIVE, &h->flags))
+			rv = -ENOENT;
+		else rv = 0;
+	}
+
+	/* up-call processing goes here later */
+
+	if (rv == -EAGAIN /* && cannot do upcall */)
+		rv = -ENOENT;
+
+	if (rv && h)
+		detail->cache_put(h, detail);
+	return rv;
+}
+
+void cache_fresh(struct cache_detail *detail,
+		 struct cache_head *head, time_t expiry)
+{
+
+	head->expiry_time = expiry;
+	head->last_refresh = CURRENT_TIME;
+	set_bit(CACHE_VALID, &head->flags);
+	clear_bit(CACHE_PENDING, &head->flags);
+}
+
+/*
+ * caches need to be periodically cleaned.
+ * For this we maintain a list of cache_detail and
+ * a current pointer into that list and into the table
+ * for that entry.
+ *
+ * Each time clean_cache is called it finds the next non-empty entry
+ * in the current table and walks the list in that entry
+ * looking for entries that can be removed.
+ *
+ * An entry gets removed if:
+ * - The expiry is before current time
+ * - The last_refresh time is before the flush_time for that cache
+ *
+ * later we might drop old entries with non-NEVER expiry if that table
+ * is getting 'full' for some definition of 'full'
+ *
+ * The question of "how often to scan a table" is an interesting one
+ * and is answered in part by the use of the "nextcheck" field in the
+ * cache_detail.
+ * When a scan of a table begins, the nextcheck field is set to a time
+ * that is well into the future.
+ * While scanning, if an expiry time is found that is earlier than the
+ * current nextcheck time, nextcheck is set to that expiry time.
+ * If the flush_time is ever set to a time earlier than the nextcheck
+ * time, the nextcheck time is then set to that flush_time.
+ *
+ * A table is then only scanned if the current time is at least
+ * the nextcheck time.
+ * 
+ */
+
+static LIST_HEAD(cache_list);
+static spinlock_t cache_list_lock = SPIN_LOCK_UNLOCKED;
+static struct cache_detail *current_detail;
+static int current_index;
+
+void cache_register(struct cache_detail *cd)
+{
+	rwlock_init(&cd->hash_lock);
+	spin_lock(&cache_list_lock);
+	cd->nextcheck = 0;
+	cd->entries = 0;
+	list_add(&cd->others, &cache_list);
+	spin_unlock(&cache_list_lock);
+}
+
+int cache_unregister(struct cache_detail *cd)
+{
+	cache_purge(cd);
+	spin_lock(&cache_list_lock);
+	write_lock(&cd->hash_lock);
+	if (cd->entries || atomic_read(&cd->inuse)) {
+		write_unlock(&cd->hash_lock);
+		spin_unlock(&cache_list_lock);
+		return -EBUSY;
+	}
+	if (current_detail == cd)
+		current_detail = NULL;
+	list_del_init(&cd->others);
+	write_unlock(&cd->hash_lock);
+	spin_unlock(&cache_list_lock);
+	return 0;
+}
+
+struct cache_detail *cache_find(char *name)
+{
+	struct list_head *l;
+
+	spin_lock(&cache_list_lock);
+	list_for_each(l, &cache_list) {
+		struct cache_detail *cd = list_entry(l, struct cache_detail, others);
+		
+		if (strcmp(cd->name, name)==0) {
+			atomic_inc(&cd->inuse);
+			spin_unlock(&cache_list_lock);
+			return cd;
+		}
+	}
+	spin_unlock(&cache_list_lock);
+	return NULL;
+}
+
+/* cache_drop must be called on any cache returned by
+ * cache_find, after it has been used
+ */
+void cache_drop(struct cache_detail *detail)
+{
+	atomic_dec(&detail->inuse);
+}
+
+/* clean cache tries to find something to clean
+ * and cleans it.
+ * It returns 1 if it cleaned something,
+ *            0 if it didn't find anything this time
+ *           -1 if it fell off the end of the list.
+ */
+int cache_clean(void)
+{
+	int rv = 0;
+	struct list_head *next;
+
+	spin_lock(&cache_list_lock);
+
+	/* find a suitable table if we don't already have one */
+	while (current_detail == NULL ||
+	    current_index >= current_detail->hash_size) {
+		if (current_detail)
+			next = current_detail->others.next;
+		else
+			next = cache_list.next;
+		if (next == &cache_list) {
+			current_detail = NULL;
+			spin_unlock(&cache_list_lock);
+			return -1;
+		}
+		current_detail = list_entry(next, struct cache_detail, others);
+		if (current_detail->nextcheck > CURRENT_TIME)
+			current_index = current_detail->hash_size;
+		else {
+			current_index = 0;
+			current_detail->nextcheck = CURRENT_TIME+30*60;
+		}
+	}
+
+	/* find a non-empty bucket in the table */
+	while (current_detail &&
+	       current_index < current_detail->hash_size &&
+	       current_detail->hash_table[current_index] == NULL)
+		current_index++;
+
+	/* find a cleanable entry in the bucket and clean it, or set to next bucket */
+	
+	if (current_detail && current_index < current_detail->hash_size) {
+		struct cache_head *ch, **cp;
+		
+		write_lock(&current_detail->hash_lock);
+
+		/* Ok, now to clean this strand */
+			
+		cp = & current_detail->hash_table[current_index];
+		ch = *cp;
+		for (; ch; cp= & ch->next, ch= *cp) {
+			if (atomic_read(&ch->refcnt))
+				continue;
+			if (ch->expiry_time < CURRENT_TIME
+			    || ch->last_refresh < current_detail->flush_time
+				)
+				break;
+			if (current_detail->nextcheck > ch->expiry_time)
+				current_detail->nextcheck = ch->expiry_time+1;
+		}
+		if (ch) {
+			cache_get(ch);
+			clear_bit(CACHE_HASHED, &ch->flags);
+			*cp = ch->next;
+			ch->next = NULL;
+			current_detail->entries--;
+			rv = 1;
+		}
+		write_unlock(&current_detail->hash_lock);
+		if (ch)
+			current_detail->cache_put(ch, current_detail);
+		else
+			current_index ++;
+	}
+	spin_unlock(&cache_list_lock);
+
+	return rv;
+}
+
+/* 
+ * Clean all caches promptly.  This just calls cache_clean
+ * repeatedly until we are sure that every cache has had a chance to 
+ * be fully cleaned
+ */
+void cache_flush(void)
+{
+	while (cache_clean() != -1)
+		cond_resched();
+	while (cache_clean() != -1)
+		cond_resched();
+}
+
+void cache_purge(struct cache_detail *detail)
+{
+	detail->flush_time = CURRENT_TIME+1;
+	detail->nextcheck = CURRENT_TIME;
+	cache_flush();
+}
+
--- ./Documentation/rpc-cache.txt	2002/10/11 00:41:49	1.1
+++ ./Documentation/rpc-cache.txt	2002/10/11 00:42:00	1.2
@@ -0,0 +1,82 @@
+This document gives a brief introduction to the caching
+mechanisms in the sunrpc layer that is used, in particular,
+for NFS authentication.
+
+CACHES
+======
+The caching replaces the old exports table and allows for
+a wide variety of values to be caches.
+
+There are a number of caches that are similar in structure though
+quite possibly very different in content and use.  There is a corpus
+of common code for managing these caches.
+
+Examples of caches that are likely to be needed are:
+  - mapping from IP address to client name
+  - mapping from client name and filesystem to export options
+  - mapping from UID to list of GIDs, to work around NFS's limitation
+    of 16 gids.
+  - mappings between local UID/GID and remote UID/GID for sites that
+    do not have uniform uid assignment
+  - mapping from network identify to public key for crypto authentication.
+
+The common code handles such things as:
+   - general cache lookup with correct locking
+   - supporting 'NEGATIVE' as well as positive entries
+   - allowing an EXPIRED time on cache items, and removing
+     items after they expire, and are no longe in-use.
+
+   Future code extensions are expect to handle
+   - making requests to user-space to fill in cache entries
+   - allowing user-space to directly set entries in the cache
+   - delaying RPC requests that depend on as-yet incomplete
+     cache entries, and replaying those requests when the cache entry
+     is complete.
+   - maintaining last-access times on cache entries
+   - clean out old entries when the caches become full
+
+The code for performing a cache lookup is also common, but in the form
+of a template.  i.e. a #define.
+Each cache defines a lookup function by using the DefineCacheLookup
+macro, or the simpler DefineSimpleCacheLookup macro
+
+Creating a Cache
+----------------
+
+1/ A cache needs a datum to cache.  This is in the form of a
+   structure definition that must contain a
+     struct cache_head
+   as an element, usually the first.
+   It will also contain a key and some content.
+   Each cache element is reference counted and contains
+   expiry and update times for use in cache management.
+2/ A cache needs a "cache_detail" structure that
+   describes the cache.  This stores the hash table, and some
+   parameters for cache management.
+3/ A cache needs a lookup function.  This is created using
+   the DefineCacheLookup macro.  This lookup function is used both
+   to find entries and to update entries.  The normal mode for
+   updating an entry is to replace the old entry with a new
+   entry.  However it is possible to allow update-in-place
+   for those caches where it makes sense (no atomicity issues
+   or indirect reference counting issue)
+4/ A cache needs to be registered using cache_register().  This
+   includes in on a list of caches that will be regularly
+   cleaned to discard old data.  For this to work, some
+   thread must periodically call cache_clean
+   
+Using a cache
+-------------
+
+To find a value in a cache, call the lookup function passing it a the
+datum which contains key, and possibly content, and a flag saying
+whether to update the cache with new data from the datum.   Depending
+on how the cache lookup function was defined, it may take an extra
+argument to identify the particular cache in question.
+
+Except in cases of kmalloc failure, the lookup function
+will return a new datum which will store the key and
+may contain valid content, or may not.
+This datum is typically passed to cache_check which determines the
+validity of the datum and may later initiate an upcall to fill
+in the data.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
