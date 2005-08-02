From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: IA64 Server / IA32 Client problem
Date: Tue, 2 Aug 2005 07:36:17 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539E55@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dzxsd-0003SL-Ro
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 07:36:31 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Dzxsc-00081o-OY
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 07:36:31 -0700
To: "Brett Petrusek" <brettp@aspsys.com>
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

> I'm not sure if this is a bug or what, but I am experiencing severe=20
> performace problems between an IA64 NFS server and IA32 NFS client. I=20
> have tried every combination of socket buffer sizes as well as many=20
> other nfs options, but none of them seem to have any effect. I have=20
> tried RHEL21 to RHEL3U5 with all of these socket combos and still no=20
> difference. The command I am running is:
>=20
> time dd if=3D/dev/zero of=3D/scratch_dir_across_nfs bs=3D1M =
count=3D128
>=20
> Between two IA32 machines this takes 4-5 seconds. Between=20
> IA64 server and IA32 client this takes on the order of=20
> minutes. Network performance has been eliminated from the=20
> equation as after kernel tuning we have achieved consistent=20
> 94% of peak tcp throughput and 95.7% of peak udp throughput=20
> on our GigE network.  This is both between IA32 and IA64 systems.

can you tell us about the file system on the ia64 server.  block size,
fstype, etc?

what's the page size on that system?

have you run local performance tests on the server?


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
