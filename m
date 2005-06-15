From: Greg Banks <gnb@sgi.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Thu, 16 Jun 2005 08:47:52 +1000
Message-ID: <20050615224752.GA18915@sgi.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net> <42AF3B6C.6070901@sohovfx.com> <20050614204138.GG1175@ti64.telemetry-investments.com> <42AF5F0A.3080601@sohovfx.com> <20050615174701.GC31465@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "M. Todd Smith" <todd@sohovfx.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Digfx-0007G6-SY
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 15:48:01 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Digfv-0006hY-Ez
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 15:48:01 -0700
To: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
In-Reply-To: <20050615174701.GC31465@ti64.telemetry-investments.com>
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

On Wed, Jun 15, 2005 at 01:47:01PM -0400, Bill Rugolsky Jr. wrote:
> These days, I'd use TCP.

Agreed.

> Additionally, modern NICs like e1000 support
> TSO (TCP Segmentation Offload), and though TSO has had its share of bugs,
> it is the better path forward.

Please don't tell him about TSO, it doesn't quite work yet ;-)

> > RAID 5, 4k strip size, XFS file system.
>  
> 4K?  That's pretty tiny.

It's extremely small.  We don't use anything less than 64KiB.  Use a
larger stripe size, and tell XFS what stripe size you're using so it
can align IOs correctly: RTFM about the options -d sunit, -d swidth,
-l sunit, and -l version to mkfs.xfs.  Also, make sure you align the
start of the XFS filesystem to a RAID stripe width; this may require
futzing with your volume manager config.

> OTOH, using too large a stripe with NFS over RAID5
> can be no good either, if it results in partial writes that require a
> read/modify/write cycle, so it is perhaps best not to go very large.

It depends on your workload; for pure streaming workloads larger stripe
is generally better up to a point determined by your filesystem, amount
of cache in your RAID controller, and other limitations.  We have
customer sites with 2MiB stripe sizes for local XFS fileystems, (*not*
for NFS service) and it works just fine.  But beware, on an NFS server
it's easier to get into the partial write case than with local IO.

> You might want to compare a local sequential read test with
> 
> 	/sbin/blockdev --setra {...,4096,8192,16384,...} <device>
> 
> Traffic on the linux-lvm list suggests increasing the readahead on the
> logical device, and decreasing it on the underlying physical devices,
> but your mileage may vary.

Agreed, I would try tuning upwards the logical block device's readahead.

> Experience with Ext3 data journaling indicates that dropping expire/writeback
> can help to smooth out I/O:
> 
>    vm.dirty_expire_centisecs = {300-1000}
>    vm.dirty_writeback_centisecs = {50-100}
> 

The performance limitation which is helped by tuning the VM to push
dirty pages earlier is in NFS not the underlying filesystem, so this
technique is useful with XFS too.

> Again, I have no experience with XFS.  Since it only does meta-data journaling,
> (equivalent of Ext3 data=writeback), its performance characteristics are probably
> quite different.

XFS also does a bunch of clever things (which I don't really understand)
to group IO going to disk and to limit metadata traffic for allocation.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
