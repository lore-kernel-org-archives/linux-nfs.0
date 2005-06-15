From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 13:47:01 -0400
Message-ID: <20050615174701.GC31465@ti64.telemetry-investments.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net> <42AF3B6C.6070901@sohovfx.com> <20050614204138.GG1175@ti64.telemetry-investments.com> <42AF5F0A.3080601@sohovfx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dibyn-0000b5-93
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 10:47:09 -0700
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dibym-0007MV-IL
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 10:47:09 -0700
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <42AF5F0A.3080601@sohovfx.com>
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

M. Todd Smith wrote:
> I'm not sure what a MiB/s is.  I've been using the following for testing 
> writes.

	MiB = 2^20 Bytes
 	MB  = 10^6 bytes

> time dd if=/dev/zero of=/mnt/array1/testfile5G.001 bs=512k count=10240

Small file and large file tests are by nature quite different, as are
cached and uncached reads and writes.

For a large file test, I'd use several times the RAM in your machine
(say 16-20GB).  For small file tests, 100-200MB.  To separate out the
effects of your SAN performance from knfsd performance, you may want to do
the small file test by exporting a (ext2) filesystem from a ramdisk, or
a loopback file mount in /dev/shm.  [Unfortunately, the tmpfs filesystem
doesn't implement the required methods directly, as it would be handy for
testing.]

For uncached reads/writes, consider using the new upstream coreutils:

ftp://alpha.gnu.org/gnu/coreutils/coreutils-5.3.0.tar.bz2

  dd has new iflag= and oflag= options with the following flags:

    append    append mode (makes sense for output file only)
    direct    use direct I/O for data
    dsync     use synchronized I/O for data
    sync      likewise, but also for metadata
    nonblock  use non-blocking I/O
    nofollow  do not follow symlinks
    noctty    do not assign controlling terminal from file 

[N.B.: NFS Direct-I/O requests > 16M may Oops on kernels prior to 2.6.11.]

> ttcp-r: 16777216 bytes in 0.141 real seconds = 115970.752 KB/sec +++

UDP result looks OK.  How about TCP?  What about packet reordering on
your bonded 4 port NIC?

> exec,dev,suid,rw,rsize=32768,wsize=32768,timeo=500,retrans=10,retry=60,bg 

UDP?

I wouldn't use UDP with such a large rsize/wsize -- that's two dozen
fragments on a 1500 MTU network!  You also have, due to the bonding,
an effectively mixed-speed network *and* packet reordering.

Have you looked at your interface statistics?  Does everything look
fine?

These days, I'd use TCP.  The Linux NFS TCP client is very mature,
and the NFS TCP server is working fine for me.  Linux NFS UDP fragment
handling / retry logic has long been a source of problems, particularly
across mixed-speed networks (e.g., 100/1000). TCP adapts automatically.
While TCP requires slightly more processing overhead, this should not be
an issue on modern CPUs.  Additionally, modern NICs like e1000 support
TSO (TCP Segmentation Offload), and though TSO has had its share of bugs,
it is the better path forward.

IMHO, packet reordering at the TCP layer is something that has received
attention in the Linux kernel, and there are ways to measure it and
compensate for it (via /proc/sys/net/ipv4/* tunables).  I'd much rather
try and understand the issue there than at either the IP fragment layer
or the kernel RPC layer.

> RAID 5, 4k strip size, XFS file system.
 
4K?  That's pretty tiny. OTOH, using too large a stripe with NFS over RAID5
can be no good either, if it results in partial writes that require a
read/modify/write cycle, so it is perhaps best not to go very large.
If your SAN gives you statistics about distribution of write sizes coming
from the NFS server, that would help in choosing a stripe size.

Sorry, I know very little about XFS.

> >
> >  o I/O scheduler
> >
> Not sure what you mean here.

The disk "elevator algorithm" - anticipatory, deadline, or cfq.

grep . /dev/null /sys/block/*/queue/scheduler 

IMHO, anticipatory is good for a workstation, but not so good for a file
server.  But that shouldn't iaffect on your sequential I/O tests.

> >  o queue depths (/sys/block/*/queue/nr_requests)
> 1024

Sane.
 
> >  o readahead (/sbin/blockdev --getra <device>)
> > 
> 256

You might want to compare a local sequential read test with

	/sbin/blockdev --setra {...,4096,8192,16384,...} <device>

Traffic on the linux-lvm list suggests increasing the readahead on the
logical device, and decreasing it on the underlying physical devices,
but your mileage may vary.

Setting it too high will pessimize random i/o performance.

> vm.vfs_cache_pressure = 100
> vm.nr_pdflush_threads = 2
> vm.dirty_expire_centisecs = 3000
> vm.dirty_writeback_centisecs = 500
> vm.dirty_ratio = 29
> vm.dirty_background_ratio = 7
 
Experience with Ext3 data journaling indicates that dropping expire/writeback
can help to smooth out I/O:

   vm.dirty_expire_centisecs = {300-1000}
   vm.dirty_writeback_centisecs = {50-100}

Again, I have no experience with XFS.  Since it only does meta-data journaling,
(equivalent of Ext3 data=writeback), its performance characteristics are probably
quite different.

Regards,

	Bill


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
