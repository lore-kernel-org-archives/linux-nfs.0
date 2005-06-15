From: "M. Todd Smith" <todd@sohovfx.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 16:33:05 -0400
Message-ID: <42B09081.50405@sohovfx.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net> <42AF3B6C.6070901@sohovfx.com> <20050614204138.GG1175@ti64.telemetry-investments.com> <42AF5F0A.3080601@sohovfx.com> <20050615174701.GC31465@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DieZZ-00014a-Ls
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 13:33:17 -0700
Received: from smtp1.beanfield.com ([66.207.192.6] helo=smtp1.beanfield.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DieZU-0005oB-U6
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 13:33:17 -0700
Received: from [192.168.1.26] ([66.207.206.227])
	by smtp1.beanfield.net (8.13.4/8.12.11) with ESMTP id j5FKWuHN032771
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 16:32:57 -0400 (EDT)
	(envelope-from todd@sohovfx.com)
To: nfs@lists.sourceforge.net
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

Bill Rugolsky Jr. wrote:

>	MiB = 2^20 Bytes
> 	MB  = 10^6 bytes
>
>  
>
Thanks for clearing that up .. nowhere near that speed.

>Small file and large file tests are by nature quite different, as are
>cached and uncached reads and writes.
>
>For a large file test, I'd use several times the RAM in your machine
>(say 16-20GB).  For small file tests, 100-200MB.  To separate out the
>effects of your SAN performance from knfsd performance, you may want to do
>the small file test by exporting a (ext2) filesystem from a ramdisk, or
>a loopback file mount in /dev/shm.  [Unfortunately, the tmpfs filesystem
>doesn't implement the required methods directly, as it would be handy for
>testing.]
>
>For uncached reads/writes, consider using the new upstream coreutils:
>
>ftp://alpha.gnu.org/gnu/coreutils/coreutils-5.3.0.tar.bz2
>
>  dd has new iflag= and oflag= options with the following flags:
>
>    append    append mode (makes sense for output file only)
>    direct    use direct I/O for data
>    dsync     use synchronized I/O for data
>    sync      likewise, but also for metadata
>    nonblock  use non-blocking I/O
>    nofollow  do not follow symlinks
>    noctty    do not assign controlling terminal from file 
>
>[N.B.: NFS Direct-I/O requests > 16M may Oops on kernels prior to 2.6.11.]
>
>  
>
I'll try out the new core-utils when I can (*hoping next week I can get 
this server out of production*).   I'm  sorry what would writing to a 
virtual FS tell me in regards to my SAN, perhaps you can explain in more 
detail?

>>ttcp-r: 16777216 bytes in 0.141 real seconds = 115970.752 KB/sec +++
>>    
>>
>
>UDP result looks OK.  How about TCP?  What about packet reordering on
>your bonded 4 port NIC?
>
>  
>
>>exec,dev,suid,rw,rsize=32768,wsize=32768,timeo=500,retrans=10,retry=60,bg 
>>    
>>
>
>UDP?
>
>I wouldn't use UDP with such a large rsize/wsize -- that's two dozen
>fragments on a 1500 MTU network!  You also have, due to the bonding,
>an effectively mixed-speed network *and* packet reordering.
>
>Have you looked at your interface statistics?  Does everything look
>fine?
>  
>
I'm very apt to agree with you, I see no reason to continue to use UDP 
for NFS traffic and have read that the UDP fragment handling in Linux 
was sub-par.  Here are some netstat -s stats from the server:

Ip:
    446801331 total packets received
    0 forwarded
    0 incoming packets discarded
    314401713 incoming packets delivered
    256822806 requests sent out
    5800 fragments dropped after timeout
    143422528 reassemblies required
    11022911 packets reassembled ok
    246950 packet reassembles failed
    48736566 fragments received ok
Icmp:
    25726 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        timeout in transit: 25709
        echo requests: 14
        echo replies: 3
    5259 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 2189
        time exceeded: 3056
        echo replies: 14
Tcp:
    34 active connections openings
    675 passive connection openings
    0 failed connection attempts
    2 connection resets received
    3 connections established
    139364522 segments received
    82043064 segments send out
    35697 segments retransmited
    0 bad segments received.
    232 resets sent
Udp:
    175434421 packets received
    2189 packets to unknown port received.
    0 packet receive errors
    549511042 packets sent
TcpExt:
    ArpFilter: 0
    294 TCP sockets finished time wait in fast timer
    165886 delayed acks sent
    310 delayed acks further delayed because of locked socket
    Quick ack mode was activated 84 times
    5347 packets directly queued to recvmsg prequeue.
    3556184 packets directly received from backlog
    7451568 packets directly received from prequeue
    115727204 packets header predicted
    7693 packets header predicted and directly queued to user
    TCPPureAcks: 7228029
    TCPHPAcks: 22682518
    TCPRenoRecovery: 37
    TCPSackRecovery: 7688
    TCPSACKReneging: 0
    TCPFACKReorder: 12
    TCPSACKReorder: 101
    TCPRenoReorder: 0
    TCPTSReorder: 949
    TCPFullUndo: 1209
    TCPPartialUndo: 6887
    TCPDSACKUndo: 2506
    TCPLossUndo: 237
    TCPLoss: 23727
    TCPLostRetransmit: 6
    TCPRenoFailures: 0
    TCPSackFailures: 291
    TCPLossFailures: 12
    TCPFastRetrans: 23567
    TCPForwardRetrans: 6191
    TCPSlowStartRetrans: 3769
    TCPTimeouts: 1505
    TCPRenoRecoveryFail: 0
    TCPSackRecoveryFail: 355
    TCPSchedulerFailed: 0
    TCPRcvCollapsed: 0
    TCPDSACKOldSent: 84
    TCPDSACKOfoSent: 0
    TCPDSACKRecv: 7454
    TCPDSACKOfoRecv: 1
    TCPAbortOnSyn: 0
    TCPAbortOnData: 0
    TCPAbortOnClose: 1
    TCPAbortOnMemory: 0
    TCPAbortOnTimeout: 0
    TCPAbortOnLinger: 0
    TCPAbortFailed: 0
    TCPMemoryPressures: 0

Regarding the bonding .. Writes to the SAN happen on a single port of 
the NIC so in writing there are very few reorderings needed.  Reading 
from the SAN breaks the read up on the four ports and so the most 
reordering would be done client side (even worse most of our clients are 
still RH 7.2).  If I mix TCP and UDP NFS connections will speed be 
slower than if I used just straight TCP conns?  I'll do some testing 
next week and report my findings.

>These days, I'd use TCP.  The Linux NFS TCP client is very mature,
>and the NFS TCP server is working fine for me.  Linux NFS UDP fragment
>handling / retry logic has long been a source of problems, particularly
>across mixed-speed networks (e.g., 100/1000). TCP adapts automatically.
>While TCP requires slightly more processing overhead, this should not be
>an issue on modern CPUs.  Additionally, modern NICs like e1000 support
>TSO (TCP Segmentation Offload), and though TSO has had its share of bugs,
>it is the better path forward.
>
>IMHO, packet reordering at the TCP layer is something that has received
>attention in the Linux kernel, and there are ways to measure it and
>compensate for it (via /proc/sys/net/ipv4/* tunables).  I'd much rather
>try and understand the issue there than at either the IP fragment layer
>or the kernel RPC layer.
>
>  
>
This as my first recommendation when I began here .. Is TSO stable 
enough for production level usage now?  Suse still turns it off by default.

I'm still looking into the other things you mentioned .. thanks again 
for your help.

Cheers
Todd

-- 
Systems Administrator
----------------------------------
Soho VFX - Visual Effects Studio
99 Atlantic Avenue, Suite 303
Toronto, Ontario, M6K 3J8
(416) 516-7863 
http://www.sohovfx.com
----------------------------------


 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
