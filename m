From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: BUG: unable to handle kernel paging request at
	virtual	address 6b6b6b6f
Date: Fri, 13 Jul 2007 23:07:25 -0400
Message-ID: <20070714030725.GD16644@fieldses.org>
References: <20070703071735.GA9481@janus> <20070703193937.GM14074@fieldses.org>
	<20070703202216.GB16497@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Xyf-0005zC-0a
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 20:07:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Xyi-0004bI-DK
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 20:07:28 -0700
In-Reply-To: <20070703202216.GB16497@janus>
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

On Tue, Jul 03, 2007 at 10:22:16PM +0200, Frank van Maarseveen wrote:
> On Tue, Jul 03, 2007 at 03:39:37PM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 03, 2007 at 09:17:35AM +0200, Frank van Maarseveen wrote:
> > > I've reported this earlier but now I figured out how to reproduce it:
> > > start nfsd with 50 instances and then try to stop it.
> > 
> > So, all it takes is this?:
> > 
> > 	rpc.nfsd 50
> > 	rpc.nfsd 0
> 
> I guess so: On debian etch I adapted /etc/defaults/nfs-kernel-server
> (IIRC) to start 50 daemons and after a reboot it sufficed to type
> /etc/init.d/nfs-kernel-server stop to make it say BUG. Very reproducable
> here (5 machines).

Could you try this?

--b.

>From b941e6b14f6cf53c6dea17cfb80c5619304afe99 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Thu, 12 Jul 2007 22:17:34 -0400
Subject: [PATCH] nfsd: fix possible read-ahead cache and export table corruption

The value of nperbucket calculated here is too small--we should be
rounding up instead of down--with the result that the index j in the
following loop can overflow the raparm_hash array.  At least in my case,
the next thing in memory turns out to be export_table, so the symptoms I
see are crashes caused by the appearance of four zeroed-out export
entries in the first bucket of the hash table of exports (which were
actually entries in the readahead cache, a pointer to which had been
written to the export table in this initialization code).

It looks like the bug was probably introduced with commit
fce1456a19f5c08b688c29f00ef90fdfa074c79b ("knfsd: make the readahead
params cache SMP-friendly").

Cc: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
