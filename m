From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] kNFSd - 1 of 5 - Fix possible scheduling_while_atomic in cache.c
Date: Sun, 8 Feb 2004 15:38:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208203826.GB27482@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org> <20040208055921.GA14053@fieldses.org> <20040208203018.GA27482@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApvhK-00070y-00
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:38:34 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ApvhJ-0004oI-Ak
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:38:33 -0800
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


We currently call cache_put, which can schedule(), under a spin_lock.  This
patch moves that call outside the spinlock.

(From neilb)


 net/sunrpc/cache.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff -puN net/sunrpc/cache.c~neil_cache_clean_fix net/sunrpc/cache.c
--- linux-2.6.1/net/sunrpc/cache.c~neil_cache_clean_fix	2004-02-08 13:54:07.000000000 -0500
+++ linux-2.6.1-bfields/net/sunrpc/cache.c	2004-02-08 13:54:07.000000000 -0500
@@ -314,6 +314,7 @@ int cache_clean(void)
 	
 	if (current_detail && current_index < current_detail->hash_size) {
 		struct cache_head *ch, **cp;
+		struct cache_detail *d;
 		
 		write_lock(&current_detail->hash_lock);
 
@@ -343,12 +344,14 @@ int cache_clean(void)
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

_


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
