From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 15 - Don't assume a reader on an RPC cache channel at statup.
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002XR-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlh-0002XS-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:25 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:04 +1100
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

Each cache channel remembers if there was a reader recently.
If there wasn't, then it doesn't bother with an up-call.
Currently, it initialises thinking there was a reader
recently incase the reader starts shortly afterwards.  However
this causes problems when a reader doesn't start soon, and
isn't necessary as the reader can easily be started before
the cache is initialised (e.g. before nfsd is started).





 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-01-06 09:54:47.000000000 +1100
+++ ./net/sunrpc/cache.c	2003-01-06 09:56:25.000000000 +1100
@@ -183,7 +183,7 @@ void cache_register(struct cache_detail 
 	cd->nextcheck = 0;
 	cd->entries = 0;
 	atomic_set(&cd->readers, 0);
-	cd->last_close = get_seconds();
+	cd->last_close = 0;
 	list_add(&cd->others, &cache_list);
 	spin_unlock(&cache_list_lock);
 }


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
