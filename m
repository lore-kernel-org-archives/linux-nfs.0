From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 7 - Change atomic_inc to cache_get twice.
Date: Tue, 05 Aug 2003 13:59:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyp-0000nG-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsyz-0001hc-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:34 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:28 +1000
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

### Comments for ChangeSet

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-08-04 11:34:43.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2003-08-04 11:34:43.000000000 +1000
@@ -173,7 +173,7 @@ RTN *FNAME ARGS										\
 			if (set && !INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
 				break;							\
 											\
-			atomic_inc(&tmp->MEMBER.refcnt);				\
+			cache_get(&tmp->MEMBER);					\
 			if (set) {							\
 				if (!INPLACE && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
 				{ /* need to swap in new */				\
@@ -221,7 +221,7 @@ RTN *FNAME ARGS										\
 	new = kmalloc(sizeof(*new), GFP_KERNEL);					\
 	if (new) {									\
 		cache_init(&new->MEMBER);						\
-		atomic_inc(&new->MEMBER.refcnt);					\
+		cache_get(&new->MEMBER);						\
 		INIT;									\
 		tmp = new;								\
 		goto retry;								\


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
