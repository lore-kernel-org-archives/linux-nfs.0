From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 8 - Include update mode in declaration of RPC information caches.
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qF-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhy-0007SM-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:15 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:54:58 +1000
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

The sunrpc/cache.c caches which store nfsd export information
can be updated either "inplace" or by replacing the entry.

replacement is needed when an entry hold a reference to some
other object, so the reference counts work properly.

"inplace" can be used when no such references are held, and should be
used when the object could be refered to by another cache (as otherwise
the other cache would have to be updated whenever this one is).

Previously the type of update (inplace or replace) was specified 
as an argument to the *_lookup operation.  This too easily lead to 
inconsistancies.

With this patch, the update mode is specified when the cache is
declared.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c             |    8 ++++----
 ./include/linux/sunrpc/cache.h |   13 +++++++------
 ./net/sunrpc/svcauth.c         |    3 ++-
 ./net/sunrpc/svcauth_unix.c    |    2 +-
 4 files changed, 14 insertions(+), 12 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-06-24 13:25:59.000000000 +1000
+++ ./fs/nfsd/export.c	2003-06-24 13:29:35.000000000 +1000
@@ -156,7 +156,7 @@ int expkey_parse(struct cache_detail *cd
 	if (len == 0) {
 		struct svc_expkey *ek;
 		set_bit(CACHE_NEGATIVE, &key.h.flags);
-		ek = svc_expkey_lookup(&key, 2);
+		ek = svc_expkey_lookup(&key, 1);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
 	} else {
@@ -176,7 +176,7 @@ int expkey_parse(struct cache_detail *cd
 		key.ek_export = exp;
 		dprintk("And found export\n");
 		
-		ek = svc_expkey_lookup(&key, 2);
+		ek = svc_expkey_lookup(&key, 1);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
 		exp_put(exp);
@@ -231,7 +231,7 @@ static inline void svc_expkey_update(str
 	new->ek_export = item->ek_export;
 }
 
-static DefineSimpleCacheLookup(svc_expkey)
+static DefineSimpleCacheLookup(svc_expkey,0) /* no inplace updates */
 
 #define	EXPORT_HASHBITS		8
 #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
@@ -438,7 +438,7 @@ static inline void svc_export_update(str
 	new->ex_fsid = item->ex_fsid;
 }
 
-static DefineSimpleCacheLookup(svc_export)
+static DefineSimpleCacheLookup(svc_export,1) /* allow inplace updates */
 
 
 struct svc_expkey *

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-06-24 13:24:43.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2003-06-24 13:31:33.000000000 +1000
@@ -155,8 +155,9 @@ struct cache_deferred_req {
  * TEST  tests if "tmp" matches "item"
  * INIT copies key information from "item" to "new"
  * UPDATE copies content information from "item" to "tmp"
+ * INPLACE is true if updates can happen inplace rather than allocating a new structure
  */
-#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE)	\
+#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE,INPLACE)	\
 RTN *FNAME ARGS										\
 {											\
 	RTN *tmp, *new=NULL;								\
@@ -170,12 +171,12 @@ RTN *FNAME ARGS										\
 		tmp = container_of(*hp, RTN, MEMBER);					\
 		if (TEST) { /* found a match */						\
 											\
-			if (set == 1 && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
+			if (set && !INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
 				break;							\
 											\
 			atomic_inc(&tmp->MEMBER.refcnt);				\
 			if (set) {							\
-				if (set == 1 && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
+				if (!INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
 				{ /* need to swap in new */				\
 					RTN *t2;					\
 											\
@@ -194,7 +195,7 @@ RTN *FNAME ARGS										\
 			else read_unlock(&(DETAIL)->hash_lock);				\
 			if (set)							\
 				cache_fresh(DETAIL, &tmp->MEMBER, item->MEMBER.expiry_time); \
-			if (set==1 && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
+			if (set && !INPLACE && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
 			if (new) (DETAIL)->cache_put(&new->MEMBER, DETAIL);		\
 			return tmp;							\
 		}									\
@@ -229,10 +230,10 @@ RTN *FNAME ARGS										\
 	return NULL;									\
 }
 
-#define DefineSimpleCacheLookup(STRUCT)	\
+#define DefineSimpleCacheLookup(STRUCT,INPLACE)	\
 	DefineCacheLookup(struct STRUCT, h, STRUCT##_lookup, (struct STRUCT *item, int set), /*no setup */,	\
 			  & STRUCT##_cache, STRUCT##_hash(item), STRUCT##_match(item, tmp),\
-			  STRUCT##_init(new, item), STRUCT##_update(tmp, item))
+			  STRUCT##_init(new, item), STRUCT##_update(tmp, item),INPLACE)
 
 #define cache_for_each(pos, detail, index, member) 						\
 	for (({read_lock(&(detail)->hash_lock); index = (detail)->hash_size;}) ;		\

diff ./net/sunrpc/svcauth.c~current~ ./net/sunrpc/svcauth.c
--- ./net/sunrpc/svcauth.c~current~	2003-06-24 13:24:43.000000000 +1000
+++ ./net/sunrpc/svcauth.c	2003-06-24 13:32:34.000000000 +1000
@@ -152,7 +152,8 @@ DefineCacheLookup(struct auth_domain,
 		  auth_domain_match(tmp, item),
 		  kfree(new); if(!set) return NULL;
 		  new=item; atomic_inc(&new->h.refcnt),
-		  /* no update */
+		  /* no update */,
+		  0 /* no inplace updates */
 		  )
 
 struct auth_domain *auth_domain_find(char *name)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-06-24 13:26:24.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2003-06-24 13:32:17.000000000 +1000
@@ -250,7 +250,7 @@ struct cache_detail ip_map_cache = {
 	.cache_show	= ip_map_show,
 };
 
-static DefineSimpleCacheLookup(ip_map)
+static DefineSimpleCacheLookup(ip_map, 0)
 
 
 int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
