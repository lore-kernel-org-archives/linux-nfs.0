From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 15 - Fix bug in RPC cache when entry in replaced
Date: Mon, 06 Jan 2003 11:05:03 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlL-0002XC-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlT-0002WJ-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:12 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:03 +1100
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



 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-01-06 09:52:01.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2003-01-06 09:52:01.000000000 +1100
@@ -171,7 +171,7 @@ RTN *FNAME ARGS										\
 					if (!new) break;				\
 											\
 					new->MEMBER.next = tmp->MEMBER.next;		\
-					*head = &new->MEMBER;				\
+					*hp = &new->MEMBER;				\
 					tmp->MEMBER.next = NULL;			\
 					set_bit(CACHE_HASHED, &new->MEMBER.flags);	\
 					clear_bit(CACHE_HASHED, &tmp->MEMBER.flags);	\


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
