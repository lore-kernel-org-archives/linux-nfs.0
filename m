From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 8 - Fix bug in rpc cache_clean introduced by previous patch
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001q1-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhx-0007Rm-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:13 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:54:56 +1000
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

8 patches for kNFSd in 2.5.latest.  Several relating to the export cache.
Thanks,
NeilBrown
### Comments for ChangeSet

Having a 'continue' at the end of this look it pointless... it should
be a break.


 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-06-24 12:37:38.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-06-24 12:46:24.000000000 +1000
@@ -319,8 +319,8 @@ int cache_clean(void)
 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
 				queue_loose(current_detail, ch);
 
-			if (atomic_read(&ch->refcnt))
-				continue;
+			if (!atomic_read(&ch->refcnt))
+				break;
 		}
 		if (ch) {
 			cache_get(ch);


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
