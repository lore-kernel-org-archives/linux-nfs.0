From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: fix possible read-ahead cache and export
	table	corruption
Date: Thu, 12 Jul 2007 22:44:20 -0400
Message-ID: <20070713024420.GA31364@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Greg Banks <gnb@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9B8n-0005Jr-Pk
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 19:44:21 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9B8q-00079m-8H
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 19:44:25 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

The value of nperbucket calculated here is too small--we should be
rounding up instead of down--with the result that the index j in the
following loop can overflow the raparm_hash array.  At least in my case,
the next thing in memory turns out to be export_table, so the symptoms I
see are crashes in cache_put caused by the appearance of four zeroed-out
export entries in the first bucket of the hash table of exports (which
were actually entries in the readahead cache, a pointer to which had
been written to the export table in this initialization code).

It looks like the bug was probably introduced with commit
fce1456a19f5c08b688c29f00ef90fdfa074c79b ("knfsd: make the readahead
params cache SMP-friendly").

Cc: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

OK, that was painful.  I need a less dumb debugging method than "test,
stare at the code for a long time, insert 20 more printk's, test
again...".

Anyway, it might explain a few other reports of export table corruption
that I hadn't previously been able to reproduce.

The code could be a little more straightforward here.   Could we just
round up cache_size to a multiple of RAPARM_HASH_SIZE, make all the hash
chains the same length, and just use them as arrays?  The p_next
pointers seem like a unnecessary complication.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7e50da0..dd3604e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1885,7 +1885,7 @@ nfsd_racache_init(int cache_size)
 		raparm_hash[i].pb_head = NULL;
 		spin_lock_init(&raparm_hash[i].pb_lock);
 	}
-	nperbucket = cache_size >> RAPARM_HASH_BITS;
+	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
 	for (i = 0; i < cache_size - 1; i++) {
 		if (i % nperbucket == 0)
 			raparm_hash[j++].pb_head = raparml + i;
-- 
1.5.3.rc0.63.gc956


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
