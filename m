From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 5 - Allow sunrpc/svc cache init function to modify the "key"
Date: Fri, 06 Feb 2004 16:13:18 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AoyIo-0007Fb-00@notabene>
References: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ4-0008Iq-TG
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ4-0003LM-4X
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:23 +1100
To: Andrew Morton <akpm@osdl.org>
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


When adding a item to a sunrpc/svc cache that contains kmalloced
data it is usefully to move the malloced data out of the key object
into the new cache object rather than copying (as then we would need to
cope with kmalloc failure and such).  This means modifying the original.

If the kmalloced data forms part of the key, then we must not move the data out until 
after the key isn't needed any more.  So this patch moves the call to "INIT" on a
new item (which fills in the key) to *after* the item has been found (or not), and
also makes sure we only call the HASH function once.
Thanks to  "J. Bruce Fields" <bfields@fieldses.org>

also

 1/ remove unnecessary assignment
 2/ fix comments that lag behind implementation.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2004-02-06 14:11:55.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2004-02-06 14:11:55.000000000 +1100
@@ -132,12 +132,14 @@ struct cache_deferred_req {
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
@@ -164,8 +166,8 @@ RTN *FNAME ARGS										\
 	RTN *tmp, *new=NULL;								\
 	struct cache_head **hp, **head;							\
 	SETUP;										\
- retry:											\
 	head = &(DETAIL)->hash_table[HASHFN];						\
+ retry:											\
 	if (set||new) write_lock(&(DETAIL)->hash_lock);					\
 	else read_lock(&(DETAIL)->hash_lock);						\
 	for(hp=head; *hp != NULL; hp = &tmp->MEMBER.next) {				\
@@ -175,6 +177,8 @@ RTN *FNAME ARGS										\
 			if (set && !INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
 				break;							\
 											\
+			if (new)							\
+				 {INIT;}						\
 			cache_get(&tmp->MEMBER);					\
 			if (set) {							\
 				if (!INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
@@ -203,6 +207,7 @@ RTN *FNAME ARGS										\
 	}										\
 	/* Didn't find anything */							\
 	if (new) {									\
+		INIT;									\
 		new->MEMBER.next = *head;						\
 		*head = &new->MEMBER;							\
 		(DETAIL)->entries ++;							\
@@ -224,8 +229,6 @@ RTN *FNAME ARGS										\
 	if (new) {									\
 		cache_init(&new->MEMBER);						\
 		cache_get(&new->MEMBER);						\
-		INIT;									\
-		tmp = new;								\
 		goto retry;								\
 	}										\
 	return NULL;									\


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
