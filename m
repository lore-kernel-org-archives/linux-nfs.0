From: Tim Southerwood <ts@dionic.net>
Subject: Optimising NFS
Date: Tue, 01 Nov 2005 14:50:36 +0000
Message-ID: <1130856636.25420.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ts@dionic.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWyX5-0000iK-Fu
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 07:58:43 -0800
Received: from mothra.dionic.net ([81.2.78.41] helo=smtp.dionic.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EWyX4-00054B-3E
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 07:58:43 -0800
To: nfs@lists.sourceforge.net
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

Subject:      Optimising NFS
From:         Tim S <ts@dionic.net>
Newsgroups:   uk.comp.os.linux
Date:         Mon, 31 Oct 2005 23:09:19 +0000

Hi

Here's a challenge; I'm in the process of building an NFS server...

The general idea is that it should go as fast as possible
serving read-only mostly unchanging content (it's my install server).

I have a dual Xeon 3GHz server with 9GB Ram and a quad intel e1000
server class card... I applied various tuning to the IP stack, e1000
driver and bonded the 4 gig links to the switch (We use Extreme switches
with 10Gig interconnects, so I am not expecting bottlnecks in teh
network infrastructure).

So far it tops out at 190MB/sec serving a DVD ISO to a load of test
clients with gig connections, cpu's running at 100%. Most of the load
comes from 4 other servers on the same switch. Extra load is applied
from more remote clients (upto 90 gig connected clients in this case).

Thus I was hoping for rather more (like saturating the 4gig bonded
channel), given the file in question is proven to be entirely in buffer
cache at this point (disk channel load is practically zero).

Have any NFS experts here got any tips or experience at achieving higher
throughput?

The tuning parameters I have applied are:

1) Set the e1000 driver to interrupt throttle at 2000/sec per NIC
(default is 8000/sec)

2) Set IRQ affinity so that each NIC's interrupts are serviced
by a different hyperthreaded CPU instance spread over both CPUs

3) These settings (taken from an IBM document on tuning NFS and
gratuitously increased in places)

ethtool -G eth2 rx 4096 tx 4096 # repeat for all bonded link members

ip link set eth2 txqueuelen 16000 # ditto + bond0 device (not sure if I
need these on the real devices or the bond device or both?)

sysctl -w net.ipv4.tcp_window_scaling=0 
sysctl -w net.ipv4.tcp_timestamps=0
sysctl -w net.ipv4.tcp_sack=0
sysctl -w net.ipv4.tcp_max_tw_buckets=8000000 
sysctl -w net.ipv4.tcp_rmem="40000000 40000000 40000000" 
sysctl -w net.ipv4.tcp_wmem="40000000 40000000 40000000" 
sysctl -w net.ipv4.tcp_mem="40000000 40000000 40000000" 
sysctl -w net.core.rmem_max=8192000
sysctl -w net.core.wmem_max=8192000
sysctl -w net.core.rmem_default=8192000 
sysctl -w net.core.wmem_default=8192000 
sysctl -w net.core.optmem_max=40000000 
sysctl -w net.core.netdev_max_backlog=8000000

NFS clients are running over TCP with window sizes of 8192, non jumbo
frames.

I've been through various numbers in a rather non scientific way and
these are the best to date... I'll admit that I'm not actually sure what
some of them do!

Any thoughts most welcome. I'm going to try the same test on a twin
dual-core opteron server that just came in (before it gets given its
rightful job) for comparision.

Many thanks

Tim

-- 
Tim Southerwood





-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
