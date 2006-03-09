From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 14] knfsd: An assortment of little fixes to the sunrpc cache code.
Date: Thu, 9 Mar 2006 17:52:19 +1100
Message-ID: <1060309065219.24647@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF1X-0000g2-Cq
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:23 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF1W-0000Lo-R1
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:23 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


- in cache_check, h must be non-NULL as it has been de-referenced,
  so don't bother checking for NULL.

- When a cache-item is updated, we need to call cache_revisit_request to see
  if there is a pending request waiting for that item.  We were using
  a transition to CACHE_VALID to see if that was needed, however that is
  wrong as an expired entry will still be marked 'valid' (as the data is valid 
  and will need to be released).  So instead use an off transition for
  CACHE_PENDING which is exactly the right thing to test.

- Add a little bit more debugging info.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/cache.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2006-03-09 17:29:35.000000000 +1100
+++ ./net/sunrpc/cache.c	2006-03-09 17:30:20.000000000 +1100
@@ -208,7 +208,7 @@ int cache_check(struct cache_detail *det
 	if (rv == -EAGAIN)
 		cache_defer_req(rqstp, h);
 
-	if (rv && h)
+	if (rv)
 		detail->cache_put(h, detail);
 	return rv;
 }
@@ -223,8 +223,10 @@ void cache_fresh(struct cache_detail *de
 	head->last_refresh = get_seconds();
 	if (!test_and_set_bit(CACHE_VALID, &head->flags))
 		cache_revisit_request(head);
-	if (test_and_clear_bit(CACHE_PENDING, &head->flags))
+	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
+		cache_revisit_request(head);
 		queue_loose(detail, head);
+	}
 }
 
 /*
@@ -551,7 +553,7 @@ static void cache_defer_req(struct cache
 		/* there was one too many */
 		dreq->revisit(dreq, 1);
 	}
-	if (test_bit(CACHE_VALID, &item->flags)) {
+	if (!test_bit(CACHE_PENDING, &item->flags)) {
 		/* must have just been validated... */
 		cache_revisit_request(item);
 	}
@@ -892,7 +894,7 @@ static void queue_loose(struct cache_det
 			if (cr->item != ch)
 				continue;
 			if (cr->readers != 0)
-				break;
+				continue;
 			list_del(&cr->q.list);
 			spin_unlock(&queue_lock);
 			detail->cache_put(cr->item, detail);
@@ -1180,8 +1182,8 @@ static int c_show(struct seq_file *m, vo
 		return cd->cache_show(m, cd, NULL);
 
 	ifdebug(CACHE)
-		seq_printf(m, "# expiry=%ld refcnt=%d\n",
-			   cp->expiry_time, atomic_read(&cp->refcnt));
+		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
+			   cp->expiry_time, atomic_read(&cp->refcnt), cp->flags);
 	cache_get(cp);
 	if (cache_check(cd, cp, NULL))
 		/* cache_check does a cache_put on failure */


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
