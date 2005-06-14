From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 16:11:24 -0500
Message-ID: <EXCHG2003z3u92o0Ndq0000058f@EXCHG2003.microtech-ks.com>
References: <42AF3B6C.6070901@sohovfx.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIfc-00089Y-TH
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 14:10:04 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIfa-0003G8-BE
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 14:10:04 -0700
To: "'M. Todd Smith'" <todd@sohovfx.com>, <nfs@lists.sourceforge.net>
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


Using Suse Enterprise 9.0 single CPU Opteron server, with single
broadcom network interface, to a single test machine I can 
get 95MiB writes, 115Mib/second reads.    The test machine
is dual cpu, the server is single cpu, and has 2GB of ram.

If you are getting 45MB/second you don't need trunking.

The local IO speed of our setup was around your 135MB/second
on the writes, more like 185MB/second on the reads.

32kb block size was the best, no other significant changes
where made to nfs or to the kernel to get this number, the
network is clean.

I have seen a SAN slow down from what I believe is overloading.

How big of test did you run to get the 135MB/second local
speed?   My test above were done with many many TB of IO such
that the cache was a non-issue.    NFS normally runs sync so
cache is a non-issue, and sustained local performance is 
the real issue.

What is your actual local SAN disk setup like?

                        Roger
				Atipa Technologies




> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of M. Todd Smith
> Sent: Tuesday, June 14, 2005 3:18 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS tuning - high performance throughput.
> 
> Hello all,
> 
> I've been attempting to get a better hold over our NFS 
> performance as our network grows and grows.
> 
> We've recently upgraded our NFS server machine to a dual 
> 3.2ghz Xeon running Fedora Core 3 (kernel 2.6.11-1.14_FC3smp) 
> w/ 4Gb RAM.  Coupled with this machine we have a 2 Broadcom 
> NetExtreme 2 Port PCI-X NIC on its own PCI-X bus (133Mhz).  
> Attached to this machine is our fibre channel SAN, using 
> Seagate fibre-channel drives and an LSI dual channel 2gigabit 
> fibre adapter on its own PCI-X bus.  Local RW is ~135Mbytes/sec.
>  
> The 4 ports are trunked together using bonding (balanced 
> round robin mode), and trunked together on our Extreme 
> Networks Summit 400i switch.  
> All the test machines are attached to this switch, making 
> everything within one hop and ping times of less than a 200 
> nanoseconds.
> 
> Current test machine is running Suse 9.2 and has an Intel 
> 100/1000 XT server adapter (e1000 driver) on a shared but not 
> high traffic PCI bus.  
> Other test machines include some Dell PowerEdge 1850's with 
> onboard Intel NICs, and some Apple G4, G5 and Xserves.
> 
> I have read most of the tuning guides I can find on the net 
> and attempted just about everything I can get my hands on (I 
> have not tried jumbo frames yet, still waiting for some 
> downtime to attempt that).  My problem is that no matter how 
> I tune the machines I can get at max 45Mb/ps throughput on 
> NFS.  This was the same throughput we were getting with our 
> old server with PCI cards, moreover this throughput is 
> roughly the same for every machine on our network.  
> Theoretically we should be able to get much higher values.
> 
> Any idea as to why this is?  I can provide config files and 
> such if needed, but I'm really at a loss as to where to start.
> 
> Cheers
> Todd
> 
> --
> Systems Administrator
> ----------------------------------
> Soho VFX - Visual Effects Studio
> 99 Atlantic Avenue, Suite 303
> Toronto, Ontario, M6K 3J8
> (416) 516-7863
> http://www.sohovfx.com
> ----------------------------------
> 
> 
>  
> 
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration 
> Strategies from IBM. Find simple to follow Roadmaps, 
> straightforward articles, informative Webcasts and more! Get 
> everything you need to get up to speed, fast. 
> http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
