From: Poul Petersen <petersp@roguewave.com>
Subject: NFSD seems to stall
Date: Thu, 27 Jun 2002 13:01:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F888C30C3021D411B9DA00B0D0209BE8038F959D@cvo-exchange.cvo.roguewave.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cvo-ext.roguewave.com ([12.22.36.198] helo=cvo-exchange.cvo.roguewave.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NfWH-0002PQ-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 13:05:33 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

	Our primary NFS server handles several file-systems that are used
24-hours a day to build software. We have been seeing a problem wherein no
less than once a night different hosts fail their builds with strange errors
- usually some header file is reported missing (the compilers are all
installed in NFS). On advice of a previous post here and the NFS FAQ sec
5.4, we increased the rec-q for nfsd to 1MB. I then began monitoring the
"rec-q" (netstat -anu), as well as /proc/net/rpc/nfsd, system load (sar -q)
and the ethernet traffic (sar -n DEV) in 5-second increments. Last night, as
usual the network was moving a fairly consistent 4MB/sec and the system load
was at about 2, when the rec-q suddenly shot up to the max (1048572). The Rx
network fell to about 100KB/s and /proc/net/rpc/nfsd showed no activity.
System load began falling. This state continued for about 40 seconds at
which point the rec-q dropped abruptly to zero and /proc/net/rpc/nfsd showed
an unreasonable amount of activity for a five second interval (far left
column is seconds since epoch):

1025147631:th 8 110295 4567.090 367.210 101.080 0.000 88.970 33.010 23.320
12.600 0.000 150.380
1025147636:th 8 110662 4568.240 367.410 101.080 0.000 88.970 33.010 23.320
12.600 0.000 194.300

	Since those data points are 5 seconds apart, the 10-th column would
indicate that during the 5-second interval, all 8-nfsd were busy for 44
seconds - clearly /proc/net/rpc/nfsd was not being updated during the prior
40 second interval.

	About 10-seconds later, the Rx traffic spiked up to 20-30MB/s and
system load shot up to 4 for 15 seconds and then settled back to 4MB/sec and
a load of 2. There were some smaller spikes in the rec-q (400k) and
/proc/net/rpc/nfsd data during this 15 seconds. 

	And indeed we lost some builds during this time period - one in
particular gave the error:

Error 5: "/package/1/compilers/hp/aCC333/opt/aCC/include_std/rw/rwlocale",
line 745 # Unable to open file
/package/1/compilers/hp/aCC333/opt/aCC/include_std/rw/vendor; Connection
timed out (238).

	The server did not report any errors during this time period
(nothing in /var/log/messages or dmesg). Based on this information, it would
seem that for some reason, the nfs daemons stopped responding. I'm presuming
that the Rx traffic subsided because the clients were waiting for some kind
of NFS ACK (The server is primarily an NFS server, but it should be noted
that the network port was still active, just not NFS). After 40 seconds, the
nfs daemons came back processed the queue and then everything went back to
normal, except that some of our builds failed due to the temporary
unresponsiveness. What would cause this? Are there other things I could
monitor to help isolate the problem?

	I suppose some hardware specifics would help : The NFS server is a
Dell 2550, Dual PIII-933, running RedHat 7.2 with kernel 2.4.18 and LVM
1.0.4. The network card is an Intel PRO/1000 (GigE Fiber) running the Intel
version 4.0.7 e1000 driver. There is also a Qlogic qla2200 card running the
Qlogic 6.0b20 driver which is connected to a Zzyzx RocketStor 2000 RAID
device with 2.2TB of disk space. That space is served up using LVM 1.0.4 and
ext3, though we saw the problem back in our XFS days as well. We are running
nfs-utils-0.3.3-1. Other than the LVM 1.0.4 patch and a pvmove patch, the
2.4.18 kernel is stock. 

	Ah, one other thing - the network card reports error in
/proc/net/PRO_LAN_Adapters and the only non-zero registers are:

Rx_Errors 547
Rx_FIFO_Errors 547
Rx_Missed_Errors 547

	I also noticed this description in the Intel driver documentation:

RxIntDelay
Valid Range: 0-65535 (0=off)
Default Value: 64
    This value delays the generation of receive interrupts in units of 1.024
    microseconds.  Receive interrupt reduction can improve CPU efficiency
    if properly tuned for specific network traffic. Increasing this value
    adds extra latency to frame reception and can end up decreasing the
    throughput of TCP traffic.  If the system is reporting dropped receives,
    this value may be set too high, causing the driver to run out of
    available receive descriptors.

	Now this would seem more suspicious, but we are not running NFS over
TCP, and this would seem to apply to "TCP traffic". Also, if this was the
case, why would nfsd stall but the rec-q be full? I suppose part of my
confusion stems from not really understanding what the rec-q is and who
manages it (who fills it, and how is the program connected to the socket
notified that data is ready?)

Many thanks for any insight,

-poul


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
