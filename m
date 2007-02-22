From: Neil Brown <neilb@suse.de>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Thu, 22 Feb 2007 13:28:48 +1100
Message-ID: <17884.65504.902843.745554@notabene.brown>
References: <45D9B915.2010305@hq.vsaa.lv>
	<17882.49990.799201.335846@notabene.brown>
	<45DC4BB3.7090706@imag.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: rich@hq.vsaa.lv, nfs@lists.sourceforge.net
To: Jean-Noel Bouvier <jean-noel.bouvier@imag.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HK3iP-0003dO-Ni
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 18:29:49 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HK3iR-0008Ii-8I
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 18:29:51 -0800
In-Reply-To: message from Jean-Noel Bouvier on Wednesday February 21
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

On Wednesday February 21, jean-noel.bouvier@imag.fr wrote:
> Hello,
> 
> I encounter the same NFS bad performance for kernels newer than 2.6.16.31
> 
> Tests : tar -xvf linux-2.4.32.tar
> 
> Environment :
> - client 2.6.16.31
> - client mounts a XFS file system through NFS on a remote machine with
> options = rw,tcp,intr
> - server : exporting file system with options = rw,sync,insecure
> 
> Results : (according to server kernel version)
> 2.6.15.7 => 1 minute 10 sec
> 2.6.16.31 => 1 minute 02 sec
> 2.6.17.14 => 15 minutes
> 2.6.18.3 => 15 minutes

Those look like very strong results....

Could you try this patch on one of the later kernels and see if it
helps?
Otherwise we might have do to the 'git bisect' thing to find the
offending patch.

Thanks,
NeilBrown


Status: ok

Stop NFSD writes from being broken into lots of little writes to filesystem.

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
 ./.patches/current/mm/filemap.c |   32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff .prev/mm/filemap.c ./mm/filemap.c
--- ./mm/filemap.c	2007-02-16 13:49:40.000000000 +1100
+++ ./.patches/current/mm/filemap.c	2007-02-16 13:55:39.000000000 +1100
@@ -2137,21 +2137,27 @@ generic_file_buffered_write(struct kiocb
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
