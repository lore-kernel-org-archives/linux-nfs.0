From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 10 - Make sure CACHE_NEGATIVE is cleared when a cache entry is updates.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004B3-Dw@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-00072I-Vc
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002yi-Gh
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:47 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:39 +1000
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


This is important for update-in-place caches which may change
from being negative to posative.

Thanks to "J. Bruce Fields" <bfields@fieldses.org>
and Olaf Kirch <okir@suse.de>

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2004-05-18 11:15:40.000000000 +1000
@@ -193,8 +193,11 @@ RTN *FNAME ARGS										\
 					t2 = tmp; tmp = new; new = t2;			\
 				}							\
 				if (test_bit(CACHE_NEGATIVE,  &item->MEMBER.flags))	\
-					 set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
-				else {UPDATE;}						\
+					set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
+				else {							\
+					UPDATE;						\
+					clear_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
+				}							\
 			}								\
 			if (set||new) write_unlock(&(DETAIL)->hash_lock);		\
 			else read_unlock(&(DETAIL)->hash_lock);				\


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
