From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 5 - Fix possible scheduling_while_atomic in cache.c
Date: Fri, 06 Feb 2004 16:13:17 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AoyIn-0007FJ-00@notabene>
References: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ3-0008Hx-J1
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:33 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ3-0004gi-6Q
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:21 +1100
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


We currently call cache_put, which can schdule(),
under a spin_lock. 
This patch moves that call outside the spinlock.

 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2004-02-06 14:11:14.000000000 +1100
+++ ./net/sunrpc/cache.c	2004-02-06 14:11:14.000000000 +1100
@@ -325,6 +325,7 @@ int cache_clean(void)
 	
 	if (current_detail && current_index < current_detail->hash_size) {
 		struct cache_head *ch, **cp;
+		struct cache_detail *d;
 		
 		write_lock(&current_detail->hash_lock);
 
@@ -354,12 +355,14 @@ int cache_clean(void)
 			rv = 1;
 		}
 		write_unlock(&current_detail->hash_lock);
-		if (ch)
-			current_detail->cache_put(ch, current_detail);
-		else
+		d = current_detail;
+		if (!ch)
 			current_index ++;
-	}
-	spin_unlock(&cache_list_lock);
+		spin_unlock(&cache_list_lock);
+		if (ch)
+			d->cache_put(ch, d);
+	} else
+		spin_unlock(&cache_list_lock);
 
 	return rv;
 }


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
