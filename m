From: Eric Whiting <ewhiting@amis.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 17:05:03 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DAC9F1F.4B254A4D@amis.com>
References: <5CA6F03EF05E0046AC5594562398B9160C773F@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181ajm-0003ps-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 16:04:30 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

"Heflin, Roger A." wrote:
> 
> After doing some reading I figured out my mistake.
> 
> Others had told me that it ran 4 pairs at 125Mhz each, and that it
> worked just like 100BT (1 bit per clock cycle), apparently they are
> sending 2bit per cycle so 2 bits x 125Mhz * 4 channels is
> 1Gbps, if they were only using 1 bit per cycle it would be
> only 50MB/second.
> 
> What is your underlying setup to get the 93MB/second,
> ie disks/controllers/cpus?

Going OT here...
That 93MB/s is with an odd mix of systems:

1. AMD MP 2000+ dual 
   Tyan Motherboard
   3G RAM
   Netgear GA620
 
2. Intel Xeon 2.2G dual
   ? Motherboard	
   4G RAM
   Motherboard Intel gigE

gigE nics are tied together with a crossover cable.

boxes were not idle, disks are slow, but ftp of a 1G file shows 93MB/s.
I'm sure others could do better -- I think I could do better.  Actually
given my disks on those boxes I have to put to /dev/null to see the
93MB/s...  Linux ide-raid list shows people with disks running 100+MB/s
-- my disks are not that fast...

eric


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
