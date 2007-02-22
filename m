From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Thu, 22 Feb 2007 13:42:08 -0600
Message-ID: <1172173328.18921.13.camel@hoeplx2923>
References: <45D9B915.2010305@hq.vsaa.lv>
	<17882.49990.799201.335846@notabene.brown> <45DC4BB3.7090706@imag.fr>
	<17884.65504.902843.745554@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKJpe-0001y6-Da
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 11:42:22 -0800
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HKJpd-0002er-7i
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 11:42:24 -0800
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [158.139.203.93])
	by mailman1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l1MJgAhq029841
	for <nfs@lists.sourceforge.net>; Thu, 22 Feb 2007 13:42:10 -0600
Received: from bvlexbh2.conoco.net (bvlexbh2.conoco.net [138.32.45.42])
	by mail1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l1MJg951015276
	for <nfs@lists.sourceforge.net>; Thu, 22 Feb 2007 13:42:09 -0600
In-Reply-To: <17884.65504.902843.745554@notabene.brown>
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


Neil,

I don't remember if I responded when you guys sent out the patch
originally.  It indeed helps the rewrite situation quite a bit with the
2.6.20 kernel.  Hopefully, it will help Jean-Noel's problem as well.
Thanks for getting that pushed through.

There is another issue, and I am not for sure where it is related.
About 18 months ago, we did some performance testing with our cluster
nodes, and noticed very good performance using iozone (good performance
meaning we had ~ 170 MB/s writes, even better for the rewrite mode, and
off the chart with read, due to caching of course).  Now, after a couple
of updates, we have noticed that our writes and reads are about the
same, but our rewrites using iozone are sometimes 1/2 of the performance
of the writes.  Also, during that time, the load average (10 nodes,
gigabit connected, server bonded dual gigabit to our core switch) is
anywhere from 15 to 32, and as it gets higher (closer to the 32), it can
cause the server to be really slow.  During this time, the disk io wait
is high, but processor load is low.  We have <>updated<> our clients
from an older 2.6.12.1 to a 2.6.14-ck1 patch, and the servers from a
2.6.11.7 to 2.6.14-ck1 as well.  Has there been some big changes in the
way clients or servers are requesting write information during an iozone
rewrite possibly.  If I truncate the file and rewrite from scratch, I
can almost always get the > 170 MB/s on the wire to my boxes...

So, the patch does now allow the iozones to complete, but there is still
a high load on the boxes.

Any testing or other information I can get that will help, please let me
know.

Pertinent Information:
64 bit servers and clients
FC3 and FC4 on the clients using 2.6.14 and later kernels
FC3 and FC6 on the servers using 2.6.14 and later kernels
All hosts are gigabit ethernet with the servers connected directly to
our core switches, and clients connected to gigabit edge switches that
are quad trunked back to the core (~ 64 nodes on the edge switch, but
all nodes are idle during the test).

Norman Weathers



On Thu, 2007-02-22 at 13:28 +1100, Neil Brown wrote:
> On Wednesday February 21, jean-noel.bouvier@imag.fr wrote:
> > Hello,
> > 
> > I encounter the same NFS bad performance for kernels newer than 2.6.16.31
> > 
> > Tests : tar -xvf linux-2.4.32.tar
> > 
> > Environment :
> > - client 2.6.16.31
> > - client mounts a XFS file system through NFS on a remote machine with
> > options = rw,tcp,intr
> > - server : exporting file system with options = rw,sync,insecure
> > 
> > Results : (according to server kernel version)
> > 2.6.15.7 => 1 minute 10 sec
> > 2.6.16.31 => 1 minute 02 sec
> > 2.6.17.14 => 15 minutes
> > 2.6.18.3 => 15 minutes
> 
> Those look like very strong results....
> 
> Could you try this patch on one of the later kernels and see if it
> helps?
> Otherwise we might have do to the 'git bisect' thing to find the
> offending patch.
> 
> Thanks,
> NeilBrown
> 
> 
> Status: ok
> 
> Stop NFSD writes from being broken into lots of little writes to filesystem.
> 
> When NFSD receives a write request, the data is typically in a number
> of 1448 byte segments and writev is used to collect them together.
> 
> Unfortunately, generic_file_buffered_write passes these to the filesystem
> one at a time, so an e.g. 32K over-write becomes a series of partial-page
> writes to each page, causing the filesystem to have to pre-read those
> pages - wasted effort.
> 
> generic_file_buffered_write handles one segment of the vector at a
> time as it has to pre-fault in each segment to avoid deadlocks.  When
> writing from kernel-space (and nfsd does) this is not an issue, so
> generic_file_buffered_write does not need to break and iovec from nfsd
> into little pieces.
> 
> This patch avoids the splitting when  get_fs is KERNEL_DS as it is
> from NFSd.
> 
> This issue was introduced by commit 6527c2bdf1f833cc18e8f42bd97973d583e4aa83
> 
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: Norman Weathers <norman.r.weathers@conocophillips.com>
> Cc: Vladimir V. Saveliev <vs@namesys.com>
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./.patches/current/mm/filemap.c |   32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
> 
> diff .prev/mm/filemap.c ./mm/filemap.c
> --- ./mm/filemap.c	2007-02-16 13:49:40.000000000 +1100
> +++ ./.patches/current/mm/filemap.c	2007-02-16 13:55:39.000000000 +1100
> @@ -2137,21 +2137,27 @@ generic_file_buffered_write(struct kiocb
>  		/* Limit the size of the copy to the caller's write size */
>  		bytes = min(bytes, count);
>  
> -		/*
> -		 * Limit the size of the copy to that of the current segment,
> -		 * because fault_in_pages_readable() doesn't know how to walk
> -		 * segments.
> +		/* We only need to worry about prefaulting when writes are from
> +		 * user-space.  NFSd uses vfs_writev with several non-aligned
> +		 * segments in the vector, and limiting to one segment a time is
> +		 * a noticeable performance for re-write
>  		 */
> -		bytes = min(bytes, cur_iov->iov_len - iov_base);
> -
> -		/*
> -		 * Bring in the user page that we will copy from _first_.
> -		 * Otherwise there's a nasty deadlock on copying from the
> -		 * same page as we're writing to, without it being marked
> -		 * up-to-date.
> -		 */
> -		fault_in_pages_readable(buf, bytes);
> +		if (!segment_eq(get_fs(), KERNEL_DS)) {
> +			/*
> +			 * Limit the size of the copy to that of the current
> +			 * segment, because fault_in_pages_readable() doesn't
> +			 * know how to walk segments.
> +			 */
> +			bytes = min(bytes, cur_iov->iov_len - iov_base);
>  
> +			/*
> +			 * Bring in the user page that we will copy from
> +			 * _first_.  Otherwise there's a nasty deadlock on
> +			 * copying from the same page as we're writing to,
> +			 * without it being marked up-to-date.
> +			 */
> +			fault_in_pages_readable(buf, bytes);
> +		}
>  		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
>  		if (!page) {
>  			status = -ENOMEM;
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
