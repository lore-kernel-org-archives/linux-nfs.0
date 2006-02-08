From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Tuning NFS for Maximum Thought put?
Date: Wed, 08 Feb 2006 20:12:54 +1100
Message-ID: <1139389974.31913.1430.camel@hole.melbourne.sgi.com>
References: <DDBAA550DD134B4197BEC287924809604F29FF@SBS-REASON.REASON.OFFICE>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6lNp-00087h-KA
	for nfs@lists.sourceforge.net; Wed, 08 Feb 2006 01:13:05 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6lNo-00030x-42
	for nfs@lists.sourceforge.net; Wed, 08 Feb 2006 01:13:05 -0800
To: Dominic Daninger <ddaninger@reasonco.com>
In-Reply-To: <DDBAA550DD134B4197BEC287924809604F29FF@SBS-REASON.REASON.OFFICE>
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

On Tue, 2006-02-07 at 09:20, Dominic Daninger wrote:
> We are working on trying to get maximum throughput from and NFS server
> for both Read and Write over bonded dual GigE NIC's.
>  
> The configuration is:
> 
> 
> SuperMicro H8DAE Motherboard
> 
> 
> Dual Opteron 248's
> 
> 
> 4GB of DDR400
> 
> 
> Areca 1130 PCI-X 12-port RAID 6 Controller
> 
> 
> Fedora Core 4 OS

You haven't mentioned which filesystem you're using on the server,
what the export options are, and what the client's mount options
are.

> 
> 
> Dual integrated Broadcom 5704C 1Gbit NICs with Linux round robin
> bonding, and 9KB jumbo frames.
> 
> 
> 12 WD RAID Edition II 400GB SATA Drives
> 
> 
> The basic problem is we have what appears to be an I/O bottleneck that
> is preventing us from serving over the network more that 100MB/s via
> NFS using either TCP or UDP. What I would like to know if 150MB/s
> sequential read or 150MB/s sequential write or greater is possible
> with this OS & HW combination .

You won't get much better than that using UDP, it's limited by
the single UDP socket the server uses for all traffic.  With TCP
you should expect to do better, depending on hardware.

>  I know that it should be based on theoretical bandwidth of the buses,

;-)

>  but we are only seeing about 1/3 of the theoretical right now. Local
> write and read tests of 10GB files consistently show file write rates
> of 300+MB/s and file reads of 260+MB/s. We had also tried a single
> Areca 1170 24-port controller earlier and we go local reads of 300MB/s
> and local writes of 150MB/s.
> 
> 
>  Results of netperf testing 8k message size and with linux kernel
> parameters tuned
> 
> 
> Test using 1 Gigabit Ethernet connection
> 
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3 
> 
> (192.168.1.3) port 0 AF_INET
> 
> Recv     Send     Send
> 
> Socket  Socket     Message     Elapsed
> 
> Size     Size     Size     Time     Throughput
> 
> bytes bytes bytes secs.         10^6bits/sec
> 
> 87380 65536 65536 10.10         908.66
> 
>  
> 
> Test using 2 Gigabit Ethernet connection (bonded)
> 
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3
> 
> (192.168.1.3) port 0 AF_INET
> 
> Recv Send Send Socket Socket Message Elapsed
> 
> Size Size Size Time Throughput
> 
> bytes bytes bytes secs. 10^6bits/sec
> 
> 256000 128000 128000 10.01 1580.06

Ok, so you have a network throughput problem.

Some PCI bridges have problems dealing with traffic from both of
the ports on a 5704 at the same time.  Have you run netperf tests
with both ports as separate devices, i.e. *not* bonded?  If you
still get 1580 rather than ~1800, it's time to buy new hardware.

Otherwise, there are a couple of bonding patches which have
helped in similar configs.  I don't know if FC4 has either
of them, perhaps Steve Dickson comment...

This patch reduces CPU usage and improves throughput on wide bonds.
It might help.

http://linus.bkbits.net:8080/linux-2.5/gnupatch@4240d81dj0OOnMm2Qk7ASVvRsnCRNg

This patch stops the bonding device carelessly disabling TCP/IP
zero-copy, which feature really helps NFS throughput with tg3's.

http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8531c5ffbca65f6df868637c26e6df6f88bff738

> 
> Other test results are indicative of bottlenecks on the motherboard,
> although that wasn't immediately apparent. Combined throughput from
> client machines never exceeded 100 MB/s write through NFS. However,
> while the network test is taking place, a local test can be run and
> reach write speeds of 180 MB/s while the network speeds stay the same.

Which filesystem?

>  Throughput has remained roughly the same whether the clients connect
> to the same bond, to different IPs on different cards, point-to-point
> with cross-over or using switches.
> 
> Testing of the two GigE bond connections complete successfully and a
> sustained throughput of 1580 Mbps.
> 
> We have done a lot of work with Broadcom's BCM5700 driver to moderate
> the NIC interrupts and tune various buffers. We have been able to cut
> interrupts from over 20,000/s to about 6000/s.

Good.  Plus you're using 9K frames, which also helps.

> Context switches are still high however and our maximum NFS throughput
> is still about 100MB/sec.

You should expect context switch rates to be about twice the number
of RPC calls per second.  How much CPU are you using during NFS tests?

> 
> Any ideas out there regarding how to tune NFS for better throughput?

Have you bound the NIC IRQs?

Greg. 
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
