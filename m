From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Stop NFSD writes from being broken into lots
	of little writes to filesystem.
Date: Tue, 13 Feb 2007 17:01:31 +1100
Message-ID: <1070213060131.3560@suse.de>
References: <20070213170049.3488.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	"Vladimir V . Saveliev" <vs@namesys.com>,
	Norman Weathers <norman.r.weathers@conocophillips.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGqk7-0008Sa-6e
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 22:02:19 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGqk7-0001uL-Ad
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 22:02:21 -0800
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

Another nfsd patch for 2.6.21...

### Comments for Changeset

When NFSD receives a write request, the data is typically in a number
of 1448 byte segments and writev is used to collect them together.

Unfortunately, generic_file_buffered_write passes these to the filesystem
one at a time, so an e.g. 32K over-write becomes a series of partial-page
writes to each page, causing the filesystem to have to pre-read those
pages - wasted effort.

generic_file_buffered_write handles one segment of the vector at a
time as it has to pre-fault in each segment to avoid deadlocks.  When
writing from kernel-space (and nfsd does) this is not an issue, so
generic_file_buffered_write does not need to break and iovec from nfsd
into little pieces.

This patch avoids the splitting when  get_fs is KERNEL_DS as it is
from NFSd.

This issue was introduced by commit 6527c2bdf1f833cc18e8f42bd97973d583e4aa83

Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Norman Weathers <norman.r.weathers@conocophillips.com>
Cc: Vladimir V. Saveliev <vs@namesys.com>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./mm/filemap.c |   32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff .prev/mm/filemap.c ./mm/filemap.c
--- .prev/mm/filemap.c	2007-02-13 16:53:19.000000000 +1100
+++ ./mm/filemap.c	2007-02-13 16:52:51.000000000 +1100
@@ -2160,21 +2160,27 @@ generic_file_buffered_write(struct kiocb
 		/* Limit the size of the copy to the caller's write size */
 		bytes = min(bytes, count);
 
-		/*
-		 * Limit the size of the copy to that of the current segment,
-		 * because fault_in_pages_readable() doesn't know how to walk
-		 * segments.
+		/* We only need to worry about prefaulting when writes are from
+		 * user-space.  NFSd uses vfs_writev with several non-aligned
+		 * segments in the vector, and limiting to one segment a time is
+		 * a noticeable performance for re-write
 		 */
-		bytes = min(bytes, cur_iov->iov_len - iov_base);
-
-		/*
-		 * Bring in the user page that we will copy from _first_.
-		 * Otherwise there's a nasty deadlock on copying from the
-		 * same page as we're writing to, without it being marked
-		 * up-to-date.
-		 */
-		fault_in_pages_readable(buf, bytes);
+		if (!segment_eq(get_fs(), KERNEL_DS)) {
+			/*
+			 * Limit the size of the copy to that of the current
+			 * segment, because fault_in_pages_readable() doesn't
+			 * know how to walk segments.
+			 */
+			bytes = min(bytes, cur_iov->iov_len - iov_base);
 
+			/*
+			 * Bring in the user page that we will copy from
+			 * _first_.  Otherwise there's a nasty deadlock on
+			 * copying from the same page as we're writing to,
+			 * without it being marked up-to-date.
+			 */
+			fault_in_pages_readable(buf, bytes);
+		}
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
 		if (!page) {
 			status = -ENOMEM;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
