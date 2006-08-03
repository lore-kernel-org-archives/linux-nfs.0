From: Neil Brown <neilb@suse.de>
Subject: [PATCH for stable] Re: [Fwd: moradin 2006-08-02 11:02 System
	Events]
Date: Thu, 3 Aug 2006 10:20:12 +1000
Message-ID: <17617.16700.274788.869486@cse.unsw.edu.au>
References: <44D08371.9070607@svs.Informatik.Uni-Oldenburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org, nfs@lists.sourceforge.net, stable@kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8Qwp-0005iM-TE
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 17:20:24 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8Qwo-00048f-R1
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 17:20:24 -0700
To: Philipp Matthias Hahn <pmhahn@svs.Informatik.Uni-Oldenburg.de>
In-Reply-To: message from Philipp Matthias Hahn on Wednesday August 2
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

On Wednesday August 2, pmhahn@svs.Informatik.Uni-Oldenburg.de wrote:
> Hello!
> 
> Rebooting one of our NFS file servers with 2.6.17.7, I just got the
> following OOPS:

Thanks for the report.
The bug was fairly easy to find and fix.
I think this would be appropriate for the next 2.6.17.x stable kernel,
and definitely for 2.6.18. (hence 'akpm' and 'stable' cc:ed).

It is not relevant for earlier kernels (e.g. 2.6.16).

Patch was made against 2.6.18-rc2-mm1, but applies equally to
2.6.17.7.

Thanks again,
NeilBrown


---------------------------------------------
Fix race related problem when adding items to and svcrpc auth cache.

If we don't find the item we are lookng for, we allocate a new one,
and then grab the lock again and search to see if it has been added
while we did the alloc.
If it had been added we need to 'cache_put' the newly created item 
that we are never going to use.  But as it hasn't been initialised
properly, putting it can cause an oops.

So move the ->init call earlier to that it will always be fully
initilised if we have to put it.

Thanks to Philipp Matthias Hahn <pmhahn@svs.Informatik.Uni-Oldenburg.de>
for reporting the problem.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/cache.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff .prev/net/sunrpc/cache.c ./net/sunrpc/cache.c
--- .prev/net/sunrpc/cache.c	2006-08-03 10:07:33.000000000 +1000
+++ ./net/sunrpc/cache.c	2006-08-03 10:08:36.000000000 +1000
@@ -71,7 +71,12 @@ struct cache_head *sunrpc_cache_lookup(s
 	new = detail->alloc();
 	if (!new)
 		return NULL;
+	/* must fully initialise 'new', else
+	 * we might get lose if we need to
+	 * cache_put it soon.
+	 */
 	cache_init(new);
+	detail->init(new, key);
 
 	write_lock(&detail->hash_lock);
 
@@ -85,7 +90,6 @@ struct cache_head *sunrpc_cache_lookup(s
 			return tmp;
 		}
 	}
-	detail->init(new, key);
 	new->next = *head;
 	*head = new;
 	detail->entries++;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
