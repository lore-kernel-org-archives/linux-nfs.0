From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Pb of optimization for a Cluster under Gigabit
Date: Tue, 6 Apr 2004 21:39:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07C06@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BB4rI-0007TP-TD
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 21:40:16 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BB4rI-0004N8-Jh
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 21:40:16 -0700
To: "Didier CONTIS" <didier@ece.gatech.edu>
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

hi didier-

do you really need to use the "sync" mount option on
the clients?  the "sync" export option on the server
should be enough for most applications.

IP fragmentation is normal for any UDP-based protocol,
and your stats don't show any reassembly failures or
timeouts.  btw you can get this information in slightly
friendlier form with "netstat -s".

> -----Original Message-----
> From: Didier CONTIS [mailto:didier@ece.gatech.edu]=20
> Sent: Tuesday, April 06, 2004 11:23 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Pb of optimization for a Cluster under Gigabit
>=20
>=20
>=20
>=20
> We have a cluster with ~60 Dell PowerEdge 1750 (dual cpu)
> running Redhat 9.0 (fully patched) connected via Gigabit
> to a stack of Catalyst 3750.
>=20
> The cluster has a dedicated NFS server also connected
> via Gigabit:
>=20
> Dell PowerEdge 2650 running AS 2.1 fully patched.
> The unit has a Raid 1 array for the OS and is connected
> via a dual Fiber Channel to a EMC Clarion SAN. We are
> running Powerpath. The server has also 1GB of memory.
>=20
> Its load is always 2 or higher an we have some flacky
> performance when copying files from one NFS partitions
> to another from the client:
>=20
> All the filesystem are exported with sync and mounted
> on the client (via autofs) with:
> rw,sync,hard,intr,rsize=3D8192,wsize=3D8192
>=20
> The time for copying a 40MB file from a NFS partition to local
> client filesystem is good.
>=20
> [didier@xfront2 ~]$ time cp jeffay.txt /tmp
> 0.010u 0.190s 0:05.19 3.8%      0+0k 0+0io 115pf+0w
>=20
> For copying same file from one NFS partition to another
> via the same client it takes more than a couple of minutes.
>=20
> We are running 96 nfsd on the file server with the Queue tune-up hack.
>=20
> The under /proc/net/rpc/nfsd
> [...]
> th 96 0 171.110 29.200 5.100 0.000 0.000 0.000 0.000 0.000 0.000 0.000
>=20
> looks good.
>=20
> It seems the file server is spending too much time doing ip frag work:
> uptime -> 18hours
>=20
> [didier@xnfs1 ~]$ cat /proc/net/snmp
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors
> ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests
> OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails
> FragOKs FragFails FragCreates
> Ip: 2 64 34249037 0 0 0 0 217 23273862 31176320 24384 0 0 16472823
> 5502518 0 0 0 10378060
> [...]
> Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens
> AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs=20
> InErrs OutRsts
> Tcp: 0 0 0 0 2532 0 0 0 1 54706 76945 15 0 12
> Udp: InDatagrams NoPorts InErrors OutDatagrams
> Udp: 23221263 75 217 23165842
>=20
> Would anyone have any suggestions or recommendations ? Should
> I switch rsize / wsize to 1024 ?
>=20
> Thanks - Didier
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> =
administration.http://ads.osdn.com/?ad_id=3D1470&alloc_id=3D3638&op=3Dcli=
ck
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
