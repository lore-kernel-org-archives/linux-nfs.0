From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 4] Fix race with flushing nfsd cache.
Date: Fri, 20 Aug 2004 16:51:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1By3FQ-00073G-87@notabene.cse.unsw.edu.au>
References: <20040820164909.27056.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By3Fb-0004fd-CN
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By3Fa-0006oD-QM
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:47 -0700
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


To purge an nfsd-authentication cache, we set the flush time
to later than last-refresh time in the cache and call cache_flush.
The easiest way to find 'later than last-refresh' is 'now+1'.
This has two problems.
  1/ if the time-of-day clock has gone bacwards, some entries might not
     be purged
  2/ if a new entry is added in the same second as cache_purge ran, it will
     get ignored.

To resolve these issues, we set the flushtime to the maximum possible time 
before calling cache_flush, and then set it back to the minimum time afterwards.


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/cache.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2004-08-20 16:38:12.000000000 +1000
+++ ./net/sunrpc/cache.c	2004-08-20 16:47:36.000000000 +1000
@@ -400,9 +400,10 @@ void cache_flush(void)
 
 void cache_purge(struct cache_detail *detail)
 {
-	detail->flush_time = get_seconds()+1;
+	detail->flush_time = LONG_MAX;
 	detail->nextcheck = get_seconds();
 	cache_flush();
+	detail->flush_time = 1;
 }
 
 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
