From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 18] knfsd: svcrpc: remove another silent drop
	from deferral code
Date: Fri, 8 Dec 2006 12:14:02 +1100
Message-ID: <1061208011402.30651@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJC-00038E-Oa
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:50 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJC-0004wY-KB
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:52 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

There's no point deferring something just to immediately fail the deferral,
especially now that we can do something more useful in the failure case by
returning an error.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/cache.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff .prev/net/sunrpc/cache.c ./net/sunrpc/cache.c
--- .prev/net/sunrpc/cache.c	2006-12-08 12:09:12.000000000 +1100
+++ ./net/sunrpc/cache.c	2006-12-08 12:09:26.000000000 +1100
@@ -530,6 +530,13 @@ static int cache_defer_req(struct cache_
 	struct cache_deferred_req *dreq;
 	int hash = DFR_HASH(item);
 
+	if (cache_defer_cnt >= DFR_MAX) {
+		/* too much in the cache, randomly drop this one,
+		 * or continue and drop the oldest below
+		 */
+		if (net_random()&1)
+			return -ETIMEDOUT;
+	}
 	dreq = req->defer(req);
 	if (dreq == NULL)
 		return -ETIMEDOUT;
@@ -548,17 +555,8 @@ static int cache_defer_req(struct cache_
 	/* it is in, now maybe clean up */
 	dreq = NULL;
 	if (++cache_defer_cnt > DFR_MAX) {
-		/* too much in the cache, randomly drop
-		 * first or last
-		 */
-		if (net_random()&1) 
-			dreq = list_entry(cache_defer_list.next,
-					  struct cache_deferred_req,
-					  recent);
-		else
-			dreq = list_entry(cache_defer_list.prev,
-					  struct cache_deferred_req,
-					  recent);
+		dreq = list_entry(cache_defer_list.prev,
+				  struct cache_deferred_req, recent);
 		list_del(&dreq->recent);
 		list_del(&dreq->hash);
 		cache_defer_cnt--;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
