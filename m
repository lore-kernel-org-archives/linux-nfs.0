From: Didier CONTIS <didier@ece.gatech.edu>
Subject: Pb of optimization for a Cluster under Gigabit
Date: Tue, 06 Apr 2004 23:22:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40737404.7000401@ece.gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BB3fC-00027M-Av
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 20:23:42 -0700
Received: from mail.ee.gatech.edu ([130.207.225.105])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BB3fA-00028u-74
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 20:23:40 -0700
Received: from localhost (k4.ece.gatech.edu [130.207.226.168])
	by mail.ee.gatech.edu (8.12.10/8.12.10) with ESMTP id i373NcZo004654
	for <nfs@lists.sourceforge.net>; Tue, 6 Apr 2004 23:23:38 -0400 (EDT)
Received: from mail.ee.gatech.edu ([130.207.225.105])
 by localhost (k4.ece.gatech.edu [130.207.226.168]) (amavisd-new, port 10024)
 with LMTP id 05017-05 for <nfs@lists.sourceforge.net>;
 Tue,  6 Apr 2004 23:23:34 -0400 (EDT)
Received: from ece.gatech.edu (adsl-19-109-196.asm.bellsouth.net [68.19.109.196])
	(authenticated bits=0)
	by mail.ee.gatech.edu (8.12.10/8.12.10) with ESMTP id i373MqLQ004630
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Tue, 6 Apr 2004 23:22:53 -0400 (EDT)
To: nfs@lists.sourceforge.net
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



We have a cluster with ~60 Dell PowerEdge 1750 (dual cpu)
running Redhat 9.0 (fully patched) connected via Gigabit
to a stack of Catalyst 3750.

The cluster has a dedicated NFS server also connected
via Gigabit:

Dell PowerEdge 2650 running AS 2.1 fully patched.
The unit has a Raid 1 array for the OS and is connected
via a dual Fiber Channel to a EMC Clarion SAN. We are
running Powerpath. The server has also 1GB of memory.

Its load is always 2 or higher an we have some flacky
performance when copying files from one NFS partitions
to another from the client:

All the filesystem are exported with sync and mounted
on the client (via autofs) with:
rw,sync,hard,intr,rsize=8192,wsize=8192

The time for copying a 40MB file from a NFS partition to local
client filesystem is good.

[didier@xfront2 ~]$ time cp jeffay.txt /tmp
0.010u 0.190s 0:05.19 3.8%      0+0k 0+0io 115pf+0w

For copying same file from one NFS partition to another
via the same client it takes more than a couple of minutes.

We are running 96 nfsd on the file server with the Queue tune-up hack.

The under /proc/net/rpc/nfsd
[...]
th 96 0 171.110 29.200 5.100 0.000 0.000 0.000 0.000 0.000 0.000 0.000

looks good.

It seems the file server is spending too much time doing ip frag work:
uptime -> 18hours

[didier@xnfs1 ~]$ cat /proc/net/snmp
Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors
ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests
OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails
FragOKs FragFails FragCreates
Ip: 2 64 34249037 0 0 0 0 217 23273862 31176320 24384 0 0 16472823
5502518 0 0 0 10378060
[...]
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens
AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 0 0 0 0 2532 0 0 0 1 54706 76945 15 0 12
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 23221263 75 217 23165842

Would anyone have any suggestions or recommendations ? Should
I switch rsize / wsize to 1024 ?

Thanks - Didier




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
