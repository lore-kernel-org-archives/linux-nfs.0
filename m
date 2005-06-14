From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 16:50:19 -0400
Message-ID: <20050614205019.GA6358@ti64.telemetry-investments.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net> <42AF3B6C.6070901@sohovfx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIMd-0006xK-7y
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:50:27 -0700
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIMb-00005X-Iu
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:50:27 -0700
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <42AF3B6C.6070901@sohovfx.com>
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

[Apologies for the resend; mutt chose the wrong From address the first time.]

On Tue, Jun 14, 2005 at 04:17:48PM -0400, M. Todd Smith wrote:
> We've recently upgraded our NFS server machine to a dual 3.2ghz Xeon 
> running Fedora Core 3 (kernel 2.6.11-1.14_FC3smp) w/ 4Gb RAM.  Coupled 
> with this machine we have a 2 Broadcom NetExtreme 2 Port PCI-X NIC on 
> its own PCI-X bus (133Mhz).  Attached to this machine is our fibre 
> channel SAN, using Seagate fibre-channel drives and an LSI dual channel 
> 2gigabit fibre adapter on its own PCI-X bus.  Local RW is ~135Mbytes/sec.

...
 
> I have read most of the tuning guides I can find on the net and 
> attempted just about everything I can get my hands on (I have not tried 
> jumbo frames yet, still waiting for some downtime to attempt that).  My 
> problem is that no matter how I tune the machines I can get at max 
> 45Mb/ps throughput on NFS.  This was the same throughput we were getting 
> with our old server with PCI cards, moreover this throughput is roughly 
> the same for every machine on our network.  Theoretically we should be 
> able to get much higher values.

I assume that you mean 45 MiB/s?  Reading or writing?  What are you
using for testing?  What are the file sizes?
 
Have you validated network throughput using ttcp or netperf?

You say that you've read the tuning guides, but you haven't told us what
you have touched.  Please tell us:

   o client-side NFS mount options

   o RAID configuration (level, stripe size, etc.)

   o I/O scheduler

   o queue depths (/sys/block/*/queue/nr_requests)

   o readahead (/sbin/blockdev --getra <device>)

   o mount options (e.g., are you using noatime)

   o filesystem type

   o journaling mode, if Ext3 or Reiserfs

   o journal size

   o internal or external journal

   o vm tunables:

      vm.dirty_writeback_centisecs
      vm.dirty_expire_centisecs
      vm.dirty_ratio
      vm.dirty_background_ratio
      vm.nr_pdflush_threads
      vm.vfs_cache_pressure

Regards,

	Bill Rugolsky



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
