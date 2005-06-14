From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 13:40:46 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539C8A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIDN-0006U9-Lw
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:40:53 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIDM-00071s-5b
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:40:53 -0700
To: "M. Todd Smith" <todd@sohovfx.com>
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

have you run any network tests, like iperf or ttcp, to determine if you
are getting adequate network throughput?

what are the export options you're using on the server?

> -----Original Message-----
> From: M. Todd Smith [mailto:todd@sohovfx.com]=20
> Sent: Tuesday, June 14, 2005 4:38 PM
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS tuning - high performance throughput.
>=20
>=20
> Charles,
>=20
> I've tried mounting both TCP and UDP and with rwsizes varying=20
> from 8k to=20
> 32k, 32k rwsizes are giving us the best performance thus far.
>=20
> Indeed I did skip a level with the ping times didn't I, 200=20
> microseconds=20
> it is.
>=20
> Cheers
> Todd
>=20
>=20
> Lever, Charles wrote:
>=20
> >first place i would look is mount options on the client.  are you
> >mounting with NFS over TCP, or NFS over UDP?
> >
> >(btw, your ping time should be 200 microseconds, not 200=20
> nanoseconds).
> >
> > =20
> >
> >>-----Original Message-----
> >>From: M. Todd Smith [mailto:todd@sohovfx.com]=20
> >>Sent: Tuesday, June 14, 2005 4:18 PM
> >>To: nfs@lists.sourceforge.net
> >>Subject: [NFS] NFS tuning - high performance throughput.
> >>
> >>
> >>Hello all,
> >>
> >>I've been attempting to get a better hold over our NFS=20
> performance as=20
> >>our network grows and grows.
> >>
> >>We've recently upgraded our NFS server machine to a dual=20
> 3.2ghz Xeon=20
> >>running Fedora Core 3 (kernel 2.6.11-1.14_FC3smp) w/ 4Gb RAM.=20
> >> Coupled=20
> >>with this machine we have a 2 Broadcom NetExtreme 2 Port=20
> PCI-X NIC on=20
> >>its own PCI-X bus (133Mhz).  Attached to this machine is our fibre=20
> >>channel SAN, using Seagate fibre-channel drives and an LSI=20
> >>dual channel=20
> >>2gigabit fibre adapter on its own PCI-X bus.  Local RW is=20
> >>~135Mbytes/sec.
> >>=20
> >>The 4 ports are trunked together using bonding (balanced=20
> round robin=20
> >>mode), and trunked together on our Extreme Networks Summit=20
> >>400i switch. =20
> >>All the test machines are attached to this switch, making=20
> everything=20
> >>within one hop and ping times of less than a 200 nanoseconds.
> >>
> >>Current test machine is running Suse 9.2 and has an Intel=20
> 100/1000 XT=20
> >>server adapter (e1000 driver) on a shared but not high=20
> >>traffic PCI bus. =20
> >>Other test machines include some Dell PowerEdge 1850's with onboard=20
> >>Intel NICs, and some Apple G4, G5 and Xserves.
> >>
> >>I have read most of the tuning guides I can find on the net and=20
> >>attempted just about everything I can get my hands on (I have=20
> >>not tried=20
> >>jumbo frames yet, still waiting for some downtime to attempt=20
> >>that).  My=20
> >>problem is that no matter how I tune the machines I can get at max=20
> >>45Mb/ps throughput on NFS.  This was the same throughput we=20
> >>were getting=20
> >>with our old server with PCI cards, moreover this throughput=20
> >>is roughly=20
> >>the same for every machine on our network.  Theoretically we=20
> >>should be=20
> >>able to get much higher values.
> >>
> >>Any idea as to why this is?  I can provide config files and such if=20
> >>needed, but I'm really at a loss as to where to start.
> >>
> >>Cheers
> >>Todd
> >>
> >>--=20
> >>Systems Administrator
> >>----------------------------------
> >>Soho VFX - Visual Effects Studio
> >>99 Atlantic Avenue, Suite 303
> >>Toronto, Ontario, M6K 3J8
> >>(416) 516-7863=20
> >>http://www.sohovfx.com
> >>----------------------------------
> >>
> >>
> >>=20
> >>
> >>
> >>
> >>-------------------------------------------------------
> >>SF.Net email is sponsored by: Discover Easy Linux Migration=20
> Strategies
> >>from IBM. Find simple to follow Roadmaps, straightforward articles,
> >>informative Webcasts and more! Get everything you need to get up to
> >>speed, fast. =
http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclick
> >>_______________________________________________
> >>NFS maillist  -  NFS@lists.sourceforge.net
> >>https://lists.sourceforge.net/lists/listinfo/nfs
> >>
> >>   =20
> >>
> >
> >
> > =20
> >
>=20
>=20
> --=20
> Systems Administrator
> ----------------------------------
> Soho VFX - Visual Effects Studio
> 99 Atlantic Avenue, Suite 303
> Toronto, Ontario, M6K 3J8
> (416) 516-7863=20
> http://www.sohovfx.com
> ----------------------------------
>=20
>=20
> =20
>=20
>=20
>=20
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> from IBM. Find simple to follow Roadmaps, straightforward articles,
> informative Webcasts and more! Get everything you need to get up to
> speed, fast. =
http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
