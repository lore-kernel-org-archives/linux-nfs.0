From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 4 - Allow sunrpc/svc cache init function to modify the "key"
Date: Fri, 21 Nov 2003 15:07:34 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AN2Zy-0002Sd-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AN2bO-0006gb-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Nov 2003 20:09:02 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AN2bN-0008Ug-UW
	for nfs@lists.sourceforge.net; Thu, 20 Nov 2003 20:09:02 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 21 Nov 2003 15:08:56 +1100
To: Linus Torvalds <torvalds@osdl.org>
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

This patch contains the 'infrastructure' that goes with patch 3 to fix the
'kmalloc failure not checked for' bug.

NeilBroown

### Comments for ChangeSet

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
--- ./include/linux/sunrpc/cache.h~current~	2003-11-21 15:01:48.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2003-11-21 15:04:44.000000000 +1100
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
+				 {INIT;}						\
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


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
