Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout1-b.corp.re1.yahoo.com ([69.147.107.20]:29053 "EHLO
	mrout1-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155AbZLZU7T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2009 15:59:19 -0500
Received: from enemycanmeet.champ.corp.yahoo.com (enemycanmeet.champ.corp.yahoo.com [10.74.90.165])
	by mrout1-b.corp.re1.yahoo.com (8.13.8/8.13.8/y.out) with ESMTP id nBQKl1hH069719
	for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2009 12:47:02 -0800 (PST)
Received: from enemycanmeet.champ.corp.yahoo.com (localhost.localdomain [127.0.0.1])
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8) with ESMTP id nBQKjWkY003392
	for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2009 14:45:32 -0600
Received: (from qbarnes@localhost)
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8/Submit) id nBQKjVtS003391
	for linux-nfs@vger.kernel.org; Sat, 26 Dec 2009 14:45:31 -0600
Date: Sat, 26 Dec 2009 14:45:31 -0600
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: linux-nfs@vger.kernel.org
Subject: Random I/O over NFS has horrible performance due to small I/O transfers
Message-ID: <20091226204531.GA3356@yahoo-inc.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On the 24th I posted this note on LKML since it was a problem in the
VFS layer.  However, since NFS is mainly affected by this problem,
I'd bring it up here for discussion as well for those that don't
follow LKML.  At the time I posted it, I didn't set it up as a
cross-posted note.

Has this interaction between random I/O and NFS been noted before?
I searched back through the archive and didn't turn up anything.

Quentin

--

In porting some application code to Linux, its performance over
NFSv3 on Linux is terrible.  I'm posting this note to LKML since
the problem was actually tracked back to the VFS layer.

The app has a simple database that's accessed over NFS.  It always
does random I/O, so any read-ahead is a waste.  The app uses
O_DIRECT which has the side-effect of disabling read-ahead.

On Linux accessing an O_DIRECT opened file over NFS is much akin to
disabling its attribute cache causing its attributes to be refetched
from the server before each NFS operation.  After some thought,
given the Linux behavior of O_DIRECT on regular hard disk files to
ensure file cache consistency, frustratingly, that's probably the
more correct answer to emulate this file system behavior for NFS.
At this point, rather than expecting Linux to somehow change to
avoid the unnecessary flood of GETATTRs, I thought it best for the
app not to just use the O_DIRECT flag on Linux.  So I changed the
app code and then added a posix_fadvise(2) call to keep read-ahead
disabled.  When I did that, I ran into an unexpected problem.

Adding the posix_fadvise(..., POSIX_FADV_RANDOM) call sets
ra_pages=0.  This has a very odd side-effect in the kernel.  Once
read-ahead is disabled, subsequent calls to read(2) are now done in
the kernel via ->readpage() callback doing I/O one page at a time!

Pouring through the code in mm/filemap.c I see that the kernel has
commingled read-ahead and plain read implementations.  The algorithms
have much in common, so I can see why it was done, but it left this
anomaly of severely pimping read(2) calls on file descriptors with
read-ahead disabled.


For example, with a read(2) of 98K bytes of a file opened with
O_DIRECT accessed over NFSv3 with rsize=32768, I see:
=========
V3 ACCESS Call (Reply In 249), FH:0xf3a8e519
V3 ACCESS Reply (Call In 248)
V3 READ Call (Reply In 321), FH:0xf3a8e519 Offset:0 Len:32768
V3 READ Call (Reply In 287), FH:0xf3a8e519 Offset:32768 Len:32768
V3 READ Call (Reply In 356), FH:0xf3a8e519 Offset:65536 Len:32768
V3 READ Reply (Call In 251) Len:32768
V3 READ Reply (Call In 250) Len:32768
V3 READ Reply (Call In 252) Len:32768
=========

I would expect three READs issued of size 32K, and that's exactly
what I see.


For the same file without O_DIRECT but with read-ahead disabled
(its ra_pages=0), I see:
=========
V3 ACCESS Call (Reply In 167), FH:0xf3a8e519
V3 ACCESS Reply (Call In 166)
V3 READ Call (Reply In 172), FH:0xf3a8e519 Offset:0 Len:4096 
V3 READ Reply (Call In 168) Len:4096
V3 READ Call (Reply In 177), FH:0xf3a8e519 Offset:4096 Len:4096  
V3 READ Reply (Call In 173) Len:4096 
V3 READ Call (Reply In 182), FH:0xf3a8e519 Offset:8192 Len:4096
V3 READ Reply (Call In 178) Len:4096
[... READ Call/Reply pairs repeated another 21 times ...]
=========

Now I see 24 READ calls of 4K each!


A workaround for this kernel problem is to hack the app to do a
readahead(2) call prior to the read(2), however, I would think a
better approach would be to fix the kernel.  I came up with the
included patch that once applied restores the expected read(2)
behavior.  For the latter test case above of a file with read-ahead
disabled but now with the patch below applied, I now see:
=========
V3 ACCESS Call (Reply In 1350), FH:0xf3a8e519
V3 ACCESS Reply (Call In 1349)
V3 READ Call (Reply In 1387), FH:0xf3a8e519 Offset:0 Len:32768
V3 READ Call (Reply In 1421), FH:0xf3a8e519 Offset:32768 Len:32768
V3 READ Call (Reply In 1456), FH:0xf3a8e519 Offset:65536 Len:32768
V3 READ Reply (Call In 1351) Len:32768
V3 READ Reply (Call In 1352) Len:32768
V3 READ Reply (Call In 1353) Len:32768
=========

Which is what I would expect -- back to just three 32K READs.

After this change, the overall performance of the application
increased by 313%!


I have no idea if my patch is the appropriate fix.  I'm well out of
my area in this part of the kernel.  It solves this one problem, but
I have no idea how many boundary cases it doesn't cover or even if
it is the right way to go about addressing this issue.

Is this behavior of shorting I/O of read(2) considered a bug?  And
is this approach for a fix approriate?

Quentin


--- linux-2.6.32.2/mm/filemap.c	2009-12-18 16:27:07.000000000 -0600
+++ linux-2.6.32.2-rapatch/mm/filemap.c	2009-12-24 13:07:07.000000000 -0600
@@ -1012,9 +1012,13 @@ static void do_generic_file_read(struct 
 find_page:
 		page = find_get_page(mapping, index);
 		if (!page) {
-			page_cache_sync_readahead(mapping,
-					ra, filp,
-					index, last_index - index);
+			if (ra->ra_pages)
+				page_cache_sync_readahead(mapping,
+						ra, filp,
+						index, last_index - index);
+			else
+				force_page_cache_readahead(mapping, filp,
+						index, last_index - index);
 			page = find_get_page(mapping, index);
 			if (unlikely(page == NULL))
 				goto no_cached_page;



My test program used to gather the network traces above:
=========
#define _GNU_SOURCE 1
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int
main(int argc, char **argv)
{
	char	scratch[32768*3];
	int	lgfd;
	int	cnt;

	//if ( (lgfd = open(argv[1], O_RDWR|O_DIRECT)) == -1 ) {
	if ( (lgfd = open(argv[1], O_RDWR)) == -1 ) {
		fprintf(stderr, "Cannot open '%s'.\n", argv[1]);
		return 1;
	}

	posix_fadvise(lgfd, 0, 0, POSIX_FADV_RANDOM);
	//readahead(lgfd, 0, sizeof(scratch));
	cnt = read(lgfd, scratch, sizeof(scratch));
	printf("Read %d bytes.\n", cnt);
	close(lgfd);

	return 0;
}
=========
