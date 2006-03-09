From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 14] knfsd: Get rid of 'inplace' sunrpc caches
Date: Thu, 9 Mar 2006 17:51:37 +1100
Message-ID: <1060309065137.24545@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF0s-0000YV-Oe
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:42 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF0r-0006wn-TS
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:42 -0800
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


These were an unnecessary wart.
Also only have one 'DefineSimpleCache..' instead of two.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c                  |    4 ++--
 ./fs/nfsd/nfs4idmap.c               |   10 ++--------
 ./include/linux/sunrpc/cache.h      |   28 +++++++++++-----------------
 ./net/sunrpc/auth_gss/svcauth_gss.c |    4 ++--
 ./net/sunrpc/svcauth_unix.c         |    2 +-
 5 files changed, 18 insertions(+), 30 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2006-03-09 17:15:13.000000000 +1100
+++ ./fs/nfsd/export.c	2006-03-09 17:15:13.000000000 +1100
@@ -250,7 +250,7 @@ static inline void svc_expkey_update(str
 	new->ek_dentry = dget(item->ek_dentry);
 }
 
-static DefineSimpleCacheLookup(svc_expkey,0) /* no inplace updates */
+static DefineSimpleCacheLookup(svc_expkey, svc_expkey)
 
 #define	EXPORT_HASHBITS		8
 #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
@@ -482,7 +482,7 @@ static inline void svc_export_update(str
 	new->ex_fsid = item->ex_fsid;
 }
 
-static DefineSimpleCacheLookup(svc_export,1) /* allow inplace updates */
+static DefineSimpleCacheLookup(svc_export, svc_export)
 
 
 struct svc_expkey *

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2006-03-09 17:12:58.000000000 +1100
+++ ./fs/nfsd/nfs4idmap.c	2006-03-09 17:15:13.000000000 +1100
@@ -76,12 +76,6 @@ struct ent {
 	char              authname[IDMAP_NAMESZ];
 };
 
-#define DefineSimpleCacheLookupMap(STRUCT, FUNC)			\
-        DefineCacheLookup(struct STRUCT, h, FUNC##_lookup,		\
-        (struct STRUCT *item, int set), /*no setup */,			\
-	& FUNC##_cache, FUNC##_hash(item), FUNC##_match(item, tmp),	\
-	STRUCT##_init(new, item), STRUCT##_update(tmp, item), 0)
-
 /* Common entry handling */
 
 #define ENT_HASHBITS          8
@@ -264,7 +258,7 @@ out:
 	return error;
 }
 
-static DefineSimpleCacheLookupMap(ent, idtoname);
+static DefineSimpleCacheLookup(ent, idtoname);
 
 /*
  * Name -> ID cache
@@ -390,7 +384,7 @@ out:
 	return (error);
 }
 
-static DefineSimpleCacheLookupMap(ent, nametoid);
+static DefineSimpleCacheLookup(ent, nametoid);
 
 /*
  * Exported API

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2006-03-09 17:12:58.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2006-03-09 17:15:13.000000000 +1100
@@ -133,14 +133,11 @@ struct cache_deferred_req {
  * If "set" == 0 :
  *    If an entry is found, it is returned
  *    If no entry is found, a new non-VALID entry is created.
- * If "set" == 1 and INPLACE == 0 :
+ * If "set" == 1 :
  *    If no entry is found a new one is inserted with data from "template"
  *    If a non-CACHE_VALID entry is found, it is updated from template using UPDATE
  *    If a CACHE_VALID entry is found, a new entry is swapped in with data
  *       from "template"
- * If set == 1, and INPLACE == 1 :
- *    As above, except that if a CACHE_VALID entry is found, we UPDATE in place
- *       instead of swapping in a new entry.
  *
  * If the passed handle has the CACHE_NEGATIVE flag set, then UPDATE is not
  * run but insteead CACHE_NEGATIVE is set in any new item.
@@ -159,13 +156,8 @@ struct cache_deferred_req {
  * TEST  tests if "tmp" matches "item"
  * INIT copies key information from "item" to "new"
  * UPDATE copies content information from "item" to "tmp"
- * INPLACE is true if updates can happen inplace rather than allocating a new structure
- *
- * WARNING: any substantial changes to this must be reflected in
- *   net/sunrpc/svcauth.c(auth_domain_lookup)
- *  which is a similar routine that is open-coded.
  */
-#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE,INPLACE)	\
+#define DefineCacheLookup(RTN,MEMBER,FNAME,ARGS,SETUP,DETAIL,HASHFN,TEST,INIT,UPDATE)	\
 RTN *FNAME ARGS										\
 {											\
 	RTN *tmp, *new=NULL;								\
@@ -179,13 +171,13 @@ RTN *FNAME ARGS										\
 		tmp = container_of(*hp, RTN, MEMBER);					\
 		if (TEST) { /* found a match */						\
 											\
-			if (set && !INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
+			if (set && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new)	\
 				break;							\
 											\
 			if (new)							\
 				{INIT;}							\
 			if (set) {							\
-				if (!INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
+				if (test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
 				{ /* need to swap in new */				\
 					RTN *t2;					\
 											\
@@ -206,7 +198,7 @@ RTN *FNAME ARGS										\
 			else read_unlock(&(DETAIL)->hash_lock);				\
 			if (set)							\
 				cache_fresh(DETAIL, &tmp->MEMBER, item->MEMBER.expiry_time); \
-			if (set && !INPLACE && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
+			if (set && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
 			if (new) (DETAIL)->cache_put(&new->MEMBER, DETAIL);		\
 			return tmp;							\
 		}									\
@@ -239,10 +231,12 @@ RTN *FNAME ARGS										\
 	return NULL;									\
 }
 
-#define DefineSimpleCacheLookup(STRUCT,INPLACE)	\
-	DefineCacheLookup(struct STRUCT, h, STRUCT##_lookup, (struct STRUCT *item, int set), /*no setup */,	\
-			  & STRUCT##_cache, STRUCT##_hash(item), STRUCT##_match(item, tmp),\
-			  STRUCT##_init(new, item), STRUCT##_update(tmp, item),INPLACE)
+#define DefineSimpleCacheLookup(STRUCT, FUNC)				\
+        DefineCacheLookup(struct STRUCT, h, FUNC##_lookup,		\
+        (struct STRUCT *item, int set), /*no setup */,			\
+	& FUNC##_cache, FUNC##_hash(item), FUNC##_match(item, tmp),	\
+	STRUCT##_init(new, item), STRUCT##_update(tmp, item))
+
 
 #define cache_for_each(pos, detail, index, member) 						\
 	for (({read_lock(&(detail)->hash_lock); index = (detail)->hash_size;}) ;		\

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-03-09 17:13:54.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-03-09 17:15:13.000000000 +1100
@@ -259,7 +259,7 @@ static struct cache_detail rsi_cache = {
 	.cache_parse    = rsi_parse,
 };
 
-static DefineSimpleCacheLookup(rsi, 0)
+static DefineSimpleCacheLookup(rsi, rsi)
 
 /*
  * The rpcsec_context cache is used to store a context that is
@@ -446,7 +446,7 @@ static struct cache_detail rsc_cache = {
 	.cache_parse	= rsc_parse,
 };
 
-static DefineSimpleCacheLookup(rsc, 0);
+static DefineSimpleCacheLookup(rsc, rsc);
 
 static struct rsc *
 gss_svc_searchbyctx(struct xdr_netobj *handle)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2006-03-09 17:13:01.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2006-03-09 17:15:13.000000000 +1100
@@ -258,7 +258,7 @@ struct cache_detail ip_map_cache = {
 	.cache_show	= ip_map_show,
 };
 
-static DefineSimpleCacheLookup(ip_map, 0)
+static DefineSimpleCacheLookup(ip_map, ip_map)
 
 
 int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
