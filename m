From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] kNFSd - 2 of 5 - Allow sunrpc/svc cache init function to modify the "key"
Date: Sun, 8 Feb 2004 15:41:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208204101.GC27482@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org> <20040208055921.GA14053@fieldses.org> <20040208203018.GA27482@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Apvjr-0000SX-MN
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:41:11 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Apvjq-0000aw-Qf
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:41:11 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040208203018.GA27482@fieldses.org>
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


When adding a item to a sunrpc/svc cache that contains kmalloced data it is
useful to move the malloced data out of the key object into the new cache
object rather than copying (as then we would need to cope with kmalloc failure
and such).  This means modifying the original.

If the kmalloced data forms part of the key, then we must not move the data out
until after the key isn't needed any more.  So this patch moves the call to
"INIT" on a new item (which fills in the key) to *after* the item has been
found (or not), and also makes sure we only call the HASH function once.


 include/linux/sunrpc/cache.h |   13 ++++++++-----
 net/sunrpc/svcauth.c         |    6 +++++-
 2 files changed, 13 insertions(+), 6 deletions(-)

diff -puN include/linux/sunrpc/cache.h~neil_NfsdCacheImprove include/linux/sunrpc/cache.h
--- linux-2.6.1/include/linux/sunrpc/cache.h~neil_NfsdCacheImprove	2004-02-08 01:49:41.000000000 -0500
+++ linux-2.6.1-bfields/include/linux/sunrpc/cache.h	2004-02-08 01:49:41.000000000 -0500
@@ -130,12 +130,14 @@ struct cache_deferred_req {
  * If "set" == 0 :
  *    If an entry is found, it is returned
  *    If no entry is found, a new non-VALID entry is created.
- * If "set" == 1 :
+ * If "set" == 1 and INPLACE == 0 :
  *    If no entry is found a new one is inserted with data from "template"
  *    If a non-CACHE_VALID entry is found, it is updated from template using UPDATE
  *    If a CACHE_VALID entry is found, a new entry is swapped in with data
  *       from "template"
- * If set == 2, we UPDATE, but don't swap. i.e. update in place
+ * If set == 1, and INPLACE == 1 :
+ *    As above, except that if a CACHE_VALID entry is found, we UPDATE in place
+ *       instead of swapping in a new entry.
  *
  * If the passed handle has the CACHE_NEGATIVE flag set, then UPDATE is not
  * run but insteead CACHE_NEGATIVE is set in any new item.
@@ -162,8 +164,8 @@ RTN *FNAME ARGS										\
 	RTN *tmp, *new=NULL;								\
 	struct cache_head **hp, **head;							\
 	SETUP;										\
- retry:											\
 	head = &(DETAIL)->hash_table[HASHFN];						\
+ retry:											\
 	if (set||new) write_lock(&(DETAIL)->hash_lock);					\
 	else read_lock(&(DETAIL)->hash_lock);						\
 	for(hp=head; *hp != NULL; hp = &tmp->MEMBER.next) {				\
@@ -173,6 +175,8 @@ RTN *FNAME ARGS										\
 			if (set && !INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
 				break;							\
 											\
+			if (new)							\
+				{INIT;}							\
 			cache_get(&tmp->MEMBER);					\
 			if (set) {							\
 				if (!INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
@@ -201,6 +205,7 @@ RTN *FNAME ARGS										\
 	}										\
 	/* Didn't find anything */							\
 	if (new) {									\
+		INIT;									\
 		new->MEMBER.next = *head;						\
 		*head = &new->MEMBER;							\
 		(DETAIL)->entries ++;							\
@@ -222,8 +227,6 @@ RTN *FNAME ARGS										\
 	if (new) {									\
 		cache_init(&new->MEMBER);						\
 		cache_get(&new->MEMBER);						\
-		INIT;									\
-		tmp = new;								\
 		goto retry;								\
 	}										\
 	return NULL;									\
diff -puN net/sunrpc/svcauth.c~neil_NfsdCacheImprove net/sunrpc/svcauth.c
--- linux-2.6.1/net/sunrpc/svcauth.c~neil_NfsdCacheImprove	2004-02-08 01:49:41.000000000 -0500
+++ linux-2.6.1-bfields/net/sunrpc/svcauth.c	2004-02-08 01:49:41.000000000 -0500
@@ -150,7 +150,11 @@ DefineCacheLookup(struct auth_domain,
 		  &auth_domain_cache,
 		  auth_domain_hash(item),
 		  auth_domain_match(tmp, item),
-		  kfree(new); if(!set) return NULL;
+		  kfree(new); if(!set) {
+		  if (new) write_unlock(&auth_domain_cache.hash_lock);
+		  else read_unlock(&auth_domain_cache.hash_lock);
+		  return NULL;
+		  }
 		  new=item; atomic_inc(&new->h.refcnt),
 		  /* no update */,
 		  0 /* no inplace updates */

_


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
