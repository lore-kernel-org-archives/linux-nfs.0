From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: slow file opens on nfs mount across high-latency network
Date: Wed, 6 Jul 2005 12:21:53 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539D61@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqFT5-0005g2-M2
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 12:21:59 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DqFT5-0001tJ-E5
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 12:21:59 -0700
To: "Anthony Howe" <ahowe_ca@yahoo.ca>
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

> I have found a solution (work around) to the latency problem that I
> described in the above posting.  The solution seems to be to=20
> add more mounts
> to the same nfs share and spread the threads evenly among the=20
> mounts. =20
>=20
> This solution is highlighted by the graph:
> http://ahowe_ca.tripod.com/nfsperformance2.pdf.  The graph shows the
> performance of 40 threads each performing file opens across=20
> an nfs share.
> Each thread repeats 10 times opening a file for write and=20
> closing it 10
> times.  The x-axis is various roundtrip network latencies. =20
> The y-axis is
> the mean time to open a file across the nfs mount.  Each line=20
> represents a
> different number of mount points.  The top line is one mount=20
> point, and 40
> threads concurrently calling file opens on this mount.  The=20
> bottom line
> represents 40 mounts to the same share, each thread with its=20
> own line.  From
> this graph I can come to the following conclusions:
>=20
> 1. Evenly distributing file access threads across many NFS=20
> mounts to the
> same share reduces the effects of latency.
>=20
> 2. There seems to be resource limit per mount point.  The=20
> higher the network
> latency the faster this limit is reached.  This explains the=20
> hockey stick
> effect shown in graph: http://ahowe_ca.tripod.com/nfsperformance.pdf.
>=20
> 3. This resource limit is not related to the hard limit of=20
> 256 read or write
> operations per mount point since we are only using 40 threads.
>=20
> 4. Removing all network latency eliminates this resource=20
> problem and 1 mount
> or 40 mounts display the same performance.
>=20
> Does anyone know what would be causing this resource limit?=20
> And is there any
> way to improve it so that I don't have to add more mounts to=20
> reduce the
> effects of latency?

you may be encountering the limit of 16 concurrent RPC requests per
mount point.

in 2.6 this is tunable:  echo 64 >
/proc/sys/sunrpc/{udp,tcp}_slot_table_entries

then remount.

in 2.4, you'll have to rebuild the kernel after changing RPC_MAXCONG to
a larger number (like 64) in include/linux/sunrpc/xprt.h.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
