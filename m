From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 14] knfsd: Remove DefineCacheLookup
Date: Thu, 9 Mar 2006 17:52:24 +1100
Message-ID: <1060309065224.24665@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF1d-0000hW-0c
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:29 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF1c-0007Co-DS
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:29 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


This has been replaced by more traditional code.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/cache.h |  113 -----------------------------------------
 1 file changed, 113 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2006-03-09 17:29:35.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2006-03-09 17:32:38.000000000 +1100
@@ -128,119 +128,6 @@ struct cache_deferred_req {
 					   int too_many);
 };
 
-/*
- * just like a template in C++, this macro does cache lookup
- * for us.
- * The function is passed some sort of HANDLE from which a cache_detail
- * structure can be determined (via SETUP, DETAIL), a template
- * cache entry (type RTN*), and a "set" flag.  Using the HASHFN and the 
- * TEST, the function will try to find a matching cache entry in the cache.
- * If "set" == 0 :
- *    If an entry is found, it is returned
- *    If no entry is found, a new non-VALID entry is created.
- * If "set" == 1 :
- *    If no entry is found a new one is inserted with data from "template"
- *    If a non-CACHE_VALID entry is found, it is updated from template using UPDATE
- *    If a CACHE_VALID entry is found, a new entry is swapped in with data
- *       from "template"
- *
- * If the passed handle has the CACHE_NEGATIVE flag set, then UPDATE is not
- * run but insteead CACHE_NEGATIVE is set in any new item.
-
- *  In any case, the new entry is returned with a reference count.
- *
- *    
- * RTN is a struct type for a cache entry
- * MEMBER is the member of the cache which is cache_head, which must be first
- * FNAME is the name for the function	
- * ARGS are arguments to function and must contain RTN *item, int set.  May
- *   also contain something to be usedby SETUP or DETAIL to find cache_detail.
- * SETUP  locates the cache detail and makes it available as...
- * DETAIL identifies the cache detail, possibly set up by SETUP
- * HASHFN returns a hash value of the cache entry "item"
- * TEST  tests if "tmp" matches "item"
- * INIT copies key information from "item" to "new"
- * UPDATE copies content information from "item" to "tmp"
- */
-#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE)	\
-RTN *FNAME ARGS										\
-{											\
-	RTN *tmp, *new=NULL;								\
-	struct cache_head **hp, **head;							\
-	SETUP;										\
-	head = &(DETAIL)->hash_table[HASHFN];						\
- retry:											\
-	if (set||new) write_lock(&(DETAIL)->hash_lock);					\
-	else read_lock(&(DETAIL)->hash_lock);						\
-	for(hp=head; *hp != NULL; hp = &tmp->MEMBER.next) {				\
-		tmp = container_of(*hp, RTN, MEMBER);					\
-		if (TEST) { /* found a match */						\
-											\
-			if (set && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new)	\
-				break;							\
-											\
-			if (new)							\
-				{INIT;}							\
-			if (set) {							\
-				if (test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
-				{ /* need to swap in new */				\
-					RTN *t2;					\
-											\
-					new->MEMBER.next = tmp->MEMBER.next;		\
-					*hp = &new->MEMBER;				\
-					tmp->MEMBER.next = NULL;			\
-					t2 = tmp; tmp = new; new = t2;			\
-				}							\
-				if (test_bit(CACHE_NEGATIVE,  &item->MEMBER.flags))	\
-					set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
-				else {							\
-					UPDATE;						\
-					clear_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
-				}							\
-			}								\
-			cache_get(&tmp->MEMBER);					\
-			if (set||new) write_unlock(&(DETAIL)->hash_lock);		\
-			else read_unlock(&(DETAIL)->hash_lock);				\
-			if (set)							\
-				cache_fresh(DETAIL, &tmp->MEMBER, item->MEMBER.expiry_time); \
-			if (set && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
-			if (new) (DETAIL)->cache_put(&new->MEMBER, DETAIL);		\
-			return tmp;							\
-		}									\
-	}										\
-	/* Didn't find anything */							\
-	if (new) {									\
-		INIT;									\
-		new->MEMBER.next = *head;						\
-		*head = &new->MEMBER;							\
-		(DETAIL)->entries ++;							\
-		cache_get(&new->MEMBER);						\
-		if (set) {								\
-			tmp = new;							\
-			if (test_bit(CACHE_NEGATIVE, &item->MEMBER.flags))		\
-				set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);		\
-			else {UPDATE;}							\
-		}									\
-	}										\
-	if (set||new) write_unlock(&(DETAIL)->hash_lock);				\
-	else read_unlock(&(DETAIL)->hash_lock);						\
-	if (new && set)									\
-		cache_fresh(DETAIL, &new->MEMBER, item->MEMBER.expiry_time);		\
-	if (new)				       					\
-		return new;								\
-	new = kmalloc(sizeof(*new), GFP_KERNEL);					\
-	if (new) {									\
-		cache_init(&new->MEMBER);						\
-		goto retry;								\
-	}										\
-	return NULL;									\
-}
-
-#define DefineSimpleCacheLookup(STRUCT, FUNC)				\
-        DefineCacheLookup(struct STRUCT, h, FUNC##_lookup,		\
-        (struct STRUCT *item, int set), /*no setup */,			\
-	& FUNC##_cache, FUNC##_hash(item), FUNC##_match(item, tmp),	\
-	STRUCT##_init(new, item), STRUCT##_update(tmp, item))
 
 extern struct cache_head *
 sunrpc_cache_lookup(struct cache_detail *detail,


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
